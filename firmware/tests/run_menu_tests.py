#!/usr/bin/env python3
"""Compile and test the MCU menu/adapter natively on macOS; no board writes."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='nanoblast-menu-') as tmp:
 for name,sources in [('crc32',['tests/crc32_test.cpp']),('sms_loader',['tests/sms_loader_test.cpp']),('snes_loader',['tests/snes_loader_test.cpp']),('core_assets',['tests/core_assets_test.cpp']),('menu',['ui/nanoblast_menu.cpp','tests/menu_test.cpp']),('runtime',['ui/nanoblast_menu.cpp','tests/runtime_test.cpp']),('browser',['tests/browser_test.cpp']),('uart_rx',['tests/uart_rx_buffer_test.cpp']),('fpga_sd',['tests/fpga_sd_test.cpp']),('fpga_flash',['tests/fpga_flash_test.cpp']),('background_install',['storage/background_install.cpp','tests/background_install_test.cpp']),('core_stage',['storage/core_stage.cpp','tests/core_stage_test.cpp']),('core_stage_xip',['tests/core_stage_xip_test.cpp']),('persistent_core',['storage/persistent_core.cpp','tests/persistent_core_test.cpp'])]:
  binary=Path(tmp)/name
  subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-pthread','-fsanitize=address,undefined','-I',str(root/'ui'),'-I',str(root/'storage'),*[str(root/s) for s in sources],'-o',str(binary)],check=True)
  subprocess.run([str(binary)],check=True)
  print('PASS '+name,flush=True)
 source=(root/'main.cpp').read_text()
 function=source[source.index('int joy_choice('):source.index('\n#define MAIN_TASK_STACK_SIZE')]
 generated=Path(tmp)/'joy_choice.cpp'
 generated.write_text((root/'tests/joy_choice_test.cpp').read_text().replace('// JOY_CHOICE_UNDER_TEST',function))
 binary=Path(tmp)/'joy_choice'
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined',str(generated),'-o',str(binary)],check=True)
 subprocess.run([str(binary)],check=True)
 print('PASS joy_choice',flush=True)
