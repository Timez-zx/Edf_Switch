module pri_fifo_tb;

		reg rst		;
		reg clk			;
		reg we	;
		reg [15:0] din;
		reg re	;
		wire [15:0] dout;
		wire valid	;

prio_fifo prio_fifo_u1(
		.rst	(rst		),
		.clk			(clk			),
		.we	(we	),
		.din(din),
		.re	(re	),
		.dout(dout),
		.valid(valid)		
	);

	always #5 clk = ~clk;
	
    initial begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, pri_fifo_tb);     //tb模块名称
    end

	initial begin
		rst = 1;
		clk = 0;
		we = 0;
		re = 0;
		din = 0;
		#200;
		rst = 0;
		#200;

		//basic test
		repeat(20) begin
		we = 1;
		din = 4 + {$random} % (200 - 4 + 1);
		#10;
		we = 0;
		#100;
		end
		#200;
		repeat(20) begin
		re = 1;
		#10;
		re = 0;
		#100;
		end

		/*repeat(10) begin
		we = 1;
		din = 4 + {$random} % (200 - 4 + 1);
		#10;
		we = 0;
		#100;
		end

		repeat(10) begin
		we = 1;
		din = 4 + {$random} % (200 - 4 + 1);
		re = 1;
		#10;
		re = 0;
		we = 0;
		#150;
		end*/


		$finish;
	end
	
	
	
	

endmodule
