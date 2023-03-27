`timescale 1ns / 1ps
module 	pri_queue_origin
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
reg    [5:0]    data_waddr=0;

reg    [11:0]   length=0;
reg    [11:0]   cnt=0;

reg    [11:0]    block_num=0;
reg    [4:0]    block_cnt=0;
reg    			block_re=0;

reg    [182:0]  time_index=0;
reg             packet_info_we=0;

reg	   [11:0]   block_index_get=0;


wire   [5:0]    block_index;
always@(posedge clk or negedge rstn)
	if(!rstn) begin
		state <= #2 0;
		data_fifo_din<=#2 0;
	end
	else begin
		block_index_get[5:0]<=#2 block_index;
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
			data_waddr<=#2 6'b111111;
		    end
        2:begin
			block_num <=#2 (length + (1<<BLOCK_ADDR_DEPTH) - 1)>>BLOCK_ADDR_DEPTH;
			time_index[154:150]<=#2 block_num[4:0]; 
			time_index[166:155]<=#2 length[11:0]-2;
			if(!dv)begin 
				state<=#2 3;
				block_cnt<=#2 0;
				data_fifo_wr<=#2 0;
				cnt<=#2 0;
				data_waddr<=#2 6'b0;
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
			if(cnt == 36) begin
				time_index[182:175]<=#2 data[7:0]; 
			end
			if(cnt == 37) begin
				time_index[174:167]<=#2 data[7:0]; 
			end
			//data_waddr不同条件判断
			if(data_waddr == 6'b111101 && block_cnt < block_num - 1) begin
				block_re <=#2 1;
				block_cnt<=#2 block_cnt + 1;
			end
			else begin
				block_re<=#2 0;
			end
			if(data_waddr == 0) begin
				case(block_cnt) 
				0:begin
					time_index[150-0*6-1:150-0*6-6]<=#2 block_index;
				end
				1:begin
					time_index[150-1*6-1:150-1*6-6]<=#2 block_index;
				end
				2:begin
					time_index[150-2*6-1:150-2*6-6]<=#2 block_index;
				end
				3:begin
					time_index[150-3*6-1:150-3*6-6]<=#2 block_index;
				end
				4:begin
					time_index[150-4*6-1:150-4*6-6]<=#2 block_index;
				end
				5:begin
					time_index[150-5*6-1:150-5*6-6]<=#2 block_index;
				end
				6:begin
					time_index[150-6*6-1:150-6*6-6]<=#2 block_index;
				end
				7:begin
					time_index[150-7*6-1:150-7*6-6]<=#2 block_index;
				end
				8:begin
					time_index[150-8*6-1:150-8*6-6]<=#2 block_index;
				end
				9:begin
					time_index[150-9*6-1:150-9*6-6]<=#2 block_index;
				end
				10:begin
					time_index[150-10*6-1:150-10*6-6]<=#2 block_index;
				end
				11:begin
					time_index[150-11*6-1:150-11*6-6]<=#2 block_index;
				end
				12:begin
					time_index[150-12*6-1:150-12*6-6]<=#2 block_index;
				end
				13:begin
					time_index[150-13*6-1:150-13*6-6]<=#2 block_index;
				end
				14:begin
					time_index[150-14*6-1:150-14*6-6]<=#2 block_index;
				end
				15:begin
					time_index[150-15*6-1:150-15*6-6]<=#2 block_index;
				end
				16:begin
					time_index[150-16*6-1:150-16*6-6]<=#2 block_index;
				end
				17:begin
					time_index[150-17*6-1:150-17*6-6]<=#2 block_index;
				end
				18:begin
					time_index[150-18*6-1:150-18*6-6]<=#2 block_index;
				end
				19:begin
					time_index[150-19*6-1:150-19*6-6]<=#2 block_index;
				end
				20:begin
					time_index[150-20*6-1:150-20*6-6]<=#2 block_index;
				end
				21:begin
					time_index[150-21*6-1:150-21*6-6]<=#2 block_index;
				end
				22:begin
					time_index[150-22*6-1:150-22*6-6]<=#2 block_index;
				end
				23:begin
					time_index[150-23*6-1:150-23*6-6]<=#2 block_index;
				end
				24:begin
					time_index[150-24*6-1:150-24*6-6]<=#2 block_index;
				end
				endcase
			end
		end
		3:begin
			packet_info_we<=#2 1;
			state<=#2 4;
			end
		4:begin
			packet_info_we<=#2 0;
			state<=#2 0;
			end
		endcase
end

reg   [15:0]    ptr_dout=0;

reg   [BLOCK_ADDR_DEPTH-1:0]     rd_addr=0;
reg   [4:0]		block_rd_cnt=0;
reg   [2:0]     rd_state=0;


reg             packet_info_rd=0;
reg	   [4:0]    block_rd_num=0;

reg				 block_we=0;
reg    [11:0]    block_index_back=0;
reg           	 rd_flag=0;

wire   [182:0]	packet_info_rd_data;
wire            packet_info_rd_valid;
wire   [6:0]    block_remain;
wire            ptr_fifo_full;

assign  ptr_fifo_dout = ptr_dout;
assign  bp=(block_remain>=25)?1:ptr_fifo_full;
always@(posedge clk or negedge rstn) begin
	if(!rstn) begin
		rd_state<=#2 0;
	end
	else begin
		case(block_rd_cnt) 
		0:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-0*6-1:150-0*6-6];
		end
		1:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-1*6-1:150-1*6-6];
		end
		2:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-2*6-1:150-2*6-6];
		end
		3:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-3*6-1:150-3*6-6];
		end
		4:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-4*6-1:150-4*6-6];
		end
		5:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-5*6-1:150-5*6-6];
		end
		6:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-6*6-1:150-6*6-6];
		end
		7:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-7*6-1:150-7*6-6];
		end
		8:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-8*6-1:150-8*6-6];
		end
		9:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-9*6-1:150-9*6-6];
		end
		10:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-10*6-1:150-10*6-6];
		end
		11:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-11*6-1:150-11*6-6];
		end
		12:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-12*6-1:150-12*6-6];
		end
		13:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-13*6-1:150-13*6-6];
		end
		14:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-14*6-1:150-14*6-6];
		end
		15:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-15*6-1:150-15*6-6];
		end
		16:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-16*6-1:150-16*6-6];
		end
		17:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-17*6-1:150-17*6-6];
		end
		18:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-18*6-1:150-18*6-6];
		end
		19:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-19*6-1:150-19*6-6];
		end
		20:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-20*6-1:150-20*6-6];
		end
		21:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-21*6-1:150-21*6-6];
		end
		22:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-22*6-1:150-22*6-6];
		end
		23:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-23*6-1:150-23*6-6];
		end
		24:begin
			block_index_back[5:0]<=#2 packet_info_rd_data[150-24*6-1:150-24*6-6];
		end
		endcase
		case(rd_state)
		0:begin
			if(ptr_fifo_rd == 1) begin
				rd_state<=#2 1;
				packet_info_rd<=#2 1;
			end
		end
		1:begin
			packet_info_rd<=#2 0;
			if(packet_info_rd_valid) begin
				ptr_dout<=#2 {4'b0,packet_info_rd_data[166:155]};
				block_rd_num<=#2 packet_info_rd_data[154:150];
				rd_addr<=#2 0;
				block_rd_cnt<=#2 0;
				rd_state<=#2 2;
				rd_flag<=#2 0;
			end
		end
		2:begin
			if(data_fifo_rd)begin
				rd_addr<=#2 rd_addr+1;
				block_we<=#2 0;
				rd_flag<=#2 1;
				if(rd_addr == 6'b111110)
					block_rd_cnt<=#2 block_rd_cnt+1;
				if((rd_addr == 6'b111110) && (block_rd_cnt < block_rd_num-1))
					block_we<=#2 1;
			end
			else if(!data_fifo_rd && rd_flag) begin
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

sync_fifo_init #(
    .ADDR_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH),
    .DATA_WIDTH(MAX_DATA_DEPTH-BLOCK_ADDR_DEPTH)
	)
	block_status_prio_fifo(
    .clk(clk),
    .rst_n(rstn),
    .fifo_rd_en(block_re),
    .fifo_wr_en(block_we),
    .fifo_wr_data(block_index_back[5:0]),
    .fifo_rd_data(block_index),
	.data_count(block_remain)
);

//用于存储比较每个包的时间信息以及对应存储位置信息
prio_fifo_ram #(
    .ADDR_WIDTH(MAX_PACKET_DEPTH),
    .DATA_WIDTH(16+12+5+150),
	.LABEL_WIDTH(16),
    .CLEAR_ON_INIT(1)
	)
	packet_info_prio_fifo(
    .clk(clk),
    .rst(rstn),
    .re(packet_info_rd),
    .we(packet_info_we),
    .din(time_index),
    .dout(packet_info_rd_data),
    .valid(packet_info_rd_valid),
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
	.raddr((block_index_back<<BLOCK_ADDR_DEPTH)+rd_addr),
	.re(data_fifo_rd),
	.waddr(data_waddr+(block_index_get<<BLOCK_ADDR_DEPTH)),
	.we(data_fifo_wr),
	.din(data_fifo_din),
	.dout(data_fifo_dout)
);


endmodule
