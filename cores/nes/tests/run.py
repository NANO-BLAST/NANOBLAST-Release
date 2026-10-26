"""Focused RTL regressions. No ROM signatures or RTL behavioral replacements.

Icarus cannot elaborate all unpacked-array assignment patterns used by v0.10.
Constant table syntax and forward declaration order are normalized in TEMPORARY
simulation copies. RTL in src and synthesized sources are untouched; every table
value and every behavioral/continuous-assignment expression is preserved.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess

p = argparse.ArgumentParser()
p.add_argument('--rtl', type=Path, default=Path(__file__).resolve().parents[1] / 'src')
p.add_argument('--iverilog', default='iverilog')
p.add_argument('--vvp', default='vvp')
p.add_argument('--out', type=Path, default=Path('backport/simulation'))
p.add_argument('--test', choices=['mappers', 'apu', 'frame_irq', 'cpu_bus', 'open_bus_cpu', 'dma_cancel', 'io_bus', 'oam_write', 'oam_boundary', 'oam_eval', 'oam_corruption', 'oam_corruption_frame', 'shifter_hold', 'boot_reset', 'ppu', 'cpu', 'hdmi_reset', 'hdmi_video', 'tmds'])
p.add_argument('--define', action='append', default=[])
p.add_argument('--gowin-primitives', type=Path, help='Installed GW2A prim_sim.v; test actual DPB model without redistributing it')
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=True)

def compatible(path):
    s = path.read_text()
    def assign_table(m):
        values = m[2].split(',')
        return '\n'.join(f'assign {m[1]}[{i}] = {v.strip()};' for i,v in enumerate(values))
    s = re.sub(r"assign\s+(\w+)\s*=\s*'\{(.*?)\};", assign_table, s, flags=re.S)
    def init_table(m):
        values = m[3].split(',')
        return f'reg {m[1]} {m[2]} [{len(values)}];\ninitial begin\n' + '\n'.join(
            f'{m[2]}[{i}] = {v.strip()};' for i,v in enumerate(values)) + '\nend'
    s = re.sub(r"reg\s+(\[[^\]]+\])\s+(\w+)\s*\[\d+\]\s*=\s*'\{(.*?)\};", init_table, s, flags=re.S)
    if path.name == 'ppu.v':
        # The same declaration-order issue occurs in two baseline PPU sites.
        s = s.replace('reg enable_playfield, enable_objects;', '')
        s = s.replace('reg object_clip;', 'reg enable_playfield, enable_objects;\nreg object_clip;')
        s = s.replace('assign short_frame =', 'wire skip_pixel;\nassign short_frame =')
        s = s.replace('wire skip_pixel =', 'assign skip_pixel =')
    out = a.out / path.name
    out.write_text(s)
    return out

def extract_module(path, name):
    # Compile exact target modules, avoiding unrelated baseline Mapper15's
    # duplicate ANSI declaration which Gowin tolerates but Icarus rejects.
    text = path.read_text()
    match = re.search(r'\bmodule\s+' + name + r'\s*\(.*?\bendmodule', text, re.S)
    if not match:
        raise RuntimeError(f'Module {name} missing in {path}')
    source = match[0]
    declarations = []
    def hoist(m):
        kind, body = m[1], m[2]
        if kind == 'wire' and '=' in body:
            decl, expression = body.split('=', 1)
            declarations.append(f'wire {decl.strip()};')
            return f'assign {decl.strip().split()[-1]} = {expression};'
        declarations.append(m[0])
        return ''
    # Declaration order only; all continuous RHS and sequential logic unchanged.
    source = re.sub(r'^\s*(wire|reg)\s+([^;]+);', hoist, source, flags=re.M)
    header_end = source.index(');') + 2
    source = source[:header_end] + '\n' + '\n'.join(declarations) + source[header_end:]
    out = a.out / f'{name}.sv'
    out.write_text(source)
    return out

def extract_io_bus(path):
    s = path.read_text()
    if 'module NesCpuBus(' in s:
        return extract_module(path, 'NesCpuBus')
    # Older inline design: supply the surrounding pins while compiling its
    # exact decoder, controller block and bus tail without replacing logic.
    decode = re.search(r'wire apu_cs = [^;]+;', s)[0].replace('wire apu_cs =', 'assign apu_cs =')
    start = s.index('reg [2:0] joy_out;')
    controller = s[start:s.index('/**********************************************************/', start)]
    start = s.rindex('reg [7:0] open_bus_data;')
    tail = s[start:s.index('endmodule', start)]
    tail = 'reg [7:0] raw_data_bus;\n' + tail.replace('reg [7:0] raw_data_bus;', '')
    header = '''module NesCpuBus(
 input wire clk, reset, cpu_ce, odd_or_even, cpu_rnw, mw_int, dma_aout_enable,
 input wire [15:0] cpu_addr, addr,
 input wire [7:0] cpu_dout, dbus, genie_data, apu_dout, ppu_dout, cpumem_din, prg_dout_mapper,
 input wire genie_ovr, ppu_cs, prg_allow, prg_bus_write,
 input wire [4:0] joypad1_data, joypad2_data,
 output wire apu_cs,
 output wire [1:0] joypad_clock,
 output wire [2:0] joypad_out,
 output wire [7:0] from_data_bus, internal_data_bus, dma_data_bus
);
'''
    out = a.out / 'NesCpuBus.sv'
    out.write_text(header + 'wire mr_int = !mw_int;\n' + decode + '\n' + controller + tail +
                   '\nassign internal_data_bus = from_data_bus;\nassign dma_data_bus = from_data_bus;\nendmodule\n')
    return extract_module(out, 'NesCpuBus')

def extract_cpu_bus(path):
    # Compile the exact NES bus-arbitration tail, with its surrounding signals
    # supplied by the bench. No assignment or condition is rewritten.
    s = path.read_text()
    if 'module NesCpuBus(' in s:
        actual = extract_module(path, 'NesCpuBus').read_text()
        wrapper = '''module nes_bus_under_test(
 input wire clk, reset, cpu_ce, mw_int, mr_int,
 input wire [7:0] dbus, genie_data, apu_dout, ppu_dout, cpumem_din, prg_dout_mapper,
 input wire genie_ovr, apu_cs, joypad1_cs, joypad2_cs, ppu_cs, prg_allow, prg_bus_write,
 input wire [4:0] joypad1_data, joypad2_data,
 input wire [15:0] addr,
 output wire [7:0] from_data_bus, cpu_data, dma_data
);
NesCpuBus actual_bus(.clk(clk),.reset(reset),.cpu_ce(cpu_ce),.odd_or_even(1'b0),
 .cpu_rnw(mr_int),.mw_int(mw_int),.dma_aout_enable(1'b0),
 .cpu_addr(apu_cs ? 16'h4015 : addr),.addr(addr),.cpu_dout(dbus),.dbus(dbus),
 .genie_data(genie_data),.apu_dout(apu_dout),.ppu_dout(ppu_dout),.cpumem_din(cpumem_din),
 .prg_dout_mapper(prg_dout_mapper),.genie_ovr(genie_ovr),.ppu_cs(ppu_cs),
 .prg_allow(prg_allow),.prg_bus_write(prg_bus_write),
 .joypad1_data(joypad1_data),.joypad2_data(joypad2_data),
 .from_data_bus(from_data_bus),.internal_data_bus(cpu_data),.dma_data_bus(dma_data));
endmodule
'''
        out = a.out / 'nes_bus_under_test.sv'
        out.write_text(actual + '\n' + wrapper)
        return out
    start = s.rindex('reg [7:0] open_bus_data;')
    tail = s[start:s.index('endmodule', start)]
    # Icarus needs this declaration before its continuous-assignment use.
    tail = 'reg [7:0] raw_data_bus;\n' + tail.replace('reg [7:0] raw_data_bus;', '')
    header = '''module nes_bus_under_test(
 input wire clk, reset, cpu_ce, mw_int, mr_int,
 input wire [7:0] dbus, genie_data, apu_dout, ppu_dout, cpumem_din, prg_dout_mapper,
 input wire genie_ovr, apu_cs, joypad1_cs, joypad2_cs, ppu_cs, prg_allow, prg_bus_write,
 input wire [4:0] joypad1_data, joypad2_data,
 input wire [15:0] addr,
 output wire [7:0] from_data_bus, cpu_data, dma_data
);
'''
    out = a.out / 'nes_bus_under_test.sv'
    out.write_text(header + tail + '\nassign cpu_data = from_data_bus;\nassign dma_data = from_data_bus;\nendmodule\n')
    return out

def extract_boot_loader(path):
    s = path.read_text()
    declarations = s[s.index('reg flash_loaded;'):s.index('// Load 256KB')]
    # The physical SPI reader is replaced by input pins. The actual loader
    # process is compiled verbatim, not an alternate implementation.
    declarations = declarations.replace('wire [7:0] flash_dout;', '').replace('wire flash_out_strb;', '')
    start = s.index('always @(posedge clk)', s.index('// Load 256KB'))
    block = s[start:s.index('// picorv32 softcore', start)]
    out = a.out / 'boot_loader_under_test.sv'
    out.write_text('''module boot_loader_under_test(
 input clk, resetn, ram_busy, input [7:0] flash_dout, input flash_out_strb,
 output loaded, loading, start, write, output [20:0] address,
 output [7:0] data, output [3:0] strobes);
 localparam FIRMWARE_SIZE=256*1024;
 wire flash_spi_hold_n, flash_spi_wp_n;
''' + declarations + block + '''
 assign loaded=flash_loaded; assign loading=flash_loading;
 assign start=flash_start; assign write=flash_wr;
 assign address=flash_addr; assign data=flash_d; assign strobes=flash_wstrb;
 endmodule
''')
    return out

def extract_rv_bridge(path):
    s = path.read_text()
    start = s.index('localparam RV_IDLE_REQ0')
    end = s.index('iosys #(', start)
    mcu_branch = s.find('`ifdef NANOBLAST_BL616', start, end)
    block = s[start:mcu_branch if mcu_branch >= 0 else end]
    out = a.out / 'rv_bridge_under_test.sv'
    out.write_text('''module rv_bridge_under_test(
 input clk, sys_resetn, rv_valid, input [3:0] rv_wstrb,
 input rv_req_ack, input [15:0] rv_dout,
 output reg rv_req, rv_word, rv_ready, output reg [1:0] rv_ds,
 output [31:0] rv_rdata);
 reg rv_valid_r, rv_new_req;
 reg [15:0] rv_dout0;
 assign rv_rdata={rv_dout,rv_dout0};
''' + block + '\nendmodule\n')
    return out

cases = {
 'tmds': [a.rtl/'hdmi2/tmds_channel.sv'],
 'hdmi_reset': [a.rtl/'hdmi2/clock_reset.sv'],
 'hdmi_video': [a.rtl/'hdmi2'/f for f in ['hdmi.sv', 'tmds_channel.sv', 'serializer.sv']],
 'mappers': [extract_module(a.rtl/'mappers/generic.sv', 'Mapper78'),
             extract_module(a.rtl/'mappers/MMC3.sv', 'MMC3')],
 'apu': [compatible(a.rtl/'apu.v')],
 'frame_irq': [compatible(a.rtl/'apu.v')],
 'cpu_bus': [extract_cpu_bus(a.rtl/'nes.v')],
 'open_bus_cpu': [extract_cpu_bus(a.rtl/'nes.v'), *[a.rtl/'t65'/f'T65{suffix}.v' for suffix in ['_Pack','_ALU','_MCode','']]],
 'dma_cancel': [extract_module(a.rtl/'nes.v', 'DmaController'), compatible(a.rtl/'apu.v')],
 'io_bus': [extract_io_bus(a.rtl/'nes.v'), compatible(a.rtl/'apu.v')],
 # Compile the full PPU source so generated RAM declarations retain scope;
 # module-level declaration hoisting is inappropriate inside a RAM bank.
 'oam_write': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'oam_boundary': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'oam_eval': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'boot_reset': [extract_boot_loader(a.rtl/'iosys/iosys.v'), extract_rv_bridge(a.rtl/'nestang_top.sv'),
                a.rtl/'iosys/spiflash.v', a.rtl/'iosys/spi_master.v',
                a.rtl/'nano20k/config.v', a.rtl/'sdram_nes.v'],
 'ppu': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'shifter_hold': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'oam_corruption': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'oam_corruption_frame': [compatible(a.rtl/'ppu.v'), a.rtl/'dpram.v'],
 'cpu': [a.rtl/'t65'/f'T65{suffix}.v' for suffix in ['_Pack','_ALU','_MCode','']],
}
for name, sources in cases.items():
    if a.test and name != a.test:
        continue
    exe = a.out / f'{name}.vvp'
    bench = Path(__file__).parent / f'tb_{name}.sv'
    # Historical SpriteRAM sources lack the corruption/reset input pins.
    # Select the bench's explicit PAL isolation only for the newer API.
    api_defines = ['SPRITERAM_CORRUPTION_PORTS'] if re.search(r'\binput\s+is_pal\b', (a.rtl/'ppu.v').read_text()) else []
    if a.gowin_primitives and name in ['ppu','oam_write','oam_boundary','oam_eval','shifter_hold','oam_corruption','oam_corruption_frame']:
        sources = [*sources, a.gowin_primitives]
        api_defines.append('OAM_USE_GOWIN_DPB')
    commands = [[a.iverilog, '-g2012', *['-D'+d for d in [*a.define,*api_defines]], '-s', f'tb_{name}', '-o', str(exe),
                 *map(str,sources), str(bench)], [a.vvp, str(exe)]]
    with (a.out / f'{name}.log').open('w') as log:
        for cmd in commands:
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            log.write(result.stdout)
            print(result.stdout[-2500:])
            if result.returncode:
                raise SystemExit(result.returncode)
