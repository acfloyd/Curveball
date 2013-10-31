module div_16(A, B, enable, ready, Out, RemOut, clk, divByZero);

   input         clk, enable;
   input [15:0]  A, B;
   output [15:0] Out, RemOut;
   output        ready, divByZero;

   reg [15:0]    Out, Out_temp;
   reg [31:0]    A_copy, B_copy, diff;
   reg           negative_output;
   
   wire [15:0]   RemOut = (!negative_output) ? 
                             A_copy[15:0] : 
                             ~A_copy[15:0] + 1'b1;

   reg [5:0]     bit; //TODO
   wire          ready = !bit;

   initial bit = 0;
   initial negative_output = 0;

   assign divByZero = ~|B;

   always @( posedge clk ) 

     if( enable && ready && !divByZero ) begin

        bit = 6'd16; //TODO
        Out = 0;
        Out_temp = 0;
        A_copy = (!A[15]) ? 
                        {16'd0,A} : 
                        {16'd0,~A + 1'b1};
        B_copy = (!B[15]) ? 
                       {1'b0,B,15'd0} : 
                       {1'b0,~B + 1'b1,15'd0};

        negative_output = ((B[15] && !A[15]) 
                        ||(!B[15] && A[15]));
        
     end 
     else if ( bit > 0 ) begin

        diff = A_copy - B_copy;

        Out_temp = Out_temp << 1;

        if( !diff[31] ) begin

           A_copy = diff;
           Out_temp[0] = 1'd1;

        end

        Out = (!negative_output) ? 
                   Out_temp : 
                   ~Out_temp + 1'b1;

        B_copy = B_copy >> 1;
        bit = bit - 1'b1;

     end
endmodule
