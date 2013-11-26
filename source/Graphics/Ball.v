module Ball(output[2:0] color, input [15:0] x_loc, y_loc, z_loc, pixel_x, pixel_y, input clk, rst);
    
    reg [5:0] radius;
    wire [13:0] addr;
    wire [5:0] x_bound, y_bound;
    wire [3:0] zone;
    wire [2:0] rom_data, data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7, data_8, data_9;
    wire active;
    
    localparam STAGE_0 = 8'd69;
    localparam STAGE_1 = 7'd59;
    localparam STAGE_2 = 7'd51;
    localparam STAGE_3 = 7'd43;
    localparam STAGE_4 = 7'd37;
    localparam STAGE_5 = 6'd31;
    localparam STAGE_6 = 6'd25;
    localparam STAGE_7 = 6'd21;
    localparam STAGE_8 = 6'd17;
    localparam STAGE_9 = 5'd15;
    
    /*
    Ball_ROM rom_0(.clka(clk), .addra(addr), .douta(data_0));
    Ball_ROM rom_1(.clka(clk), .addra(addr), .douta(data_1));
    Ball_ROM rom_2(.clka(clk), .addra(addr), .douta(data_2));
    Ball_ROM rom_3(.clka(clk), .addra(addr), .douta(data_3));
    Ball_ROM rom_4(.clka(clk), .addra(addr), .douta(data_4));
    Ball_ROM rom_5(.clka(clk), .addra(addr), .douta(data_5));
    Ball_ROM rom_6(.clka(clk), .addra(addr), .douta(data_6));
    Ball_ROM rom_7(.clka(clk), .addra(addr), .douta(data_7));
    Ball_ROM rom_8(.clka(clk), .addra(addr), .douta(data_8));
    Ball_ROM rom_9(.clka(clk), .addra(addr), .douta(data_9));
    */
    
    assign zone = (z_loc <= 7'd99) ? 4'd0 :
                  (z_loc <= 8'd199) ? 4'd1 :
                  (z_loc <= 9'd299) ? 4'd2 :
                  (z_loc <= 9'd399) ? 4'd3 :
                  (z_loc <= 9'd499) ? 4'd4 :
                  (z_loc <= 10'd599) ? 4'd5 :
                  (z_loc <= 10'd699) ? 4'd6 :
                  (z_loc <= 10'd799) ? 4'd7 :
                  (z_loc <= 10'd899) ? 4'd8 : 4'd9; 
                  
    assign x_bound = (zone == 4'd0) ? x_loc + STAGE_0 :
                     (zone == 4'd1) ? x_loc + STAGE_1 :
                     (zone == 4'd2) ? x_loc + STAGE_2 :
                     (zone == 4'd3) ? x_loc + STAGE_3 :
                     (zone == 4'd4) ? x_loc + STAGE_4 :
                     (zone == 4'd5) ? x_loc + STAGE_5 :
                     (zone == 4'd6) ? x_loc + STAGE_6 :
                     (zone == 4'd7) ? x_loc + STAGE_7 :
                     (zone == 4'd8) ? x_loc + STAGE_8 : x_loc + STAGE_9;
                     
    assign y_bound = (zone == 4'd0) ? y_loc + STAGE_0 :
                     (zone == 4'd1) ? y_loc + STAGE_1 :
                     (zone == 4'd2) ? y_loc + STAGE_2 :
                     (zone == 4'd3) ? y_loc + STAGE_3 :
                     (zone == 4'd4) ? y_loc + STAGE_4 :
                     (zone == 4'd5) ? y_loc + STAGE_5 :
                     (zone == 4'd6) ? y_loc + STAGE_6 :
                     (zone == 4'd7) ? y_loc + STAGE_7 :
                     (zone == 4'd8) ? y_loc + STAGE_8 : y_loc + STAGE_9;
     
    assign addr = ((pixel_x - (x_loc - 16'd1)) - (pixel_y - y_loc));
    
    assign active = ((pixel_x >= x_loc) && (pixel_x <= x_bound)) && ((pixel_y >= y_loc) && (pixel_y <= y_bound)) ? 1'b1 : 1'b0;         
      
	 assign rom_data = (zone == 4'd0) ? data_0 :
                      (zone == 4'd1) ? data_1 :
                      (zone == 4'd2) ? data_2 :
                      (zone == 4'd3) ? data_3 :
                      (zone == 4'd4) ? data_4 :
                      (zone == 4'd5) ? data_5 :
                      (zone == 4'd6) ? data_6 :
                      (zone == 4'd7) ? data_7 :
                      (zone == 4'd8) ? data_8 : data_9;
                      
    assign color = rom_data;
	 
endmodule
