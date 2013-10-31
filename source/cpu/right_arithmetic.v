module right_arithmetic (In, Cnt, Out);
   
   input [15:0] In;
   input [3:0]  Cnt;
   output [15:0] Out;
   wire [15:0] First_Out, Second_Out, Third_Out;

//mux2_1 MUX1[15:0] (In[15:0], {In[15], In[15:1]}, Cnt[0], First_Out[15:0]);
//mux2_1 MUX2[15:0] (First_Out[15:0], {{2{First_Out[15]}}, First_Out[15:2]}, Cnt[1], Second_Out[15:0]);
//mux2_1 MUX3[15:0] (Second_Out[15:0], {{4{Second_Out[15]}}, Second_Out[15:4]}, Cnt[2], Third_Out[15:0]);
//mux2_1 MUX4[15:0] (Third_Out[15:0], {{8{Third_Out[15]}}, Third_Out[15:8]}, Cnt[3], Out[15:0]);

   assign First_Out = (Cnt[0]) ? {In[15], In[15:1]} : In[15:0];
   assign Second_Out = (Cnt[1]) ? {{2{First_Out[15]}}, First_Out[15:2]} : First_Out[15:0];
   assign Third_Out = (Cnt[2]) ? {{4{Second_Out[15]}}, Second_Out[15:4]} : Second_Out[15:0];
   assign Out = (Cnt[3]) ? {{8{Third_Out[15]}}, Third_Out[15:8]} : Third_Out[15:0];

endmodule
