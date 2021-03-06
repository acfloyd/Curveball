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
			  input sw2,
			  input sw3,
			  output blank,
			  output comp_sync,
			  output hsync,
			  output vsync,
			  output[7:0] pixel_r,
			  output[7:0] pixel_g,
			  output[7:0] pixel_b,
			  output vgaclk,
			  inout MOUSE_CLOCK,
			  inout MOUSE_DATA,
			  input BIT_CLK, 
			  output SDATA_OUT, 
			  output SYNC, 
			  output AUDIO_RESET_Z,
			  output LED_0, 
			  output LED_1, 
			  output LED_2, 
			  output LED_3,
			  output txd,
			  input rxd
    );
        
        wire graphics_VGA_ready;
    wire locked_dcm, cpu_locked_dcm, clkin_ibufg_out;
    wire clk_100mhz_buf, clk_100mhz_buf2;
	wire[23:0] graphics_color;
	wire cpuclk;
	wire Read, Write, CS_RAM, CS_Audio, CS_Graphics, CS_Spart, CS_PS2;
	wire [15:0] Addr, WriteData, DataToCPU, DataBus;
	wire [3:0] zone;
	
	
	proc PROC(.clk(cpuclk), 
			  .rst(rst | ~cpu_locked_dcm), 
			  .WriteMem(Write), 
			  .ReadMem(Read), 
			  .ExternalAddr(Addr),
			  .ExternalWriteData(WriteData), 
			  .ExternalReadData(DataToCPU));

	External_Mem MEM(.clk(cpuclk),
					 .rst(rst | ~cpu_locked_dcm),
					 .Addr(Addr[15:12]), 
					 .WriteData(WriteData), 
					 .Read(Read), 
					 .Write(Write),
					 .DataToCPU(DataToCPU), 
					 .DataBus(DataBus), 
					 .CS_RAM(CS_RAM), 
					 .CS_Audio(CS_Audio), 
					 .CS_Graphics(CS_Graphics), 
					 .CS_Spart(CS_Spart),
					 .CS_PS2(CS_PS2),
					 .switch(sw1));

	proc_ram PROCRAM(.clk(cpuclk),
					 .rst(rst | ~cpu_locked_dcm),
					 .DataBus(DataBus),
					 .Addr(Addr[7:0]),
					 .CS_RAM(CS_RAM),
					 .Read(Read));

    Graphics_ASIC graphics(.clk(cpuclk),
					.rst(rst | ~cpu_locked_dcm),
					.read(Read),
					.chipselect(CS_Graphics),
					.databus(DataBus),
					.data_address(Addr[3:0]),
					.VGA_ready(graphics_VGA_ready),
					.color(graphics_color),
					.zone(zone)
					);
	
	
	ps2_external p_ex(.clk(cpuclk),
							.rst(rst | ~cpu_locked_dcm), 
							.cs(CS_Spart), 
							.addr_in(Addr[1:0]), 
							.DataBus(DataBus), 
							.rxd(rxd));	

	ps2_internal p_in(.clk(cpuclk), 
							.rst(rst | ~cpu_locked_dcm), 
							.cs(CS_PS2), 
							.addr(Addr[1:0]), 
							.DataBus(DataBus), 
							.txd(txd), 
							.MOUSE_CLOCK(MOUSE_CLOCK), 
							.MOUSE_DATA(MOUSE_DATA));

	Audio_Controller ac(.clk(cpuclk),
						.rst(rst | ~cpu_locked_dcm), 
						.cs(CS_Audio), 
						.data(DataBus), 
						.BIT_CLK(BIT_CLK), 
						.SDATA_OUT(SDATA_OUT), 
						.SYNC(SYNC), 
						.AUDIO_RESET_Z(AUDIO_RESET_Z));
	
	
	vga_controller vga(.clk_100mhz_buf(cpuclk),
							 .rst(rst),
							 .Wdata(graphics_color),
							 .vgaclk(vgaclk),
							  .locked_dcm(locked_dcm),
							  .state(graphics_VGA_ready),
							  .blank(blank),
							  .comp_sync(comp_sync),
							  .hsync(hsync),
							  .vsync(vsync),
							  .pixel_r(pixel_r),
							  .pixel_g(pixel_g),
							  .pixel_b(pixel_b));
                                                         
        vga_clk vga_clk_gen1(clk_100mhz, rst, vgaclk, clk_100mhz_buf, locked_dcm);
        cpu_clk cpu_clk_gen1(clk_100mhz, rst, cpuclk, clk_100mhz_buf2, cpu_locked_dcm);
endmodule
