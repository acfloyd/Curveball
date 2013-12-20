//top-level module instatiation
module ps2_mouse(
	output r_ack, 			//signals that the PS/2 mouse has been set to stream mode; debug purposes
	inout [15:0] databus, 		//the databus that the status, x loc, and y loc are driven to
	inout MOUSE_CLOCK, 		//the mouse supplied by the clock and the transmitter during setup
	inout MOUSE_DATA, 		//the data supplied by the clock and the transmitter during setup
	input[1:0] addr, 		//the memory mapped address being read
	input clk, 			//system clock
	input rst, 			//system reset
	input io_cs, 			//chip select
	input read			//data read reqeust
);
  
  reg [16:0] next_pos_x, next_pos_y;				//registers to hold next x and y locations after calculation
  reg [15:0] status, pos_x, pos_y, next_status, r_databus;	//registers to be accessed via memory mapped I/O
  wire [23:0] data_in;						//data from ps2_packets
  wire [15:0] data;						//data for databus
  wire [7:0] byte_rec;						//byte received from ps2_rx
  
  
  //instantiating all submodules
  ps2_clock clock_edge(.clk_high(clk_high), .clk_low(clk_low), .MOUSE_CLOCK(MOUSE_CLOCK), .clk(clk), .rst(rst));
  ps2_tx tx(.TCP(TCP), .r_ack_bit(r_ack_bit), .t_clk(t_clk), .t_data(t_data), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .clk_high(clk_high), .clk_low(clk_low));
  ps2_rx rx(.byte_rec(byte_rec), .received(received), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .TCP(TCP), .clk_low(clk_low));
  ps2_packets packets(.data_out(data_in), .r_dav(dav), .r_ack(r_ack), .data_in(byte_rec), .clk(clk), .rst(rst), .received(received));
  
  //paddle bounds
  localparam top = 16'd0;
  localparam bottom = 16'd308;
  localparam right = 16'd410;
  localparam left = 16'd0;
  localparam middle_x = 16'd204;
  localparam middle_y = 16'd153;
  
  //assign data on a data read
  assign data = (addr == 2'b00) ? status : 
                (addr == 2'b01) ? pos_x :
                (addr == 2'b10) ? pos_y : 16'd0;
			
  //output data onto databus
  assign databus = r_databus;

  //handle tristating of databus
  always@(posedge clk, posedge rst) begin
	if (rst)
		r_databus <= 16'hzzzz;
	else
		if(io_cs && read)
			r_databus <= data;
		else
			r_databus <= 16'hzzzz;
  end  
  
  //updates the status, x, and y locations
  always@(posedge clk, posedge rst) begin
    //reset all registers
    if(rst) begin
      pos_x <= middle_x;
      pos_y <= middle_y;
      status <= 16'd0;
    end
    else begin
      //update the status, x, and y locations
      pos_x <= next_pos_x[15:0];
      pos_y <= next_pos_y[15:0];
      status <= next_status;
    end
  end
  
  //calculates the register updates
  always@(*) begin
    //defaults
    next_pos_x = pos_x;
    next_pos_y = pos_y;
    next_status = status;
    //when data available, receive and operate
    if(dav) begin
      //receive the status, and calculate next x and y locations
      next_status = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, data_in[23:16]};
      next_pos_x = {1'b0, pos_x} + {data_in[20], data_in[20], data_in[20], data_in[20], data_in[20], data_in[20], data_in[20], data_in[20], data_in[20], data_in[15:8]};
      next_pos_y = {1'b0, pos_y} - {data_in[21], data_in[21], data_in[21], data_in[21], data_in[21], data_in[21], data_in[21], data_in[21], data_in[21], data_in[7:0]};
      //perform bounds checks on updated locations
      f(data_in[20] && next_pos_x[16])
        next_pos_x = {1'b0, left};
      else if(next_pos_x[15:0] >= right)
        next_pos_x = {1'b0, right};
      if(!data_in[21] && next_pos_y[16])
        next_pos_y = {1'b0, top};
      else if(next_pos_y[15:0] >= bottom)
        next_pos_y = {1'b0, bottom};
    end
  end
  
endmodule

//interprets the packets received from PS/2 mouse
module ps2_packets(output reg [23:0] data_out, output reg r_dav, r_ack, input [7:0] data_in, input clk, rst, received);
    
   reg [7:0] button_data, x_data, y_data;		//status, x, and y date
   reg [1:0] state, next_state;				//state declarations
   reg ack, dav;					//acknowledge and data available signals
    
   //state paramters
   localparam ACK = 2'd0, BUTTON = 2'd1, X_MOVE = 2'd2, Y_MOVE = 2'd3;
	
   //sequential logic to update state, dav, ack, and data_out
   always@(posedge clk, posedge rst) begin
     //reset signals
     if(rst) begin
        state <= ACK;
        r_dav <= 1'b0;
        r_ack <= 1'b0;
        data_out <= 23'd0; 
     end
     else begin
     	//update the state
        state <= next_state;
        //receive new data
        data_out <= {button_data, x_data, y_data};
        //update dav signal
        r_dav <= dav;
        //if ack is ever sent, stays asserted
        if(ack)
           r_ack <= ack;
     end 
   end
   
   //combinational logic
   always@(*) begin
      //defaults
      next_state = state;
      ack = 1'b0;
      dav = 1'b0;
      button_data = data_out[23:16];
      x_data = data_out[15:8];
      y_data = data_out[7:0];
      //state case statement
      case(state)
      	 //if waiting for ack signal
         ACK: begin
           //packet received
            if(received) begin
               //packet was ack packet
               if(data_in == 8'hfa) begin
                   //set acknowledge signal and move to button state
                   ack = 1'b1;
                   next_state = BUTTON;
               end
            end
         end
         //waiting for status packet
         BUTTON: begin
            //packet received
            if(received) begin
                //store status and go to x movement state
                button_data = data_in;
                next_state = X_MOVE;
            end
         end
         //waiting for status packet
         X_MOVE: begin
            //packet received
            if(received) begin
                //store x movement and go to y movement state
                x_data = data_in;
                next_state = Y_MOVE;
            end
         end
         //waiting for status packet
         Y_MOVE: begin
            //packet received
            if(received) begin
                //store x movement and go to y movement state
                y_data = data_in;
                next_state = BUTTON;
                dav = 1'b1;
            end
         end
      endcase    
   end
   
endmodule

//receives data from PS/2 mouse
module ps2_rx(output reg [7:0] byte_rec, output reg received, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, TCP, clk_low);
  
  reg [9:0] shifter, next_shift;		//shift registers for serial data
  reg [3:0] state, next_state;			//state declarations
  
  //state parameters
  localparam INIT = 4'd0, IDLE = 4'd1, START = 4'd2, STOP = 4'd12;
  
  //sequential logic to update state and shifter
  always@(posedge clk, posedge rst) begin
    //reset state and shifter
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
    end
    else begin
      //update state and shifter
      state <= next_state;
      shifter <= next_shift;
    end
  end
   
  //combinational logic
  always@(*) begin
    //defaults
    next_state = state;
    next_shift = shifter;
    received = 1'b0;
    byte_rec = 7'd0;
    //state case statement
    case(state)
      //waiting for TCP from ps2_tx
      INIT: begin
        //TCP received
        if(TCP)
          //go to idle state and wait for start bit
          next_state = IDLE;  
      end
      //waiting for start of transfer
      IDLE: begin
      	//start bit received
        if(clk_low && !MOUSE_DATA)
          //go to next state
          next_state = state + 4'd1;
      end
      //received all bits
      STOP: begin
        //set received signal
        received = 1'b1;
        //go to idle state
        next_state = IDLE;
        //output packer received
        byte_rec = shifter[7:0];
      end
      //default state
      default: begin
        //new bit received
        if(clk_low) begin
          //receive bit and go to next state
          next_shift = {MOUSE_DATA, shifter[9:1]};
          next_state = state + 4'd1;  
        end
      end
    endcase
  end
  
endmodule

//transmits setup packet to PS/2 mouse
module ps2_tx(output reg TCP, r_ack_bit, t_clk, t_data, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, clk_high, clk_low);
  
  reg [13:0] hold_clk, next_hold_clk;			//signals to hold MOUSE_CLOCK low
  reg [8:0] shifter, next_shift;			//shift registers to shift out data	
  reg [3:0] state, next_state;				//state declarations
  reg m_clk, m_data, ack_bit;				//control MOUSE_CLOCk and MOUSE_DATA trisates
  wire [7:0] status_req;				//status request packet (0xF4)
  
  //state parameters
  localparam INIT = 4'd0, SEND_REQ = 4'd1, SEND_START = 4'd2, SEND_DATA = 4'd3, STOP = 4'd12, ACK = 4'd13;
  
  assign MOUSE_CLOCK = (t_clk) ? m_clk : 1'bz;		//send data over MOUSE_CLOCK or disconnect
  assign MOUSE_DATA = (t_data) ? m_data : 1'bz;		//send data over MOUSE_DATA or disconnect
  assign status_req = 8'hf4;				//initialize data packet
  assign par = ~(^status_req);				//data parity
  
  //sequential logic to update state, shifter, clock hold, and acknowledge signals
  always@(posedge clk, posedge rst) begin
    //reset all signals
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
      hold_clk <= 14'd0;
      r_ack_bit <= 1'b0;
    end
    else begin
      //update state
      state <= next_state;
      //update shifter
      shifter <= next_shift;
      //update clock hold
      hold_clk <= next_hold_clk;
      //if acknowledge received, stays asserted
      if(ack_bit)
         r_ack_bit <= ack_bit;
    end
  end
  
  //combinational logic
  always@(*) begin
    //defaults
    t_clk = 1'b0;
    m_clk = 1'b1;
    t_data = 1'b0;
    m_data = 1'b1;
    next_state = state;
    next_shift = shifter;
    next_hold_clk = hold_clk;
    TCP = 1'b0;
    ack_bit = 1'b0;
    //state case statement
    case(state)
      //waiting for reset or holding state machine after transfer
      INIT: begin
        //not reset yet, or already transferred
        if(!rst && !TCP) begin
          //go to send reqeuest state
          next_state = SEND_REQ;
          //initialize data packet sending
          next_shift = {par, status_req};
          //holds the clock low for 100 microseconds
          next_hold_clk = 14'd10000;
        end 
      end
      //send request state
      SEND_REQ: begin
        //hold MOUSE_CLOCK signal low
        t_clk = 1'b1;
        m_clk = 1'b0;
        //decrement clock hold signal
        next_hold_clk = hold_clk - 14'd1;
        //if we're done holding MOUSE_CLOCK, go to next state
        if(next_hold_clk == 14'd0)
          next_state = state + 4'd1; 
      end
      //send the start bit of transfer
      SEND_START: begin
         //send over MOUSE_DATA bus
         t_data = 1'b1;
         m_data = 1'b0;
         //if MOUSE_CLOCK low, go to next state
         if(clk_low)
           next_state = state + 4'd1;
      end
      //transferred all data
      STOP: begin
      	 //send stop bit
         t_data = 1'b1;
         m_data = 1'b1;
         //if MOUSE_CLOCK low, go to next state
         if(clk_high) begin
           next_state = ACK;
        end
      end
      //waiting for acknowledge bit from PS/2 mouse
      ACK: begin
         //if MOUSE_CLOCK low
         if(clk_low) begin
            //receive bit from mouse and signal that acknowledge was received
            ack_bit = ~MOUSE_DATA;
            //stay in state
            next_state = ACK;
            //output that transmission is complete
            TCP = 1'b1;
         end
      end
      //default state
      default: begin
        //output bit over MOUSE_DATA signal
        t_data = 1'b1;
        m_data = shifter[0];
         //if MOUSE_CLOCK low, update shifter and go to next state
        if(clk_low) begin
          next_shift = {1'b1, shifter[8:1]};
          next_state = state + 4'd1;
        end
      end 
    endcase
  end
    
endmodule

//takes clock samples of MOUSE_CLOCK for use in module
module ps2_clock(output clk_high, output clk_low, inout MOUSE_CLOCK, input clk, rst);
    
    reg [15:0] shifter;			//MOUSE_CLOCK sample shifter
    
    //assign clk_low if sampled 8 1's followed by 8 0's
    assign clk_low = ((shifter[15:8] == 8'b11111111) && (shifter[7:0] == 8'b00000000)) ? 1'b1 : 1'b0;
    //assign clk_high if sampled 8 0's followed by 8 1's
    assign clk_high = ((shifter[15:8] == 8'b00000000) && (shifter[7:0] == 8'b11111111)) ? 1'b1 : 1'b0;
    
    //update shifter
    always@(posedge clk, posedge rst) begin
       //reset shifter
       if(rst) begin
          shifter <= 8'd0;
      end
       else begin
          //shift in a MOUSE_CLOCk sample
          shifter <= {shifter[14:0], MOUSE_CLOCK};
      end
    end
    
endmodule
