`timescale 1ns/1ns

module dpram_sclk_tb2;

reg clk;
reg rst_n;
reg w_en;
reg r_en;
reg [8:0]w_addr;
reg [8:0]r_addr;
reg [15:0]w_data;
wire [15:0]r_data;

//define the clock period

parameter PERIOD=20;

dpram_sclk u0(
.clk(clk),
.rst(rst_n),
.we(w_en),
.re(r_en),
.waddr(w_addr),
.raddr(r_addr),
.din(w_data),
.dout(r_data)
);


//define clock
always #(PERIOD/2) clk <= ~clk;

initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, dpram_sclk_tb2);     //tb模块名称
end

initial begin
w_addr = 9'b0;
r_addr = 9'b0;
w_data = 0;
clk = 1'b1;
rst_n = 1'b1;
w_en = 1'b0;
r_en = 1'b0;
#(PERIOD)
rst_n = 1'b0;

#(PERIOD*10 + PERIOD/2);
w_en = 1;

#(PERIOD);
r_en = 1;

#(PERIOD*150);

#(PERIOD/2)
w_en = 0;
#(PERIOD)
r_en =0;

#(PERIOD*10)
$finish;
end

always @(posedge clk or negedge rst_n)
if(rst_n) begin
    w_data = 0;
    w_addr = 0;
end
else if(w_en) 
begin
	w_data = w_data + 1;
    w_addr = w_addr + 1;
end


always @(posedge clk or negedge rst_n)
if(rst_n) begin
    r_addr = 0;
end
else if(r_en) 
begin
	r_addr = r_addr + 1;
end
endmodule