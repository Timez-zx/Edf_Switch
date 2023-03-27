`timescale 1ns/1ns

module dpram_aclk_tb;

reg wr_clk;
reg rd_clk;
reg rst_n;
reg w_en;
reg r_en;
reg [8:0]w_addr;
reg [8:0]r_addr;
reg [15:0]w_data;
wire [15:0]r_data;

//define the clock PERIOD_WR

parameter PERIOD_WR=20;
parameter PERIOD_RD=20;

dpram_aclk #(
    .ADDR_WIDTH(9),
    .DATA_WIDTH(16)
)
u0(
.wr_clk(wr_clk),
.rd_clk(rd_clk),
.rst(rst_n),
.we(w_en),
.re(r_en),
.waddr(w_addr),
.raddr(r_addr),
.din(w_data),
.dout(r_data)
);


//define clock
always #(PERIOD_WR/2) wr_clk = ~wr_clk;
always #(PERIOD_RD/2) rd_clk = ~rd_clk;

initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, dpram_aclk_tb);     //tb模块名称
end

initial begin
w_addr = 9'b0;
r_addr = 9'b0;
w_data = 0;
wr_clk = 1'b1;
rd_clk = 1'b0;
rst_n = 1'b1;
w_en = 1'b0;
r_en = 1'b0;
#(PERIOD_WR)
rst_n = 1'b0;

#(PERIOD_WR*10 + PERIOD_WR/2);
w_en = 1;

#(PERIOD_WR/2);
r_en = 1;
#(PERIOD_WR/2);

#(PERIOD_WR*150);

#(PERIOD_WR/2)
w_en = 0;
#(PERIOD_WR/2)
r_en =0;

#(PERIOD_WR*10)
$finish;
end

always @(posedge wr_clk or negedge rst_n)
if(rst_n) begin
    w_data <= 0;
    w_addr <= 0;
end
else if(w_en) 
begin
	w_data <= w_data + 1;
    w_addr <= w_addr + 1;
end


always @(posedge rd_clk or negedge rst_n)
if(rst_n) begin
    r_addr <= 0;
end
else if(r_en) 
begin
	r_addr <= r_addr + 1;
end
endmodule