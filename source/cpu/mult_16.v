module mult_16(A, B, Out);
    input signed [15:0] A, B;
    output signed [15:0] Out;
    
    wire [31:0] mult_out;
    
    assign mult_out = A * B;
	 assign overflow = (mult_out[31]) ? ~(&mult_out[31:16]) : |mult_out[31:16];
    assign Out = overflow ? 16'd0 : mult_out[15:0];
endmodule