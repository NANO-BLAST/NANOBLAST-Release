from pathlib import Path
p=Path(__file__).resolve().parent
old="/Users/ryan/Documents/Codex/2026-10-14/is-x20"
setup="/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup"
for f in (p/'build-inputs').rglob('*'):
 if f.is_file() and f.suffix in {'.f','.ys','.tcl'}:
  f.write_text(f.read_text().replace(old,str(p/'build-inputs/original-workspace')).replace(setup,str(p/'build-inputs/setup-workspace')))
print('Build recipes relocated to',p)
