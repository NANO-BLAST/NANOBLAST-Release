"""Execute the exact distributable SMS diagnostic on the real Z80/VDP core."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[1];work=root.parent;port=work/'smstang/nanoblast';out=work.parent/'outputs/sms-integration-fixes'
rom=(out/'NANOBLAST-Test.sms').read_bytes();(out/'diagnostic.hex').write_text('\n'.join('%02x'%b for b in rom)+'\n')
s=(port/'tests/core_tb.sv').read_text().split('integer i;')[0].replace('module core_tb;','module diagnostic_tb;').replace('joy1=12\'h011','joy1=0').replace('rom[0:65535]','rom[0:8191]').replace('rom_addr[15:0]','rom_addr[12:0]')
s+='''
reg[11:0]background=0;
always @(posedge clk)if(dut.sms.vdp_inst.cram_cpu_WE&&dut.sms.vdp_inst.cram_vdp_A_in==0)
 background<=dut.sms.vdp_inst.cram_vdp_D_in;
initial begin
 $readmemh("ROM_PATH",rom);
 repeat(10)@(negedge clk);resetn=1;
 wait(dut.sms.vdp_inst.display_on);
 assert(dut.sms.vdp_inst.vdp_vram_inst.mem[16'h38e8]==8'h4e)else $fatal(1,"Diagnostic title did not reach name table");
 wait(background==12'h00f);
 @(negedge clk);joy1=12'h010;
 wait(background!=12'h00f);
 @(negedge clk);joy1=0;
 wait(background==12'h00f);
 @(negedge clk);joy1=12'h008;
 wait(dut.ram_we&&dut.ram_addr[12:0]==0&&dut.ram_data==8'h30);
 @(negedge clk);joy1=0;
 wait(background==12'hf0f);
 $display("PASS exact 8KiB diagnostic: Z80 initializes screen/title, controller changes palette, START NMI changes background");$finish;
end
initial begin #1000000000;$fatal(1,"Diagnostic timeout PC=%h bg=%h",dut.sms.z80_inst.A,background);end
endmodule
'''.replace('ROM_PATH',str((out/'diagnostic.hex').resolve()))
# Title row3, centered17characters -> column7; second character A follows N.
s=s.replace("16'h38e8","16'h38ce")
(out/'diagnostic_tb.sv').write_text(s)
sources=[str((work/'sms-vhdl'/p).resolve()) for p in (work/'sms-core.f').read_text().splitlines() if p.strip()]
files=[work/'sms-vhdl/opll.v',*sources,port/'rtl/sms_nano_raster.v',port/'rtl/sms_nano_core.sv',out/'diagnostic_tb.sv']
log=(out/'diagnostic-simulation.log').open('w');mdir=out/'verilator-diagnostic'
subprocess.run([str(work/'oss-cad-suite/bin/verilator'),'--binary','--assert','--timing','-Wno-fatal','-j','4','--top-module','diagnostic_tb','--Mdir',str(mdir.resolve()),'-o','diagnostic_tb',*map(lambda p:str(Path(p).resolve()),files)],cwd=work/'smstang/src',stdout=log,stderr=subprocess.STDOUT,check=True)
subprocess.run([str((mdir/'diagnostic_tb').resolve())],cwd=work/'smstang/src',stdout=log,stderr=subprocess.STDOUT,check=True)
print('PASS exact distributable SMS diagnostic on real engine; see diagnostic-simulation.log')
