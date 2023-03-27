module sync_fifo_init_tb;

		reg rst			;
		reg clk			;
		reg fifo_wr_en	;
		reg [5:0]fifo_wr_data=0;
		reg fifo_rd_en	;
		
		wire fifo_full	;
		wire [5:0]fifo_rd_data;
		wire fifo_empty	;
		wire fifo_wr_err;
		wire fifo_rd_err;

sync_fifo_init sync_fifo_u1(
		.rst_n		(rst			),
		.clk			(clk			),
		.fifo_wr_en	(fifo_wr_en	),
		.fifo_full	(fifo_full	),
		.fifo_wr_data(fifo_wr_data),
		.fifo_rd_en	(fifo_rd_en	),
		.fifo_rd_data(fifo_rd_data),
		.fifo_empty	(fifo_empty	),
		.fifo_wr_err	(fifo_wr_err	),
		.fifo_rd_err	(fifo_rd_err	)
		
	);

	always #5 clk = ~clk;
	
    initial begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, sync_fifo_init_tb);     //tb模块名称
    end

	initial begin
		rst = 0;
		clk = 0;
        fifo_rd_en = 0;
        fifo_wr_en = 0;
		#200;
		rst = 1;
		#200;

		//basic test
		// repeat(20) begin
		// fifo_rd_en = 1;
		// #10;
		// fifo_rd_en = 0;
		// end
		// #200;
		repeat(32) begin
        fifo_rd_en = 1;
		#10;
        fifo_rd_en = 0;
		end



        #200;
		$finish;
	end
	
	
	
	

endmodule
