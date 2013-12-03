module Audio_Setup(input clk, input rst, input shft_ready, output[75:0] shft_data, output shft_load, output done);

	parameter NUM_CMDS = 4;
	
	reg[3:0] cmd_cnt;
	
	assign shft_load = (shft_ready && cmd_cnt != NUM_CMDS) ? 1'd1 : 1'd0;
	
	assign shft_data = (cmd_cnt == 0) ? 76'hE000_02000_08080_00000 : // Master volume
							 (cmd_cnt == 1) ? 76'hE000_0A000_80000_00000 : // Mute PC_BEEP
							 (cmd_cnt == 2) ? 76'hE000_04000_00000_00000 : // Aux Out Volume
							 (cmd_cnt == 3) ? 76'hE000_18000_00000_00000 : // PCM Volume
													76'h0000_00000_00000_00000;
													
	assign done = (cmd_cnt == NUM_CMDS);
	
	always@(posedge clk) begin
		if(rst)
			cmd_cnt <= 0;
		else if(shft_ready && cmd_cnt < NUM_CMDS)
			cmd_cnt <= cmd_cnt + 1;
	end
	
endmodule
