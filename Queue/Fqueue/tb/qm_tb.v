`timescale 1ns/1ns

module qm_tb;

reg clk;
reg rstn;
reg [3:0] port_id;
reg sof;
reg dv;
reg [7:0] data;
reg data_fifo_rd;
reg ptr_fifo_rd;

wire bp;
wire [7:0] data_fifo_dout;
wire [15:0] ptr_fifo_dout;

//define the clock period

parameter PERIOD=20;

qm qm0(
.clk(clk),
.rstn(rstn),
.port_id(port_id),
.sof(sof),
.dv(dv),
.data(data),
.data_fifo_rd(data_fifo_rd),
.ptr_fifo_rd(ptr_fifo_rd),

.bp(bp),
.data_fifo_dout(data_fifo_dout),
.ptr_fifo_dout(ptr_fifo_dout)
);

always #(PERIOD/2) clk <= ~clk;

initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, qm_tb);     //tb模块名称
end

initial begin
clk = 1'b1;
rstn = 1'b0;
port_id = 4'h1;
sof = 1'b0;
dv = 1'b0;
data = 8'b0;
data_fifo_rd = 1'b0;
ptr_fifo_rd = 1'b0;


#(PERIOD)
rstn = 1'b1;

#(PERIOD*10);
dv = 1'b1;
sof = 1'b1;
data = 8'h01;
#(PERIOD);
sof = 1'b0;
data = 8'h32;
#(PERIOD);
data = 8'h02;
repeat(31) begin
    #(PERIOD);
    data = data + 1;
end
#(PERIOD);
dv = 0;
#(PERIOD*10);
$finish;
end



endmodule