module mult_16(A, B, Out, overflow);
    input signed [15:0] A, B;
    output signed [15:0] Out;
    output overflow;
    
    wire [31:0] mult_out;
    
    assign mult_out = A * B;
    assign overflow = ^mult_out[31:16];
    assign Out = mult_out[15:0];
endmodule