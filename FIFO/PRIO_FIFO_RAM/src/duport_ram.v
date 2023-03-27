module  duport_ram
#(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 16
) 
(clka,clkb,ena,enb,wea,web,addra,addrb,dina,dinb,douta,doutb);

 

input clka,clkb,ena,enb,wea,web;

input [ADDR_WIDTH-1:0] addra,addrb;

input [DATA_WIDTH-1:0] dina,dinb;

output [DATA_WIDTH-1:0] douta,doutb;

reg [DATA_WIDTH-1:0] douta_reg,doutb_reg;
reg[DATA_WIDTH-1:0] ram [(1<<ADDR_WIDTH)-1:0];

assign douta = douta_reg;
assign doutb = doutb_reg;
 

always @(posedge clka) begin 
if (ena) begin
    if (wea)
        ram[addra] <= dina;
    else
        douta_reg <= ram[addra];
    
end
end
 

always @(posedge clkb) begin 
if (enb) begin
    if (web)
        ram[addrb] <= dinb;
    else
        doutb_reg <= ram[addrb];

end
end
endmodule