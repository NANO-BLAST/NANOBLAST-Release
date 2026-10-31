import io
import zipfile
import struct
import tempfile
import unittest
import zlib
from pathlib import Path
from usb_files import Client, upload_destination, validate_zip
class Wire:
    def __init__(self, corrupt=False, status=0):self.reply=bytearray();self.data=bytearray();self.corrupt=corrupt;self.status=status
    def write(self,frame):
        magic,op,_,n,seq,crc=struct.unpack('<4sBBHII',frame[:16]);payload=frame[16:]
        assert magic==b'NBR1' and len(payload)==n and zlib.crc32(frame[:12]+payload)==crc
        data=b''
        if op==1:data=b'NANOBLAST-ROM/1'
        if op==2 and struct.unpack('<I',payload[:4])[0]==0:data=b'\x00'+struct.pack('<I',4)+b'test.nes'
        if op==3:self.size,self.crc=struct.unpack('<II',payload[:8])
        if op==4:
            assert len(frame)<=64, 'Keep upload requests within one USB packet'
            assert struct.unpack('<I',payload[:4])[0]==len(self.data)
            self.data.extend(payload[4:]);data=struct.pack('<I',len(self.data))
        if op==5:assert len(self.data)==self.size and zlib.crc32(self.data)==self.crc
        header=struct.pack('<4sBBHI',magic,op,self.status,len(data),seq)
        self.reply.extend(header+struct.pack('<I',zlib.crc32(header+data)^(1 if self.corrupt else 0))+data)
        return len(frame)
    def read(self,n):
        count=min(n,3);data=self.reply[:count];del self.reply[:count];return bytes(data)
class Tests(unittest.TestCase):
    def test_common_rom_filename_is_compatible(self):
        self.assertEqual(upload_destination('sms/X-Men - Mojo World (Brazil).sms'), 'sms/X-Men - Mojo World (Brazil).sms')
        self.assertEqual(upload_destination('gb/Game [USA] é.gbc'), 'gb/Game _USA_ _.gbc')
        self.assertEqual(upload_destination('sms/Sonic the Hedgehog 2.gg'), 'sms/Sonic the Hedgehog 2.gg')
    def test_wrong_console_and_unsafe_paths_refused_before_transfer(self):
        for destination in ['nes/game.sms', 'sms/game.rar', 'sms/../game.sms', 'gb/saves/game.gb', 'sms/.hidden.sms', 'sms/game\\name.sms']:
            with self.assertRaises(ValueError):upload_destination(destination)
    def test_zip_upload_preserves_archive(self):
        wire=Wire();client=Client(wire);client.hello()
        with tempfile.TemporaryDirectory() as directory:
            path=Path(directory)/'Game (USA).zip'
            with zipfile.ZipFile(path,'w',compression=zipfile.ZIP_DEFLATED) as z:z.writestr('Game (USA).sms',b'ROM'*100)
            result=client.upload(path,'sms/Game (USA).zip')
            self.assertEqual(result['path'],'sms/Game (USA).zip')
            self.assertEqual(bytes(wire.data),path.read_bytes())
    def test_zip_multiple_and_wrong_core_refused(self):
        for names in [('a.sms','b.sms'),('a.gb',)]:
            stream=io.BytesIO()
            with zipfile.ZipFile(stream,'w') as z:
                for name in names:z.writestr(name,b'ROM')
            stream.seek(0)
            with self.assertRaises(ValueError):validate_zip(stream,'sms')
    def test_fragmented_frames_and_directory(self):
        c=Client(Wire());c.hello();self.assertEqual(c.list('nes')[0]['path'],'nes/test.nes')
    def test_multichunk_upload(self):
        wire=Wire();c=Client(wire);c.hello()
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'test.nes';p.write_bytes(bytes(range(256))*20)
            result=c.upload(p,'nes/test.nes');self.assertEqual(result['bytes'],5120);self.assertEqual(bytes(wire.data),p.read_bytes())
    def test_bad_frame_crc(self):
        with self.assertRaisesRegex(ValueError,'checksum'):Client(Wire(corrupt=True)).hello()
    def test_filesystem_error(self):
        with self.assertRaisesRegex(ValueError,'SD operation'):Client(Wire(status=3)).hello()
    def test_empty_rom_refused(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'empty.nes';p.write_bytes(b'')
            with self.assertRaises(ValueError):Client(Wire()).upload(p,'nes/empty.nes')
if __name__=='__main__':unittest.main()
