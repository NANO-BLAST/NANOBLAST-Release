#!/usr/bin/env python3
"""Verify raw and compressed artwork loaders with the supplied original assets."""
from pathlib import Path
import argparse,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('original');p.add_argument('compressed');args=p.parse_args()
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='nanoblast-artwork-') as tmp:
 for name,sources,assets in [
  ('background',['ui/background_upload.cpp','tests/background_upload_test.cpp'],[args.original]),
  ('compressed',['ui/background_upload.cpp','ui/background_compression.cpp','tests/background_compression_test.cpp'],[args.original,args.compressed])]:
  binary=Path(tmp)/name
  subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I',str(root/'ui'),*[str(root/s) for s in sources],'-o',str(binary)],check=True)
  subprocess.run([str(binary),*assets],check=True)
  print('PASS '+name,flush=True)
