module pri_fifo_ram_tb;

		reg rst		;
		reg clk			;
		reg we	;
		reg [15:0] din;
		reg re	;
		wire [15:0] dout;
		wire valid	;
		wire empty;
		wire full;

prio_fifo_ram prio_fifo_u1(
		.rst	(rst		),
		.clk			(clk			),
		.we	(we	),
		.din(din),
		.re	(re	),
		.dout(dout),
		.valid(valid),
		.empty(empty),
		.full(full)
	);

	always #5 clk = ~clk;


    initial
    begin            
        $dumpfile("wave.vcd");        //生成的vcd文件名称
        $dumpvars(0, pri_fifo_ram_tb);     //tb模块名称
    end
	initial begin
		rst = 0;
		clk = 0;
		we = 0;
		re = 0;
		din = 0;
		#200;
		rst = 1;
		#200;

		//basic test
		/*repeat(20) begin
		we = 1;
		din[15:8] = 4 + {$random} % (200 - 4 + 1);
        din[7:0] = 0 + {$random} % (100 - 0 + 1);
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
		end*/

		repeat(31) begin
		we = 1;
		din[15:8] = 4 + {$random} % (200 - 4 + 1);
        din[7:0] = 0 + {$random} % (100 - 0 + 1);
		#10;
		we = 0;
		#150;
		end

		repeat(10) begin
		re = 1;
		we = 1;
		din[15:8] = 4 + {$random} % (200 - 4 + 1);
        din[7:0] = 0 + {$random} % (100 - 0 + 1);
		#10;
		re = 0;
		we = 0;
		#200;
		end

		repeat(34) begin
		re = 1;
		#10;
		re = 0;
		#200;
		end


		$finish;
	end
	
	
	
	

endmodule
