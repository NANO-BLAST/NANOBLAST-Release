#!/usr/bin/env python3
"""Prepare the pinned JT System 16B game-logic probe, not a flashable core."""
import argparse
from fractions import Fraction
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

PIN = '7637835e6b3656c5897bff7c4c421902c27fe7fb'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--upstream', required=True, type=Path)
p.add_argument('--jtframe', required=True, type=Path)
p.add_argument('--out', required=True, type=Path)
p.add_argument('--logic-mcu-rom', action='store_true')
p.add_argument('--with-memory-wrapper', action='store_true')
p.add_argument('--tag-ram', action='store_true', help='Use synchronous block RAM for the main CPU cache tags')
p.add_argument('--gowin-fir', action='store_true')
p.add_argument('--goldenaxe', action='store_true', help='Fixed goldnaxe3 World FD1094 profile')
a = p.parse_args()
u, out, tool = a.upstream.resolve(), a.out.resolve(), a.jtframe.resolve()
commit = subprocess.check_output(['git', '-C', str(u), 'rev-parse', 'HEAD'], text=True).strip()
if commit != PIN:
    raise SystemExit(f'Expected upstream {PIN}, found {commit}; review patches before changing the pin')
out.mkdir(parents=True, exist_ok=True)
(out/'jtbin').mkdir(exist_ok=True)
env = dict(os.environ, JTROOT=str(u), JTFRAME=str(u/'modules/jtframe'),
           CORES=str(u/'cores'), MODULES=str(u/'modules'), JTBIN=str(out/'jtbin'))
def generate(*args):
    result = subprocess.run([str(tool), *args], cwd=out, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
    with (out/'generator.log').open('a') as log:
        log.write(result.stdout + result.stderr)
    return result.stdout

generate('mem', 's16b', '--target', 'mister', '--local', '--inc', '--nodbg')
defs = generate('cfgstr', 's16b', '--target', 'mister', '--output', 'iverilog', '--nodbg', '--def', 'JTFRAME_VZ80')
generate('files', 'plain', 's16b', '--target', 'mister', '--local', '--macro', 'JTFRAME_VZ80')
if a.gowin_fir:
    for coeff_file in out.glob('fir*.hex'):
        words=coeff_file.read_text().split()
        assert len(words)==512 and all(re.fullmatch('[0-9a-fA-FxXzZ]{4}',word) for word in words)
        for suffix,start in [('coeff',0),('left',128),('right',256)]:
            coeff_file.with_name(coeff_file.name+'.'+suffix).write_text('\n'.join(words[start:start+128])+'\n')
if a.logic_mcu_rom:
    f = out/'jt8051.vh'
    text = f.read_text()
    old = 'reg  [47:0] ucode_rom[0:2**15-1];'
    assert text.count(old) == 1
    f.write_text(text.replace(old, '(* ram_style = "logic" *) '+old))

sources = []
original_hashes = {}
for line in (out/'files').read_text().splitlines():
    f = Path(line)
    f = f if f.is_absolute() else u/f
    if f.suffix.lower() not in ('.v', '.sv') or '/modules/jtframe/target/' in str(f):
        continue
    if f.name == 'jts16b_game_sdram.v':
        if not a.with_memory_wrapper:
            continue
        text=f.read_text()
        assert text.count("parameter VRAM_OFFSET = 22'h10_0000;")==1
        if a.tag_ram:
            text=text.replace(".TAG_RAM(0)",".TAG_RAM(1)").replace(".CACHE1_SIZE(1024)",".CACHE1_SIZE(256)")
        if a.goldenaxe:
            # Keep the requested peripheral rates with the legal 50.625 MHz PLL.
            for inst, rate, master in [('u_cen0_clk24',8_000_000,25_312_500),
                    ('u_cen0_clk',4_000_000,50_625_000),('u_cen1_clk',5_000_000,50_625_000),
                    ('u_cen2_clk',6_000_000,50_625_000),('u_cen3_clk',640_000,50_625_000)]:
                ratio=Fraction(rate,master)
                pattern=r'\.NUM\(\d+\),\.DEN\(\d+\),\.MFREQ\(\d+\)\) '+inst+r'\('
                text,count=re.subn(pattern,f'.NUM({ratio.numerator}),.DEN({ratio.denominator}),.MFREQ({master//1000})) {inst}(',text)
                assert count==1,inst
            assert text.count('( 149 )')==1 and text.count('( 39049 )')==1
            text=text.replace('( 149 )','( 64 )').replace('( 39049 )','( 16875 )')
            assert text.count('.FRACN(149), .FRACM(39049)')==1
            text=text.replace('.FRACN(149), .FRACM(39049)', '.FRACN(64), .FRACM(16875)')
        f.write_text(text.replace("parameter VRAM_OFFSET = 22'h10_0000;","parameter VRAM_OFFSET = 22'h04_0000;"))
    if not f.is_file():
        raise SystemExit('Missing input: '+str(f))
    if f.is_relative_to(u):
        original_hashes[str(f.relative_to(u))] = hashlib.sha256(f.read_bytes()).hexdigest()
    text = f.read_text()
    changed = False
    if f.name == 'jts16b_mapper.v':
        old = 'always @(addr_out,cpu_fc,mmr,inta_n) begin'
        assert text.count(old) == 1
        text = text.replace(old, 'always @* begin')
        if a.goldenaxe:
            assert "FNUM = 7'd29, FDEN = 8'd146" in text
            text=text.replace("FNUM = 7'd29, FDEN = 8'd146","FNUM = 7'd16, FDEN = 8'd81")
        changed = True
    if f.name == 'fx68k.sv':
        for reg in ('regs68L', 'regs68H'):
            old = reg+"[i] <= '0;"
            assert text.count(old) == 1
            text = text.replace(old, reg+"[i] = '0;")
        if a.goldenaxe:
            # Replace only the register file, preserving simultaneous writes,
            # byte enables and same-address Y priority.
            lo = text.index('// Register file')
            hi = text.index('wire [15:0] aluOut;', lo)
            text = text[:lo] + 'wire [15:0] rxL,ryL,rxH,ryH;\n    ' + text[hi:]
            for side in ['x','y']:
                for half in ['L','H']:
                    text=text.replace(f'regs68{half}[ actualR{side}]', f'r{side}{half}')
            lo = text.index('always_ff', text.index('// Main A/D registers'))
            hi = text.index('// PC & AT', lo)
            rf = []
            for side in ['x','y']:
                q = 'r'+side
                rf += [f'wire w{side} = enT3 && (Nanod.dbl2{q}l || Nanod.abl2{q}l);',
                       f'wire b{side} = !{q}IsAreg && !Nanod.dbl2{q}l && abdIsByte;',
                       f'wire [15:0] d{side} = {q}IsAreg ? (Nanod.dbl2{q}l ? Dbl : Abl) : (Nanod.dbl2{q}l ? Dbd : Abd);',
                       f'wire h{side} = enT3 && (Nanod.dbh2{q}h || Nanod.abh2{q}h);']
            rf += ['s16_fx68k_rf #(8) low(Clks.clk,actualRx,actualRy,wx,wy,dx[7:0],dy[7:0],rxL[7:0],ryL[7:0]);',
                   's16_fx68k_rf #(8) middle(Clks.clk,actualRx,actualRy,wx && !bx,wy && !by,dx[15:8],dy[15:8],rxL[15:8],ryL[15:8]);',
                   's16_fx68k_rf #(16) high(Clks.clk,actualRx,actualRy,hx,hy,Nanod.dbh2rxh ? Dbh : Abh,Nanod.dbh2ryh ? Dbh : Abh,rxH,ryH);']
            text = text[:lo] + '\n'.join(rf) + '\n' + text[hi:]
        changed = True
    if f.name == 'jtframe_rpwp_ram.v':
        assert text.count('no_rw_check, m9k') == 1
        text = text.replace('no_rw_check, m9k', 'no_rw_check')
        changed = True
    if a.goldenaxe and f.name == 'jt51_sh.v':
        # Gowin has distributed dual-port RAM but no native shift-register LUT.
        # Preserve the upstream reset mux and enabled-edge latency.
        start = text.index('reg [stages-1:0] bits')
        text = text[:start] + '''localparam AW = $clog2(stages);
reg [AW-1:0] head = 0;
wire [AW-1:0] tail = head - stages;
always @(posedge clk) if (cen) head <= head + 1'b1;
wire [width-1:0] value;
if (width >= 10 && stages >= 8) begin : synchronous_delay
    // Prefetch the following tail at each enabled edge. The read address
    // is distinct from the concurrent write for every supported depth.
    (* ram_style = "block" *) reg [width-1:0] mem [0:(1<<AW)-1];
    reg [width-1:0] q;
    wire [AW-1:0] next_tail = tail + 1'b1;
    always @(posedge clk) if (cen) begin
        mem[head] <= din;
        q <= mem[next_tail];
    end
    assign value = q;
end else begin : asynchronous_delay
    (* ram_style = "distributed" *) reg [width-1:0] mem [0:(1<<AW)-1];
    always @(posedge clk) if (cen) mem[head] <= din;
    assign value = mem[tail];
end
assign drop = rst ? {width{rstval[0]}} : value;
endmodule
'''
        changed = True
    if a.goldenaxe and f.name == 'jts16_mem.v':
        pattern = r'always @\(posedge clk\) begin\n    if\( header && prog_we \).*?\nend'
        fixed = """always @(posedge clk) begin
    fd1089_en <= 1'b0;
    dec_type <= 1'b0;
    fd1094_en <= 1'b1;
    mc8123_en <= 1'b0;
    mcu_en <= 1'b0;
    game_id <= 8'h40;
    dec_en <= 1'b1;
end"""
        text, count = re.subn(pattern, lambda _: fixed, text, flags=re.S)
        assert count == 1
        changed = True
    if a.goldenaxe and f.name == 'jts16b_main.v':
        start = text.index('jtframe_8751mcu #(')
        end = text.index('\n);', start)+3
        text = text[:start]+"assign mcu_dout=8'd0, mcu_addr=16'd0, mcu_wr=1'b0, mcu_acc=1'b0;\n"+text[end:]
        changed = True
    if a.gowin_fir and f.name=='jtframe_pole.v':
        f=Path(__file__).resolve().parent/'rtl/jtframe_pole_gowin.v'
        text=f.read_text()
    if a.gowin_fir and f.name=='jtframe_fir.v':
        f=Path(__file__).resolve().parent/'rtl/jtframe_fir_gowin.v'
        text=f.read_text()
    if changed:
        f = out/f.name
        f.write_text(text)
    if f not in sources:
        sources.append(f)
if a.goldenaxe:
    sources.append(Path(__file__).resolve().parent/'rtl/s16_fx68k_rf.sv')
for name in ('microrom.mem', 'nanorom.mem'):
    shutil.copyfile(u/'modules/fx68k/hdl'/name, out/name)
incs = {out, u/'modules/jtframe/hdl/inc', u/'modules/jt8051/hdl'} | {f.parent for f in sources}
header = ''.join('`define '+line[len('+define+'):].replace('=', ' ', 1)+'\n'
                 for line in defs.splitlines() if line.startswith('+define+'))
if a.goldenaxe:
    header,count=re.subn(r'(?m)^(`define JTFRAME_MCLK )\d+',r'\g<1>50625000',header)
    assert count==1
(out/'macros.vh').write_text(header)
def quote(path):
    value=str(path)
    if any(c.isspace() or c in '\";' for c in value):
        raise SystemExit('Use build and source paths without whitespace, quotes or semicolons: '+value)
    return value
top='jts16b_game_sdram' if a.with_memory_wrapper else 'jts16_game'
ys = 'read_slang --single-unit --top '+top+' '+ ' '.join('-I'+quote(d) for d in sorted(incs))
ys += ' '+quote(out/'macros.vh')+' '+' '.join(quote(f) for f in sources)+'\n'
ys += 'synth_gowin -family gw2a -top '+top+' -noiopads -nowidelut -nolutram -json logic.json\n'
ys += 'tee -o statistics.json stat -json\n'
(out/'synthesis.ys').write_text(ys)
(out/'probe-manifest.json').write_text(json.dumps({
    'upstream_commit': commit,
    'profile': 'goldnaxe3 FD1094' if a.goldenaxe else 'general s16b',
    'logic_mcu_rom': a.logic_mcu_rom,
    'with_memory_wrapper':a.with_memory_wrapper,
    'gowin_fir':a.gowin_fir,
    'top':top,
    'scope': 'Game logic and optional JTFRAME memory/audio wrapper. Excludes physical SDRAM controller, HDMI, menus, loader and board IO; not a flashable core.',
    'original_source_sha256': original_hashes,
    'adapted_source_sha256': {f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in sources if not f.is_relative_to(u)},
    'generated_sha256': {f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in out.iterdir()
                         if f.is_file() and f.suffix in ('.vh', '.inc', '.uc', '.mem', '.hex', '.coeff', '.left', '.right')},
    'submodules': subprocess.check_output(['git', '-C', str(u), 'submodule', 'status'], text=True),
}, indent=2)+'\n')
print('Prepared', len(sources), 'source files:', out/'synthesis.ys')
