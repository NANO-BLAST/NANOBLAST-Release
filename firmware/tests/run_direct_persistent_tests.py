from pathlib import Path
import subprocess,tempfile,argparse
root=Path(__file__).resolve().parents[1];out=root.parent.parent/'outputs'
p=argparse.ArgumentParser();p.add_argument('--nes',default=str(out/'direct-flash-switch/nanoblast-nes.bin'));p.add_argument('--sms',default=str(out/'direct-flash-switch/smstang-nano20k.bin'));p.add_argument('--snes');a=p.parse_args()
with tempfile.TemporaryDirectory(prefix='direct-persist-') as tmp:
 binary=Path(tmp)/'test'
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I',str(root/'storage'),str(root/'tests/direct_persistent_test.cpp'),str(root/'storage/persistent_core.cpp'),'-o',str(binary)],check=True)
 subprocess.run([str(binary),a.nes,a.sms,str(out/'menu-unified/nanoblast-menu-unified.bin'),*([a.snes] if a.snes else [])],check=True)
 print('PASS actual direct persistence: direct built-in NES/SMS with no cache dependency/writes, readback ON/OFF, source CRC/footer guards in both modes, busy/WEL/protection, read-only boot fingerprint, no automatic NES writes or reload after failed save')
