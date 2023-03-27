
module sync_fifo
#(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 16,
	parameter COUNT_WIDTH = ADDR_WIDTH
)
(
		rst_n		,
		clk			,
		fifo_wr_en	,
		fifo_full	,
		fifo_wr_data,
		
		fifo_rd_en	,
		fifo_rd_data,
		fifo_empty	,
		
		fifo_wr_err ,
		fifo_rd_err
		
);

		input 						rst_n			;
		input 						clk				;
		input 						fifo_wr_en		;
		input  [DATA_WIDTH-1:0]		fifo_wr_data	;
		input 						fifo_rd_en		;
		
		output 						fifo_full		;
		output [DATA_WIDTH-1:0]		fifo_rd_data	;
		output 						fifo_empty		;
		
		
		output 						fifo_wr_err		;
		output 						fifo_rd_err		;
		
		reg	   [ADDR_WIDTH-1:0]  	rdaddress		;
		reg	   [ADDR_WIDTH-1:0]  	wraddress		;
	
		reg	   [COUNT_WIDTH-1:0]	data_cnt		;
		
		assign fifo_full = (data_cnt == (1<<ADDR_WIDTH));
		assign fifo_empty = (data_cnt == 0);
		
		assign fifo_wr_err = (data_cnt == (1<<ADDR_WIDTH) && fifo_wr_en);
		assign fifo_rd_err = (data_cnt == 0 && fifo_rd_en);
	
		dpram_sclk  #(
 				.ADDR_WIDTH(ADDR_WIDTH),
    			.DATA_WIDTH(DATA_WIDTH),
    			.CLEAR_ON_INIT(1),
    			.ENABLE_BYPASS(1)
			)
			ram(
			.clk		(clk),
			.rst        (~rst_n),
			.din		(fifo_wr_data),
			.raddr		(rdaddress),
			.waddr		(wraddress),
			.we			(fifo_wr_en),
			.re			(1'b1),
			.dout		(fifo_rd_data)
			);
			
		
			
		/*读数据地址生成*/
		always@(posedge clk or negedge rst_n)
		if(!rst_n)
			rdaddress <= {ADDR_WIDTH{1'b0}};
		else if(fifo_rd_en && ~fifo_empty)begin
			rdaddress <= rdaddress + 1'b1;
		end
		
		/*写数据地址生成*/
		always@(posedge clk or negedge rst_n)
		if(!rst_n)
			wraddress <= {ADDR_WIDTH{1'b0}};
		else if(fifo_wr_en && ~fifo_full)begin
			wraddress <= wraddress + 1'b1;
		end
		
		/*fifo 中存储的数据长度计数*/
		always@(posedge clk or negedge rst_n)
		if(!rst_n)
			data_cnt <= 0;
		else if(fifo_wr_en && ~fifo_rd_en && ~fifo_full)
			data_cnt <= data_cnt + 1'b1;
		else if(fifo_rd_en && ~fifo_wr_en && ~fifo_empty)
			data_cnt <= data_cnt - 1'b1;
		else 
			data_cnt <= data_cnt;

endmodule