"""Narrow NanoBlast v0.2.0 updater. No chip erase, efuse, or primary firmware writes."""
import argparse
import hashlib
import json
import struct
import sys
import zlib
from pathlib import Path

SIZE = 0x400000
PROTECTED = [(0, 0x40000), (0x1DF000, 0x201000), (0x3FF000, SIZE)]
RANGES = [(0x201000, 0x3FF000), (0x100000, 0x1DF000), (0xE8000, 0x100000), (0x40000, 0xE8000)]
FW_HASH = '89154be0b98d13d501eab3406c479fca544ef6ddebe9b84f982e410f21a00acb'
CORES = [
 ('cores/nes.core',0x201000,333364,'36feb7ed131880c6535f8bf77acd98bccc4688c8376bceae914359dc09683bfd'),
 ('cores/sms-gamegear.core',0x253000,321392,'8b10f626550116d175e1cc1db2af496040e3a28cabf89228790c4ce4252431a3'),
 ('cores/gb-colour.core',0x2A2000,351916,'81348b6247eb6abe43a1b2c89fa069223257401055468907a3e464937019388f'),
 ('cores/snes-experimental.core',0x2F8000,449296,'f87e8f92d0a4f432228fa427b0d56858840c8bfe401400b5aa942c617ae3574c')]

def require(ok, message):
    if not ok:
        raise ValueError(message)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def firmware(data):
    require(len(data) >= 4096, 'Truncated menu')
    word = lambda n: struct.unpack_from('<I', data, n)[0]
    require(data[:4] == b'BFNP' and word(124) == 4096 and word(132) == len(data)-4096, 'Invalid firmware header')
    require(word(96) == zlib.crc32(data[12:96]) and word(116) == zlib.crc32(data[104:116]) and word(252) == zlib.crc32(data[:252]), 'Firmware CRC mismatch')
    require(data[136:168] == hashlib.sha256(data[4096:]).digest(), 'Firmware payload hash mismatch')
    require(word(120) & 15 == 0 and word(120) & (3 << 16) == 0 and len(data) <= 0xA8000, 'Unsupported firmware flags or size')

def writes(root):
    fw = (root/'nanoblast-firmware.bin').read_bytes()
    require(sha(fw) == FW_HASH, 'Unreviewed menu firmware')
    firmware(fw)
    bank = bytearray(b'\xff' * (0x3FF000-0x201000))
    for name, address, size, digest in CORES:
        data = (root/name).read_bytes()
        require(len(data) == size and sha(data) == digest and data[:8] == b'NBCRXZ01', 'Unreviewed core asset')
        bank[address-0x201000:address-0x201000+len(data)] = data
    return [(0x201000, bytes(bank)), (0x100000,b'\xff'*0xDF000), (0xE8000,b'\xff'*0x18000), (0x40000,fw+b'\xff'*(0xA8000-len(fw)))]

def validate_baseline(before, changes):
    require(len(before) == SIZE, 'A complete 4 MiB flash backup is required')
    length = 4096 + struct.unpack_from('<I', before, 0x40000+132)[0]
    require(4096 < length <= 0xA8000, 'Unknown menu baseline; backup retained, no writes')
    old = before[0x40000:0x40000+length]
    firmware(old)
    if sha(old) == FW_HASH:
        # Already-installed v0.2.0: accept only the complete audited core/staging layout.
        require(all(before[a:a+len(b)] == b for a,b in changes), 'Current menu has an unknown core layout; no writes')
        return
    require(sha(old) in {'1f42bc5515ebce8c2b63e0bf4f51a5450fa397eb1cf37b7a50f53f415e146260','272153d641639a71b7ef062e9aad60d03fbe1ca87b499d710be32651a4e208aa'}, 'Unknown firmware baseline; no writes')
    for start,end,digest in [(0x100000,0x1DF000,'a69769900d0850874f88cb6165abc3e492e56b1b98630941291d5ef42ed39be1'),(0x201000,0x2E0000,'747a8fe7e6643e1507e9fc94ff482cf0939a3a3e04f4fc2f5f8e1082e0b9401a'),(0x300000,0x3DF000,'5db41e499a503b34a8fe6199e5982b3fba7a805c3b5e8eefea6a42b3e7cf6383')]:
        require(sha(before[start:end]) == digest, 'Unknown existing core asset; no writes')
    gb = before[0xE8000:0x100000]+before[0x2E0000:0x300000]+before[0x3DF000:0x3FF000]
    length = 4096+struct.unpack_from('<I',gb,24)[0]
    require(gb[:8] == b'NBGBXZ01' and 4096 < length <= len(gb) and sha(gb[:length]) == '6348ea878de55542dfb4df37b5054cc4d3358f28b2cf538a45d793eb06a38eef', 'Unknown GB asset; no writes')

def planned(before, changes):
    require([(a,a+len(b)) for a,b in changes] == RANGES, 'Write regions differ from reviewed layout')
    validate_baseline(before, changes)
    after = bytearray(before)
    for address,data in changes:
        require(address % 4096 == 0 and len(data) % 4096 == 0, 'Unaligned erase region')
        after[address:address+len(data)] = data
    require(all(after[a:b] == before[a:b] for a,b in PROTECTED), 'Protected region changed')
    return bytes(after)

def ports():
    from serial.tools import list_ports
    # USB serial candidates still require explicit physical UPDATE-port confirmation.
    return [dict(port=p.device, identity=json.dumps([p.device,p.vid,p.pid,p.serial_number,p.location]), description=p.description)
            for p in list_ports.comports() if p.vid is not None and p.pid is not None]

def check_port(port, identity):
    require(any(p['port'] == port and p['identity'] == identity for p in ports()), 'Selected USB serial device disconnected or changed')

def library_paths(root):
    import bflb_mcu_tool
    import libs
    # Vendor modules cache resource paths at import time. Point every cached path
    # at the operation's writable copy, never at the installed app bundle.
    for name,module in list(sys.modules.items()):
        if name == 'libs' or name.startswith('libs.'):
            if hasattr(module,'app_path'): module.app_path=str(root)
            if hasattr(module,'chip_path'): module.chip_path=str(root/'chips')
    return Path(bflb_mcu_tool.__file__).parent

class Transport:
    def __init__(self, port, identity, out):
        import bflb_mcu_tool
        import shutil
        runtime=out/'runtime'
        source=Path(bflb_mcu_tool.__file__).parent
        shutil.copytree(source/'chips/bl616',runtime/'chips/bl616')
        shutil.copytree(source/'utils/flash/bl616',runtime/'utils/flash/bl616')
        library_paths(runtime)
        from libs.bflb_configobj import BFConfigParser
        self.out, self.port, self.identity = out, port, identity
        self.cfg = BFConfigParser()
        self.cfg.read(str(Path(bflb_mcu_tool.__file__).parent/'chips/bl616/eflash_loader/eflash_loader_cfg.conf'))
        for key,value in {'device':port,'do_reset':'false','erase':'0','verify':'1','check_mac':'false','local_log':'false','load_function':'2','cpu_reset_after_load':'false','interface':'uart'}.items():
            self.cfg.set('LOAD_CFG',key,value)
        self.cfg.set('FLASH_CFG','decompress_write','false')
    def perform(self, options, writing=False):
        from libs.bflb_utils import eflash_loader_parser_init
        from libs.bflb_eflash_loader import BflbEflashLoader
        check_port(self.port,self.identity)
        self.cfg.set('LOAD_CFG','erase','1' if writing else '0')
        config = self.out/'loader.conf'
        self.cfg.write(str(config),'w')
        parsed = eflash_loader_parser_init().parse_args(options+['--config',str(config)])
        require(not parsed.erase and not parsed.efuse, 'Chip erase and efuse are prohibited')
        require(BflbEflashLoader('bl616','bl616').efuse_flash_loader(parsed,str(config),'') is True, 'BL616 operation failed. Stop and retain the backup; do not retry blindly.')
    def read(self,start,end,path):
        self.perform(['--read','--flash','--start',f'{start:x}','--end',f'{end-1:x}','--file',str(path)])
        return path.read_bytes()
    def write(self,start,data,path):
        require(any(a <= start and start+len(data) <= b for a,b in RANGES), 'Write outside allowed region')
        require(start % 4096 == 0 and len(data) % 4096 == 0, 'Unaligned write')
        path.write_bytes(data)
        self.perform(['--write','--flash','--addr',hex(start),'--file',str(path)],True)

def durable(path,data):
    import os
    with path.open('xb') as f:
        f.write(data)
        f.flush()
        os.fsync(f.fileno())

def install(transport, changes, out, planner=planned):
    def read_all(label):
        parts=[]
        for start in range(0,SIZE,0x20000):
            data=transport.read(start,start+0x20000,out/f'{label}-{start:06x}.bin')
            require(len(data)==0x20000,'Short flash read')
            parts.append(data)
            print(f'{label}: {start+len(data)}/{SIZE} bytes',flush=True)
        data=b''.join(parts)
        durable(out/f'{label}-full-flash.bin',data)
        return data
    before=read_all('before')
    expected=planner(before,changes)
    record={'status':'BACKUP_VALIDATED','before_sha256':sha(before),'expected_sha256':sha(expected),'protected_regions':PROTECTED}
    durable(out/'plan.json',json.dumps(record,indent=2).encode())
    print(f'Backup validated: {out}. Keep power connected until readback finishes.',flush=True)
    for address,data in changes:
        for offset in range(0,len(data),0x4000):
            start,chunk=address+offset,data[offset:offset+0x4000]
            if before[start:start+len(chunk)] != chunk:
                transport.write(start,chunk,out/f'write-{start:06x}.bin')
                print(f'Wrote {start:06x} ({len(chunk)} bytes)',flush=True)
    after=read_all('after')
    require(after==expected,'Full flash readback differs from plan. Keep backups and seek recovery assistance; do not retry blindly.')
    record.update(status='FULL_FLASH_READBACK_PASS',after_sha256=sha(after))
    durable(out/'result.json',json.dumps(record,indent=2).encode())
    print('FULL_FLASH_READBACK_PASS',flush=True)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--select-release',type=Path)
    parser.add_argument('--trusted-receipts',type=Path)
    parser.add_argument('--current-bundle',type=Path)
    parser.add_argument('--plan-backup',type=Path)
    parser.add_argument('--development-menu',type=Path)
    parser.add_argument('--restore-menu',action='store_true')
    parser.add_argument('--files',choices=['ports','list','upload'])
    parser.add_argument('--remote')
    parser.add_argument('--local')
    parser.add_argument('--list',action='store_true')
    parser.add_argument('--self-check',action='store_true')
    parser.add_argument('--release',type=Path)
    parser.add_argument('--output',type=Path)
    parser.add_argument('--port')
    parser.add_argument('--identity')
    parser.add_argument('--confirmation')
    args=parser.parse_args()
    if args.files:
        import usb_files
        print('RESULT '+json.dumps(usb_files.run(args)),flush=True)
    elif args.self_check:
        import bflb_mcu_tool
        library_paths(Path(bflb_mcu_tool.__file__).parent)
        from libs.bflb_eflash_loader import BflbEflashLoader
        from libs.bflb_utils import eflash_loader_parser_init
        require((Path(bflb_mcu_tool.__file__).parent/'chips/bl616/eflash_loader/eflash_loader_cfg.conf').is_file(),'Missing loader resources')
        import usb_files, development_menu, current_bundle, release_files
        print('NanoBlast BL616 and USB ROM helpers ready')
    elif args.select_release:
        require(args.release and args.output and not args.port,'Release selection needs a cache and no device arguments')
        import release_files
        print('RESULT '+json.dumps(release_files.select(args.select_release,args.output,args.release)),flush=True)
    elif args.plan_backup:
        require(args.current_bundle and args.release and not args.port and not args.output,'Offline planning needs a bundle/release and no device arguments')
        import current_bundle
        changes,planner=current_bundle.load(args.current_bundle,args.release,args.trusted_receipts)
        before=args.plan_backup.read_bytes();expected=planner(before,changes)
        print('RESULT '+json.dumps(dict(status='OFFLINE_PLAN_PASS',before_sha256=sha(before),expected_sha256=sha(expected))),flush=True)
    elif args.list:
        print(json.dumps(ports()))
    else:
        require(args.port and args.identity and args.release and args.output,'Missing install arguments')
        require(args.confirmation == 'UPDATE '+args.port,'Explicit UPDATE-port confirmation required')
        check_port(args.port,args.identity)
        planner=planned
        if args.current_bundle:
            require(not args.development_menu and not args.restore_menu,'Choose one firmware bundle')
            import current_bundle
            changes,planner=current_bundle.load(args.current_bundle,args.release,args.trusted_receipts)
        elif args.development_menu:
            import development_menu
            changes,planner=development_menu.load(args.development_menu,args.release,args.restore_menu)
        else:
            require(not args.restore_menu,'Restore requires a development manifest')
            changes=writes(args.release)
        args.output.mkdir(parents=True,exist_ok=False)
        install(Transport(args.port,args.identity,args.output),changes,args.output,planner=planner)
        if args.current_bundle:
            try: current_bundle.remember(args.trusted_receipts,changes)
            except Exception as error: print(f'WARNING: Flash verified, but installed-release history could not be saved: {error}',flush=True)

if __name__=='__main__':
    try:
        main()
    except Exception as error:
        print(f'ERROR: {error}',file=sys.stderr,flush=True)
        sys.exit(1)
