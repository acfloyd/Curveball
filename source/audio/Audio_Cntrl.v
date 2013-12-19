module Audio_Cntrl(
	input clk, // BIT_CLK
	input rst, // global reset
	input en,  // enable, only set after audio reset and configured
	input[15:0] audio_index, // index into audio ROM, sourced by cmd reg
	input shft_ready, // ready signal from shifter to audio codec
	output[75:0] shft_data, // data to be shifted to audio codec
	output shft_load, // load signal to shifter to audio codec
	output ready // indicates audio_cntrl ready for new index
    );

	// state parameters
	parameter IDLE = 3'd0; // waiting for index
	parameter READ_SIZE_0 = 3'd1; // read MSB of audio size
	parameter READ_SIZE_1 = 3'd2; // read LSB of audio size
	parameter READ_ADDR_0 = 3'd3; // read MSB of audio address
	parameter READ_ADDR_1 = 3'd4; // read LSB of audio address
	parameter SEND = 3'd5; // send data to codec
	parameter WAIT = 3'd6; // wait to set frequency

	// Audio ROM parameters
	parameter ROM_ADDR_W = 13; // MAKE SURE TO CHANGE THIS WHEN COE CHANGES
	parameter ROM_DATA_W = 8; // 8 bit audio

	// frequency parameters
	parameter WAIT_TIME = 2047; // 6 kHz

	// state info
	reg[2:0] state, next_state;

	// Audio ROM
	reg[ROM_ADDR_W-1:0] data_addr, start_addr;
	wire[ROM_ADDR_W-1:0] rom_addr, next_data_addr, next_start_addr;
	wire[ROM_DATA_W-1:0] rom_data;
	reg[ROM_DATA_W*2-1:0] audio_size;
	wire[ROM_DATA_W*2-1:0] next_audio_size;
	//ROM #(ROM_ADDR_W, ROM_DATA_W, "audio.mem") rom(clk, rom_addr, rom_data); // sim ROM
	Audio_ROM rom(clk, rom_addr, rom_data); // Xilinx ROM
	
	// Set ROM address to get out index entries, otherwise set to audio data address
	assign rom_addr = (state == IDLE) ? audio_index & 16'h7FFF : 
	                  (state == READ_ADDR_1 && next_state == SEND) ? next_start_addr :
			   data_addr;
			   
	assign next_data_addr = (state == IDLE) ? rom_addr + 1 : 
	                        (state == READ_ADDR_1 && next_state == SEND) ? next_start_addr :
	                        (state != WAIT) ? data_addr + 1 :
	                         data_addr;
	                         
	assign next_audio_size = (state == READ_SIZE_0) ? rom_data :
				 (state == READ_SIZE_1) ? {audio_size[ROM_DATA_W-1:0], rom_data} :
				  audio_size;
				  
	assign next_start_addr = (state == READ_ADDR_0) ? {rom_data, 8'd0} : //HACK
	                         (state == READ_ADDR_1) ? start_addr | rom_data : 0;

   	// shifter connections
   	assign shft_load = (state == SEND) ? 1'b1: 1'b0;
   	assign shft_data = (state == SEND) ? {56'h9000_00000_00000, rom_data, 12'd0} : 0;
   	assign ready = (state == IDLE && ~rst && en);

	// wait counting info
	reg[ROM_ADDR_W-1:0] sent_count;
	reg[clog2(WAIT_TIME)-1:0] wait_count;
	wire[ROM_ADDR_W-1:0] next_sent_count;
	wire[clog2(WAIT_TIME)-1:0] next_wait_count;
	
	// update sent count on each data send
	assign next_sent_count = (state == IDLE) ? 0 :
				 (state == SEND) ? sent_count + 1:
				  sent_count;
				  
	// update wait count only during WAIT state			  
	assign next_wait_count = (state == WAIT)? wait_count + 1: 0;

	// sequential logic
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			state <= IDLE;
			data_addr <= 0;
			start_addr <= 0;
			audio_size <= 0;
			sent_count <= 0;
			wait_count <= 0;
		end 
		else if(en) begin
			state <= next_state;
			data_addr <= next_data_addr;
			start_addr <= next_start_addr;
			audio_size <= next_audio_size;
			sent_count <= next_sent_count;
			wait_count <= next_wait_count;
		end
	end
	
	// next state logic
	always@(*) begin
		case(state)
			// wait for audio index to be set, then gather audio playback info	
			IDLE:	if(audio_index != 0) next_state = READ_SIZE_0;
				   else next_state = IDLE;			
			
			READ_SIZE_0: next_state = READ_SIZE_1;
			
			READ_SIZE_1: next_state = READ_ADDR_0;
			
			READ_ADDR_0 : next_state = READ_ADDR_1;
			
			READ_ADDR_1: next_state = SEND;
			
			SEND: next_state = WAIT;
			
			// stay in wait loop until frequency count ends, exit if done sending
			WAIT: if(wait_count == WAIT_TIME)
					if(sent_count == audio_size) next_state = IDLE;
					else next_state = SEND;
			      else next_state = WAIT;
			endcase
	end

	// ceiling log2 function for dynamic address sizing
	function integer clog2;
		input integer value;
		begin 
			value = value-1;
			for (clog2=0; value>0; clog2=clog2+1)
				value = value>>1;
		end 
  endfunction
  
endmodule

/* ONLY NEEDED FOR SIMULATION
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
