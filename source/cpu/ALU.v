module ALU (A, B, ALUMux, SetFlag, FlagMux, AOp, ZeroB, ShiftMode, AddMode, clk, Out, Remainder, rst, ready);
    input [15:0] A, B;
    input [2:0] ALUMux;
    input [1:0] SetFlag, AOp, ShiftMode;
    input ZeroB, AddMode, clk, rst, FlagMux;
    output [15:0] Out, Remainder;
    output  ready;
    
    wire [15:0] Aout, Bout, ShifterOut, AdderOut, MultiplierOut, DividerOut, AndOut, OrOut, XorOut, ALUMuxOut;
    wire AdderZero, AdderOverflow, Flag;
    wire divByZero;
    wire divEnable;
    
    //Modify value of A if needed. Can invert, shift arithmetically left 8 (SLBI), or set to zero.
    assign Aout = (AOp == 2'b00) ? A : (AOp == 2'b01) ? ~A : (AOp == 2'b10) ? {A[7:0], 8'd0} : 16'd0;
    
    assign Bout = (ZeroB) ? 16'd0 : B;
    
    Adder_16 adder (.A(Aout), .B(Bout), .AddMode(AddMode), .Out(AdderOut), .Z(AdderZero), .Overflow(AdderOverflow));
    
    mult_16 multiplier (.A(Aout), .B(Bout), .Out(MultiplierOut));
    
    div_16 divider (.A(Aout), .B(Bout), .enable(divEnable), .ready(ready), .Out(DividerOut), .RemOut(Remainder), .clk(clk), .divByZero(divByZero));

    shifter shift (.In(Aout), .Cnt(Bout[3:0]), .Op(ShiftMode), .Out(ShifterOut));
    //Only enable the divider when instruction is being used, otherwise it constantly runs
    assign divEnable = ALUMux[0] && ALUMux[1] && ~ALUMux[2];
    
    assign AndOut = Aout & Bout;
    
    assign OrOut = Aout | Bout;
    
    assign XorOut = Aout ^ Bout;
    //Final mux to decide which value to output
    assign ALUMuxOut = (ALUMux == 3'b000) ? AdderOut : 
                       (ALUMux == 3'b001) ? ShifterOut : 
                       (ALUMux == 3'b010) ? MultiplierOut : 
                       (ALUMux == 3'b011) ? DividerOut : 
                       (ALUMux == 3'b100) ? AndOut : 
                       (ALUMux == 3'b101) ? OrOut : 
                       (ALUMux == 3'b110) ? XorOut : 
                       (ALUMux == 3'b111) ? Aout :
                        16'bzzzzzzzzzzzzzzzz;
    //Flag Logic
    assign Flag = (SetFlag == 2'b00) ? AdderZero : //SEQ
                  (SetFlag == 2'b01) ? AdderOut[15] : //SLT (if MSB of AdderOut is 0, Rs is less)
                  (SetFlag == 2'b10) ? AdderOut[15] | AdderZero : //SLE
                  (SetFlag == 2'b11) ? AdderOverflow : //SCO
                  1'bz; 
      
    assign Out = (FlagMux) ? {15'd0,Flag} : ALUMuxOut; 
    
endmodule
