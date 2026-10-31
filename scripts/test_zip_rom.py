"""Exercise actual firmware ZIP parsing and streaming Deflate with generated archives."""
import io
import os
import struct
import sys
import subprocess
import tempfile
import zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='nanoblast-zip-') as folder:
    folder=Path(folder);obj=folder/'inflate.o'
    flags=['-g','-fsanitize=address,undefined','-fno-omit-frame-pointer']
    subprocess.run(['cc',*flags,'-c',str(ROOT/'firmware/storage/tinf/tinf_stream.c'),'-o',str(obj)],check=True)
    target=folder/'zip-test'
    subprocess.run(['c++','-std=c++17',*flags,'-Wall','-Wextra','-Werror','-Wno-misleading-indentation',str(ROOT/'firmware/storage/zip_rom.cpp'),str(ROOT/'firmware/tests/zip_rom_test.cpp'),str(obj),'-o',str(target)],check=True)
    sdk=os.environ.get('BL_SDK_BASE')
    if sdk:
        fatfs=Path(sdk)/'components/fs/fatfs';objects=[str(obj)]
        for source in ['ff.c','ffunicode.c']:
            output=folder/(source+'.o');objects.append(str(output))
            subprocess.run(['cc',*flags,'-I'+str(fatfs),'-I'+str(ROOT/'firmware'),'-c',str(fatfs/source),'-o',str(output)],check=True)
        fat_target=folder/'zip-fatfs-test'
        subprocess.run(['c++','-std=c++17',*flags,'-DNANOBLAST_ZIP_FATFS_HOST_TEST','-I'+str(fatfs),'-I'+str(ROOT/'firmware'),*[str(ROOT/'firmware/storage'/s) for s in ['zip_rom.cpp','zip_rom_fatfs.cpp','usb_rom_service.cpp','usb_rom_fatfs.cpp']],str(ROOT/'firmware/tests/zip_rom_fatfs_test.cpp'),*objects,'-o',str(fat_target)],check=True)
        source=folder/'fatfs.zip';expected=folder/'rom.sms';rom=bytes(range(256))*2048;expected.write_bytes(rom)
        with zipfile.ZipFile(source,'w',compression=zipfile.ZIP_DEFLATED) as z:z.writestr('X-Men - Mojo World (Brazil).sms',rom)
        subprocess.run([str(fat_target),str(source),str(expected)],check=True)
    cases=0
    def archive(entries,method=zipfile.ZIP_DEFLATED,level=None,comment=b''):
        stream=io.BytesIO()
        with zipfile.ZipFile(stream,'w',compression=method,compresslevel=level) as z:
            z.comment=comment
            for name,data in entries:z.writestr(name,data)
        return stream.getvalue()
    def run(data,core=5,result=0,expected=None,fail=0):
        global cases
        cases+=1;path=folder/f'{cases}.zip';path.write_bytes(data)
        subprocess.run([str(target),str(path),str(core),str(result),str(fail)],check=True,stdout=subprocess.DEVNULL)
        if expected is not None:assert Path(str(path)+'.out').read_bytes()==expected
    # Large compressible streams exercise 32 KiB ring wrap and overlapping copies;
    # random data exercises stored Deflate blocks and bounded byte reads.
    rom=bytes(range(256))*8192
    run(archive([('X-Men - Mojo World (Brazil).sms',rom)]),expected=rom)
    run(archive([('nested/Game.sms',rom)],zipfile.ZIP_STORED),expected=rom)
    for level in [0,1,6,9]:
        data=os.urandom(100000) if level==0 else (b'abcd'*20000+os.urandom(40000))*3
        run(archive([('Game.gg',data)],level=level),expected=data)
    for core,ext in [(1,'nes'),(7,'gb'),(7,'gbc'),(2,'sfc'),(2,'smc')]:run(archive([(f'Game.{ext}',rom[:32768])]),core=core,expected=rom[:32768])
    run(archive([('manual.txt',b'doc'),('Game.SMS',rom[:8192])],comment=b'X'*65535),expected=rom[:8192])
    run(archive([('a.sms',b'a'),('b.sms',b'b')]),result=2)
    run(archive([('a.nes',b'a')]),result=1)
    run(archive([('../a.sms',b'a')]),result=3)
    run(archive([('/a.sms',b'a')]),result=3)
    run(archive([('a.sms',b'a')],zipfile.ZIP_BZIP2),result=3)
    data=bytearray(archive([('a.sms',b'abcd')]))
    cd=data.index(b'PK\x01\x02');struct.pack_into('<I',data,cd+16,0x12345678);struct.pack_into('<I',data,14,0x12345678)
    run(data,result=4)
    data=archive([('a.sms',rom[:32768])]);run(data[:-8],result=4)
    for n in [0,10,22,50]:run(data[:n],result=4)
    data=bytearray(archive([('a.sms',b'abc')]))
    cd=data.index(b'PK\x01\x02');struct.pack_into('<H',data,cd+8,1);run(data,result=3)
    data=bytearray(archive([('a.sms',b'abc')]))
    cd=data.index(b'PK\x01\x02');struct.pack_into('<I',data,cd+24,64*1024*1024+1);run(data,result=6)
    data=archive([('a.sms',rom[:8192])])
    for fail in [1,2,3,4]:run(data,result=5,fail=fail)
    # CRC errors and extra compressed bytes must never produce a committed ROM.
    for i in range(50):
        data=bytearray(archive([('a.sms',os.urandom(1000))]));data[50+i]^=0xff
        run(data,result=4)
    if len(sys.argv)>1:
        actual=Path(sys.argv[1])
        with zipfile.ZipFile(actual) as z:
            members=[i for i in z.infolist() if i.filename.lower().endswith(('.sms','.gg'))]
            assert len(members)==1
            expected=z.read(members[0])
        run(actual.read_bytes(),expected=expected)
        print('PASS actual user archive:',actual.name)
    print(f'PASS {cases} ZIP parser/Deflate cases under sanitizers')
