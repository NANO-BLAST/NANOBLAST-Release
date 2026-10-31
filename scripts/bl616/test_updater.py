import contextlib
import io
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import updater as u

ROOT=Path(__file__).resolve().parents[2]/'src-tauri/resources/nanoblast-v0.2.0'
class Fake:
    def __init__(self,data,fail=False,corrupt=False): self.data=bytearray(data);self.written=[];self.fail=fail;self.corrupt=corrupt
    def read(self,a,b,path):
        data=bytes(self.data[a:b])
        if self.corrupt and self.written and a==0: data=bytes([data[0]^1])+data[1:]
        return data
    def write(self,a,b,path):
        if self.fail: raise RuntimeError('Injected disconnect')
        self.written.append((a,len(b)));self.data[a:a+len(b)]=b
class Tests(unittest.TestCase):
    def setUp(self):
        self.changes=u.writes(ROOT)
        self.current=bytearray(b'\xa5'*u.SIZE)
        for a,b in self.changes:self.current[a:a+len(b)]=b
        self.current=bytes(self.current)
    def test_official_release_and_idempotence(self):
        self.assertEqual(u.planned(self.current,self.changes),self.current)
    def test_unknown_baseline_refused_without_writes(self):
        fake=Fake(b'\xff'*u.SIZE)
        with tempfile.TemporaryDirectory() as d, contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):u.install(fake,self.changes,Path(d))
            self.assertEqual(len((Path(d)/'before-full-flash.bin').read_bytes()),u.SIZE)
            self.assertEqual(fake.written,[])
    def test_current_menu_unknown_cores_refused(self):
        data=bytearray(self.current);data[0x201000]^=1
        with self.assertRaises(ValueError):u.planned(bytes(data),self.changes)
    def test_protected_write_plan_refused(self):
        with self.assertRaises(ValueError):u.planned(self.current,[(0,b'x'*4096)]+self.changes)
    def test_preservation_and_menu_last(self):
        old=b'\xa5'*u.SIZE;fake=Fake(old)
        with tempfile.TemporaryDirectory() as d, patch.object(u,'validate_baseline'), contextlib.redirect_stdout(io.StringIO()):
            u.install(fake,self.changes,Path(d))
            self.assertTrue((Path(d)/'result.json').is_file())
        for a,b in u.PROTECTED:self.assertEqual(fake.data[a:b],old[a:b])
        self.assertEqual(fake.written[-1][0],0xE4000)
    def test_readback_corruption_never_reports_success(self):
        fake=Fake(b'\xa5'*u.SIZE,corrupt=True)
        with tempfile.TemporaryDirectory() as d, patch.object(u,'validate_baseline'), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):u.install(fake,self.changes,Path(d))
            self.assertFalse((Path(d)/'result.json').exists())
    def test_disconnect_keeps_backup_no_success(self):
        fake=Fake(b'\xa5'*u.SIZE,fail=True)
        with tempfile.TemporaryDirectory() as d, patch.object(u,'validate_baseline'), contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(RuntimeError):u.install(fake,self.changes,Path(d))
            self.assertTrue((Path(d)/'before-full-flash.bin').exists())
            self.assertFalse((Path(d)/'result.json').exists())
    def test_changed_port_refused(self):
        with patch.object(u,'ports',return_value=[{'port':'test','identity':'changed'}]):
            with self.assertRaises(ValueError):u.check_port('test','original')
if __name__=='__main__':unittest.main()
