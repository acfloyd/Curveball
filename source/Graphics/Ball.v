module Ball(output[23:0] color, output [3:0] zone_copy, input [15:0] x_loc, y_loc, z_loc, pixel_x, pixel_y, input clk, rst);
    
    reg [15:0] r_pixel_y;								//holds last pixel_y value to trigger on a line change
    reg [12:0] offset;									//increase offset for new line of ROM
    wire [15:0] x_bound, y_bound;						//x and y ball boundary
    wire [12:0] addr;									//address to ROM
	wire [12:0] next_offset;							//next offset value
	wire[12:0] stage_add;								//amount added to offset for each ROM line (effectively ROM line size)
    wire [3:0] zone;									//current z depth zone displaying in
    wire [23:0] rom_data;								//select proper ROM output
	wire [23:0] data_0;									//data from each ROM
	wire [23:0] data_1;
	wire [23:0] data_2;
	wire [23:0] data_3;
	wire [23:0] data_4;
	wire [23:0] data_5;
	wire [23:0] data_6;
	wire [23:0] data_7;
	wire [23:0] data_8;
	wire [23:0] data_9;
    wire active;										//pixel_x and pixel_y are in the bounds of the ball; output
    
	//length of ROM lines; used to set boundaries and compute ROM address
    localparam STAGE_0 = 8'd69;							
    localparam STAGE_1 = 7'd53;
    localparam STAGE_2 = 7'd43;
    localparam STAGE_3 = 7'd36;
    localparam STAGE_4 = 7'd31;
    localparam STAGE_5 = 6'd27;
    localparam STAGE_6 = 6'd24;
    localparam STAGE_7 = 6'd22;
    localparam STAGE_8 = 6'd20;
    localparam STAGE_9 = 5'd18;
    
	//instantiate all ROMs
    Ball_ROM_0 rom_0(.clka(clk), .addra(addr), .douta(data_0));
    Ball_ROM_1 rom_1(.clka(clk), .addra(addr[11:0]), .douta(data_1));
    Ball_ROM_2 rom_2(.clka(clk), .addra(addr[11:0]), .douta(data_2));
    Ball_ROM_3 rom_3(.clka(clk), .addra(addr[11:0]), .douta(data_3));
    Ball_ROM_4 rom_4(.clka(clk), .addra(addr[11:0]), .douta(data_4));
    Ball_ROM_5 rom_5(.clka(clk), .addra(addr[9:0]), .douta(data_5));
    Ball_ROM_6 rom_6(.clka(clk), .addra(addr[9:0]), .douta(data_6));
    Ball_ROM_7 rom_7(.clka(clk), .addra(addr[9:0]), .douta(data_7));
    Ball_ROM_8 rom_8(.clka(clk), .addra(addr[9:0]), .douta(data_8));
    Ball_ROM_9 rom_9(.clka(clk), .addra(addr[7:0]), .douta(data_9));
    
	//stores the number of the z depth zone currently occupied
    assign zone = (z_loc <= 7'd99) ? 4'd0 :
                  (z_loc <= 8'd199) ? 4'd1 :
                  (z_loc <= 9'd299) ? 4'd2 :
                  (z_loc <= 9'd399) ? 4'd3 :
                  (z_loc <= 9'd499) ? 4'd4 :
                  (z_loc <= 10'd599) ? 4'd5 :
                  (z_loc <= 10'd699) ? 4'd6 :
                  (z_loc <= 10'd799) ? 4'd7 :
                  (z_loc <= 10'd899) ? 4'd8 : 4'd9; 
	
	//output zone to LEDs
    assign zone_copy = zone;
                  
	//store bound in which a pixel will be output in x direction			  
    assign x_bound = (zone == 4'd0) ? x_loc + STAGE_0 :
                     (zone == 4'd1) ? x_loc + STAGE_1 :
                     (zone == 4'd2) ? x_loc + STAGE_2 :
                     (zone == 4'd3) ? x_loc + STAGE_3 :
                     (zone == 4'd4) ? x_loc + STAGE_4 :
                     (zone == 4'd5) ? x_loc + STAGE_5 :
                     (zone == 4'd6) ? x_loc + STAGE_6 :
                     (zone == 4'd7) ? x_loc + STAGE_7 :
                     (zone == 4'd8) ? x_loc + STAGE_8 : x_loc + STAGE_9;
    
	//store bound in which a pixel will be output in y direction	
    assign y_bound = (zone == 4'd0) ? y_loc + STAGE_0 :
                     (zone == 4'd1) ? y_loc + STAGE_1 :
                     (zone == 4'd2) ? y_loc + STAGE_2 :
                     (zone == 4'd3) ? y_loc + STAGE_3 :
                     (zone == 4'd4) ? y_loc + STAGE_4 :
                     (zone == 4'd5) ? y_loc + STAGE_5 :
                     (zone == 4'd6) ? y_loc + STAGE_6 :
                     (zone == 4'd7) ? y_loc + STAGE_7 :
                     (zone == 4'd8) ? y_loc + STAGE_8 : y_loc + STAGE_9;
							
	//used to add offset the address for the next ROM line						
    assign stage_add = (zone == 4'd0) ? STAGE_0 + 13'd1 :
					   (zone == 4'd1) ? STAGE_1 + 13'd1 :
                       (zone == 4'd2) ? STAGE_2 + 13'd1 :
                       (zone == 4'd3) ? STAGE_3 + 13'd1 :
                       (zone == 4'd4) ? STAGE_4 + 13'd1 :
                       (zone == 4'd5) ? STAGE_5 + 13'd1 :
                       (zone == 4'd6) ? STAGE_6 + 13'd1 :
                       (zone == 4'd7) ? STAGE_7 + 13'd1 :
                       (zone == 4'd8) ? STAGE_8 + 13'd1 : STAGE_9 + 13'd1;
     
    //output the address; address output one pixel early so accurate data is available at each pixel given ROM's one cycle delay
    assign addr = offset + (pixel_x - (x_loc - 16'd1));
    
	//signals that we have a pixel to output
    assign active = ((pixel_x >= x_loc) && (pixel_x <= x_bound)) && ((pixel_y >= y_loc) && (pixel_y <= y_bound)) ? 1'b1 : 1'b0;         
     
	//selects correct data from ROMs
    assign rom_data = (zone == 4'd0) ? data_0 :
                      (zone == 4'd1) ? data_1 :
                      (zone == 4'd2) ? data_2 :
                      (zone == 4'd3) ? data_3 :
                      (zone == 4'd4) ? data_4 :
                      (zone == 4'd5) ? data_5 :
                      (zone == 4'd6) ? data_6 :
                      (zone == 4'd7) ? data_7 :
                      (zone == 4'd8) ? data_8 : data_9;
     
	//if we should output a pixel, output
    assign color = (active) ? rom_data : 3'd0;
	 
	//next offset logic to calculate the next offset used for address in next ROM line
    assign next_offset = (pixel_y < y_loc) ? 13'd0 :
						 ((pixel_y >= y_loc) && (pixel_y <= y_bound)) ? offset + stage_add : 13'd0;
	 
	//sequential logic
    always@(posedge clk, posedge rst) begin
		//resetting registers
		if(rst) begin
			offset <= 13'd0;
	        r_pixel_y <= 16'd0;
		end
	else begin
		//if switching to next line, update the ROM line offset
		if(r_pixel_y != pixel_y)
			offset <= next_offset;
		//register the pixel_y
	    r_pixel_y <= pixel_y;
		end   
    end
	 
endmodule
