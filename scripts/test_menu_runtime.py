"""Focused tests of the actual menu runtime, overlay and game browser."""
import subprocess
import tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]/'firmware'
with tempfile.TemporaryDirectory(prefix='nanoblast-runtime-') as folder:
    for name,sources in [
        ('overlay',['tests/overlay_test.cpp']),
        ('usb_shortcut',['ui/nanoblast_menu.cpp','tests/usb_shortcut_test.cpp']),
        ('horizon_palette',['ui/nanoblast_menu.cpp','tests/horizon_runtime_test.cpp']),
        ('horizon_layout',['ui/nanoblast_menu.cpp','tests/theme_test.cpp']),
        ('loading',['ui/nanoblast_menu.cpp','tests/loading_runtime_test.cpp']),
        ('gameboy',['ui/nanoblast_menu.cpp','tests/gb_runtime_test.cpp']),
        ('browser',['tests/browser_test.cpp']),
        ('sms_loader',['tests/sms_loader_test.cpp']),
        ('gb_loader',['tests/gb_loader_test.cpp']),
        ('snes_loader',['tests/snes_loader_test.cpp']),
    ]:
        binary=Path(folder)/name
        subprocess.run(['c++','-std=c++17','-Wall','-Wextra','-Werror','-pthread','-fsanitize=address,undefined','-I'+str(ROOT/'ui'),'-I'+str(ROOT/'storage'),*[str(ROOT/source) for source in sources],'-o',str(binary)],check=True)
        subprocess.run([str(binary)],check=True)
        print('PASS',name,flush=True)
