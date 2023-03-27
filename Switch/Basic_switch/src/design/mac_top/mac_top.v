`timescale 1ns / 1ps

module mac_top(
    input              clk,
	input              rstn,
    input     [3:0]    MII_RXD,
    input              MII_RX_DV,
    input              MII_RX_CLK,
    input              MII_RX_ER,
                  
    output    [3:0]    MII_TXD,
    output             MII_TX_EN,
    output              MII_TX_CLK,
    output             MII_TX_ER,
 
    /*output             e_reset,
    output             e_mdc,
    inout              e_mdio,*/
                  
    output             tx_data_fifo_rd,
    input     [7:0]    tx_data_fifo_dout,
    output             tx_ptr_fifo_rd,
    input     [15:0]   tx_ptr_fifo_dout,
    input              tx_ptr_fifo_empty,
                  
    input             rx_data_fifo_rd,
    output    [7:0]   rx_data_fifo_dout,
    input             rx_ptr_fifo_rd,
	output    [15:0]  rx_ptr_fifo_dout,
    output            rx_ptr_fifo_empty
    );
/*assign e_reset = 1'b1;
miim_top miim_top_m0(
    .reset_i            (1'b0),
    .miim_clock_i       (MII_RX_CLK),
    .mdc_o              (e_mdc),
    .mdio_io            (e_mdio),
    .link_up_o          (),                  //link status
    .speed_o            (),                  //link speed
    .speed_override_i   (2'b11)              //11: autonegoation
    );              */ 
 
mac_r u_mac_r(
    .clk(clk),
    .rstn(rstn),
    .rx_clk(MII_RX_CLK),
    .rx_d(MII_RXD),
    .rx_dv(MII_RX_DV),
    .data_fifo_rd(rx_data_fifo_rd),
    .data_fifo_dout(rx_data_fifo_dout),
    .ptr_fifo_rd(rx_ptr_fifo_rd),
    .ptr_fifo_dout(rx_ptr_fifo_dout),
    .ptr_fifo_empty(rx_ptr_fifo_empty)
    );
mac_t u_mac_t(
    .clk(clk),
    .rstn(rstn),
    .tx_clk(MII_RX_CLK),
    .tx_d(MII_TXD),
    .tx_dv(MII_TX_EN),
    .data_fifo_rd(tx_data_fifo_rd),
    .data_fifo_din(tx_data_fifo_dout),
    .ptr_fifo_rd(tx_ptr_fifo_rd),
    .ptr_fifo_din(tx_ptr_fifo_dout),
    .ptr_fifo_empty(tx_ptr_fifo_empty)  ,
    .tx_c(MII_TX_CLK)        
    );
    
    
endmodule
