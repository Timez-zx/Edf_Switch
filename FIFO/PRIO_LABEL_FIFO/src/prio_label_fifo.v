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

module prio_label_fifo
#(
    parameter ADDR_WIDTH = 9,
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
    valid
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
/*
 Internals
 */
reg [ADDR_WIDTH-1:0]          exchange_addr=0;
reg [ADDR_WIDTH-1:0]          shuffle_addr=0;
reg [ADDR_WIDTH-1:0]          waddr=0;
reg [DATA_WIDTH-1:0]           mem[(1<<ADDR_WIDTH)-1:0];
reg [DATA_WIDTH-1:0]           exchange_data=0;
reg [DATA_WIDTH-1:0]           shuffle_data=0;

reg [DATA_WIDTH-1:0]           dout_reg=0;
reg [DATA_WIDTH-1:0]           din_reg=0;

reg begin_exchange_flag=0;
reg begin_shuffle_flag=0;

reg re_flag=0;
reg we_flag=0;
reg re_reg=0;
reg we_reg=0;
reg valid_reg=0;

reg exchange_flag=0;
reg shuffle_flag=0;

assign dout = dout_reg;
assign valid = valid_reg;

    /*
     reset in verification
     */
generate
  if(CLEAR_ON_INIT) begin :clear_on_init
    integer               idx;
    initial
    for(idx=0; idx < (1<<ADDR_WIDTH); idx=idx+1)
        mem[idx] = {DATA_WIDTH{1'b1}};
  end
endgenerate


always @(posedge clk)
    if(re == 1 && begin_exchange_flag == 1) begin
        re_flag <= 1;
    end
    else if (re == 1 && begin_exchange_flag == 0 && we != 1) begin
        re_reg <= 1;
        begin_shuffle_flag <= 1;
    end
    else if (re == 0 && begin_exchange_flag == 0 && re_flag == 1) begin
        re_reg <= 1;
        re_flag <= 0;
        begin_shuffle_flag <= 1;
    end

always @(posedge clk)
    if(we == 1 && begin_shuffle_flag == 1) begin
        we_flag <= 1;
        din_reg <= din;
    end
    else if (we == 1 && begin_shuffle_flag == 0 && re != 1) begin
        we_reg <= 1;
        din_reg <= din;
        begin_exchange_flag <= 1;
    end
    else if (we == 0 && begin_shuffle_flag == 0 && we_flag == 1) begin
        we_reg <= 1;
        we_flag <= 0;
        begin_exchange_flag <= 1;
    end

always @(posedge clk)
    if (rst) begin
        dout_reg <= 0;
        exchange_addr<=0;
        waddr<=0;
        begin_exchange_flag<=0;
    end 
    else begin
        if(we_reg) begin
            exchange_addr <= waddr;
            exchange_data <= din_reg;
            waddr <= waddr + 1;
            exchange_flag <= begin_exchange_flag;
            we_reg <= 0;
        end
        if(re_reg) begin
            dout_reg <= mem[0];
            valid_reg <= 1;
            shuffle_flag <= begin_shuffle_flag;
            shuffle_addr <=0;
            shuffle_data <= mem[waddr-1];
            waddr <= waddr -1;
            re_reg <= 0;
        end
        if(re == 1 && we == 1) begin
            dout_reg <= mem[0];
            shuffle_flag <= 1;
            shuffle_addr <=0;
            shuffle_data <= din;
        end
    end

always @(posedge clk)
    if(exchange_flag) begin
        if(exchange_addr == 0) begin
            begin_exchange_flag <= 0;
            exchange_flag <= 0;
            mem[exchange_addr] <= exchange_data;
        end
        else begin
            if (exchange_data[DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH] < mem[(exchange_addr-1)>>1][DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH]) begin
                mem[exchange_addr] <= mem[(exchange_addr-1)>>1];
                exchange_addr <= (exchange_addr-1)>>1;
            end
            else begin
                mem[exchange_addr] <= exchange_data;
                begin_exchange_flag <= 0;
                exchange_flag <= 0;
            end
        end
    end

always @(posedge clk)
    if(shuffle_flag) begin
        if(((shuffle_addr+1)<<1)-1 > waddr) begin
            mem[shuffle_addr] <= shuffle_data;
            begin_shuffle_flag <= 0;
            shuffle_flag <= 0;
            valid_reg <= 0;
        end
        else begin
            if(mem[((shuffle_addr+1)<<1)-1][DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH] <= mem [(shuffle_addr+1)<<1][DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH]) begin
                if(shuffle_data[DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH] <= mem[((shuffle_addr+1)<<1)-1][DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH]) begin
                    begin_shuffle_flag <= 0;
                    shuffle_flag <= 0;
                    mem[shuffle_addr] <= shuffle_data;
                    valid_reg <= 0;
                end
                else begin
                    mem[shuffle_addr] <= mem[((shuffle_addr+1)<<1)-1];
                    shuffle_addr <= ((shuffle_addr+1)<<1)-1;
                end
            end
            else begin
                if(shuffle_data[DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH] <= mem[(shuffle_addr+1)<<1][DATA_WIDTH-1:DATA_WIDTH-LABEL_WIDTH]) begin
                    begin_shuffle_flag <= 0;
                    shuffle_flag <= 0;
                    mem[shuffle_addr] <= shuffle_data;
                    valid_reg <= 0;
                end
                else begin
                    mem[shuffle_addr] <= mem[(shuffle_addr+1)<<1];
                    shuffle_addr <=(shuffle_addr+1)<<1;
                end
            end
        end
    end





endmodule