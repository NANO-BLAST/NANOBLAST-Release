from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='nanoblast-trace-') as tmp:
 binary=Path(tmp)/'test'
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-DNANOBLAST_SWITCH_TRACE_HOST_TEST','-I',str(root/'storage'),str(root/'tests/switch_trace_test.cpp'),str(root/'storage/switch_trace.cpp'),'-o',str(binary)],check=True)
 subprocess.run([str(binary)],check=True)
 print('PASS durable switch trace: ownership guard, bounded metadata-only writes, reset recovery phase, torn-record rejection and later-record recovery')
