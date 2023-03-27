/**@file
 * Double port sync Write async Read RAM
 */

/*
 * OpenProcessor-X architecture (OpenPX)
 *
 * Copyleft (C) 2016, the 1st Middle School in Yongsheng,Lijiang,China
 * This file is part of OpenPX (Open Processor-X architecture)
 * project. It is a free item; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License (GPL), in version 2
 * as it comes in the "COPYING" file of the OpenPX distribution. OpenPX
 * is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY of any kind.
 */

module dpram_aclk
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter CLEAR_ON_INIT = 1,
    parameter ENABLE_BYPASS = 0,
    parameter STATE_KEEP = 1'b1
)
(
    wr_clk,
    rd_clk,
    rst,
    raddr,
    re,
    waddr,
    we,
    din,
    dout
);

/*
 Ports
 */
input                           wr_clk;
input                           rd_clk;
input                           rst;
input [ADDR_WIDTH-1:0]          raddr;
input                           re;
input [ADDR_WIDTH-1:0]          waddr;
input                           we;
input [DATA_WIDTH-1:0]          din;
output [DATA_WIDTH-1:0]         dout;
    
/*
 Internals
 */
reg [DATA_WIDTH-1:0]            mem[(1<<ADDR_WIDTH)-1:0];
reg [DATA_WIDTH-1:0]            rdata=0;
reg                             re_r;
wire [DATA_WIDTH-1:0]           dout_w;

    /*
     reset in verification
     */
generate
  if(CLEAR_ON_INIT) begin :clear_on_init
    integer               idx;
    initial
    for(idx=0; idx < (1<<ADDR_WIDTH); idx=idx+1)
        mem[idx] = {DATA_WIDTH{1'b0}};
  end
endgenerate

    /*
     bypass control
     */
generate
  if (ENABLE_BYPASS) begin : bypass_gen
    assign dout_w = (waddr == raddr && we && re) ? din : rdata;
  end else begin
    assign dout_w = rdata;
  end
endgenerate


assign dout = (re_r | STATE_KEEP) ? dout_w : {DATA_WIDTH{1'b0}};
 
/*
 R logic
 */

always @(posedge rd_clk)
  if (rst) begin
      re_r <= 1'b0;
  end else
      re_r <= re;

always @(posedge rd_clk) begin
    if (re)
        rdata <= mem[raddr];
    else
        if (!STATE_KEEP)
          rdata = {DATA_WIDTH{1'b0}};
end

/*
 W logic
 */
always @(posedge wr_clk) begin
    if (we)
        mem[waddr] <= din;
end

endmodule