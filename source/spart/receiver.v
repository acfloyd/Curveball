`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    receiver
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Receives data from workstation terminal
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module receiver(output [7:0] rec_buff, output RDA, input clk, rst, RxD, rxEnable);
    
  //instantiate receiver and sampler
  rx r(.rec_buff(rec_buff), .RDA(RDA), .clk(clk), .rst(rst), .RxD(RxD), .rxEnable(rxEnable), .start(start), .enable(enable));
  sampler s(.start(start), .enable(enable), .RxD(RxD), .rxEnable(rxEnable), .clk(clk), .rst(rst));

endmodule

//handles sampling of received data
module sampler(output reg start, output reg enable, input RxD, rxEnable, clk, rst);

  reg [3:0] counter, enable_count;			// count the samples received, count enables given
  reg [2:0] start_count;						// count start bit samples
  reg reg_RxD;										// metastability registers for received data
  reg temp;
  
  // state variables
  localparam IDLE = 4'd0, START = 4'd8;

  // sequential logic, handle metastability of received data
  always@(posedge clk, posedge rst) begin
     if(rst) begin
        temp <= 1'b0;
        reg_RxD <= 1'b0;
     end
     else begin
        temp <= RxD;
        reg_RxD <= temp;    
     end 
  end
  
  // sequential logic
  always@(posedge clk, posedge rst) begin
	 // reset signals
    if(rst) begin
      counter <= 4'd0;
      enable <= 1'b0;
      start <= 1'b0;
      enable_count <= 4'd0;
    end
	 
	 // sampling signal received
    else if(rxEnable) begin
	 
		  // start bit has been detected
        if(start) begin
		  
		      // all enable signals given and last data bit through, reset enable and start signals
            if((enable_count == 4'd8) && (counter == 4'd8)) begin
               start <= 1'b0; 
               enable <= 1'b0;
               start_count <= 3'd0;
               enable_count <= 4'd0; 
               counter <= 4'd0;
            end
				
				// sent enable signal
            else if(counter == 4'd15) begin
                enable <= 1'b1;
                enable_count <= enable_count + 4'h1;
                counter <= 4'd0; 
            end
				
				// increment enable sample counter
            else begin
               enable <= 1'b0; 
               counter <= counter + 4'h1; 
            end
        end
		  
		  // start bit not received
        else begin
		  
			  // start bit sample received
           if(!reg_RxD) begin
				  // 8 start bit samples received, output start signal
              if(start_count == 3'd7) begin
                 start <= 1'b1; 
              end
				  
				  // increment start bit samples received
              else begin 
                 start_count <= start_count + 3'h1;
              end
           end
			  
			  // start bit not received
           else begin
              start_count <= 3'd0; 
           end
        end
    end
  end
  
endmodule

// receives data in
module rx(output reg [7:0] rec_buff, output reg RDA, input clk, rst, RxD, rxEnable, start, enable);
  
  reg [3:0] state, next_state;			//state and next state
  reg [7:0] shifter;							// receiver shifter
  reg RDA_flop;
  
  
  // state variables
  localparam IDLE = 4'd0, DATA = 4'd1, END = 4'd8;
  
  // sequential logic
  always@(posedge clk, posedge rst) begin
	 // reset signals
    if(rst) begin
      state <= IDLE;
		shifter <= 8'b11111111;
		rec_buff <= 8'b00000000;
		RDA_flop <= 1'b0;
    end
    else begin
		RDA_flop <= RDA;
	 
	   // sampling signal received
      if(rxEnable) begin
			// enable receive
         if(enable) begin
            shifter <= {shifter[6:0], RxD};		// shifted data in
            state <= next_state;						// update state
         end
      end
		
		// all data received
      if(state == END) begin
			rec_buff <= shifter[7:0];					// output the data received
         state <= next_state; 						// move to IDLE state
      end
	 end
  end
  
  // next state and combinational logic
  // determine next state and output signals
  always@(*) begin
    case(state)
      IDLE: begin
		  RDA = 1'b0;
        if(start) begin
          next_state = DATA;
        end
        else begin
          next_state = IDLE;
        end
		end
      END: begin
		  // output received data avaiable in END state
        if(RDA_flop) begin
          next_state = IDLE;
          RDA = 1'b0;
        end
        else begin
			 RDA = 1'b1;	
          next_state = END;
        end 
      end
      default: begin
		  RDA = 1'b0;
        next_state = state + 4'h1;
      end
	endcase
  end
  
endmodule
