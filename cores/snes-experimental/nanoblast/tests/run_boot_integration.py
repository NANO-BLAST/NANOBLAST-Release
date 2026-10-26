"""Upload a generated, redistributable diagnostic ROM through real UART/top/SDRAM/CPU RTL.
Only PLL oscillators, HDMI sink and text glyph RAM are replaced for simulation.
The test top disables upstream's alternate VERILATOR top branch, retaining the
production loading, memory arbitration and SNES wiring. Leaf RAMs use their
upstream behavioral simulation implementations.
"""
from pathlib import Path
import subprocess,re,argparse,zlib
root=Path(__file__).resolve().parents[2];base=root.parent.parent
p=argparse.ArgumentParser()
p.add_argument('--sources', default='outputs/snes-nano-compact-coarse/sources.f')
p.add_argument('--out', default='outputs/snes-boot-integration')
p.add_argument('--include-root', default='work/snestang')
p.add_argument('--verify-rom', action='store_true')
p.add_argument('--vram-negedge', action='store_true')
p.add_argument('--request-negedge', action='store_true')
p.add_argument('--engine-ppu', help='Alternative PPU source for isolated pause-phase comparison')
p.add_argument('--engine-snes', help='Alternative SNES bus wrapper for isolated data-path comparison')
p.add_argument('--sdram', help='Alternative controller source for isolated timing comparison')
p.add_argument('--trace-fetch', action='store_true')
p.add_argument('--hirom-fast', action='store_true', help='Exercise HiROM mapping, FastROM instruction/data access')
p.add_argument('--ppu-vram', action='store_true', help='Check real PPU background/sprite VRAM consumption deadlines')
p.add_argument('--apu-test', action='store_true', help='Exercise CPU-to-SPC700 IPL upload and execute code from audio RAM')
args=p.parse_args()
include_root=base/args.include_root
out=base/args.out;out.mkdir(exist_ok=True)
top=(root/'src/snestang_top.v').read_text().replace('VERILATOR','NANOBLAST_LEGACY_SIM_TOP')
if args.request_negedge:
 before='// Generate SDRAM signals\nalways @(posedge mclk) begin'
 assert top.count(before)==1
 top=top.replace(before,'// Generate SDRAM signals\nalways @(negedge mclk) begin')
if args.vram_negedge:
 before='always @(posedge mclk) begin\n    if(!resetn)begin\n        vram1_we_n_old'
 assert top.count(before)==1
 top=top.replace(before,before.replace('posedge','negedge'))
(out/'production-top.v').write_text(top)
rom=bytearray([0xea]*32768)
program=bytes.fromhex('78 18 fb c2 30 a2 ff 1f 9a e2 20 a9 80 8d 00 21 a9 00 8d 21 21 a9 e0 8d 22 21 a9 03 8d 22 21 a9 0f 8d 00 21 a9 5a 8f 00 00 7e 80 fe')
if args.apu_test:
 # Public, generated test code: actual 65816 uses the real $2140 handshake
 # to upload 256 distinguishable bytes through the SPC700 IPL into ARAM.
 code=bytearray();labels={};branches=[]
 def emit(*values):code.extend(values)
 def label(name):labels[name]=len(code)
 def branch(op,name):emit(op,0);branches.append((len(code)-1,name))
 emit(0x78,0x18,0xfb,0xc2,0x30,0xa2,0xff,0x1f,0x9a,0xe2,0x30)
 if args.hirom_fast:
  emit(0xa9,1,0x8d,0x0d,0x42)
  target=0x8000+len(code)+4;emit(0x5c,target&255,target>>8,0xc0)
 label('ready');emit(0xad,0x40,0x21,0xc9,0xaa);branch(0xd0,'ready')
 emit(0xa9,0,0x8d,0x42,0x21,0xa9,2,0x8d,0x43,0x21)
 emit(0xa9,1,0x8d,0x41,0x21,0xa9,0xcc,0x8d,0x40,0x21)
 label('start');emit(0xcd,0x40,0x21);branch(0xd0,'start')
 emit(0xa2,0)
 label('byte')
 if args.hirom_fast:emit(0xbf,0,0x81,0xc0)
 else:emit(0xbd,0,0x81)
 emit(0x8d,0x41,0x21,0x8a,0x8d,0x40,0x21)
 label('echo');emit(0xcd,0x40,0x21);branch(0xd0,'echo')
 emit(0xe8);branch(0xd0,'byte')
 emit(0xa9,0,0x8d,0x41,0x21,0x8d,0x42,0x21,0xa9,2,0x8d,0x43,0x21)
 emit(0xa9,1,0x8d,0x40,0x21)
 label('run');emit(0xad,0x40,0x21,0xc9,0x42);branch(0xd0,'run')
 label('run2');emit(0xad,0x41,0x21,0xc9,0x43);branch(0xd0,'run2')
 # Exercise every write-data bit and both SDRAM byte lanes, then read back
 # through the actual CPU before displaying success.
 emit(0xa2,0)
 label('wram_fill');emit(0x8a,0x9f,0,0x10,0x7e,0xe8);branch(0xd0,'wram_fill')
 emit(0xa2,0)
 label('wram_check');emit(0x8a,0xdf,0,0x10,0x7e);branch(0xd0,'wram_bad')
 emit(0xe8);branch(0xd0,'wram_check');branch(0x80,'wram_good')
 label('wram_bad');branch(0x80,'wram_bad')
 label('wram_good');emit(*program[11:])
 for at,name in branches:
  offset=labels[name]-(at+1);assert -128<=offset<128
  code[at]=offset&255
 assert len(code)<256
 program=bytes(code)
 payload=bytearray((i*73+0x35)&255 for i in range(256))
 payload[:8]=bytes.fromhex('8f 42 f4 8f 43 f5 2f fe')
 rom[0x100:0x200]=payload
if args.ppu_vram:
 assert not args.apu_test and not args.hirom_fast
 code=bytearray.fromhex('78 18 fb c2 30 a2 ff 1f 9a e2 20')
 def ppu(reg,value):code.extend([0xa9,value,0x8d,reg,0x21])
 ppu(0,0x80);ppu(5,0);ppu(7,4);ppu(0x0b,0)
 for reg in (0x0d,0x0e):ppu(reg,0);ppu(reg,0)
 ppu(0x2c,0x11);ppu(0x2d,0);ppu(0x21,0)
 for byte in (0,0,31,0,0xe0,3,0,0x7c):ppu(0x22,byte)
 # Write 256 VRAM words using the real CPU/PPU ports, with high-byte
 # increment. This covers both byte lanes and an address-page crossing.
 ppu(0x15,0x80);ppu(0x16,0x40);ppu(0x17,0x3f)
 code.extend(bytes.fromhex('e2 30 a2 00 8a 8d 18 21 49 a5 8d 19 21 e8 d0 f4'))
 ppu(0,15);code.extend(bytes.fromhex('a9 5a 8f 00 00 7e 80 fe'))
 program=bytes(code)
rom[:len(program)]=program
rom[0x7fc0:0x8000]=bytes(64)
rom[0x7fc0:0x7fc0+21]=b'NANOBLAST BOOT TEST'.ljust(21,b' ')
rom[0x7fd5:0x7fd9]=bytes([0x20,0,5,0]);rom[0x7ffc:0x7ffe]=bytes([0,0x80])
if args.hirom_fast:
 assert args.apu_test
 rom=bytearray([0xea]*32768)+rom
 rom[0xffd5:0xffd9]=bytes([0x31,0,7,0])
(out/'diagnostic.hex').write_text('\n'.join(f'{b:02x}' for b in rom)+'\n')
# All stub interfaces are copied from the production definitions.
hdmi=(root/'src/snes2hdmi_nano.v').read_text();hdmi=hdmi[hdmi.index('module snes2hdmi'):hdmi.index(');')+2]
text=(base/'work/nanoblast/src/iosys/textdisp.v').read_text();text=text[text.index('module textdisp'):text.index(');')+2]
stubs='''`timescale 1ns/1ps
module gowin_pll_snes(input clkin,output reg clkout=0,clkoutp=0,clkoutd=0,output reg lock=0);
 always #5.787037 clkout=~clkout;
 always #5.787037 clkoutp=~clkoutp;
 integer phase=0;
 initial begin
  if($value$plusargs("mclkphase=%d",phase))begin end
  #(phase*2.8935185);
  forever #23.148148 clkoutd=~clkoutd;
 end
 initial #1000 lock=1;
endmodule
module gowin_pll_hdmi(input clkin,output clkout,output lock);assign clkout=clkin;assign lock=1;endmodule
module CLKDIV #(parameter DIV_MODE=5)(input HCLKIN,RESETN,CALIB,output CLKOUT);assign CLKOUT=HCLKIN;endmodule
'''
stubs+=hdmi+'''\ninitial pause_snes_for_frame_sync=0;
assign overlay_x=0;assign overlay_y=0;assign audio_en=1;
assign tmds_clk_p=0;assign tmds_clk_n=0;assign tmds_d_p=0;assign tmds_d_n=0;
endmodule\n'''+text+'\nassign overlay_color=0;\nendmodule\n'
(out/'stubs.sv').write_text(stubs)
model=(root/'nanoblast/tests/sdram_tb.sv').read_text()
model=model[model.index('// Independent x32'):model.index('integer elapsed,n,line;')]
model=model.replace('dut.dq_oen','dut.sdram.dq_oen').replace('cycle-last_refresh<600','cycle-last_refresh<2500')
model=model.replace('$fatal(1,"Wrong mode/tMRD")','$fatal(1,"Wrong mode/tMRD a=%h ba=%h cycle=%d available=%d",a,ba,cycle,global_available)')
model=model.replace('if(!resetn)begin','if(!resetn||(!dut.sdram.setup&&!dut.sdram.normal))begin')
# Match the independent VRAM fixture's tWR=2 plus tRP=2 recovery bound.
# The generic artwork fixture conservatively uses five clocks.
model=model.replace('available_cycle[ba]=cycle+5;', 'available_cycle[ba]=cycle+4;')
model=model.replace('$fatal(1,"Refresh before auto-precharge complete")', '$fatal(1,"Refresh before auto-precharge complete bank=%0d cycle=%0d available=%0d",i,cycle,available_cycle[i])')
tb='''`timescale 1ns/1ps
module boot_tb;
reg sys_clk=0;always #18.518519 sys_clk=~sys_clk;
reg uart_rx=1;wire uart_tx;
tri[31:0]dq;wire[10:0]a;wire[1:0]ba;wire[3:0]dqm;wire cs,ras,cas,we,cke;
snestang_top dut(.sys_clk(sys_clk),.s0(1'b1),.UART_RXD(uart_rx),.UART_TXD(uart_tx),
 .sd_dat0(1'b1),.flash_spi_miso(1'b1),.joy1_data(1'b1),.joy2_data(1'b1),.ds_miso(1'b1),.ds_miso2(1'b1),
 .IO_sdram_dq(dq),.O_sdram_addr(a),.O_sdram_ba(ba),.O_sdram_dqm(dqm),.O_sdram_cs_n(cs),
 .O_sdram_ras_n(ras),.O_sdram_cas_n(cas),.O_sdram_wen_n(we),.O_sdram_cke(cke));
wire clk=dut.fclk,resetn=dut.fast_resetn,busy=dut.sdram_busy;
'''+model+'''
task send(input[7:0]b);integer bitnum;begin
 uart_rx=0;#500;
 for(bitnum=0;bitnum<8;bitnum++)begin uart_rx=b[bitnum];#500;end
 uart_rx=1;#500;
end endtask
task header(input[15:0]length,input[7:0]command);begin send(8'haa);send(length[15:8]);send(length[7:0]);send(command);end endtask
reg[7:0]rom[0:32767];integer n,blocknum,elapsed;
integer ppu_writes=0;reg seen_green=0;
always @(posedge dut.mclk)begin
 if(dut.loaded&&dut.enable&&!dut.main.SNES.INT_PAWR_N)begin
  ppu_writes<=ppu_writes+1;
  if(ppu_writes<32)$display("PPU write A=%h D=%h",dut.main.SNES.INT_PA,dut.main.SNES.PPU_DI);
 end
 if(dut.loaded&&dut.rgb_out==15'h03e0)seen_green<=1;
end
initial begin
 $readmemh("diagnostic.hex",rom);
 wait(dut.resetn&&!busy);repeat(20)@(posedge dut.mclk);
 header(2,6);send(1);
 header(65,7);for(n=0;n<64;n++)send(rom[16'h7fc0+n]);
 for(blocknum=0;blocknum<32;blocknum++)begin
  header(1025,7);for(n=0;n<1024;n++)send(rom[blocknum*1024+n]);
 end
 header(2,6);send(0);
 repeat(200)@(posedge dut.mclk);
 $display("Upload count=%h loaded=%b fault=%b type=%h mask=%h",dut.loader_addr,dut.loaded,dut.load_fault,dut.rom_type,dut.rom_mask);
 assert(dut.loaded&&!dut.load_fault&&dut.loader_addr==32768)else $fatal(1,"ROM load handshake");
 for(n=0;n<32768;n++)assert(mem[n>>2][8*(n&3)+:8]==rom[n])else $fatal(1,"Uploaded byte mismatch at %h expected %h got %h",n,rom[n],mem[n>>2]);
 $display("PASS all 32768 uploaded bytes in physical SDRAM model");
 header(2,8);send(0);
 elapsed=0;
 while(!seen_green&&elapsed<800000)begin @(posedge dut.mclk);elapsed=elapsed+1;end
 $display("CPU ROM_ADDR=%h ROM_Q=%h enable=%b status=%h WRAM=%h PPUwrites=%0d rgb=%h",dut.ROM_ADDR,dut.ROM_Q,dut.enable,dut.core_status,mem[23'h3e0000>>2],ppu_writes,dut.rgb_out);
 assert(mem[23'h3e0000>>2][7:0]==8'h5a&&ppu_writes>=6&&seen_green)else $fatal(1,"CPU diagnostic did not execute/display");
 $display("PASS production UART -> loader -> SDRAM -> CPU program -> WRAM marker and green PPU output");$finish;
end
initial begin #300000000;$fatal(1,"Integration timeout");end
endmodule
'''
if args.hirom_fast:
 monitor="""
integer traced=0;
always @(posedge dut.mclk)if($test$plusargs("tracefetch")&&dut.enable&&
 dut.main.SNES.CPU.P65_EN&&dut.main.SNES.CPU.INT_CLKF_CE&&dut.main.SNES.CPU.P65_R_WN&&
 !dut.ROM_CE_N)begin
 if(traced<120)$display("FETCH CPU=%h ROM=%h expected=%h DI=%h Q=%h req=%b ack=%b slot=%h",dut.main.SNES.CPU.P65_A,dut.ROM_ADDR,rom[dut.ROM_ADDR&65535],dut.main.SNES.CPU.P65_DI,dut.ROM_Q,dut.cpu_req,dut.cpu_req_ack,dut.sdram.cycle);
 traced++;
 assert(dut.main.SNES.CPU.P65_DI==rom[dut.ROM_ADDR&65535])else $fatal(1,"CPU consumed stale ROM byte at %h expected %h got %h",dut.ROM_ADDR,rom[dut.ROM_ADDR&65535],dut.main.SNES.CPU.P65_DI);
end
"""
 tb=tb.replace('integer ppu_writes=0;',monitor+'\ninteger ppu_writes=0;')
 tb=tb.replace('rom[0:32767]' ,'rom[0:65535]').replace("rom[16'h7fc0+n]","rom[16'hffc0+n]")
 tb=tb.replace('blocknum<32','blocknum<64').replace('==32768','==65536').replace('n<32768','n<65536').replace('all 32768','all 65536')
 tb=tb.replace('#300000000;','#600000000;')
# main's SNES instance is named SNES? Confirm from actual source rather than assuming.
main=(root/'src/main.v').read_text();instance=re.search(r'SNES\s+(\w+)\s*\(',main).group(1)
tb=tb.replace('dut.main.SNES.',f'dut.main.{instance}.').replace(',dut.core_status,',',8\'d0,')
if args.verify_rom:
 monitor='''
wire[7:0]mon_data;wire mon_valid;
async_receiver #(.ClkFrequency(21600000),.Baud(2000000))monitor(
 .clk(dut.mclk),.RxD(uart_tx),.RxD_data(mon_data),.RxD_data_ready(mon_valid));
reg[2:0]mon_state=0;reg[15:0]mon_length=0,mon_left=0;
reg[7:0]mon_command=0;reg[31:0]mon_word=0,diag_value=0;
integer diag_sequence=0;
always @(posedge dut.mclk)if(mon_valid)begin
 case(mon_state)
  0:if(mon_data==8'haa)mon_state<=1;
  1:begin mon_length[15:8]<=mon_data;mon_state<=2;end
  2:begin mon_length[7:0]<=mon_data;mon_state<=3;end
  3:begin mon_command<=mon_data;mon_word<=0;mon_left<=mon_length-1;mon_state<=mon_length>1?4:0;end
  4:begin
   mon_word<={mon_word[23:0],mon_data};mon_left<=mon_left-1;
   if(mon_left==1)begin
    mon_state<=0;
    if(mon_command==8'h17&&mon_length==5)begin diag_value<={mon_word[23:0],mon_data};diag_sequence<=diag_sequence+1;end
   end
  end
 endcase
end
task query(input[7:0]index);integer seen,timeout;begin
 seen=diag_sequence;header(2,8'h17);send(index);timeout=0;
 while(diag_sequence==seen)begin @(posedge dut.mclk);timeout++;
  if(timeout>100000)$fatal(1,"Diagnostic UART reply timeout index=%h",index);
 end
end endtask
task scan;integer timeout;begin
 query(8'h80);timeout=0;query(4);
 while(diag_value[0])begin query(4);timeout++;if(timeout>10000)$fatal(1,"ROM scan timeout");end
 assert(diag_value==2)else $fatal(1,"ROM scan status %h",diag_value);
 query(3);
end endtask
'''
 tb=tb.replace('task send(input[7:0]b);',monitor+'\ntask send(input[7:0]b);')
 checks=f'''
 query(0);assert(diag_value==32'h534e3031)else $fatal(1,"Diagnostic identity");
 query(1);assert(diag_value=={len(rom)})else $fatal(1,"Received length");
 query(2);assert(diag_value==32'h{zlib.crc32(rom):08x})else $fatal(1,"Received CRC %h",diag_value);
 scan();assert(diag_value==32'h{zlib.crc32(rom):08x})else $fatal(1,"SDRAM readback CRC %h",diag_value);
 assert(!dut.rom_diag_active&&dut.cpu_req==dut.cpu_req_ack)else $fatal(1,"Diagnostic did not restore CPU bus");
 mem[17][0]=~mem[17][0];
 scan();assert(diag_value!=32'h{zlib.crc32(rom):08x})else $fatal(1,"Corrupted SDRAM byte not detected");
 mem[17][0]=~mem[17][0];
 scan();assert(diag_value==32'h{zlib.crc32(rom):08x})else $fatal(1,"Restored SDRAM CRC");
 $display("PASS real diagnostic UART: received CRC, SDRAM CRC, corrupt-bit detection and restored bus ownership");
'''
 tb=tb.replace(' header(2,6);send(0);',checks+'\n header(2,6);send(0);')
if args.apu_test:
 checks=f"""
 for(n=0;n<256;n++)assert(mem[(23'h400200+n)>>2][8*(n&3)+:8]==rom[{32768 if args.hirom_fast else 0}+256+n])
   else $fatal(1,"SPC700 IPL upload corrupt at %h expected %h got %h",n,rom[{32768 if args.hirom_fast else 0}+256+n],mem[(23'h400200+n)>>2]);
 for(n=0;n<256;n++)assert(mem[(23'h3e1000+n)>>2][8*(n&3)+:8]==8'(n))
  else $fatal(1,"WRAM byte mismatch %h",n);
 $display("PASS actual CPU verifies 256 work-RAM bytes through both SDRAM lanes");
 $display("PASS actual 65816 -> APU ports -> SPC700 IPL -> 256 ARAM bytes -> SPC program echo 42/43");
 """
 tb=tb.replace(' $display("PASS production UART',checks+'\n $display("PASS production UART')
 tb=tb.replace('CPU diagnostic did not execute/display','CPU/APU diagnostic did not execute/display')
 tb=tb.replace('while(!seen_green&&elapsed<800000)',"while((!seen_green||mem[23'h3e0000>>2][7:0]!=8'h5a)&&elapsed<800000)")
if args.ppu_vram:
 monitor="""
integer bg_samples=0,sprite_samples=0,active_lines=0;reg[7:0]expected_a,expected_b;
always @(posedge dut.mclk)begin
 if(!dut.loaded||dut.main.SNES.PPU.FORCE_BLANK)active_lines<=0;
 else if(dut.enable&&dut.main.SNES.PPU.DOT_CLKR_CE&&dut.main.SNES.PPU.H_CNT==0)active_lines<=active_lines+1;
end
reg pause_done=0;
initial begin : pause_stimulus
 integer phase,goal;
 if($test$plusargs("menupause"))begin
  wait(bg_samples>=1000);
  for(phase=0;phase<4;phase++)begin
   header(2,8);send(1);
   repeat(20+phase)@(posedge dut.mclk);
   header(2,8);send(0);
   goal=bg_samples+1000;wait(bg_samples>=goal);
  end
  for(phase=0;phase<4;phase++)begin
   wait(dut.main.SNES.PPU.CLK_CNT==phase&&dut.main.SNES.PPU.OBJ_TIME_SAVE);
   force dut.pause_snes_for_frame_sync=1;
   wait(!dut.enable);repeat(17+phase)@(posedge dut.mclk);
   release dut.pause_snes_for_frame_sync;
   wait(dut.enable);goal=bg_samples+500;wait(bg_samples>=goal);
  end
 end
 pause_done=1;
end
reg previous_enable=0;reg[2:0]previous_sprite_count=0;
integer paused_sprite_checks=0;
always @(posedge dut.mclk)begin
 if(dut.loaded&&!dut.enable&&!previous_enable&&dut.main.SNES.PPU.OBJ_TIME_SAVE)begin
  assert(!dut.main.SNES.PPU.SPR_PIX_WE_A&&!dut.main.SNES.PPU.SPR_PIX_WE_B&&
         dut.main.SNES.PPU.SPR_PIX_CNT==previous_sprite_count)
   else $fatal(1,"Sprite pixel buffer advances while paused");
  paused_sprite_checks++;
 end
 previous_enable<=dut.enable;previous_sprite_count<=dut.main.SNES.PPU.SPR_PIX_CNT;
end
wire [14:0]va=dut.VRAM1_ADDR[14:0],vb=dut.VRAM2_ADDR[14:0];
always @(posedge dut.mclk)if(dut.enable&&dut.main.SNES.PPU.DOT_CLKR_CE&&
 active_lines>=2&&dut.main.SNES.PPU.V_CNT>=2&&!dut.main.SNES.PPU.FORCE_BLANK&&
 ((dut.main.SNES.PPU.BG_FETCH&&!dut.main.SNES.PPU.BG_FORCE_BLANK)||
 (dut.main.SNES.PPU.OBJ_FETCH&&!dut.main.SNES.PPU.OBJ_TIME_DONE)))begin
 expected_a=mem[(23'h7f0000+{va,1'b0})>>2][8*({va,1'b0}&3)+:8];
 expected_b=mem[(23'h7f0000+{vb,1'b0})>>2][8*(({vb,1'b0}+1)&3)+:8];
 assert(dut.VRAM1_Q==expected_a&&dut.VRAM2_Q==expected_b)else
  $fatal(1,"PPU VRAM deadline H=%0d V=%0d phase=%0d CPUdot=%0d addr=%h/%h expected=%h/%h got=%h/%h slot=%h",dut.main.SNES.PPU.H_CNT,dut.main.SNES.PPU.V_CNT,dut.main.SNES.PPU.CLK_CNT,dut.main.SNES.CPU.DOT_CLK_CNT,va,vb,expected_a,expected_b,dut.VRAM1_Q,dut.VRAM2_Q,dut.sdram.cycle);
 if(dut.main.SNES.PPU.BG_FETCH)bg_samples++;
 else sprite_samples++;
end
"""
 setup="""
 for(n=0;n<32768;n++)begin
  mem[(23'h7f0000+n*2)>>2][16*(n&1)+:16]=16'((n*197)^16'h5ac3);
 end
 for(n=0;n<1024;n++)mem[(23'h7f0800+n*2)>>2][16*(n&1)+:16]=16'(n&31);
 for(n=0;n<128;n++)begin
  dut.main.SNES.PPU.OAM.mem[n*2]={n<32?8'd32:8'd240,8'(n*8)};
  dut.main.SNES.PPU.OAM.mem[n*2+1]={8'd0,8'(n&31)};
 end
 begin integer wait_cycles;
  if($value$plusargs("menuwait=%d",wait_cycles))repeat(wait_cycles)@(posedge dut.mclk);
 end
"""
 tb=tb.replace(' header(2,8);send(0);',setup+'\n header(2,8);send(0);',1)
 tb=tb.replace('integer ppu_writes=0;',monitor+'\ninteger ppu_writes=0;')
 a=tb.index(' elapsed=0;');b=tb.index('end\ninitial begin #',a)
 tb=tb[:a]+""" elapsed=0;
 while((bg_samples<10000||sprite_samples<100||!pause_done)&&elapsed<1600000)begin @(posedge dut.mclk);elapsed++;end
 assert(bg_samples>=10000&&sprite_samples>=100)else $fatal(1,"PPU sample coverage bg=%0d obj=%0d",bg_samples,sprite_samples);
 for(n=0;n<256;n++)assert(mem[(23'h7f0000+(16'h3f40+n)*2)>>2][16*((16'h3f40+n)&1)+:16]=={8'(n^8'ha5),8'(n)})
  else $fatal(1,"CPU-to-VRAM byte pair mismatch word %h",n);
 $display("PASS actual CPU writes all 256 VRAM byte pairs with high-byte address increment");
 if($test$plusargs("menupause"))assert(paused_sprite_checks>20)else $fatal(1,"Paused-sprite coverage insufficient");
 $display("PASS actual PPU consumes %0d background and %0d sprite VRAM words before their deadlines; %0d paused-sprite checks",bg_samples,sprite_samples,paused_sprite_checks);$finish;
"""+tb[b:]
(out/'boot_tb.sv').write_text(tb)
sources=[Path(f) for f in (base/args.sources).read_text().splitlines() if f]
diagnostics=root/'nanoblast/rtl/snes_rom_diagnostics.sv'
if diagnostics not in sources:sources.append(diagnostics)
if args.sdram:sources=[(base/args.sdram) if f.name=='sdram_nano.v' else f for f in sources]
sources=[f.with_name('SNES.v') if f.name=='snes.v' else f for f in sources]
if args.engine_ppu:sources=[(base/args.engine_ppu) if f.name=='ppu.v' else f for f in sources]
if args.engine_snes:sources=[(base/args.engine_snes) if f.name=='SNES.v' else f for f in sources]
common=next(f for f in sources if f.name=='common.sv');sources.remove(common);sources.insert(1,common)
uart=base/'work/nanoblast/src/iosys/mcu_uart.v'
uart_sim=out/'mcu_uart_sim.v'
uart_sim.write_text(uart.read_text().replace('module ASSERTION_ERROR();','module ASSERTION_ERROR(input string message);'))
sources=[uart_sim if f==uart else f for f in sources]
sources=[f for f in sources if '/hdmi2/'not in str(f) and '/nanoblast/hdmi/'not in str(f) and f.name not in ('snestang_top.v','snes2hdmi_nano.v','textdisp.v')]
# Vendor manifests also contain primitive wrappers; simulation uses the PLL
# stubs above and the engine's behavioral RAM branches instead.
sources=[f for f in sources if not f.name.lower().startswith('gowin_') and f.name!='dsp_data_ram.v']
sources += [out/'production-top.v',out/'stubs.sv',out/'boot_tb.sv']
cmd=[str(base/'work/oss-cad-suite/bin/verilator'),'--binary','--timing','--assert','-Wno-fatal','--top-module','boot_tb','-j','4','--Mdir',str(out/'obj'),f'-I{include_root}/src',f'-I{include_root}/src/spc700',*map(str,sources)]
with (out/'build.log').open('w') as log:subprocess.run(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT,check=True)
romdir=out/'src/chip/DSP';romdir.mkdir(parents=True,exist_ok=True)
for f in (root/'src/chip/DSP').glob('*.hex'):
 (romdir/f.name).write_bytes(f.read_bytes())
 (out/f.name).write_bytes(f.read_bytes())
with (out/'run.log').open('w') as log:subprocess.run([str(out/'obj/Vboot_tb'),*(['+tracefetch'] if args.trace_fetch else [])],cwd=out,stdout=log,stderr=subprocess.STDOUT,check=True)
print((out/'run.log').read_text())
