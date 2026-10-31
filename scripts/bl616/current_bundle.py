"""User-selected NanoBlast releases for the supported BL616/NBCRXZ01 layout."""
import json, struct, zlib, lzma, re, os, uuid
from pathlib import Path
import updater as u
import development_menu

# Exact, hardware-read-back USB/ZIP release installed before external releases.
KNOWN_PAIRS = [{"menu_sha256": "a77bb320a7f59752d433694bc9eae65f45c2c103189db30795f4d7c3aa3291a6", "bank_sha256": "b9883d0e11f0ecdc91ff00f3abac868e2ff104f3cc008631465685112c3055e1"}]

def read_json(path):
    u.require(path.stat().st_size <= 65536, 'Release metadata is too large')
    return json.loads(path.read_text())

def inside(folder, name):
    u.require(isinstance(name,str) and name and not any(x in name for x in ('\\', ':', '\0')), 'Invalid release file path')
    reserved={'CON','PRN','AUX','NUL'}|{f'{p}{i}' for p in ('COM','LPT') for i in range(1,10)}
    u.require(all(not part.endswith(('.', ' ')) and all(ord(c)>=32 and c not in '<>"|?*' for c in part) and part.split('.')[0].upper() not in reserved for part in name.split('/')), 'Invalid cross-platform release path')
    relative=Path(name)
    u.require(not relative.is_absolute() and all(p not in ('','.','..') for p in name.split('/')), 'Release path escapes its folder')
    path=folder
    for part in relative.parts:
        path=path/part
        u.require(not path.is_symlink(), 'Symlinks are not supported in releases')
    u.require(path.resolve().is_relative_to(folder.resolve()), 'Release path escapes its folder')
    return path

def describe(folder, manifest=None):
    manifest=manifest or (folder/'manifest.json' if (folder/'manifest.json').exists() else folder/'development-menu.json')
    m=read_json(manifest)
    version=m.get('version')
    u.require(isinstance(version,str) and 0<len(version)<=100, 'Missing release version')
    if 'firmware' in m and 'assets' in m:
        u.require(m.get('core_format')=='NBCRXZ01', 'Unsupported release layout: expected NBCRXZ01 cores')
        menu=dict(m['firmware']);menu.setdefault('file','nanoblast-firmware.bin')
        assets=m['assets']
    else:
        u.require(m.get('base')=='solid-loading-v0.2.0', 'Select a NanoBlast firmware release manifest, not an individual binary')
        menu=m;assets=read_json(folder/'core-manifest.json')['assets']
    u.require(isinstance(assets,list) and len(assets)==4, 'The release must contain all four console cores')
    return version,menu,assets

def receipts(path):
    if not path or not Path(path).exists(): return []
    records=read_json(Path(path))
    u.require(isinstance(records,list) and len(records)<=256,'Invalid installed-release history')
    for r in records:
        u.require(isinstance(r,dict) and all(isinstance(r.get(k),str) and re.fullmatch('[0-9a-f]{64}',r[k]) for k in ('menu_sha256','bank_sha256')), 'Invalid installed-release history')
    return records

def target_receipt(changes):
    targets=dict(changes);menu=targets[0x40000];length=4096+struct.unpack_from('<I',menu,132)[0]
    return dict(menu_sha256=u.sha(menu[:length]),bank_sha256=u.sha(targets[0x201000]))

def remember(path, changes):
    if not path: return
    path=Path(path);record=target_receipt(changes);items=[r for r in receipts(path) if r!=record][-255:]+[record]
    path.parent.mkdir(parents=True,exist_ok=True)
    temporary=path.with_name(path.name+'.'+uuid.uuid4().hex+'.tmp')
    u.durable(temporary,(json.dumps(items,indent=2)+'\n').encode());os.replace(temporary,path)

def load(folder, release, trusted_receipts=None, manifest=None):
    folder=Path(folder).resolve()
    version,menu,assets=describe(folder,manifest)
    def checked(record):
        path=inside(folder,record['file'])
        u.require(path.is_file() and path.stat().st_size==record['bytes'] and 0<record['bytes']<=1024*1024, 'Release file is missing or has the wrong size')
        data=path.read_bytes()
        u.require(u.sha(data)==record['sha256'],'Release file checksum mismatch')
        return data
    fw=checked(menu);u.firmware(fw)
    bank=bytearray(b'\xff'*(0x3ff000-0x201000));slots=bytearray();seen=set();end=0x201000
    for a in assets:
        data=checked(a);core=a['core_id'];base=a['offset']
        u.require(core in (1,5,7,2) and core not in seen,'Invalid core set');seen.add(core)
        u.require(base>=end and base%4096==0 and base+len(data)<=0x3ff000,'Invalid bank bounds')
        u.require(len(data)>4096 and data[:8]==b'NBCRXZ01','Invalid compressed core')
        cid,length,crc,board,payload,count,block,meta=struct.unpack_from('<8I',data,8)
        u.require(cid==core and length==907418 and board==0x4b30324e and payload==len(data)-4096 and count==14 and block==65536 and data[40:64]==bytes(24),'Unsupported core image/layout')
        u.require(meta==a.get('meta',meta)==zlib.crc32(data[:36]+data[40:64]+data[64:64+count*8]),'Invalid core metadata')
        raw=bytearray();pos=4096
        for i in range(count):
            offset,size=struct.unpack_from('<II',data,64+i*8);stored=bool(size&0x80000000);size&=0x7fffffff
            expected=min(block,length-len(raw))
            u.require(offset==pos and 0<size<=expected and offset+size<=len(data),'Invalid core block')
            chunk=data[offset:offset+size]
            if stored: decoded=chunk
            else:
                decoder=lzma.LZMADecompressor(memlimit=2*1024*1024)
                decoded=decoder.decompress(chunk,max_length=expected+1)
                u.require(decoder.eof and not decoder.unused_data,'Core block exceeds its decoded size or has trailing data')
            u.require(len(decoded)==expected,'Invalid decoded core length');raw+=decoded;pos+=size
        u.require(pos==len(data) and len(raw)==length and zlib.crc32(raw)==crc and u.sha(raw)==a.get('raw_sha256',a.get('image_sha256')),'Core image check failed')
        bank[base-0x201000:base-0x201000+len(data)]=data
        slots+=struct.pack('<IIII',core,base,len(data),meta)
        end=base+((len(data)+4095)&~4095)
    u.require(seen=={1,5,7,2} and bytes(slots) in fw,'Firmware and cores do not belong to the same release')
    changes=[(0x201000,bytes(bank)),(0x40000,fw+b'\xff'*(0xa8000-len(fw)))]
    canonical=u.writes(Path(release))
    trusted=KNOWN_PAIRS+receipts(trusted_receipts)
    def plan(before,requested):
        u.require(requested==changes and len(before)==u.SIZE,'Invalid update request')
        already=all(before[start:start+len(data)]==data for start,data in changes)
        if not already:
            current=before[0x40000:0xe8000];length=4096+struct.unpack_from('<I',current,132)[0]
            u.require(4096<=length<=len(current),'Unknown installed menu')
            previous=current[:length];u.firmware(previous)
            u.require(current[length:]==b'\xff'*(len(current)-length),'Unknown installed menu padding')
            pair=dict(menu_sha256=u.sha(previous),bank_sha256=u.sha(before[0x201000:0x3ff000]))
            known=pair in trusted
            legacy=u.sha(previous) in development_menu.PREVIOUS_MENU_HASHES|{u.FW_HASH} and all(before[start:start+len(data)]==data for start,data in canonical[:-1])
            u.require(known or legacy,'Unknown installed layout; retain the backup before recovery')
        after=bytearray(before)
        for start,data in changes:after[start:start+len(data)]=data
        for start,end in [(0,0x40000),(0xe8000,0x201000),(0x3ff000,u.SIZE)]:u.require(after[start:end]==before[start:end],'Protected bytes changed')
        return bytes(after)
    return changes,plan
