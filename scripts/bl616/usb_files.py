"""NanoBlast ROM protocol client. Filesystem operations stay inside firmware's ROM roots."""
import json
import struct
import time
import zlib
from pathlib import Path

EXTENSIONS = {'nes': ('.nes', '.zip'), 'sms': ('.sms', '.gg', '.zip'), 'gb': ('.gb', '.gbc', '.zip'), 'snes': ('.sfc', '.smc', '.zip')}

def upload_destination(destination):
    """Adapt only the filename to the installed firmware's path alphabet."""
    parts = destination.split('/')
    if len(parts) < 2 or parts[0] not in EXTENSIONS:
        raise ValueError('Open a console folder before adding ROMs')
    for segment in parts[:-1]:
        if (not segment or segment.startswith('.') or segment.endswith(('.', ' '))
                or segment.lower() == 'saves'
                or any(not (c.isascii() and (c.isalnum() or c in ' ._-()')) for c in segment)):
            raise ValueError('Unsupported destination folder')
    filename = parts[-1]
    if not filename or filename.startswith('.') or '\\' in filename or '\x00' in filename:
        raise ValueError('Invalid ROM filename')
    extension = Path(filename).suffix.lower()
    if extension not in EXTENSIONS[parts[0]]:
        raise ValueError(f'{filename}: /{parts[0]} accepts {", ".join(EXTENSIONS[parts[0]])}; choose the matching console folder and an extracted ROM')
    compatible = ''.join(c if c.isascii() and (c.isalnum() or c in ' ._-()') else '_' for c in filename)
    parts[-1] = compatible
    result = '/'.join(parts)
    if len(result) > 160:
        raise ValueError('ROM destination exceeds 160 characters; shorten the filename or folder path')
    return result

def validate_zip(stream, core):
    import zipfile
    try:
        with zipfile.ZipFile(stream) as archive:
            entries=archive.infolist()
            if len(entries)>4096:raise ValueError('ZIP has too many entries')
            roms=[entry for entry in entries if not entry.is_dir()
                  and not entry.filename.startswith('__MACOSX/')
                  and not entry.filename.rsplit('/',1)[-1].startswith('.')
                  and Path(entry.filename).suffix.lower() in EXTENSIONS[core][:-1]]
            if len(roms)!=1:raise ValueError('ZIP must contain exactly one ROM for /'+core)
            entry=roms[0]
            if entry.flag_bits&1 or entry.compress_type not in (zipfile.ZIP_STORED,zipfile.ZIP_DEFLATED):
                raise ValueError('ZIP must use stored or Deflate compression without encryption')
            if not 0<entry.file_size<=64*1024*1024:raise ValueError('ZIP ROM must be between 1 byte and 64 MiB')
            if any(not part or part.startswith('.') or part.endswith(('.', ' ')) for part in entry.filename.split('/')) or any(ord(c)<32 or ord(c)>=127 or c in '\\:*?"<>|' for c in entry.filename):
                raise ValueError('ZIP member has an unsupported path or filename')
    except zipfile.BadZipFile as error:
        raise ValueError('Invalid ZIP archive') from error
    stream.seek(0)

class Client:
    def __init__(self, stream): self.stream=stream;self.seq=0
    def exact(self,n,timeout=30):
        data=bytearray();deadline=time.monotonic()+timeout
        while len(data)<n:
            if time.monotonic()>deadline:raise TimeoutError('USB transfer timed out; reconnect and inspect the destination before retrying')
            part=self.stream.read(n-len(data))
            if part:data.extend(part)
        return bytes(data)
    def request(self,op,payload=b''):
        if len(payload)>1024:raise ValueError('Payload too large')
        self.seq+=1
        header=struct.pack('<4sBBHI',b'NBR1',op,0,len(payload),self.seq)
        message=header+struct.pack('<I',zlib.crc32(header+payload))+payload
        if self.stream.write(message)!=len(message):raise IOError('Short USB write')
        head=self.exact(16,600 if op==5 else 30);magic,reply,status,n,seq,crc=struct.unpack('<4sBBHII',head)
        if magic!=b'NBR1' or reply!=op or seq!=self.seq or n>1024:raise ValueError('Unexpected USB protocol response')
        data=self.exact(n)
        if zlib.crc32(head[:12]+data)!=crc:raise ValueError('USB response checksum failed')
        if status:raise ValueError({1:'Invalid ROM path or request',2:'Transfer state conflict; reconnect',3:'SD operation failed: check card, free space, destination or leftover .nbpart file',4:'Transfer checksum or length mismatch'}.get(status,'Device error'))
        return data
    def hello(self):
        if self.request(1)!=b'NANOBLAST-ROM/1':raise ValueError('This is not compatible NanoBlast file-transfer firmware')
    def list(self,path):
        entries=[]
        for index in range(10000):
            data=self.request(2,struct.pack('<I',index)+path.encode('ascii'))
            if not data:return entries
            if len(data)<6 or data[0]>1:raise ValueError('Malformed directory entry')
            name=data[5:].decode('ascii')
            if '/' in name or '\\' in name or name in ('.','..'):raise ValueError('Unsafe directory entry')
            entries.append(dict(name=name,directory=bool(data[0]),size=struct.unpack('<I',data[1:5])[0],path=(path+'/' if path else '')+name))
        raise ValueError('Directory exceeds 10,000 entries')
    def upload(self,source,destination,report=lambda _:None):
        destination=upload_destination(destination)
        # Hold the same file descriptor for both passes; device checks the announced
        # size and CRC again after reading the temporary file back from the SD card.
        with Path(source).open('rb') as f:
            if destination.lower().endswith('.zip'):validate_zip(f,destination.split('/')[0])
            crc=0;size=0
            while True:
                data=f.read(65536)
                if not data:break
                crc=zlib.crc32(data,crc);size+=len(data)
            if not 0<size<=64*1024*1024:raise ValueError('ROM must be between 1 byte and 64 MiB')
            f.seek(0)
            self.request(3,struct.pack('<II',size,crc)+destination.encode('ascii'))
            try:
                offset=0
                while True:
                    # Keep header + offset + data within one short 64-byte USB
                    # packet. The installed BL616 driver stalls on a multi-packet
                    # OUT request; single-packet requests are verified on hardware.
                    data=f.read(40)
                    if not data:break
                    ack=self.request(4,struct.pack('<I',offset)+data);offset+=len(data)
                    if ack!=struct.pack('<I',offset):raise ValueError('Unexpected upload offset')
                    report(dict(sent=offset,total=size))
                self.request(5)
            except Exception:
                # No automatic retry or destructive cleanup on an uncertain link.
                # Device aborts an active temp upload on disconnect/idle timeout.
                raise
        return dict(path=destination,bytes=size,crc32=f'{crc:08x}')

def run(args):
    from serial.tools import list_ports
    import serial
    def candidates():
        return [dict(port=p.device,identity=json.dumps([p.device,p.vid,p.pid,p.serial_number,p.location]),description=p.description) for p in list_ports.comports() if p.vid==0xffff and p.pid==0x4e42]
    if args.files=='ports':return candidates()
    if not any(p['port']==args.port and p['identity']==args.identity for p in candidates()):raise ValueError('ROM-transfer device disconnected or changed; use console Settings → Advanced → USB ROM transfer')
    with serial.Serial(args.port,115200,timeout=0.25,write_timeout=5) as stream:
        stream.reset_input_buffer();client=Client(stream);client.hello()
        if args.files=='list':return client.list(args.remote or '')
        if args.files=='upload':return client.upload(args.local,args.remote,lambda p:print('PROGRESS '+json.dumps(p),flush=True))
        raise ValueError('Unknown file operation')
