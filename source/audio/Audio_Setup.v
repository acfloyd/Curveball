// Module responsible for sending configuration cmds to audio codec

module Audio_Setup(
	input clk, // BIT_CLK
	input rst, // global reset
	input shft_ready, // ready signal from shifter to codec
	output[75:0] shft_data, // audio data to be sent to codec
	output shft_load, // load signal to shifter to codec
	output done // signal indicating audio codec has been configured
	);

	// number of commands to be sent to audio codec	
	parameter NUM_CMDS = 4;
	
	reg[3:0] cmd_cnt; // number of cmds sent so far
	
	// send load command to shifter when it's ready and there are more config needed
	assign shft_load = (shft_ready && cmd_cnt != NUM_CMDS) ? 1'd1 : 1'd0;
	
	// set audio codec cmd data
	assign shft_data = (cmd_cnt == 0) ? 76'hE000_02000_08080_00000 : // Unmute Master volume
		  	   (cmd_cnt == 1) ? 76'hE000_0A000_80000_00000 : // Mute PC_BEEP
			   (cmd_cnt == 2) ? 76'hE000_04000_00000_00000 : // Unmute Aux Out Volume
			   (cmd_cnt == 3) ? 76'hE000_18000_00000_00000 : // Unmute PCM Volume
			   		    76'h0000_00000_00000_00000; // NULL cmd
	
	// indicate done once all config cmds have been sent												
	assign done = (cmd_cnt == NUM_CMDS);
	
	// update cmd_cnt each time a config cmd is sent
	always@(posedge clk) begin
		if(rst)
			cmd_cnt <= 0;
		else if(shft_ready && cmd_cnt < NUM_CMDS)
			cmd_cnt <= cmd_cnt + 1;
	end
	
endmodule
