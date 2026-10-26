from pathlib import Path
import subprocess,tempfile,argparse
p=argparse.ArgumentParser();p.add_argument('--snes');args=p.parse_args()
root=Path(__file__).resolve().parents[1]
s=(root/'fpga/programmer.cpp').read_text();start=s.index('static const char *nano_program_error=');end=s.index('\n#include "nano_direct_persistent.inc"',start)
with tempfile.TemporaryDirectory(prefix='nano-jtag-') as tmp:
 generated=Path(tmp)/'programmer_test.cpp';generated.write_text((root/'tests/nano_programmer_test.cpp').read_text().replace('// NANO_PROGRAMMER_UNDER_TEST',s[start:end]))
 binary=Path(tmp)/'test';subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I',str(root/'storage'),str(generated),str(root/'storage/core_stage.cpp'),'-o',str(binary)],check=True)
 subprocess.run([str(binary),*([args.snes] if args.snes else [])],check=True)
 print('PASS actual Nano programmer: direct built-in bootstrap with ZERO SD/cache writes, CRC/footer/ID validation, staged custom-SD fallback, fixed 1KiB buffer, foreign-slot rejection and recovery')
