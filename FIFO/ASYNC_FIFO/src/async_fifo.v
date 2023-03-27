/*异步fifo 参考文献  Simulation and Synthesis Techniques for Asynchronous FIFO Design*/
//When the two clk are the same, there may some problem
module async_fifo
#(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 16,
	parameter COUNT_WIDTH = ADDR_WIDTH+1
)
(
		rst_n			,
		fifo_wr_clk	,
		fifo_wr_en	,
		r_fifo_full	,
		fifo_wr_data,
		
		fifo_rd_clk	,
		fifo_rd_en	,
		fifo_rd_data,
		r_fifo_empty,
        wr_data_count
		
		
	);
        
		input rst_n			;
		input fifo_wr_en	;
		input	[DATA_WIDTH-1:0]fifo_wr_data;
		input fifo_rd_en	;
		input fifo_rd_clk;
		input fifo_wr_clk;
		output reg r_fifo_full	;
		output [DATA_WIDTH-1:0] fifo_rd_data;
		output reg r_fifo_empty	;
		output [ADDR_WIDTH-1:0] wr_data_count;
		
		
		reg	[COUNT_WIDTH-1:0]  rdaddress; //RAM地址为9位地址 扩展一位用于同步
		reg	[COUNT_WIDTH-1:0]  wraddress;
        reg	[ADDR_WIDTH-1:0]  data_cnt0=0;
        reg	[ADDR_WIDTH-1:0]  data_cnt1=0;
		wire	[COUNT_WIDTH-1:0]	gray_rdaddress;
		wire	[COUNT_WIDTH-1:0]	gray_wraddress;
		
		/*同步寄存器*/
		reg	[COUNT_WIDTH-1:0] sync_w2r_r1,sync_w2r_r2;
		reg	[COUNT_WIDTH-1:0] sync_r2w_r1,sync_r2w_r2;
		
		wire fifo_empty;
		wire fifo_full;
        
		assign wr_data_count = (data_cnt0 >= data_cnt1) ? (data_cnt0-data_cnt1):(data_cnt0+1+({ADDR_WIDTH{1'b1}}-data_cnt1));
		/*二进制转化为格雷码计数器*/
		assign gray_rdaddress = (rdaddress >>1) ^ rdaddress;//(({1'b0,rdaddress[9:1]}) ^ rdaddress);
		
		/*二进制转化为格雷码计数器*/
		assign gray_wraddress = (({1'b0,wraddress[COUNT_WIDTH-1:1]}) ^ wraddress);
		
		assign fifo_empty = (gray_rdaddress == sync_w2r_r2);
		
		assign fifo_full = (gray_wraddress == {~sync_r2w_r2[COUNT_WIDTH-1:COUNT_WIDTH-2],sync_r2w_r2[COUNT_WIDTH-3:0]});

		dpram_aclk  #(
            .ADDR_WIDTH(ADDR_WIDTH),
            .DATA_WIDTH(DATA_WIDTH)
        )
        ram(
            .rst(!rst_n),
			.din		(fifo_wr_data		),
			.raddr(rdaddress[ADDR_WIDTH-1:0]),
			.rd_clk	(fifo_rd_clk	),
			.re (fifo_rd_en),
			.waddr(wraddress[ADDR_WIDTH-1:0]),
			.wr_clk	(fifo_wr_clk	),
			.we		(fifo_wr_en	),
			.dout		(fifo_rd_data)
			);	
		
		/*在读时钟域同步FIFO空 sync_w2r_r2 为同步的写指针地址 延迟两拍 非实际 写指针值 但是确保不会发生未写入数据就读取*/	
		always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)
			r_fifo_empty <= 1'b1;
		else 
			r_fifo_empty <= fifo_empty;


			/*在写时钟域判断FIFO满 sync_r2w_r2 实际延迟两个节拍 可能存在非满判断为满 但不会导致覆盖*/
		always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)
			r_fifo_full <= 1'b0;
		else 									
			r_fifo_full <= fifo_full;//格雷码判断追及问题			
			
			
		/*读数据地址生成*/
		always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)
			rdaddress <= {COUNT_WIDTH{1'b0}};
		else if(fifo_rd_en && ~fifo_empty)begin
			rdaddress <= rdaddress + 1'b1;
		end
		
		/*写数据地址生成*/
		always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)
			wraddress <=  {COUNT_WIDTH{1'b0}};
		else if(fifo_wr_en && ~r_fifo_full)begin
			wraddress <= wraddress + 1'b1;
		end
		
		/*同步读地址到写时钟域*/
		always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)begin
			sync_r2w_r1 <=  {COUNT_WIDTH{1'b0}};
			sync_r2w_r2 <=  {COUNT_WIDTH{1'b0}};
		end else begin
			sync_r2w_r1 <= gray_rdaddress;
			sync_r2w_r2 <= sync_r2w_r1;		
		end

		/*同步写地址到读时钟域, 同步以后 存在延迟两个节拍*/
		always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)begin
			sync_w2r_r1 <=  {COUNT_WIDTH{1'b0}};
			sync_w2r_r2 <=  {COUNT_WIDTH{1'b0}};
		end else begin
			sync_w2r_r1 <= gray_wraddress ;
			sync_w2r_r2 <= sync_w2r_r1;		
		end		
        		
        always@(posedge fifo_wr_clk or negedge rst_n)
		if(!rst_n)
			data_cnt0 <= 0;
		else if(fifo_wr_en && ~fifo_full)
			data_cnt0 <= data_cnt0 + 1'b1;
		else 
			data_cnt0 <= data_cnt0;
        
        always@(posedge fifo_rd_clk or negedge rst_n)
		if(!rst_n)
			data_cnt1 <= 0;
		else if(fifo_rd_en && ~fifo_empty)
			data_cnt1 <= data_cnt1 + 1'b1;
		else 
			data_cnt1 <= data_cnt1;
endmodule