`timescale 1ns / 1ps
module counter_tb;

reg clk;
reg reset;
reg enable;
wire [1:0] counter_out;

counter c1(clk,reset,enable,counter_out);

/*iverilog */
initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, counter_tb);     //tb模块名称
end
/*iverilog */

initial
begin
  clk=0;
  reset=1;
  enable=1;
  clk=1;
  #10
  reset=0;
end

always
#5 clk=~clk;

initial
  #200 $finish;

endmodule

