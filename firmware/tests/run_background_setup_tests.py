#!/usr/bin/env python3
"""Test onboard setup with SDK FatFs, using host-only FAT32 and exFAT RAM disks."""
from pathlib import Path
import argparse,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('sdk');p.add_argument('original');p.add_argument('compressed');a=p.parse_args()
root=Path(__file__).resolve().parents[1];fatfs=Path(a.sdk).resolve()/'components/fs/fatfs'
with tempfile.TemporaryDirectory(prefix='nanoblast-sd-setup-') as tmp:
 includes=['-I',str(root),'-I',str(root/'ui'),'-I',str(root/'storage'),'-I',str(fatfs)]
 objects=[]
 for source in ['ff.c','ffunicode.c']:
  obj=Path(tmp)/(source+'.o');objects.append(str(obj))
  subprocess.run(['clang','-std=c11','-fsanitize=address,undefined',*includes,'-c',str(fatfs/source),'-o',str(obj)],check=True)
 # Link the real embedded bytes, with a wrapper that injects source faults.
 asset=Path(tmp)/'background_setup.o';objects.append(str(asset))
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined',
  '-DTANG_NANO20K','-DNANOBLAST_SD_SETUP_HOST_TEST',
  '-Dnanoblast_builtin_background=nanoblast_real_builtin_background',*includes,
  '-c',str(root/'ui/background_setup.cpp'),'-o',str(asset)],check=True)
 binary=Path(tmp)/'setup'
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-DTANG_NANO20K','-DNANOBLAST_SD_SETUP_HOST_TEST',*includes,*[str(root/s) for s in ['ui/background_runtime.cpp','ui/background_upload.cpp','ui/background_compression.cpp','storage/background_install.cpp','tests/background_setup_test.cpp']],*objects,'-o',str(binary)],check=True)
 subprocess.run([str(binary),a.original,a.compressed],check=True)
 print('PASS embedded artwork: real compiled bytes, ZERO SD I/O, no mounted media; FAT32/exFAT source/transport faults also perform ZERO SD I/O, no fallback, preserved files and overlay reset',flush=True)
