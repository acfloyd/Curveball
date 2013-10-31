module Adder_16(A, B, AddMode, Out, Z, Overflow);
   
   input signed [15:0] A, B;
   input AddMode;
   output signed [15:0] Out;
   output Z, Overflow;

   wire [16:0] OutAdd;
   
   assign Z = (Out == 16'd0) ? 1'b1 : 1'b0;
   assign Overflow = OutAdd[16] ^ OutAdd[15]; 
   assign Out = OutAdd[15:0];
   
   assign OutAdd = (AddMode) ? A+B : A-B; 
    
endmodule
