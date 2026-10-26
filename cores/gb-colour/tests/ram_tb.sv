module ram_tb;
reg clk=0;always #5 clk=~clk;
reg en=0,we=0;reg[7:0]a=0,d=0;wire[7:0]q;
dpram #(.addr_width(8)) dut(.clock_a(clk),.clken_a(en),.address_a(a),.data_a(d),.wren_a(we),.q_a(q));
task tick;begin @(posedge clk);#1;end endtask
initial begin
 @(negedge clk);en=1;we=1;a=17;d=8'hc9;tick();if(q!==8'hc9)$fatal(1,"write through failed");
 @(negedge clk);en=0;we=1;a=18;d=8'ha5;tick();if(q!==8'hc9)$fatal(1,"clock enable hold failed");
 @(negedge clk);en=1;we=0;a=17;tick();if(q!==8'hc9)$fatal(1,"stored byte failed");
 @(negedge clk);we=1;d=8'h3c;tick();if(q!==8'h3c)$fatal(1,"overwrite forwarding failed");
 @(negedge clk);we=0;tick();if(q!==8'h3c)$fatal(1,"overwrite persistence failed");
 $display("PASS RAM write-through, enable hold, overwrite and readback");$finish;
end
endmodule
