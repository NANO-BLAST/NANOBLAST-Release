"""Real release files, future versions and bounded, device-free selection."""
import copy, hashlib, json, shutil, stat, struct, tempfile, unittest, zipfile, zlib
from pathlib import Path
import current_bundle as bundle
import release_files
import updater as u
ROOT=Path(__file__).resolve().parents[2]
RELEASE=ROOT/'src-tauri/resources/nanoblast-v0.2.0'

def baseline():
    data=bytearray(b'\xff'*u.SIZE)
    for start,block in u.writes(RELEASE):data[start:start+len(block)]=block
    data[0:8]=b'PRIMARY!';data[0x1df000:0x1df008]=b'RESERVED';data[0x3ff000:0x3ff008]=b'JOURNAL!'
    return bytes(data)

def future(root,version,change):
    shutil.copytree(RELEASE,root)
    p=root/'manifest.json';m=json.loads(p.read_text());m['version']=version
    fw=bytearray((root/'nanoblast-firmware.bin').read_bytes());fw[-1]^=change
    fw[136:168]=hashlib.sha256(fw[4096:]).digest();struct.pack_into('<I',fw,252,zlib.crc32(fw[:252]));u.firmware(fw)
    (root/'nanoblast-firmware.bin').write_bytes(fw);m['firmware']['sha256']=u.sha(fw);p.write_text(json.dumps(m))

class ReleaseFiles(unittest.TestCase):
    def setUp(self):self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
    def tearDown(self):self.tmp.cleanup()
    def test_official_github_zip(self):
        selected=release_files.select(ROOT/'src-tauri/tests/fixtures/nanoblast-v0.2.0-firmware.zip',self.root/'cache',RELEASE)
        self.assertEqual(selected['version'],'v0.2.0');self.assertEqual(selected['cores'],4)
        self.assertTrue((Path(selected['path'])/'manifest.json').is_file())
    def test_folder_and_manifest_are_copied_privately(self):
        for i,source in enumerate([RELEASE,RELEASE/'manifest.json']):
            selected=release_files.select(source,self.root/str(i),RELEASE)
            self.assertNotEqual(Path(selected['path']),RELEASE)
            self.assertEqual(bundle.load(selected['path'],RELEASE)[0][0][1][:8],b'NBCRXZ01')
    def test_future_version_and_changed_menu_hash_need_no_code_update(self):
        future(self.root/'v9','v9.4.2',1)
        value=release_files.select(self.root/'v9',self.root/'cache',RELEASE)
        self.assertEqual(value['version'],'v9.4.2');self.assertNotEqual(value['sha256'],u.FW_HASH)
        changes,plan=bundle.load(value['path'],RELEASE);before=baseline();after=plan(before,changes)
        for start,end in [(0,0x40000),(0xe8000,0x201000),(0x3ff000,u.SIZE)]:self.assertEqual(before[start:end],after[start:end])
    def test_verified_install_receipts_enable_later_future_updates(self):
        future(self.root/'v9','v9.4.2',1);future(self.root/'v10','v10.0.0',2)
        first,plan=bundle.load(self.root/'v9',RELEASE);installed=plan(baseline(),first)
        next_changes,next_plan=bundle.load(self.root/'v10',RELEASE)
        with self.assertRaises(ValueError):next_plan(installed,next_changes)
        receipt=self.root/'verified.json';bundle.remember(receipt,first)
        next_changes,next_plan=bundle.load(self.root/'v10',RELEASE,receipt)
        self.assertEqual(next_plan(installed,next_changes)[0x40000:0x40000+668640],(self.root/'v10/nanoblast-firmware.bin').read_bytes())
    def test_selected_source_changes_do_not_change_private_cache(self):
        source=self.root/'source';shutil.copytree(RELEASE,source)
        selected=release_files.select(source,self.root/'cache',RELEASE)
        (source/'nanoblast-firmware.bin').write_bytes(b'changed')
        bundle.load(selected['path'],RELEASE)
    def test_mixed_layout_or_corrupt_files_fail(self):
        for label in ['format','core','table']:
            source=self.root/label;shutil.copytree(RELEASE,source)
            m=json.loads((source/'manifest.json').read_text())
            if label=='format':m['core_format']='unknown'
            elif label=='core':(source/m['assets'][0]['file']).write_bytes(b'bad')
            else:m['assets'][-1]['offset']+=4096
            (source/'manifest.json').write_text(json.dumps(m))
            with self.assertRaises(ValueError):release_files.select(source,self.root/(label+'cache'),RELEASE)
    def test_unsafe_zip_paths_and_symlinks_refused(self):
        for name,symlink in [('../escape.bin',False),('C:/escape.bin',False),('CON.bin',False),('folder/file. ',False),('link.bin',True)]:
            p=self.root/('link.zip' if symlink else str(len(name))+'.zip')
            with zipfile.ZipFile(p,'w') as z:
                info=zipfile.ZipInfo(name)
                if symlink:info.create_system=3;info.external_attr=(stat.S_IFLNK|0o777)<<16
                z.writestr(info,b'bad')
            with self.assertRaises(ValueError):release_files.select(p,self.root/('cache'+str(len(name))+str(symlink)),RELEASE)
        self.assertFalse((self.root/'escape.bin').exists())
    def test_ambiguous_archives_require_explicit_manifest(self):
        source=self.root/'source';shutil.copytree(RELEASE,source/'one');shutil.copytree(RELEASE,source/'two')
        with self.assertRaises(ValueError):release_files.select(source,self.root/'cache',RELEASE)
    def test_no_unchecked_individual_binary_selection(self):
        with self.assertRaises(ValueError):release_files.select(RELEASE/'nanoblast-firmware.bin',self.root/'cache',RELEASE)

if __name__=='__main__':unittest.main()
