// Top level AC97 audio codec controller module

module Audio_Controller(
   input clk, // CPU clk
   input rst, // global reset
   input cs,  // chip select for writing
   input[15:0] data, // data to be written to cmd reg
   input BIT_CLK, // BIT_CLK FPGA pin
   output SDATA_OUT, // SDATA_OUT FPGA pin
   output SYNC, // SYMC FPGA pin
   output AUDIO_RESET_Z // AUDIO_RESET_Z FPGA pin
   );
  
   	// audio io
   	reg[15:0] cmd_reg;
	reg[31:0] cmd_reg_sync;
        
	// reset module
	wire audio_ready;
	Audio_Reset ar(clk, rst, AUDIO_RESET_Z, audio_ready);
		
	// audio shifter
	wire shft_load, shft_ready;
	wire[75:0] shft_data;
	Audio_Shifter as(BIT_CLK, rst, shft_load, shft_data, shft_ready, SYNC, SDATA_OUT);
	
	// audio setup state machine
	wire[75:0] setup_data;
	wire setup_load, setup_done;
	Audio_Setup aset(BIT_CLK, rst, audio_ready & shft_ready, setup_data, setup_load, setup_done);
	
	// audio cntrl state machine
	wire[75:0] cntrl_data;
	wire cntrl_load, cntrl_ready;
	Audio_Cntrl acntrl(BIT_CLK, rst | cs, setup_done, cmd_reg_sync[31:16], shft_ready, cntrl_data, cntrl_load, cntrl_ready);
	
	// set audio cnttrl state machine to take over control of shifter once audio setup is done
	assign shft_load = (setup_done) ? cntrl_load : setup_load;
	assign shft_data = (setup_done) ? cntrl_data : setup_data;
	
	// audio datapath io
	always@(posedge clk) begin
		if(rst) cmd_reg <= 16'd0;
		else if(cs) cmd_reg <= data;
		else if(~cntrl_ready) cmd_reg <= 16'd0;
	end
	
	// synrchornize input across clock domains
	always@(posedge BIT_CLK) begin
		if(rst) cmd_reg_sync <= 32'd0;
		else cmd_reg_sync <= {cmd_reg_sync[15:0], cmd_reg};
	end

endmodule   
