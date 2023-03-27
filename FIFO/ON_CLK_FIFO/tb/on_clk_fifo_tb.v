`timescale 1 ns/ 1 ps
module on_clk_fifo_tb();
	reg CLK;
	reg RSTn;
	reg write;
	reg read;
	reg [7:0] iData;
	
	wire [7:0] oData;
	wire full;
	wire empty;


initial
begin
	CLK <= 1'b1;
	forever #10 CLK <= ~CLK;
end

initial begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, on_clk_fifo_tb);     //tb模块名称
end

initial 
begin
		RSTn <= 0;
		read <= 0;
		write <= 0;
		#100;
		RSTn <= 1;
		#100;
		write <= 1;
		#60;
		read <= 1;
		#140;
		write <= 0;
		#60;
		read <= 0;


		#100;
		$finish;
end
	
always @(posedge CLK or negedge RSTn)
if(!RSTn)
	iData <= 8'd0;
else if(write && ~full)
	iData <= iData + 1'b1;




on_clk_fifo fifo (.CLK(CLK),
				  .RSTn(RSTn),
				  .write(write),
				  .read(read),
				  .iData(iData),
				  .full(full),
				  .empty(empty),
				  .oData(oData));
				  
endmodule