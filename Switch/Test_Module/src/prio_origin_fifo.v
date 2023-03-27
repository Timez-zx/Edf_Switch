

module prio_origin_fifo
(
    clk,
    rst,
    re,
    we,
    din,
    dout,
    valid,
    empty,
    full
);

/*
 Ports
 */
input                           clk;
input                           rst;
input                           re;
input                           we;
input [20:0]          din;
output [20:0]         dout;
output                          valid;  
output                          empty;
output                          full;

reg                                  flag=0;
reg       [2:0]                      cnt=0;
reg                                    valid0=0;

assign valid = valid0;
always@(posedge clk) begin
    if(re) begin
        flag <= 1;
        cnt <= 0;
    end
    if(flag) begin
        cnt <= cnt + 1;
    end
    if(cnt == 1) begin
        valid0 <= 1;
    end
    if(cnt == 4) begin
        valid0 <= 0;
        flag <= 0;
    end 


    
end


sfifo_w21_d32   origin_fifo(
    .clk(clk),
    .srst(!rst),
	.din(din),
	.wr_en(we),
	.rd_en(re),
	.dout(dout),
	.empty(empty), 
	.full(full)
    );

endmodule