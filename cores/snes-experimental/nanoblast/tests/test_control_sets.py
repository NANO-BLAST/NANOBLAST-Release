from pathlib import Path
import importlib.util,subprocess
base=Path(__file__).resolve().parents[4];port=base/'work/snestang';out=base/'outputs/snes-nano-integration'
spec=importlib.util.spec_from_file_location('relax',port/'nanoblast/relax_control_sets.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
s='''`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg d=0,ce=0,rst=0;wire q0,q1,mux0,q2,q3,mux1;
DFFE ref0(.Q(q0),.D(d),.CLK(clk),.CE(ce));
DFFRE ref1(.Q(q2),.D(d),.CLK(clk),.CE(ce),.RESET(rst));
LUT3 #(.INIT(8'bTABLE3)) l0(.I0(d),.I1(ce),.I2(q1),.F(mux0));
LUT4 #(.INIT(16'bTABLE4)) l1(.I0(d),.I1(ce),.I2(q3),.I3(rst),.F(mux1));
DFF actual0(.Q(q1),.D(mux0),.CLK(clk));
DFF actual1(.Q(q3),.D(mux1),.CLK(clk));
integer n;
initial begin
 #1;assert(q0===q1&&q2===q3)else $fatal(1,"INIT changed");
 for(n=0;n<4096;n=n+1)begin
  @(negedge clk);d=n[1]^n[3];ce=n[0]^n[2];rst=n[4];
  @(posedge clk);#1;assert(q0===q1&&q2===q3)else $fatal(1,"Native FF conversion changed enable/reset priority");
 end
 $display("PASS control-set relaxation against Gowin primitive models: INIT, hold, data and synchronous reset priority");$finish;
end
endmodule
'''.replace('TABLE3',module.table(False)).replace('TABLE4',module.table(True))
(out/'control-set-test.sv').write_text(s)
subprocess.run([str(base/'work/oss-cad-suite/bin/iverilog'),'-g2012','-s','tb','-o',str(out/'control-set-test.vvp'),str(base/'work/oss-cad-suite/share/yosys/gowin/cells_sim.v'),str(out/'control-set-test.sv')],check=True)
subprocess.run([str(base/'work/oss-cad-suite/bin/vvp'),str(out/'control-set-test.vvp')],check=True)
