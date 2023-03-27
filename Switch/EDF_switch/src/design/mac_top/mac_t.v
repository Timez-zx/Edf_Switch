`timescale 1ns / 1ps
module mac_t(
input               	rstn,
input               	clk,
input              		tx_clk,
output  reg        		tx_dv,
output  reg [3:0]    	tx_d,
output  reg         	data_fifo_rd=0,
input      [7:0]  		data_fifo_din,
output  reg        		ptr_fifo_rd=0, 
input       [15:0]  	ptr_fifo_din,
input              		ptr_fifo_empty,
input                   packet_info_rd_valid,
output                  tx_c
    );
parameter       DELAY=2;
reg	[10:0]  	cnt=0;
reg 	[10:0]  pad_cnt=0;
reg        		crc_init=0;
wire	[7:0]  	crc_din;
reg         	crc_cal=0;
reg         	crc_dv=0;
wire	[31:0]  crc_result;
wire	[7:0]   crc_dout;

reg [7:0]   	data_fifo_din_1=0;
reg         	data_fifo_wr_1=0;
reg         	data_fifo_rd_1=0;
wire[7:0]   	data_fifo_dout_1;
wire[11:0]  	data_fifo_depth_1;
reg [15:0]  	ptr_fifo_din_1=0;
reg        		ptr_fifo_wr_1=0;
reg         	ptr_fifo_rd_1=0;
wire[15:0]  	ptr_fifo_dout_1;
wire       		ptr_fifo_full_1;
wire       		ptr_fifo_empty_1;

wire        	bp_1;
assign      	bp_1=ptr_fifo_full_1 | (data_fifo_depth_1>2566);
reg [2:0]   state=0;
reg         rd_flag=0;

assign tx_c = tx_clk;
    
always @(posedge clk or negedge rstn) 
    if(!rstn)begin
        state<=#DELAY 0;
        ptr_fifo_rd     <=#DELAY 0;
        data_fifo_rd    <=#DELAY 0;
        cnt             <=#DELAY 0;
        pad_cnt         <=#DELAY 0;
        crc_init        <=#DELAY 0;
        crc_cal         <=#DELAY 0;
        crc_dv          <=#DELAY 0;
        data_fifo_din_1 <=#DELAY 0;
        data_fifo_wr_1  <=#DELAY 0;
        ptr_fifo_din_1  <=#DELAY 0;
        ptr_fifo_wr_1   <=#DELAY 0; 
        rd_flag         <=#DELAY 0;
        end
    else begin
        crc_init<=#DELAY 0;
        ptr_fifo_rd<=#DELAY 0;
        case(state)
        0:begin
            ptr_fifo_wr_1<=#DELAY 0;
            data_fifo_wr_1<=#DELAY 0;
            if(!ptr_fifo_empty & !bp_1) begin
                ptr_fifo_rd<=#DELAY 1;
                crc_init<=#DELAY 1;
                data_fifo_wr_1<=#DELAY 1;
                data_fifo_din_1<=#DELAY 8'h55;
                cnt<=#DELAY 7;
                state<=#DELAY 1;
                end
            end
        1:begin //cnt为15减去6的大小
            if(cnt>1) begin
                cnt<=#DELAY cnt-1;
            end
            if(packet_info_rd_valid) begin
                rd_flag<=#DELAY 1;
            end

            if(cnt==1 && rd_flag) begin  
                data_fifo_wr_1<=#DELAY 1;
                data_fifo_din_1<=#DELAY 8'hd5;
                data_fifo_rd<=#DELAY 1;
                cnt<=#DELAY ptr_fifo_din[10:0];
                state<=#DELAY 2;
                rd_flag<=#DELAY 0;
                end
            else if(cnt==1 && !rd_flag) begin
                data_fifo_wr_1<=#DELAY 0;
            end
            end
        2:begin
            cnt<=#DELAY cnt-1;
            if(cnt<60) pad_cnt<=#DELAY 60-cnt;
            else pad_cnt<=#DELAY 0;
            data_fifo_wr_1<=#DELAY 0;
            state<=#DELAY 3;
            end
        3:begin
            data_fifo_wr_1 <=#DELAY 1;
            data_fifo_din_1<=#DELAY data_fifo_din;
            crc_cal     <=#DELAY 1;
            crc_dv      <=#DELAY 1;
            if(cnt>1) cnt   <=#DELAY cnt-1;
            else begin
                data_fifo_rd<=#DELAY 0;
                cnt <=#DELAY 0;
                state   <=#DELAY 4;
                end
            end
        4:begin
            data_fifo_wr_1  <=#DELAY 1;
            data_fifo_din_1 <=#DELAY data_fifo_din;
            state           <=#DELAY 5;
            end
        5:begin
            if(pad_cnt) begin
                cnt             <=#DELAY pad_cnt;
                data_fifo_wr_1  <=#DELAY 1;
                data_fifo_din_1 <=#DELAY 8'b0;
                state           <=#DELAY 6;
                end
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 4;
                state           <=#DELAY 7;
                end
            end
        6:begin
            if(cnt>1) cnt<=#DELAY cnt-1;
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                crc_cal         <=#DELAY 0;
                cnt             <=#DELAY 4;
                state           <=#DELAY 7;
                end
            end
        7:begin
            data_fifo_wr_1  <=#DELAY 1;
            data_fifo_din_1 <=#DELAY crc_dout;
            if(cnt==1)  crc_dv  <=#DELAY 0;
            if(cnt>0)   cnt     <=#DELAY cnt-1;
            else begin
                data_fifo_wr_1  <=#DELAY 0;
                ptr_fifo_din_1<=#DELAY ptr_fifo_din+12+pad_cnt;
                ptr_fifo_wr_1<=#DELAY 1;
                state       <=#DELAY 0;
                end
            end
        endcase
        end
crc32_8023 u_crc32_8023(
    .clk(clk), 
    .reset(!rstn), 
    .d(crc_din), 
    .load_init(crc_init),
    .calc(crc_cal), 
    .d_valid(crc_dv), 
    .crc_reg(crc_result), 
    .crc(crc_dout)
    );
assign  crc_din=data_fifo_din_1;
//8,4k
async_fifo #(
 	.ADDR_WIDTH(12),
    .DATA_WIDTH(8)
	)   
    u_data_fifo_1 (
  .rst_n(rstn),                      // input rst
  .fifo_wr_clk(clk),                     // input wr_clk
  .fifo_rd_clk(tx_clk),                  // input rd_clk
  .fifo_wr_data(data_fifo_din_1),            // input [7 : 0] din
  .fifo_wr_en(data_fifo_wr_1),           // input wr_en
  .fifo_rd_en(data_fifo_rd_1),           // input rd_en
  .fifo_rd_data(data_fifo_dout_1),          // output [7 : 0] dout
  .wr_data_count(data_fifo_depth_1) // output [11 : 0] wr_data_count
);
//16,32
async_fifo  #(
 	.ADDR_WIDTH(5),
    .DATA_WIDTH(16)
	) 
    u_ptr_fifo_1 (
  .rst_n(rstn),                      // input rst
  .fifo_wr_clk(clk),                     // input wr_clk
  .fifo_rd_clk(tx_clk),                  // input rd_clk
  .fifo_wr_data(ptr_fifo_din_1),             // input [15 : 0] din
  .fifo_wr_en(ptr_fifo_wr_1),            // input wr_en
  .fifo_rd_en(ptr_fifo_rd_1),            // input rd_en
  .fifo_rd_data(ptr_fifo_dout_1),           // output [15 : 0] dout
  .r_fifo_full(ptr_fifo_full_1),           // output full
  .r_fifo_empty(ptr_fifo_empty_1)      	// output empty
);

reg     [10:0]  cnt_t=0;
reg     [2:0]       state_t=0;
reg             data_fifo_rd_1_reg_0=0;
reg             data_fifo_rd_1_reg_1=0;
reg             tx_sof=0;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_t         <=#DELAY 0;
        cnt_t           <=#DELAY 0;
        data_fifo_rd_1  <=#DELAY 0;
        ptr_fifo_rd_1   <=#DELAY 0;
        data_fifo_rd_1_reg_0<=#DELAY 0;
        data_fifo_rd_1_reg_1<=#DELAY 0;
        tx_sof          <=#DELAY 0;
        end
    else begin
        ptr_fifo_rd_1<=#DELAY 0;
        data_fifo_rd_1_reg_0<=#DELAY data_fifo_rd_1;
        data_fifo_rd_1_reg_1<=#DELAY data_fifo_rd_1_reg_0;
        tx_sof          <=#DELAY 0;
        case(state_t)
        0:begin
            if(!ptr_fifo_empty_1) begin
                ptr_fifo_rd_1<=#DELAY 1;
                state_t<=#DELAY 1;
                end
            end
        1:state_t<=#DELAY 2;
        2:begin
            cnt_t   <=#DELAY ptr_fifo_dout_1[10:0];
            data_fifo_rd_1<=#DELAY 1;
            tx_sof  <=#DELAY 1;
            state_t <=#DELAY 3;
            end
        3:begin
            data_fifo_rd_1<=#DELAY 0;
            state_t <=#DELAY 4;
            end
        4:begin
            if(cnt_t>1) begin
                data_fifo_rd_1<=#DELAY 1;
                cnt_t<=#DELAY cnt_t-1;
                state_t <=#DELAY 3;
                end
            else begin
                data_fifo_rd_1<=#DELAY 0;
                cnt_t<=#DELAY 24;
                state_t<=#DELAY 5;
                end
            end
        5:begin
            if(cnt_t>0) cnt_t<=#DELAY cnt_t-1;
            else begin
                cnt_t   <=#DELAY 0;
                state_t <=#DELAY 0;
                end
            end
        endcase
        end

wire    tx_dv_i;
assign  tx_dv_i=data_fifo_rd_1_reg_0 |  data_fifo_rd_1_reg_1;
reg     [1:0]   state_tx=0;
always @(posedge tx_clk or negedge rstn) 
    if(!rstn) begin
        state_tx<=#DELAY 0;
        tx_dv<=#DELAY 0;
        tx_d<=#DELAY 0;
        end
    else begin
        tx_dv<=#DELAY tx_dv_i;
        case(state_tx)
        0:begin
            if(tx_sof)state_tx<=#DELAY 1;
            end
        1:begin
            if(data_fifo_rd_1_reg_0)        tx_d<=#DELAY data_fifo_dout_1[3:0];
            else if(data_fifo_rd_1_reg_1)   tx_d<=#DELAY data_fifo_dout_1[7:4];
            else begin
                tx_d<=#DELAY 0;
                state_tx<=#DELAY 0;
                end
            end
        endcase
        end
endmodule	
