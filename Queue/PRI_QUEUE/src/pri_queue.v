`timescale 1ns / 1ps
module 	pri_queue
#(
    parameter MAX_DATA_DEPTH = 12,
    parameter MAX_PACKET_DEPTH = 5,
	parameter DATA_WIDTH = 8,
	parameter PTR_WIDTH = 16,
	parameter BLOCK_ADDR_DEPTH = 6
)
(
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

reg    [2:0] 	state=0;
reg             data_fifo_wr=0;
reg    [7:0]    data_fifo_din=0;

reg    [11:0]   length=0;
reg    [11:0]   data_cnt=0;

reg    [4:0]    block_num=0;
reg    [4:0]    block_cnt=0;
reg    			block_re=0;

reg    [220:0]  time_index=0;
reg             packet_info_we=0;

reg             ptr_fifo_wr=0;
reg    [31:0]   ptr_fifo_din=0;



wire   [5:0]    block_index;
always@(posedge clk or negedge rstn)
	if(!rstn) begin
		state <= #2 0;
		data_fifo_din<=#2 0;
	end
	else begin
		data_fifo_din<=#2 data;
		case(state)
        0:begin
            if(sof)begin
                if(port_id[3:0] & data[3:0])begin 
					block_re<=#2 1;
                    state<=#2 1;
					length[11:8]<=#2 data[7:4];
                    end
                else state<=#2 0;
                end  
            end      
		1:begin
			block_re<=#2 0;
 		    length[7:0]<=#2 data[7:0];
			cnt<=#2 2;		
			state<=#2 2;
			block_cnt<= #2 0;
			data_waddr<=#2 0;
		    end
        2:begin
			block_num <=#2 (length + 1<<BLOCK_ADDR_DEPTH - 1)>>BLOCK_ADDR_DEPTH;
			time_index[204:200]<=#2 block_num; 
			if(!dv)begin 
				state<=#2 3;
				block_cnt<=#2 0;
				data_fifo_wr<=#2 0;
				cnt<=#2 0;
				data_waddr<=#2 0;
				end
			else begin
				cnt<=#2 cnt+1;
				data_waddr<=#2 data_waddr+1;
			end 
			//cnt不同条件判断
			if(cnt>=length) begin 
				data_fifo_wr<=#2 0;
			end
			else begin
				data_fifo_wr<=#2 1;
			end
			if(cnt == 14) begin
				time_index[220:213]<=#2 data[7:0]; 
			end
			if(cnt == 15) begin
				time_index[212:205]<=#2 data[7:0]; 
			end
			//data_waddr不同条件判断
			if(data_waddr == 1<<MAX_DATA_DEPTH-1 && block_cnt < block_num - 1) begin
				block_re <=#2 1;
				block_cnt<=#2 block_cnt + 1;
			end
			else begin
				block_re<=#2 0;
			end
			if(data_waddr == 0) begin 
				time_index[200-block_cnt*6-1:200-block_cnt*6-6]<=#2 block_index;
			end
		end
		3:begin
			ptr_fifo_wr<=#2 1;
			ptr_fifo_din<=#2 {time_index[220:205],4'b0,length[11:0]}-2;
			packet_info_we<=#2 1;
			state<=#2 4;
			end
		4:begin
			ptr_fifo_wr<=#2 0;
			packet_info_we<=#2 0;
			state<=#2 0;
			end
		endcase
end

reg   [7:0]     data_dout=0;
reg   [15:0]    ptr_dout=0;

reg   [BLOCK_ADDR_DEPTH-1:0]     rd_addr=0;
reg   [4:0]		block_rd_cnt=0;
reg   [2:0]     rd_state=0;

reg   [31:0]    ptr_rd_data=0;
reg             ptr_rd_valid=0;

reg             packet_info_rd=0;
reg	   [220:0]	packet_info_reg=0;
reg	   [4:0]    block_rd_num=0;

reg				block_we=0;

wire   [220:0]	packet_info_rd_data=0;
wire            packet_info_rd_valid=0;
wire   [5:0]    block_used=0;
wire            ptr_fifo_full=0;

assign  data_fifo_dout = data_dout;
assign  ptr_fifo_dout = ptr_dout;
assign  bp=(block_used>39)?1:ptr_fifo_full;
always@(posedge clk or negedge rstn) begin
	if(!rstn) begin
		data_rd<=#2 0;
		ptr_rd<=#2 0;
		rd_cnt<=#2 0;
		rd_state<=#2 0;
	end
	else begin
		case(rd_state)
		0:begin
			if(ptr_fifo_rd == 1) begin
				rd_state<=#2 1;
				packet_info_rd<=#2 1;
			end
		end
		1:begin
			packet_info_rd<=#2 0;
			if(ptr_rd_valid) begin
				ptr_dout<=#2 ptr_rd_data[15:0];
			end
			if(packet_info_rd_valid) begin
				packet_info_reg<=#2 packet_info_rd_data;
				block_rd_num<=#2 packet_info_rd_data[204:200];
				rd_addr<=#2 0;
				block_rd_cnt<=#2 0;
				state<=#2 2;
			end
		end
		2:begin
			if(data_fifo_rd)begin
				rd_addr<=#2 rd_addr+1;
				block_we<=#2 0;
				if(rd_addr == 1<<BLOCK_ADDR_DEPTH-1)
					block_rd_cnt<=#2 block_rd_cnt+1;
				if((rd_addr == 1<<BLOCK_ADDR_DEPTH-2) && block_rd_cnt < block_rd_num-1)
					block_we<=#2 1;
			end
			else begin
				block_we<=#2 1;
				rd_state<=#2 3;
			end
		end
		3:begin
			block_we<=#2 0;
			rd_state<=#2 0;
		end
		endcase

	end

end
//用于查看每个块是否空闲，优先级队列可以优先告诉我们哪个块即空闲而且对应的索引小

sync_fifo #(
    .ADDR_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH),
    .DATA_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH)
	)
	block_status_prio_fifo(
    .clk(clk),
    .rst_n(rstn),
    .fifo_rd_en(block_re),
    .fifo_wr_en(block_we),
    .fifo_wr_data(packet_info_reg[200-block_rd_cnt*6-1:200-block_cnt*6-6]),
    .fifo_rd_data(block_index),
	.data_count(block_used)
);

//用于存储比较每个包的时间信息以及对应存储位置信息
prio_label_fifo #(
    .ADDR_WIDTH(MAX_PACKET_DEPTH),
    .DATA_WIDTH(16+5+200),
	.LABEL_WIDTH(16),
    .CLEAR_ON_INIT(1)
	)
	packet_info_prio_fifo(
    .clk(clk),
    .rst(!rstn),
    .re(packet_info_rd),
    .we(packet_info_we),
    .din(time_index),
    .dout(packet_info_rd_data),
    .valid(packet_info_rd_valid)
);

//用于储存每个包的长度信息的优先级队列，16为表示ddl，16为包长度
prio_label_fifo #(
    .ADDR_WIDTH(MAX_PACKET_DEPTH),
    .DATA_WIDTH(16+16),
	.LABEL_WIDTH(16),
    .CLEAR_ON_INIT(1)
	)
	packet_ptr_prio_fifo(
    .clk(clk),
    .rst(!rstn),
    .re(ptr_fifo_rd),
    .we(ptr_fifo_wr),
    .din(ptr_fifo_din),
    .dout(ptr_rd_data),
    .valid(ptr_rd_valid),
	.empty(ptr_fifo_empty),
	.full(ptr_fifo_full)
);

dpram_sclk #(
	.ADDR_WIDTH(MAX_DATA_DEPTH),
	.DATA_WIDTH(DATA_WIDTH)
	)
	queue_data_ram(
	.clk(clk),
	.rst(!rstn),
	.raddr(packet_info_reg[200-block_rd_cnt*6-1:200-block_cnt*6-6]+rd_addr),
	.re(data_fifo_rd),
	.waddr(data_waddr+block_index<<BLOCK_ADDR_DEPTH),
	.we(data_fifo_wr),
	.din(data_fifo_din),
	.dout(data_fifo_dout)
);


endmodule
`timescale 1ns / 1ps
module 	pri_queue
#(
    parameter MAX_DATA_DEPTH = 12,
    parameter MAX_PACKET_DEPTH = 5,
	parameter DATA_WIDTH = 8,
	parameter PTR_WIDTH = 16,
	parameter BLOCK_ADDR_DEPTH = 6
)
(
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

reg    [2:0] 	state=0;
reg             data_fifo_wr=0;
reg    [7:0]    data_fifo_din=0;

reg    [11:0]   length=0;
reg    [11:0]   data_cnt=0;

reg    [4:0]    block_num=0;
reg    [4:0]    block_cnt=0;
reg    			block_re=0;

reg    [220:0]  time_index=0;
reg             packet_info_we=0;

reg             ptr_fifo_wr=0;
reg    [31:0]   ptr_fifo_din=0;



wire   [5:0]    block_index;
always@(posedge clk or negedge rstn)
	if(!rstn) begin
		state <= #2 0;
		data_fifo_din<=#2 0;
	end
	else begin
		data_fifo_din<=#2 data;
		case(state)
        0:begin
            if(sof)begin
                if(port_id[3:0] & data[3:0])begin 
					block_re<=#2 1;
                    state<=#2 1;
					length[11:8]<=#2 data[7:4];
                    end
                else state<=#2 0;
                end  
            end      
		1:begin
			block_re<=#2 0;
 		    length[7:0]<=#2 data[7:0];
			cnt<=#2 2;		
			state<=#2 2;
			block_cnt<= #2 0;
			data_waddr<=#2 0;
		    end
        2:begin
			block_num <=#2 (length + 1<<BLOCK_ADDR_DEPTH - 1)>>BLOCK_ADDR_DEPTH;
			time_index[204:200]<=#2 block_num; 
			if(!dv)begin 
				state<=#2 3;
				block_cnt<=#2 0;
				data_fifo_wr<=#2 0;
				cnt<=#2 0;
				data_waddr<=#2 0;
				end
			else begin
				cnt<=#2 cnt+1;
				data_waddr<=#2 data_waddr+1;
			end 
			//cnt不同条件判断
			if(cnt>=length) begin 
				data_fifo_wr<=#2 0;
			end
			else begin
				data_fifo_wr<=#2 1;
			end
			if(cnt == 14) begin
				time_index[220:213]<=#2 data[7:0]; 
			end
			if(cnt == 15) begin
				time_index[212:205]<=#2 data[7:0]; 
			end
			//data_waddr不同条件判断
			if(data_waddr == 1<<MAX_DATA_DEPTH-1 && block_cnt < block_num - 1) begin
				block_re <=#2 1;
				block_cnt<=#2 block_cnt + 1;
			end
			else begin
				block_re<=#2 0;
			end
			if(data_waddr == 0) begin 
				time_index[200-block_cnt*6-1:200-block_cnt*6-6]<=#2 block_index;
			end
		end
		3:begin
			ptr_fifo_wr<=#2 1;
			ptr_fifo_din<=#2 {time_index[220:205],4'b0,length[11:0]}-2;
			packet_info_we<=#2 1;
			state<=#2 4;
			end
		4:begin
			ptr_fifo_wr<=#2 0;
			packet_info_we<=#2 0;
			state<=#2 0;
			end
		endcase
end

reg   [7:0]     data_dout=0;
reg   [15:0]    ptr_dout=0;

reg   [BLOCK_ADDR_DEPTH-1:0]     rd_addr=0;
reg   [4:0]		block_rd_cnt=0;
reg   [2:0]     rd_state=0;

reg   [31:0]    ptr_rd_data=0;
reg             ptr_rd_valid=0;

reg             packet_info_rd=0;
reg	   [220:0]	packet_info_reg=0;
reg	   [4:0]    block_rd_num=0;

reg				block_we=0;

wire   [220:0]	packet_info_rd_data=0;
wire            packet_info_rd_valid=0;
wire   [5:0]    block_used=0;
wire            ptr_fifo_full=0;

assign  data_fifo_dout = data_dout;
assign  ptr_fifo_dout = ptr_dout;
assign  bp=(block_used>39)?1:ptr_fifo_full;
always@(posedge clk or negedge rstn) begin
	if(!rstn) begin
		data_rd<=#2 0;
		ptr_rd<=#2 0;
		rd_cnt<=#2 0;
		rd_state<=#2 0;
	end
	else begin
		case(rd_state)
		0:begin
			if(ptr_fifo_rd == 1) begin
				rd_state<=#2 1;
				packet_info_rd<=#2 1;
			end
		end
		1:begin
			packet_info_rd<=#2 0;
			if(ptr_rd_valid) begin
				ptr_dout<=#2 ptr_rd_data[15:0];
			end
			if(packet_info_rd_valid) begin
				packet_info_reg<=#2 packet_info_rd_data;
				block_rd_num<=#2 packet_info_rd_data[204:200];
				rd_addr<=#2 0;
				block_rd_cnt<=#2 0;
				state<=#2 2;
			end
		end
		2:begin
			if(data_fifo_rd)begin
				rd_addr<=#2 rd_addr+1;
				block_we<=#2 0;
				if(rd_addr == 1<<BLOCK_ADDR_DEPTH-1)
					block_rd_cnt<=#2 block_rd_cnt+1;
				if((rd_addr == 1<<BLOCK_ADDR_DEPTH-2) && block_rd_cnt < block_rd_num-1)
					block_we<=#2 1;
			end
			else begin
				block_we<=#2 1;
				rd_state<=#2 3;
			end
		end
		3:begin
			block_we<=#2 0;
			rd_state<=#2 0;
		end
		endcase

	end

end
//用于查看每个块是否空闲，优先级队列可以优先告诉我们哪个块即空闲而且对应的索引小

sync_fifo #(
    .ADDR_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH),
    .DATA_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH)
	)
	block_status_prio_fifo(
    .clk(clk),
    .rst_n(rstn),
    .fifo_rd_en(block_re),
    .fifo_wr_en(block_we),
    .fifo_wr_data(packet_info_reg[200-block_rd_cnt*6-1:200-block_cnt*6-6]),
    .fifo_rd_data(block_index),
	.data_count(block_used)
);

//用于存储比较每个包的时间信息以及对应存储位置信息
prio_label_fifo #(
    .ADDR_WIDTH(MAX_PACKET_DEPTH),
    .DATA_WIDTH(16+5+200),
	.LABEL_WIDTH(16),
    .CLEAR_ON_INIT(1)
	)
	packet_info_prio_fifo(
    .clk(clk),
    .rst(!rstn),
    .re(packet_info_rd),
    .we(packet_info_we),
    .din(time_index),
    .dout(packet_info_rd_data),
    .valid(packet_info_rd_valid)
);

//用于储存每个包的长度信息的优先级队列，16为表示ddl，16为包长度
prio_label_fifo #(
    .ADDR_WIDTH(MAX_PACKET_DEPTH),
    .DATA_WIDTH(16+16),
	.LABEL_WIDTH(16),
    .CLEAR_ON_INIT(1)
	)
	packet_ptr_prio_fifo(
    .clk(clk),
    .rst(!rstn),
    .re(ptr_fifo_rd),
    .we(ptr_fifo_wr),
    .din(ptr_fifo_din),
    .dout(ptr_rd_data),
    .valid(ptr_rd_valid),
	.empty(ptr_fifo_empty),
	.full(ptr_fifo_full)
);

dpram_sclk #(
	.ADDR_WIDTH(MAX_DATA_DEPTH),
	.DATA_WIDTH(DATA_WIDTH)
	)
	queue_data_ram(
	.clk(clk),
	.rst(!rstn),
	.raddr(packet_info_reg[200-block_rd_cnt*6-1:200-block_cnt*6-6]+rd_addr),
	.re(data_fifo_rd),
	.waddr(data_waddr+block_index<<BLOCK_ADDR_DEPTH),
	.we(data_fifo_wr),
	.din(data_fifo_din),
	.dout(data_fifo_dout)
);


endmodule
