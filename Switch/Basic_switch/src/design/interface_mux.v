`timescale 1ns / 1ps
module interface_mux(
input              clk,
input              rstn,
output             rx_data_fifo_rd0,
input     [7:0]     rx_data_fifo_dout0,
output             rx_ptr_fifo_rd0,
input    [15:0]     rx_ptr_fifo_dout0,
input              rx_ptr_fifo_empty0,
output             rx_data_fifo_rd1,
input     [7:0]     rx_data_fifo_dout1,
output             rx_ptr_fifo_rd1,
input     [15:0]    rx_ptr_fifo_dout1,
input              rx_ptr_fifo_empty1,

output             rx_data_fifo_rd2,
input     [7:0]     rx_data_fifo_dout2,
output             rx_ptr_fifo_rd2,
input     [15:0]    rx_ptr_fifo_dout2,
input              rx_ptr_fifo_empty2,

output             rx_data_fifo_rd3,
input     [7:0]     rx_data_fifo_dout3,
output             rx_ptr_fifo_rd3,
input     [15:0]    rx_ptr_fifo_dout3,
input              rx_ptr_fifo_empty3,
input              sfifo_rd,
output    [7:0]     sfifo_dout,
input              ptr_sfifo_rd,
output    [15:0]    ptr_sfifo_dout,
output             ptr_sfifo_empty
);
wire   [3:0]  source_portmap;
wire          bp;
reg    [3:0]  state=0;
reg           error;
reg           sfifo_wr=0;
reg   [7:0]   sfifo_din;
wire  [14:0]  sfifo_cnt;
reg          ptr_sfifo_wr=0;
reg   [15:0]  ptr_sfifo_din;
wire         ptr_sfifo_full;
wire  [15:0]  rx_ptr_fifo_dout;
wire  [7:0]   rx_data_fifo_dout;
reg          rx_ptr_fifo_rd=0;
reg          rx_data_fifo_rd=0;
reg   [10:0]  cnt=0;
reg   [1:0]   sel=0;
reg   [1:0]   RR=0;
always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        state<=#2 0;
        sfifo_wr<=#2 0;
		ptr_sfifo_wr<=#2 0;
        rx_ptr_fifo_rd<=#2 0;
        rx_data_fifo_rd<=#2 0;
        RR<=#2 0;
        sel<=#2 0;
        cnt<=#2 0;
        end
    else  begin
		case(state)
		0:begin
			if(!bp) begin
				case(RR)
				2'b00:begin
					if(!rx_ptr_fifo_empty0) begin sel<=#2 0; rx_ptr_fifo_rd<=#2 1;state<=#2 1;     end
					else if(!rx_ptr_fifo_empty1)begin  sel<=#2 1;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty2)begin  sel<=#2 2;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty3)begin  sel<=#2 3;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					end
				2'b01:begin
					if(!rx_ptr_fifo_empty1) begin sel<=#2 1; rx_ptr_fifo_rd<=#2 1;state<=#2 1;     end
					else if(!rx_ptr_fifo_empty2)begin  sel<=#2 2;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty3)begin  sel<=#2 3;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty0)begin  sel<=#2 0;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					end
				2'b10:begin
					if(!rx_ptr_fifo_empty2) begin sel<=#2 2; rx_ptr_fifo_rd<=#2 1;state<=#2 1;     end
					else if(!rx_ptr_fifo_empty3)begin  sel<=#2 3;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty0)begin  sel<=#2 0;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty1)begin  sel<=#2 1;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					end
				2'b11:begin
					if(!rx_ptr_fifo_empty3) begin sel<=#2 3; rx_ptr_fifo_rd<=#2 1;state<=#2 1;     end
					else if(!rx_ptr_fifo_empty0)begin  sel<=#2 0;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty1)begin  sel<=#2 1;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					else if(!rx_ptr_fifo_empty2)begin  sel<=#2 2;rx_ptr_fifo_rd<=#2 1;state<=#2 1; end
					end
				endcase
				end
			end
        1:begin
            if(RR==2'B11) RR<=#2 0;
            else  RR<=#2 RR+1;
            rx_ptr_fifo_rd<=#2 0;
            state<=#2 2;
            end
		2:begin
            cnt<=#2 rx_ptr_fifo_dout[10:0];
            error<=#2 rx_ptr_fifo_dout[14]|rx_ptr_fifo_dout[15];
            rx_data_fifo_rd<=#2 1;
            state<=#2 3;
            end
		3:begin
            cnt<=#2 cnt-1;
            state<=#2 4;
            end
		4:begin
			if(cnt>1)cnt<=#2 cnt-1;
            else  begin
                cnt<=#2 0;
                rx_data_fifo_rd<=#2 0;
                state<=#2 5;
                end
            if(cnt>3) sfifo_wr<=#2 !error;	
			else sfifo_wr<=#2 0;
            sfifo_din<=#2 rx_data_fifo_dout;
            end
		5:begin
            state<=#2 6;
            sfifo_din<=#2 rx_data_fifo_dout;
			ptr_sfifo_din<=#2 {1'b0,source_portmap,rx_ptr_fifo_dout[10:0]};
            end
		6:begin
            sfifo_wr<=#2 0;
            ptr_sfifo_wr<=#2 !error;
            ptr_sfifo_din<=#2 ptr_sfifo_din-4;	
            state<=#2 7;
            end 
		7:begin
            ptr_sfifo_wr<=#2 0;
            state<=#2 0;
            end
		endcase
		end
    end
assign     bp=(sfifo_cnt>14866)?1:ptr_sfifo_full;
assign     rx_ptr_fifo_rd0=rx_ptr_fifo_rd&(sel==0);
assign     rx_ptr_fifo_rd1=rx_ptr_fifo_rd&(sel==1);
assign     rx_ptr_fifo_rd2=rx_ptr_fifo_rd&(sel==2);
assign     rx_ptr_fifo_rd3=rx_ptr_fifo_rd&(sel==3);
assign    rx_data_fifo_rd0=rx_data_fifo_rd&(sel==0);
assign    rx_data_fifo_rd1=rx_data_fifo_rd&(sel==1);
assign    rx_data_fifo_rd2=rx_data_fifo_rd&(sel==2);
assign    rx_data_fifo_rd3=rx_data_fifo_rd&(sel==3);
assign    rx_ptr_fifo_dout=(sel==0)?rx_ptr_fifo_dout0:
                           (sel==1)?rx_ptr_fifo_dout1:
                           (sel==2)?rx_ptr_fifo_dout2:rx_ptr_fifo_dout3;    
assign    rx_data_fifo_dout=(sel==0)?rx_data_fifo_dout0:
                            (sel==1)?rx_data_fifo_dout1:
                            (sel==2)?rx_data_fifo_dout2:rx_data_fifo_dout3; 
assign    source_portmap=(sel==0)?4'b0001:
                         (sel==1)?4'b0010:
                         (sel==2)?4'b0100:4'b1000;
//8,16k
sync_fifo   #(
 	.ADDR_WIDTH(14),
    .DATA_WIDTH(8)
	)   
    u_sfifo(
    .clk(clk),
    .rst_n(rstn),
    .fifo_wr_data(sfifo_din),
    .fifo_wr_en(sfifo_wr),
    .fifo_rd_en(sfifo_rd),
    .fifo_rd_data(sfifo_dout),
	.fifo_full(), 							
	.fifo_empty(), 					
    .data_count(sfifo_cnt)
    );
//16,32
sync_fifo  #(
 	.ADDR_WIDTH(5),
    .DATA_WIDTH(16)
	)    
    u_ptr_sfifo(
    .clk(clk),
    .rst_n(rstn),
    .fifo_wr_data(ptr_sfifo_din),
    .fifo_wr_en(ptr_sfifo_wr),
    .fifo_rd_en(ptr_sfifo_rd),
    .fifo_rd_data(ptr_sfifo_dout),
    .fifo_empty(ptr_sfifo_empty),
    .fifo_full(ptr_sfifo_full),
	.data_count()	
    );                                   
endmodule
