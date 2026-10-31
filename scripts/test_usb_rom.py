"""Host tests for the actual C++ service and Python client; no board access."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts/bl616'))
from usb_files import Client
with tempfile.TemporaryDirectory(prefix='nanoblast-usb-test-') as directory:
    temp=Path(directory)
    for name in ['usb_rom_service_test','usb_rom_wire_test']:
        subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-Wall','-Wextra','-Werror','-Wno-misleading-indentation',str(ROOT/'firmware/storage/usb_rom_service.cpp'),str(ROOT/f'firmware/tests/{name}.cpp'),'-o',str(temp/name)],check=True)
    subprocess.run([str(temp/'usb_rom_service_test')],check=True)
    sdk=os.environ.get('BL_SDK_BASE')
    if sdk:
        fatfs=Path(sdk)/'components/fs/fatfs'
        objects=[]
        for source in ['ff.c','ffunicode.c']:
            obj=temp/(source+'.o');objects.append(str(obj))
            subprocess.run([os.environ.get('CC','cc'),'-I'+str(fatfs),'-I'+str(ROOT/'firmware'),'-c',str(fatfs/source),'-o',str(obj)],check=True)
        target=temp/'fatfs-test'
        subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-I'+str(fatfs),'-I'+str(ROOT/'firmware'),str(ROOT/'firmware/storage/usb_rom_service.cpp'),str(ROOT/'firmware/storage/usb_rom_fatfs.cpp'),str(ROOT/'firmware/tests/usb_rom_fatfs_test.cpp'),*objects,'-o',str(target)],check=True)
        subprocess.run([str(target)],check=True)
    process=subprocess.Popen([str(temp/'usb_rom_wire_test')],stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    class Wire:
        def write(self,data):process.stdin.write(data);process.stdin.flush();return len(data)
        def read(self,n):return process.stdout.read(n)
    try:
        client=Client(Wire());client.hello()
        rom=temp/'game (USA).nes';rom.write_bytes(bytes(range(256))*100)
        uploaded=client.upload(rom,'nes/game (USA).nes')
        assert uploaded['bytes']==25600 and uploaded['path']=='nes/game (USA).nes'
        assert client.list('nes')[0]['size']==25600
        try:client.upload(rom,'nes/game (USA).nes')
        except ValueError:pass
        else:raise AssertionError('Existing ROM overwritten')
    finally:
        process.stdin.close();process.wait(timeout=5)
    assert process.returncode==0
subprocess.run([sys.executable,'-m','unittest','discover','-s',str(ROOT/'scripts/bl616'),'-v'],check=True)
print('PASS: Python client ↔ actual C++ service, fragmented frames, uploads, preservation and failures')
