`timescale 1ns / 1ps
module top_switch(
	input              clk,
    input    [3:0]     MII_RXD_0,
    input              MII_RX_DV_0,
    input              MII_RX_CLK_0,
    input              MII_RX_ER_0,
    output   [3:0]     MII_TXD_0,
    output             MII_TX_EN_0,
    output              MII_TX_CLK_0,
    output             MII_TX_ER_0,
    
    /*output             e0_reset,
    output             e0_mdc,
    inout              e0_mdio,*/
	
    input    [3:0]     MII_RXD_1,
    input              MII_RX_DV_1,
    input              MII_RX_CLK_1,
    input              MII_RX_ER_1,
    output   [3:0]     MII_TXD_1,
    output             MII_TX_EN_1,
    output              MII_TX_CLK_1,
    output             MII_TX_ER_1,

    /*output             e1_reset,
    output             e1_mdc,
    inout              e1_mdio,*/

    input    [3:0]     MII_RXD_2,
    input              MII_RX_DV_2,
    input              MII_RX_CLK_2,
    input              MII_RX_ER_2,
    output   [3:0]     MII_TXD_2,
    output             MII_TX_EN_2,
    output              MII_TX_CLK_2,
    output             MII_TX_ER_2,

    /*output             e2_reset,
    output             e2_mdc,
    inout              e2_mdio,*/

    input    [3:0]     MII_RXD_3,
    input              MII_RX_DV_3,
    input              MII_RX_CLK_3,
    input              MII_RX_ER_3,
    output   [3:0]     MII_TXD_3,
    output             MII_TX_EN_3,
    output              MII_TX_CLK_3,
    output             MII_TX_ER_3/*,
    output             e3_reset,
    output             e3_mdc,
    inout              e3_mdio*/
                   
    );
wire	    	     emac0_tx_data_fifo_rd;
wire    [7:0]        emac0_tx_data_fifo_dout;
wire                 emac0_tx_ptr_fifo_rd;
wire    [15:0]       emac0_tx_ptr_fifo_dout;
wire                 emac0_tx_ptr_fifo_empty;
                     
wire                 emac0_rx_data_fifo_rd;
wire    [7:0]        emac0_rx_data_fifo_dout;
wire                 emac0_rx_ptr_fifo_rd;
wire    [15:0]       emac0_rx_ptr_fifo_dout;
wire                 emac0_rx_ptr_fifo_empty;

wire	    	     emac1_tx_data_fifo_rd;
wire    [7:0]        emac1_tx_data_fifo_dout;
wire                 emac1_tx_ptr_fifo_rd;
wire    [15:0]       emac1_tx_ptr_fifo_dout;
wire                 emac1_tx_ptr_fifo_empty;
                     
wire                 emac1_rx_data_fifo_rd;
wire    [7:0]        emac1_rx_data_fifo_dout;
wire                 emac1_rx_ptr_fifo_rd;
wire    [15:0]       emac1_rx_ptr_fifo_dout;
wire                 emac1_rx_ptr_fifo_empty;

wire	    	     emac2_tx_data_fifo_rd;
wire    [7:0]        emac2_tx_data_fifo_dout;
wire                 emac2_tx_ptr_fifo_rd;
wire    [15:0]       emac2_tx_ptr_fifo_dout;
wire                 emac2_tx_ptr_fifo_empty;
                     
wire                 emac2_rx_data_fifo_rd;
wire    [7:0]        emac2_rx_data_fifo_dout;
wire                 emac2_rx_ptr_fifo_rd;
wire    [15:0]       emac2_rx_ptr_fifo_dout;
wire                 emac2_rx_ptr_fifo_empty;

wire	    	     emac3_tx_data_fifo_rd;
wire    [7:0]        emac3_tx_data_fifo_dout;
wire                 emac3_tx_ptr_fifo_rd;
wire    [15:0]       emac3_tx_ptr_fifo_dout;
wire                 emac3_tx_ptr_fifo_empty;
                     
wire                 emac3_rx_data_fifo_rd;
wire    [7:0]        emac3_rx_data_fifo_dout;
wire                 emac3_rx_ptr_fifo_rd;
wire    [15:0]       emac3_rx_ptr_fifo_dout;
wire                 emac3_rx_ptr_fifo_empty;
wire                 clk;

wire                 emac0_packet_info_valid;
wire                 emac1_packet_info_valid;
wire                 emac2_packet_info_valid;
wire                 emac3_packet_info_valid;


mac_top u_mac_top_0(
    .clk(clk),
    .rstn(1'b1),
    .MII_RXD(MII_RXD_0),
    .MII_RX_DV(MII_RX_DV_0),
    .MII_RX_CLK(MII_RX_CLK_0),
    .MII_RX_ER(MII_RX_ER_0),
    .MII_TXD(MII_TXD_0),
    .MII_TX_CLK(MII_TX_CLK_0),
    .MII_TX_EN(MII_TX_EN_0),
    .MII_TX_ER(MII_TX_ER_0),
    
    /*.e_reset(e0_reset),
    .e_mdc(e0_mdc),
    .e_mdio(e0_mdio),*/
                     
    .rx_data_fifo_rd(emac0_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac0_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac0_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac0_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac0_rx_ptr_fifo_empty),
                     
    .tx_data_fifo_rd(emac0_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac0_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac0_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac0_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac0_tx_ptr_fifo_empty),
    .tx_packet_info_valid(emac0_packet_info_valid)
    );
mac_top u_mac_top_1(
    .clk(clk),
    .rstn(1'b1),
    .MII_RXD(MII_RXD_1),
    .MII_RX_DV(MII_RX_DV_1),
    .MII_RX_CLK(MII_RX_CLK_1),
    .MII_RX_ER(MII_RX_ER_1),
    .MII_TX_CLK(MII_TX_CLK_1),
    .MII_TXD(MII_TXD_1),
    .MII_TX_EN(MII_TX_EN_1),
    .MII_TX_ER(MII_TX_ER_1),
    
    /*.e_reset(e1_reset),
    .e_mdc(e1_mdc),
    .e_mdio(e1_mdio),*/
                                            
    .rx_data_fifo_rd(emac1_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac1_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac1_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac1_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac1_rx_ptr_fifo_empty),
                                            
    .tx_data_fifo_rd(emac1_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac1_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac1_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac1_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac1_tx_ptr_fifo_empty),
    .tx_packet_info_valid(emac1_packet_info_valid)
    );
mac_top u_mac_top_2(
    .clk(clk),
    .rstn(1'b1),
    .MII_RXD(MII_RXD_2),
    .MII_RX_DV(MII_RX_DV_2),
    .MII_RX_CLK(MII_RX_CLK_2),
    .MII_RX_ER(MII_RX_ER_2),
    .MII_TX_CLK(MII_TX_CLK_2),
    .MII_TXD(MII_TXD_2),
    .MII_TX_EN(MII_TX_EN_2),
    .MII_TX_ER(MII_TX_ER_2),
    
    /*.e_reset(e2_reset),
    .e_mdc(e2_mdc),
    .e_mdio(e2_mdio),*/
                                                                   
    .rx_data_fifo_rd(emac2_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac2_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac2_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac2_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac2_rx_ptr_fifo_empty),
                                                                   
    .tx_data_fifo_rd(emac2_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac2_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac2_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac2_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac2_tx_ptr_fifo_empty),
    .tx_packet_info_valid(emac2_packet_info_valid)
    );     
mac_top u_mac_top_3(
    .clk(clk),
    .rstn(1'b1),
    .MII_RXD(MII_RXD_3),
    .MII_RX_DV(MII_RX_DV_3),
    .MII_RX_CLK(MII_RX_CLK_3),
    .MII_RX_ER(MII_RX_ER_3),
    .MII_TX_CLK(MII_TX_CLK_3),
    .MII_TXD(MII_TXD_3),
    .MII_TX_EN(MII_TX_EN_3),
    .MII_TX_ER(MII_TX_ER_3),
    
    /*.e_reset(e3_reset),
    .e_mdc(e3_mdc),
    .e_mdio(e3_mdio),*/
                                         
    .rx_data_fifo_rd(emac3_rx_data_fifo_rd),
    .rx_data_fifo_dout(emac3_rx_data_fifo_dout),
    .rx_ptr_fifo_rd(emac3_rx_ptr_fifo_rd),
    .rx_ptr_fifo_dout(emac3_rx_ptr_fifo_dout),
    .rx_ptr_fifo_empty(emac3_rx_ptr_fifo_empty),
                                         
    .tx_data_fifo_rd(emac3_tx_data_fifo_rd),
    .tx_data_fifo_dout(emac3_tx_data_fifo_dout),
    .tx_ptr_fifo_rd(emac3_tx_ptr_fifo_rd),
    .tx_ptr_fifo_dout(emac3_tx_ptr_fifo_dout),
    .tx_ptr_fifo_empty(emac3_tx_ptr_fifo_empty),
    .tx_packet_info_valid(emac3_packet_info_valid)
    );   

wire               sfifo_rd;
wire     [7:0]     sfifo_dout;
wire               ptr_sfifo_rd;
wire     [15:0]    ptr_sfifo_dout;
wire               ptr_sfifo_empty;
interface_mux u_interface_mux(
    .clk(clk),
	.rstn(1'b1),
    .rx_data_fifo_dout0(emac0_rx_data_fifo_dout),
	.rx_data_fifo_rd0(emac0_rx_data_fifo_rd),
	.rx_ptr_fifo_dout0(emac0_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd0(emac0_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty0(emac0_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout1(emac1_rx_data_fifo_dout),
	.rx_data_fifo_rd1(emac1_rx_data_fifo_rd),
	.rx_ptr_fifo_dout1(emac1_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd1(emac1_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty1(emac1_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout2(emac2_rx_data_fifo_dout),
	.rx_data_fifo_rd2(emac2_rx_data_fifo_rd),
	.rx_ptr_fifo_dout2(emac2_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd2(emac2_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty2(emac2_rx_ptr_fifo_empty),
										 
	.rx_data_fifo_dout3(emac3_rx_data_fifo_dout),
	.rx_data_fifo_rd3(emac3_rx_data_fifo_rd),
	.rx_ptr_fifo_dout3(emac3_rx_ptr_fifo_dout),
	.rx_ptr_fifo_rd3(emac3_rx_ptr_fifo_rd),
	.rx_ptr_fifo_empty3(emac3_rx_ptr_fifo_empty),
										 
	.sfifo_rd(sfifo_rd),
	.sfifo_dout(sfifo_dout),
	.ptr_sfifo_rd(ptr_sfifo_rd),
	.ptr_sfifo_dout(ptr_sfifo_dout),
	.ptr_sfifo_empty(ptr_sfifo_empty)
    );
                               
wire         sof;
wire         dv;
wire  [7:0]  data;
wire         se_source;
wire  [47:0] se_mac;
wire  [15:0] source_portmap;
wire         se_req;
wire         se_ack;
wire  [15:0] se_result;   
wire  [9:0]  se_hash;
wire         se_nak;
wire         aging_req;
wire         aging_ack;

wire         bp0;
wire  		 bp1;
wire		 bp2;
wire         bp3;

frame_process u_frame_process(
    .clk(clk),
	.rstn(1'b1),
	.sfifo_dout(sfifo_dout),
	.sfifo_rd(sfifo_rd),
	.ptr_sfifo_rd(ptr_sfifo_rd),
	.ptr_sfifo_empty(ptr_sfifo_empty),
	.ptr_sfifo_dout(ptr_sfifo_dout),
										 
    .sof(sof),
	.dv(dv),
	.data(data),
										 
	.se_mac(se_mac),
	.se_req(se_req),
	.se_ack(se_ack),
	.source_portmap(source_portmap),
	.se_result(se_result),
	.se_nak(se_nak),
	.se_source(se_source),
	.se_hash(se_hash),
										 
	.bp0(bp0),
	.bp1(bp1),
	.bp2(bp2),
	.bp3(bp3)						   	                             
    );
hash_2_bucket u_hash(
    .clk(clk),
	.rstn(1'b1),
	.se_req(se_req),
	.se_ack(se_ack),
	.se_hash(se_hash),
	.se_portmap(source_portmap),
	.se_source(se_source),
	.se_result(se_result),
	.se_nak(se_nak),
	.se_mac(se_mac),
	.aging_req(),
	.aging_ack()
    );


pri_queue_renew  u_qm0(
    .clk(clk),
	.rstn(1'b1),
	.port_id(4'b0001),
	.bp(bp0),
	.sof(sof),
	.dv(dv),
	.data(data),
	.data_fifo_rd(emac0_tx_data_fifo_rd),
	.data_fifo_dout(emac0_tx_data_fifo_dout),
	.ptr_fifo_rd(emac0_tx_ptr_fifo_rd),
	.ptr_fifo_dout(emac0_tx_ptr_fifo_dout),
	.ptr_fifo_empty(emac0_tx_ptr_fifo_empty),
    .packet_rd_valid(emac0_packet_info_valid)
    );   
pri_queue_renew   u_qm1(
    .clk(clk),
	.rstn(1'b1),
	.port_id(4'b0010),
	.bp(bp1),
	.sof(sof),
	.dv(dv),
	.data(data),
	.data_fifo_rd(emac1_tx_data_fifo_rd),
	.data_fifo_dout(emac1_tx_data_fifo_dout),
	.ptr_fifo_rd(emac1_tx_ptr_fifo_rd),
	.ptr_fifo_dout(emac1_tx_ptr_fifo_dout),
	.ptr_fifo_empty(emac1_tx_ptr_fifo_empty),
    .packet_rd_valid(emac1_packet_info_valid)
    );	
pri_queue_renew  u_qm2(
    .clk(clk),
	.rstn(1'b1),
	.port_id(4'b0100),
	.bp(bp2),
	.sof(sof),
	.dv(dv),
	.data(data),
	.data_fifo_rd(emac2_tx_data_fifo_rd),
	.data_fifo_dout(emac2_tx_data_fifo_dout),
	.ptr_fifo_rd(emac2_tx_ptr_fifo_rd),
	.ptr_fifo_dout(emac2_tx_ptr_fifo_dout),
	.ptr_fifo_empty(emac2_tx_ptr_fifo_empty),
    .packet_rd_valid(emac2_packet_info_valid)
    );	
pri_queue_renew  u_qm3(
    .clk(clk),
	.rstn(1'b1),
	.port_id(4'b1000),
	.bp(bp3),
	.sof(sof),
	.dv(dv),
	.data(data),
	.data_fifo_rd(emac3_tx_data_fifo_rd),
	.data_fifo_dout(emac3_tx_data_fifo_dout),
	.ptr_fifo_rd(emac3_tx_ptr_fifo_rd),
	.ptr_fifo_dout(emac3_tx_ptr_fifo_dout),
	.ptr_fifo_empty(emac3_tx_ptr_fifo_empty),
    .packet_rd_valid(emac3_packet_info_valid)
    );	
/*wire    clk_2;
pll_100M U_pll(
    .clk_in1(sys_clk),
	.clk_out1(clk)

    );*/




endmodule
