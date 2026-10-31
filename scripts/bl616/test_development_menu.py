import hashlib
import json
import struct
import tempfile
import unittest
from unittest.mock import patch
import zlib
from pathlib import Path
import development_menu as dev
import updater as u

RELEASE = Path(__file__).resolve().parents[2] / 'src-tauri/resources/nanoblast-v0.2.0'

class Tests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)
        image = bytearray((RELEASE / 'nanoblast-firmware.bin').read_bytes())
        image[-1] ^= 1  # Valid, distinct test image; never used on hardware.
        image[136:168] = hashlib.sha256(image[4096:]).digest()
        struct.pack_into('<I', image, 252, zlib.crc32(image[:252]))
        (self.folder / 'nanoblast-usb-menu.bin').write_bytes(image)
        self.manifest = self.folder / 'development-menu.json'
        self.manifest.write_text(json.dumps(dict(file='nanoblast-usb-menu.bin', base='v0.2.0', bytes=len(image), sha256=u.sha(image))))
        before = bytearray(b'\xa5' * u.SIZE)
        for address, blob in u.writes(RELEASE):
            before[address:address + len(blob)] = blob
        self.before = bytes(before)

    def test_install_restore_preserves_all_other_bytes(self):
        changes, plan = dev.load(self.manifest, RELEASE)
        after = plan(self.before, changes)
        self.assertNotEqual(after, self.before)
        self.assertEqual(after[:0x40000], self.before[:0x40000])
        self.assertEqual(after[0xE8000:], self.before[0xE8000:])
        self.assertEqual(plan(after, changes), after)
        changes, plan = dev.load(self.manifest, RELEASE, restore=True)
        self.assertEqual(plan(after, changes), self.before)

    def test_unknown_menu_or_core_refused(self):
        changes, plan = dev.load(self.manifest, RELEASE)
        for offset in (0x40000, 0x201000, 0x100000):
            before = bytearray(self.before)
            before[offset] ^= 1
            with self.assertRaises(ValueError):
                plan(bytes(before), changes)

    def test_corrupt_image_refused(self):
        (self.folder / 'nanoblast-usb-menu.bin').write_bytes(b'bad')
        with self.assertRaises(ValueError):
            dev.load(self.manifest, RELEASE)

    def test_extra_write_refused(self):
        changes, plan = dev.load(self.manifest, RELEASE)
        with self.assertRaises(ValueError):
            plan(self.before, changes + [(0, b'bad')])

    def test_audited_previous_development_menu(self):
        changes, plan = dev.load(self.manifest, RELEASE)
        previous = plan(self.before, changes)
        image = (self.folder / 'nanoblast-usb-menu.bin').read_bytes()
        old_digest = u.sha(image)
        updated = bytearray(image)
        updated[-1] ^= 2
        updated[136:168] = hashlib.sha256(updated[4096:]).digest()
        struct.pack_into('<I', updated, 252, zlib.crc32(updated[:252]))
        (self.folder / 'nanoblast-usb-menu.bin').write_bytes(updated)
        self.manifest.write_text(json.dumps(dict(file='nanoblast-usb-menu.bin', base='v0.2.0', bytes=len(updated), sha256=u.sha(updated))))
        changes, plan = dev.load(self.manifest, RELEASE)
        with self.assertRaises(ValueError):
            plan(previous, changes)
        with patch.object(dev, 'PREVIOUS_MENU_HASHES', {old_digest}):
            after = plan(previous, changes)
            self.assertEqual(after[0x40000:0x40000+len(updated)], updated)
            self.assertEqual(after[:0x40000], previous[:0x40000])
            self.assertEqual(after[0xE8000:], previous[0xE8000:])
            corrupt = bytearray(previous)
            corrupt[0xE8000-1] = 0
            with self.assertRaises(ValueError):
                plan(bytes(corrupt), changes)
