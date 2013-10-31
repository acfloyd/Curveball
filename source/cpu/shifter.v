module shifter (In, Cnt, Op, Out);
   
   input [15:0] In;
   input [3:0]  Cnt;
   input [1:0]  Op;
   output [15:0] Out;
   wire[15:0] out1, out2, out3, out4;

left_rotate lrot (In[15:0], Cnt[3:0], out1[15:0]);
left_logical llog (In[15:0], Cnt[3:0], out2[15:0]);
right_logical rlog (In[15:0], Cnt[3:0], out3[15:0]);
right_arithmetic rarith (In[15:0], Cnt[3:0], out4[15:0]);

//mux4_1 MUX_FINAL[15:0] (out1[15:0], out2[15:0], out3[15:0], out4[15:0], Op[1:0], Out[15:0]);

assign Out = (Op[1:0] == 2'b00) ? out1[15:0] : (Op[1:0] == 2'b01) ? out2[15:0] 
            : (Op[1:0] == 2'b10) ? out3[15:0] : out4[15:0];

endmodule

