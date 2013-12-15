`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:52:55 11/07/2013 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(input clk_100mhz,
			  input rst,
			  input sw1,
			  output LED_0, 
			  output LED_1, 
			  output LED_2, 
			  output LED_3,
			  output txd,
			  input rxd,
			  inout MOUSE_DATA,
			  inout MOUSE_CLOCK
    );
	
	wire [15:0] ps2_mouse_data, spart_data, x_loc, y_loc, x_loc2, x_loc3;
	wire [1:0] ps2_mouse_addr, spart_addr;
	wire TCP, t_clk, t_data, r_ack, r_ack_bit, dav, r_dav, spart_dav, rda, locked_dcm, vgaclk, clk_100mhz_buf;
	wire [1:0] status_bits, status;
	wire [7:0] data_out, data_in;
	wire [3:0] x_bits, y_bits;
	reg rda_hold;
	wire [3:0] read_driver_state;
	
	/*assign LED_0 = ~rda_hold;
	assign LED_1 = ~status[0];
	assign LED_2 = ~status[1]; 
	assign LED_3 = ~1'b0;*/
	assign LED_0 = (sw1)?~x_loc[0]:~read_driver_state[0];
	assign LED_1 = (sw1)?~x_loc[1]:~read_driver_state[1];
	assign LED_2 = (sw1)?~x_loc[2]:~read_driver_state[2];
	assign LED_3 = (sw1)?~x_loc[3]:~read_driver_state[3];
	
	always@(posedge clk_100mhz_buf, posedge rst) begin
		if(rst)
			rda_hold <= 1'b0;
		else
			if(rda)
				rda_hold <= rda;
	end
							  
   ps2_mouse mouse(.x_loc(x_loc2),
						.r_ack(r_ack),
						.data(ps2_mouse_data),
						.dav(dav),
						.MOUSE_CLOCK(MOUSE_CLOCK),
						.MOUSE_DATA(MOUSE_DATA),
						.addr(ps2_mouse_addr),
						.clk(clk_100mhz_buf),
						.rst(rst),
						.io_cs(graphics_chipselect));
						
	writer spart0( .clk(clk_100mhz_buf),
                 .rst(rst),
					  .iocs(iocs),
					  .write(write),
					  .tbr(tbr),
					  .data_in(data_out),
					  .txd(txd)
					);

	write_driver driver0( .clk(clk_100mhz_buf),
	                .rst(rst),
						 .dav(dav),
						 .data_in(ps2_mouse_data),
						 .addr(ps2_mouse_addr),
						 .status_bits(status_bits),
						 .iocs(iocs),
						 .tbr(tbr),
						 .data_out(data_out),
						 .write(write),
						 .x_loc(x_loc3)
					 );
					 
	reader spart1( .clk(clk_100mhz_buf),
                 .rst(rst),
					  .iocs(read_iocs),
					  .rda(rda),
					  .data_out(data_in),
					  .rxd(txd)
					);
	
	// Instantiate your driver here
	read_driver driver1( .clk(clk_100mhz_buf),
	                .rst(rst),
						 .iocs(read_iocs),
						 .rda(rda),
						 .data_in(data_in),
						 .addr(spart_addr),
						 .data_out(spart_data),
						 .dav(spart_dav),
						 .state(read_driver_state)
					 );
				
	paddle_position paddle(.x_loc(x_loc), 
									.y_loc(y_loc), 
									.status(status), 
									.addr(spart_addr), 
									.data(spart_data),
									.dav(spart_dav), 
									.clk(clk_100mhz_buf), 
									.rst(rst));
	
	clk_gen vga_clk_gen1(clk_100mhz, rst, vgaclk, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
	
endmodule
