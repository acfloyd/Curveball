// AC97 audio codec controller module

module Audio_Controller(
   input clk,
   input rst,
   input cs,
   input rw,
   inout[15:0] data,
   input BIT_CLK,
   output SDATA_OUT,
   output SYNC,
   output AUDIO_RESET_Z
   );
     
	// reset module
	wire audio_ready;
	Audio_Reset ar(clk, rst, AUDIO_RESET_Z, audio_ready);
	
	// audio shifter
	wire shft_load, shft_ready;
	wire[63:0] shft_data;
	Audio_Shifter as(BIT_CLK, rst, shft_load, shft_data, shft_ready, SYNC, SDATA_OUT);
	
	// state machines
	wire[63:0] setup_data;
	wire setup_load, setup_done;
	Audio_Setup aset(BIT_CLK, rst, audio_ready & shft_ready, setup_data, setup_load, setup_done);
	
	wire pulse_load;
	wire[63:0] pulse_data;
	Audio_Pulse apulse(BIT_CLK, rst, setup_done, audio_ready & shft_ready, pulse_data, pulse_load); 
	
	assign shft_load = (setup_done) ? pulse_load : setup_load;
	assign shft_data = (setup_done) ? pulse_data : setup_data;
	
endmodule   


/*
module ROM(clk, addr, data);
    parameter ADDR_W = 8;
    parameter DATA_W = 24;
    parameter ROM_DATA = "undef";
    
    input clk;
    input[ADDR_W-1:0] addr;
    output reg [DATA_W-1:0] data;
    
    reg [DATA_W-1:0] rom[0:2**ADDR_W-1];
    initial $readmemh(ROM_DATA, rom);
    always@(posedge clk) data <= rom[addr];
endmodule
*/
