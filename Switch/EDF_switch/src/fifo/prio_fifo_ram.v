/**@file
 * Double port Sync RAM
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

module prio_fifo_ram
#(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 16,
    parameter LABEL_WIDTH = 8,
    parameter CLEAR_ON_INIT = 1
)
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
input [DATA_WIDTH-1:0]          din;
output [DATA_WIDTH-1:0]         dout;
output                          valid;  
output                          empty;
output                          full;  
/*
 Internals
 */
 //fifo
reg                   fifo_rd_en=0;
reg                   fifo_wr_en=0;
reg  [ADDR_WIDTH-1:0] fifo_wr_data=0;

wire [ADDR_WIDTH-1:0] fifo_rd_data;
wire [ADDR_WIDTH:0] data_count;

//prio_fifo
reg                   prio_re=0;
reg                   prio_we=0;
reg  [LABEL_WIDTH+ADDR_WIDTH-1:0] prio_din=0;

wire [LABEL_WIDTH+ADDR_WIDTH-1:0] prio_dout;               
wire                  prio_valid; 

//data_ram
reg  [ADDR_WIDTH-1:0] ram_raddr=0;
reg  [ADDR_WIDTH-1:0] ram_waddr=0;
reg                   ram_re=0;
reg                   ram_we=0;


reg [2:0]             wr_state=0;
reg                   rd_state=0;
reg                   final_valid=0;
reg                   final_valid_reg=0;

assign  valid = final_valid_reg;
always@(posedge clk)
    case(wr_state)
    0:begin
        if(we) begin
            fifo_rd_en <= 1;
            wr_state <= 1;
        end
    end
    1:begin
        wr_state <= 2;
        fifo_rd_en <= 0;
    end
    2:begin
            wr_state <= 3;
            ram_we <= 1;
            ram_waddr <= fifo_rd_data;
            prio_we <= 1;
            prio_din <= {din[DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH],fifo_rd_data};
    end
    3:begin
        ram_we <= 0;
        prio_we <= 0;
        wr_state <= 0;
    end
    endcase
always@(posedge clk)
    case(rd_state)
    0:begin
        final_valid_reg <= final_valid;
        if(re) prio_re <= 1;
        else prio_re <= 0;
        if(prio_valid) begin
            ram_re <= 1;
            ram_raddr <= prio_dout[ADDR_WIDTH-1:0];
            final_valid <= 1;
        end
        else begin
            final_valid <= 0;
            ram_re <= 0;
            if(final_valid) begin
                rd_state <= 1;
                fifo_wr_en <= 1;
                fifo_wr_data <= prio_dout[ADDR_WIDTH-1:0];
            end
        end
    end
    1:begin
        fifo_wr_en <= 0;
        rd_state <= 0;
    end

    endcase


sync_fifo_init #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(ADDR_WIDTH)
	)
	index_fifo(
    .clk(clk),
    .rst_n(rst),
    .fifo_rd_en(fifo_rd_en),
    .fifo_wr_en(fifo_wr_en),
    .fifo_wr_data(fifo_wr_data),
    .fifo_rd_data(fifo_rd_data),
	.data_count(data_count)
);

prio_label_fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(LABEL_WIDTH+ADDR_WIDTH),
	.LABEL_WIDTH(LABEL_WIDTH),
    .CLEAR_ON_INIT(1)
	)
	head_fifo(
    .clk(clk),
    .rst(!rst),
    .re(prio_re),
    .we(prio_we),
    .din(prio_din),
    .dout(prio_dout),
    .valid(prio_valid),
    .full(full),
    .empty(empty)
);

dpram_sclk #(
	.ADDR_WIDTH(ADDR_WIDTH),
	.DATA_WIDTH(DATA_WIDTH)
	)
	payload_ram(
	.clk(clk),
	.rst(!rst),
	.raddr(ram_raddr),
	.re(ram_re),
	.waddr(ram_waddr),
	.we(ram_we),
	.din(din),
	.dout(dout)
);

/*dpram_simple payload_ram(
	.clka(clk),
	.clkb(clk),
	.addrb(ram_raddr),
	.enb(ram_re),
	.addra(ram_waddr),
	.wea(ram_we),
	.dina(din),
	.doutb(dout)
);*/
endmodule