"""Explicitly selected development menu; exact known baseline and menu-only writes."""
import json
import struct
from pathlib import Path
import updater as u

# Audited first USB menu flashed and read back on 27 October 2026.
PREVIOUS_MENU_HASHES = {'168182bf2c651e6e20e3cd77331b101bf8e9585374a992d93e93e64048a58122', '07ca4d9d762c7a5023163c261af32dd40ecb65523c6dba96ad0c41883d61ba9b', '6f14fcabddecc3a7819be095b0a036fbdf4be965cb5c8607eb5c436db711a73c', 'e5ddc56e18cdc7c79ea30868b0b30c8d5a8f6618401c166064ae01876144d68f', '469125dfa60175016168eb56762157c97b795cd378e9d42613dfd6ca8de3ab61', '69b2c1d1a86eca34e3aaa7054590bf258f7cc44d0d086e9bf70c3c42a1ad1893', 'bf1e06d1dbc8eebf846f2d3b1916816d170366c009c86b7572ee0d852604aa84'}

def load(manifest, release, restore=False):
    manifest=Path(manifest);m=json.loads(manifest.read_text())
    u.require(m.get('file')=='nanoblast-usb-menu.bin' and m.get('base')=='v0.2.0','Unsupported development manifest')
    image=(manifest.parent/m['file']).resolve()
    u.require(image.parent==manifest.parent.resolve(),'Development image escapes its directory')
    data=image.read_bytes()
    u.require(m['sha256']==u.sha(data) and m['bytes']==len(data),'Development image checksum mismatch');u.firmware(data)
    canonical=u.writes(Path(release));original=canonical[-1][1]
    updated=data+b'\xff'*(len(original)-len(data));target=original if restore else updated
    changes=[(0x40000,target)]
    def plan(before, changes):
        u.require(len(before)==u.SIZE,'Full backup required')
        current=before[0x40000:0xE8000]
        known=current in (original,updated)
        if not known:
            length=4096+struct.unpack_from('<I',current,132)[0]
            if 4096<=length<=len(current):
                previous=current[:length]
                if u.sha(previous) in PREVIOUS_MENU_HASHES:
                    u.firmware(previous)
                    known=current[length:]==b'\xff'*(len(current)-length)
        u.require(known,'Unknown menu baseline; no writes')
        u.require(all(before[start:start+len(blob)]==blob for start,blob in canonical[:-1]),'Unknown core bank; no writes')
        u.require(changes==[(0x40000,target)],'Only the menu may change')
        after=before[:0x40000]+target+before[0xE8000:]
        u.require(after[:0x40000]==before[:0x40000] and after[0xE8000:]==before[0xE8000:],'Non-menu region changed')
        return after
    return changes,plan
