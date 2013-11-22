//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    driver 
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Implements a driver to control SPART operation
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,						// 100 MHz clock
    input rst,						// Asynchronous reset, tied to dip switch 0
	 input dav,
	 input [7:0] data_in,
	 output reg [1:0] addr,
	 output [1:0] status_bits,
	 input [1:0] br_cfg,
	 output reg iocs,
	 output reg iorw,
	 input rda,
	 input tbr,
	 output reg [1:0] ioaddr,
	 inout [7:0] databus 
    );
	 
	 reg [7:0] status, next_status;
	 reg [2:0] state, next_state;
	 reg [7:0] temp_data;	
    wire [15:0] baud_count;
	 wire [7:0] data_flip;
    
	 localparam LOAD_LOW = 3'd0, LOAD_HIGH = 3'd1, WAIT = 3'd2, STATUS = 3'd3, X_POS = 3'd4, Y_POS = 3'd5;
	 
    assign baud_count = (br_cfg == 2'b00) ? 16'd1301 : 
                        (br_cfg == 2'b01) ? 16'd650 : 
                        (br_cfg == 2'b10) ? 16'd325 : 16'd162;
    assign databus = (!iorw) ? temp_data : 8'bzzzzzzzz;
	 assign status_bits = status[1:0];
	 assign data_flip = {data_in[0], data_in[1], data_in[2], data_in[3], data_in[4], data_in[5], data_in[6], data_in[7]};
	 
    always@(posedge clk, posedge rst) begin
		if(rst) begin
		    state <= LOAD_LOW;
			 status <= 8'd0;
		end
		else begin
		    state <= next_state;
			 status <= next_status;
		end
    end
    
    always@(*) begin
       iocs = 1'b1;
       iorw = 1'b1;
       ioaddr = 2'b11;
       temp_data = 8'bxxxxxxxx;
       next_state = state;
       addr = 2'd0;
       next_status = status;
	    case(state)
	        LOAD_LOW: begin
	           iocs = 1'b1;
	           iorw = 1'b0;
	           ioaddr = 2'b10;
	           temp_data = baud_count[7:0];
	           next_state = LOAD_HIGH;    
	        end
	        LOAD_HIGH: begin
	           iocs = 1'b1;
	           iorw = 1'b0;
	           ioaddr = 2'b11;
	           temp_data = baud_count[15:8];
	           next_state = WAIT; 
	        end
	        WAIT: begin
	           if(dav)
	              next_state = STATUS;
	        end
	        STATUS: begin
	           if(tbr) begin
	              addr = 2'd0;
	              next_status = data_in[7:0];
	              iocs = 1'b1;
	              iorw = 1'b0;
	              ioaddr = 2'b00;
	              temp_data = data_flip;
	              next_state = X_POS;
	           end
	        end
	        X_POS: begin
	           if(tbr) begin
	              addr = 2'd1;
	              iocs = 1'b1;
	              iorw = 1'b0;
	              ioaddr = 2'b00;
	              temp_data = data_flip;
	              next_state = Y_POS;
	           end
	        end
	        Y_POS: begin
	           if(tbr) begin
	              addr = 2'd2;
	              iocs = 1'b1;
	              iorw = 1'b0;
	              ioaddr = 2'b00;
	              temp_data = data_flip;
	              next_state = WAIT;
	           end
	        end
	    endcase
    end
    
endmodule
