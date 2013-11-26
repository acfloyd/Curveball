module Ball(output[2:0] color, input [15:0] x_loc, y_loc, z_loc, pixel_x, pixel_y, input clk, rst);
    
    reg [5:0] radius;
    wire [13:0] addr;
    wire [5:0] x_bound, y_bound;
    wire [3:0] zone;
    
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
    Ball_ROM stage_0(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_1(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_2(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_3(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_4(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_5(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_6(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_7(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_8(.clka(clk), .addra(addr), .douta(data));
    Ball_ROM stage_9(.clka(clk), .addra(addr), .douta(data));
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
     
    assign addr =               
   
	
endmodule
