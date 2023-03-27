`timescale 1ns / 1ps
module qm(
input          clk,
input          rstn,
input	[3:0]  port_id,        
input          sof,
input          dv,
input   [7:0]  data,
output         bp,
        
input           data_fifo_rd,
output   [7:0]  data_fifo_dout,
input           ptr_fifo_rd,
output   [15:0] ptr_fifo_dout,
output          ptr_fifo_empty
);
reg             data_fifo_wr=0;
reg    [7:0]    data_fifo_din=0;
reg    [7:0]    data_fifo_din_0=0;
reg             ptr_fifo_wr=0;
reg    [15:0]   ptr_fifo_din=0;
reg    [2:0]    state=0;
reg    [11:0]   cnt=0;
reg    [11:0]   length=0;
wire   [11:0]   data_depth;
wire            ptr_fifo_full;

always@(posedge clk or negedge rstn) begin
    if(!rstn)begin
        data_fifo_wr<=#2 0;
        data_fifo_din<=#2 0;
        ptr_fifo_wr<=#2 0;
        ptr_fifo_din<=#2 0;
        state<=#2 0;
        cnt<=#2 0;
        end
    else begin
        data_fifo_din<=#2 data;
        case(state)
        0:begin
            if(sof)begin
                if(port_id[3:0]& data[3:0])begin 
                    data_fifo_wr<=#2 0; 
                    state<=#2 1;
					length[11:8]<=#2 data[7:4];
                    end
                else state<=#2 0;
                end  
            end        
		1:begin
 		    length[7:0]<=#2 data[7:0];
			cnt<=#2 2;		
			state<=#2 2;
		    end
        2:begin
			if(cnt>=length)data_fifo_wr<=#2 0;
			else data_fifo_wr<=#2 1;
			if(!dv)begin 
				state<=#2 3;
				data_fifo_wr<=#2 0;
				cnt<=#2 0;
				end
			else cnt<=#2 cnt+1;    
			end
        3:begin
				ptr_fifo_wr<=#2 1;
				ptr_fifo_din<=#2 {4'b0,length[11:0]}-2;
				state<=#2 4;
				end
        4:begin
				ptr_fifo_wr<=#2 0;
				state<=#2 0;
				end
        endcase
        end     
    end
assign  bp=(data_depth>2578)?1:ptr_fifo_full;

//8,4096
sync_fifo	#(
 	.ADDR_WIDTH(12),
    .DATA_WIDTH(8)
	)   
	qm_data_fifo(
    .clk(clk),
    .rst_n(rstn),
	.fifo_wr_data(data_fifo_din),
	.fifo_wr_en(data_fifo_wr),
	.fifo_rd_en(data_fifo_rd),
	.fifo_rd_data(data_fifo_dout),
	.fifo_full(), 				
	.fifo_empty(), 				
	.data_count(data_depth) 
);

//16,32
sync_fifo   #(
 	.ADDR_WIDTH(5),
    .DATA_WIDTH(16)
	)   
	qm_ptr_fifo(
    .clk(clk),
    .rst_n(rstn),
	.fifo_wr_data(ptr_fifo_din),
	.fifo_wr_en(ptr_fifo_wr),
	.fifo_rd_en(ptr_fifo_rd),
	.fifo_rd_data(ptr_fifo_dout),
	.fifo_empty(ptr_fifo_empty), 
	.fifo_full(ptr_fifo_full),
	.data_count() 			
    );
endmodule
