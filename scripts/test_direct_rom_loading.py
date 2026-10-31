"""Actual FAT32 + ROM reader + existing core loaders, raw versus streamed ZIP."""
import os
import random
import sys
import subprocess
import tempfile
import zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SDK=Path(os.environ['BL_SDK_BASE'])/'components/fs/fatfs'
FLAGS=['-g','-fsanitize=address,undefined','-fno-omit-frame-pointer']
with tempfile.TemporaryDirectory(prefix='nanoblast-core-stream-') as directory:
    temp=Path(directory);objects=[]
    for source in [SDK/'ff.c',SDK/'ffunicode.c',ROOT/'firmware/storage/tinf/tinf_stream.c']:
        obj=temp/(source.name+'.o');objects.append(str(obj))
        subprocess.run(['cc',*FLAGS,'-I'+str(SDK),'-I'+str(ROOT/'firmware'),'-c',str(source),'-o',str(obj)],check=True)
    for name,macro in [('nes','NES'),('sms','SMS'),('gb','GB'),('snes','SNES')]:
        obj=temp/(name+'.o');objects.append(str(obj))
        subprocess.run(['c++','-std=c++17',*FLAGS,'-DTANG_NANO20K','-DNANOBLAST_'+macro+'_LOADER_HOST_TEST','-DNANOBLAST_ROM_READER_INTEGRATION','-c',str(ROOT/f'firmware/core/{name}.cpp'),'-o',str(obj)],check=True)
    binary=temp/'cores'
    subprocess.run(['c++','-std=c++17',*FLAGS,'-I'+str(SDK),'-I'+str(ROOT/'firmware'),str(ROOT/'firmware/storage/zip_rom.cpp'),str(ROOT/'firmware/storage/zip_rom_fatfs.cpp'),str(ROOT/'firmware/tests/zip_core_stream_test.cpp'),*objects,'-o',str(binary)],check=True)
    rng=random.Random(42)
    cases=[(5,'Game (USA).sms',rng.randbytes(16384)),(5,'Game.gg',rng.randbytes(16384)),(5,'Copier.sms',b'\0'*512+rng.randbytes(8192)),(1,'Game.nes',b'NES\x1a'+bytes([2,0])+bytes(10)+rng.randbytes(32768))]
    for ext,battery in [('gb',False),('gb',True),('gbc',False)]:
        data=bytearray(rng.randbytes(32768));data[0x143]=0;data[0x147]=3 if battery else 0;data[0x148]=0;data[0x149]=2 if battery else 0
        data[0x14d]=(-sum(data[0x134:0x14d])-25)&255
        cases.append((7,('Battery' if battery else 'Game')+'.'+ext,bytes(data)))
    for size,offset,mapper in [(32768,0,0x20),(65536,0,0x21),(32768,512,0x20)]:
        data=bytearray(size+offset);pos=offset+(0xffc0 if mapper&1 else 0x7fc0);data[pos:pos+21]=b'STREAM TEST'.ljust(21,b' ');data[pos+21]=mapper;data[pos+23]=5 if size==32768 else 6;data[pos+61]=0x80
        cases.append((2,'Copier.smc' if offset else 'Game.sfc',bytes(data)))
    for index,(core,name,data) in enumerate(cases):
        for method in [zipfile.ZIP_STORED,zipfile.ZIP_DEFLATED]:
            raw=temp/f'{index}.rom';raw.write_bytes(data);archive=temp/f'{index}-{method}.zip'
            with zipfile.ZipFile(archive,'w',compression=method) as z:z.writestr('nested/'+name,data)
            subprocess.run([str(binary),str(archive),str(raw),str(core),name],check=True)
    for index in [0,3,4,7]:
        core,name,data=cases[index];archive=temp/f'bad-{index}.zip';raw=temp/'invalid-source.rom';raw.write_bytes(data)
        with zipfile.ZipFile(archive,'w',compression=zipfile.ZIP_DEFLATED) as z:z.writestr(name,data)
        damaged=bytearray(archive.read_bytes());offset=30+int.from_bytes(damaged[26:28],'little')+int.from_bytes(damaged[28:30],'little');damaged[offset]=7;archive.write_bytes(damaged)
        subprocess.run([str(binary),str(archive),str(raw),str(core),name,'invalid'],check=True)
    for path in sys.argv[1:]:
        archive=Path(path)
        with zipfile.ZipFile(archive) as z:
            entries=[i for i in z.infolist() if Path(i.filename).suffix.lower() in ('.nes','.sms','.gg','.gb','.gbc','.sfc','.smc')]
            assert len(entries)==1
            member=entries[0];name=Path(member.filename).name;data=z.read(member)
        core={'.nes':1,'.sms':5,'.gg':5,'.gb':7,'.gbc':7,'.sfc':2,'.smc':2}[Path(name).suffix.lower()]
        raw=temp/'user.rom';raw.write_bytes(data)
        subprocess.run([str(binary),str(archive),str(raw),str(core),name],check=True)
    print('PASS 20 raw/ZIP core streaming comparisons and supplied archives; existing GB/SNES core verification retained')
