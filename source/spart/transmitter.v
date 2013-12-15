`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    transmitter
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Transmits data to workstation terminal
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmitter(output TxD, output reg TBR, input [7:0] trans_buff, input clk, rst, txEnable, trans_load);
  
  reg [7:0] trans_buff_hold;			// hold the data to transmit
  reg[3:0] state, next_state;			// state and next state
  reg [9:0] shifter;						// transmitter shifter
  reg trans_load_hold;					// to hold the transmitter load signal
  
  // state variables
  localparam IDLE = 4'd0, START_BIT = 4'd1, STOP_BIT = 4'd10;
  
  // output serial data
  assign TxD = shifter[9];
  
  // sequential logic
  always@(posedge clk, posedge rst) begin
	 //reset signals
    if(rst) begin
      state <= 4'b0;
      shifter <= 10'b1111111111;
      trans_load_hold <= 1'b0;
      trans_buff_hold <= trans_buff;
    end
	 
	 
	 else begin
		// loading the transmitter
      if(trans_load) begin
         trans_load_hold <= trans_load;
			trans_buff_hold <= trans_buff;
		end
		
		// baud rate signal received
		if(txEnable) begin
			state <= next_state;				// update state
			trans_load_hold <= 1'b0;
			
			// load the shifter
			if(trans_load_hold && state == IDLE) begin
				shifter <= {1'b0, trans_buff_hold, 1'b1};
			end
			
			// shift out data
			else begin
				shifter <= {shifter[8:0], 1'b1};
			end
		end
	 end
  end
  
  // next state and combinational logic
  // determine next state and output signals
  always@(*) begin
    TBR = 1'b1;				// transmit buffer only read in IDLE state
    case(state)
      IDLE:
        if(trans_load_hold) begin
           next_state = START_BIT;
           TBR = 1'b0;
        end
        else next_state = IDLE;
      STOP_BIT: begin
        next_state = IDLE;
        TBR = 1'b0;
      end
      default: begin
        next_state = state + 4'd1;
        TBR = 1'b0;
      end
      endcase
  end
    
endmodule
