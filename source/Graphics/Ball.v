module Ball(output [3:0] zone_copy, output[23:0] color, input [15:0] x_loc, y_loc, z_loc, pixel_x, pixel_y, input clk, rst);
    
    reg [15:0] r_pixel_y;								//holds last pixel_y value to trigger on a line change
    reg [12:0] offset;									//increase offset for new line of ROM
    wire [15:0] x_bound, y_bound;						//x and y ball boundary
    wire [12:0] addr;									//address to ROM
	wire [12:0] next_offset;							//next offset value
	wire[12:0] stage_add;								//amount added to offset for each ROM line (effectively ROM line size)
    wire [4:0] zone;									//current z depth zone displaying in
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
	wire [23:0] data_10;
	wire [23:0] data_11;
	wire [23:0] data_12;
	wire [23:0] data_13;
	wire [23:0] data_14;
	wire [23:0] data_15;
	wire [23:0] data_16;
	wire [23:0] data_17;
	wire [23:0] data_18;
	wire [23:0] data_19;
    wire active;										//pixel_x and pixel_y are in the bounds of the ball; output
    
	 //length of ROM lines; used to set boundaries and compute ROM address
    localparam STAGE_0 = 8'd69;							
    localparam STAGE_1 = 7'd60;
    localparam STAGE_2 = 7'd53;
    localparam STAGE_3 = 7'd48;
    localparam STAGE_4 = 7'd43;
    localparam STAGE_5 = 7'd39;
    localparam STAGE_6 = 7'd36;
    localparam STAGE_7 = 7'd33;
    localparam STAGE_8 = 5'd31;
    localparam STAGE_9 = 5'd29;
	localparam STAGE_10 = 5'd27;
	localparam STAGE_11 = 5'd26;
	localparam STAGE_12 = 5'd24;
	localparam STAGE_13 = 5'd23;
	localparam STAGE_14 = 5'd22;
	localparam STAGE_15 = 5'd21;
	localparam STAGE_16 = 5'd20;
	localparam STAGE_17 = 5'd19;
	localparam STAGE_18 = 5'd18;
	localparam STAGE_19 = 5'd17;
    
	//instantiate all ROMs
    Ball_ROM_0 rom_0(.clka(clk), .addra(addr), .douta(data_0));
    Ball_ROM_1 rom_1(.clka(clk), .addra(addr[11:0]), .douta(data_1));
    Ball_ROM_2 rom_2(.clka(clk), .addra(addr[11:0]), .douta(data_2));
    Ball_ROM_3 rom_3(.clka(clk), .addra(addr[11:0]), .douta(data_3));
    Ball_ROM_4 rom_4(.clka(clk), .addra(addr[10:0]), .douta(data_4));
    Ball_ROM_5 rom_5(.clka(clk), .addra(addr[10:0]), .douta(data_5));
    Ball_ROM_6 rom_6(.clka(clk), .addra(addr[10:0]), .douta(data_6));
    Ball_ROM_7 rom_7(.clka(clk), .addra(addr[10:0]), .douta(data_7));
    Ball_ROM_8 rom_8(.clka(clk), .addra(addr[9:0]), .douta(data_8));
    Ball_ROM_9 rom_9(.clka(clk), .addra(addr[9:0]), .douta(data_9));
    Ball_ROM_10 rom_10(.clka(clk), .addra(addr[9:0]), .douta(data_10));
    Ball_ROM_11 rom_11(.clka(clk), .addra(addr[9:0]), .douta(data_11));
    Ball_ROM_12 rom_12(.clka(clk), .addra(addr[9:0]), .douta(data_12));
    Ball_ROM_13 rom_13(.clka(clk), .addra(addr[9:0]), .douta(data_13));
    Ball_ROM_14 rom_14(.clka(clk), .addra(addr[9:0]), .douta(data_14));
    Ball_ROM_15 rom_15(.clka(clk), .addra(addr[8:0]), .douta(data_15));
    Ball_ROM_16 rom_16(.clka(clk), .addra(addr[8:0]), .douta(data_16));
    Ball_ROM_17 rom_17(.clka(clk), .addra(addr[8:0]), .douta(data_17));
    Ball_ROM_18 rom_18(.clka(clk), .addra(addr[8:0]), .douta(data_18));
    Ball_ROM_19 rom_19(.clka(clk), .addra(addr[8:0]), .douta(data_19));
    
	//stores the number of the z depth zone currently occupied
    assign zone = (z_loc <= 7'd49) ? 5'd0 :
						(z_loc <= 7'd99) ? 5'd1 :
                  (z_loc <= 8'd149) ? 5'd2 :
						(z_loc <= 8'd199) ? 5'd3 :
                  (z_loc <= 9'd249) ? 5'd4 :
						(z_loc <= 9'd299) ? 5'd5 :
                  (z_loc <= 9'd349) ? 5'd6 :
						(z_loc <= 9'd399) ? 5'd7 :
                  (z_loc <= 9'd449) ? 5'd8 :
						(z_loc <= 9'd499) ? 5'd9 :
                  (z_loc <= 10'd549) ? 5'd10 :
						(z_loc <= 10'd599) ? 5'd11 :
                  (z_loc <= 10'd649) ? 5'd12 :
						(z_loc <= 10'd699) ? 5'd13 :
                  (z_loc <= 10'd749) ? 5'd14 :
						(z_loc <= 10'd799) ? 5'd15 :
                  (z_loc <= 10'd849) ? 5'd16 : 
						(z_loc <= 10'd899) ? 5'd17 :
					   (z_loc <= 10'd949) ? 5'd18 : 5'd19; 
						
	assign zone_copy = zone[3:0];
                  
	//store bound in which a pixel will be output in x direction			  
    assign x_bound = (zone == 5'd0) ? x_loc + STAGE_0 :
                     (zone == 5'd1) ? x_loc + STAGE_1 :
                     (zone == 5'd2) ? x_loc + STAGE_2 :
                     (zone == 5'd3) ? x_loc + STAGE_3 :
                     (zone == 5'd4) ? x_loc + STAGE_4 :
                     (zone == 5'd5) ? x_loc + STAGE_5 :
                     (zone == 5'd6) ? x_loc + STAGE_6 :
                     (zone == 5'd7) ? x_loc + STAGE_7 :
                     (zone == 5'd8) ? x_loc + STAGE_8 :
							(zone == 5'd9) ? x_loc + STAGE_9 :
                     (zone == 5'd10) ? x_loc + STAGE_10 :
                     (zone == 5'd11) ? x_loc + STAGE_11 :
                     (zone == 5'd12) ? x_loc + STAGE_12 :
                     (zone == 5'd13) ? x_loc + STAGE_13 :
                     (zone == 5'd14) ? x_loc + STAGE_14 :
                     (zone == 5'd15) ? x_loc + STAGE_15 :
                     (zone == 5'd16) ? x_loc + STAGE_16 :
                     (zone == 5'd17) ? x_loc + STAGE_17 :	
                     (zone == 5'd18) ? x_loc + STAGE_18 : x_loc + STAGE_19; 
    
	//store bound in which a pixel will be output in y direction	
    assign y_bound = (zone == 5'd0) ? y_loc + STAGE_0 :
                     (zone == 5'd1) ? y_loc + STAGE_1 :
                     (zone == 5'd2) ? y_loc + STAGE_2 :
                     (zone == 5'd3) ? y_loc + STAGE_3 :
                     (zone == 5'd4) ? y_loc + STAGE_4 :
                     (zone == 5'd5) ? y_loc + STAGE_5 :
                     (zone == 5'd6) ? y_loc + STAGE_6 :
                     (zone == 5'd7) ? y_loc + STAGE_7 :
                     (zone == 5'd8) ? y_loc + STAGE_8 :
							(zone == 5'd9) ? y_loc + STAGE_9 :
                     (zone == 5'd10) ? y_loc + STAGE_10 :
                     (zone == 5'd11) ? y_loc + STAGE_11 :
                     (zone == 5'd12) ? y_loc + STAGE_12 :
                     (zone == 5'd13) ? y_loc + STAGE_13 :
                     (zone == 5'd14) ? y_loc + STAGE_14 :
                     (zone == 5'd15) ? y_loc + STAGE_15 :
                     (zone == 5'd16) ? y_loc + STAGE_16 :
                     (zone == 5'd17) ? y_loc + STAGE_17 :	
                     (zone == 5'd18) ? y_loc + STAGE_18 : y_loc + STAGE_19; 
							
	//used to add offset the address for the next ROM line						
    assign stage_add = (zone == 5'd0) ? 13'd1 + STAGE_0 :
							  (zone == 5'd1) ? 13'd1 + STAGE_1 :
                       (zone == 5'd2) ? 13'd1 + STAGE_2 :
							  (zone == 5'd3) ? 13'd1 + STAGE_3 :
                       (zone == 5'd4) ? 13'd1 + STAGE_4 :
                       (zone == 5'd5) ? 13'd1 + STAGE_5 :
                       (zone == 5'd6) ? 13'd1 + STAGE_6 :
                       (zone == 5'd7) ? 13'd1 + STAGE_7 :
                       (zone == 5'd8) ? 13'd1 + STAGE_8 :
							  (zone == 5'd9) ? 13'd1 + STAGE_9 :
                       (zone == 5'd10) ? 13'd1 + STAGE_10 :
                       (zone == 5'd11) ? 13'd1 + STAGE_11 :
                       (zone == 5'd12) ? 13'd1 + STAGE_12 :
                       (zone == 5'd13) ? 13'd1 + STAGE_13 :
                       (zone == 5'd14) ? 13'd1 + STAGE_14 :
                       (zone == 5'd15) ? 13'd1 + STAGE_15 :
                       (zone == 5'd16) ? 13'd1 + STAGE_16 :
                       (zone == 5'd17) ? 13'd1 + STAGE_17 :	
                       (zone == 5'd18) ? 13'd1 + STAGE_18 : 13'd1 + STAGE_19; 
     
    //output the address
    assign addr = offset + (pixel_x - x_loc);
    
	//signals that we have a pixel to output
    assign active = (rom_data[15:8] >= 8'h90) && ((pixel_x >= x_loc) && (pixel_x <= x_bound)) && ((pixel_y >= y_loc) && (pixel_y <= y_bound)) ? 1'b1 : 1'b0;         
     
	//selects correct data from ROMs
    assign rom_data = (zone == 5'd0) ? data_0 :
							 (zone == 5'd1) ? data_1 :
                      (zone == 5'd2) ? data_2 :
					   	 (zone == 5'd3) ? data_3 :
                      (zone == 5'd4) ? data_4 :
                      (zone == 5'd5) ? data_5 :
                      (zone == 5'd6) ? data_6 :
                      (zone == 5'd7) ? data_7 :
                      (zone == 5'd8) ? data_8 :
							 (zone == 5'd9) ? data_9 :
                      (zone == 5'd10) ? data_10 :
                      (zone == 5'd11) ? data_11 :
                      (zone == 5'd12) ? data_12 :
                      (zone == 5'd13) ? data_13 :
                      (zone == 5'd14) ? data_14 :
                      (zone == 5'd15) ? data_15 :
                      (zone == 5'd16) ? data_16 :
                      (zone == 5'd17) ? data_17 :	
                      (zone == 5'd18) ? data_18 : data_19; 
     
	//if we should output a pixel, output
    assign color = (active) ? rom_data : 24'd0;
	 
	//next offset logic to calculate the next offset used for address in next ROM line
    assign next_offset = (pixel_y < y_loc) ? 13'd0 :
						 ((pixel_y > y_loc) && (pixel_y <= y_bound)) ? offset + stage_add : 13'd0;
	 
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
