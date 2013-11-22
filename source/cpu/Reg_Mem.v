module Reg_Mem(clk, rst, DataIn, AddrS, AddrT, WrSel, WrRegEn, Rs, Rt);
	input clk, rst;
	input WrRegEn;
	input [2:0] AddrS, AddrT, WrSel;
	input [15:0] DataIn;
	output [15:0] Rs, Rt;

	wire [15:0] DataOut0, DataOut1, DataOut2, DataOut3, DataOut4, DataOut5, DataOut6, DataOut7;
	wire [7:0] WriteEn, WriteSel;
	assign WriteSel = 8'd1 << WrSel;
	assign WriteEn = WriteSel & {8{WrRegEn}};
	Reg_16_En reg0(.clk(clk), .rst(rst), .WrRegEn(WriteEn[0]), .DataIn(DataIn), .DataOut(DataOut0));
	Reg_16_En reg1(.clk(clk), .rst(rst), .WrRegEn(WriteEn[1]), .DataIn(DataIn), .DataOut(DataOut1));
	Reg_16_En reg2(.clk(clk), .rst(rst), .WrRegEn(WriteEn[2]), .DataIn(DataIn), .DataOut(DataOut2));
	Reg_16_En reg3(.clk(clk), .rst(rst), .WrRegEn(WriteEn[3]), .DataIn(DataIn), .DataOut(DataOut3));
	Reg_16_En reg4(.clk(clk), .rst(rst), .WrRegEn(WriteEn[4]), .DataIn(DataIn), .DataOut(DataOut4));
	Reg_16_En reg5(.clk(clk), .rst(rst), .WrRegEn(WriteEn[5]), .DataIn(DataIn), .DataOut(DataOut5));
	Reg_16_En reg6(.clk(clk), .rst(rst), .WrRegEn(WriteEn[6]), .DataIn(DataIn), .DataOut(DataOut6));
	Reg_16_En reg7(.clk(clk), .rst(rst), .WrRegEn(WriteEn[7]), .DataIn(DataIn), .DataOut(DataOut7));

	Mux_8to1 MUX1[15:0](.in7(DataOut7), .in6(DataOut6), .in5(DataOut5), .in4(DataOut4), 
	                    .in3(DataOut3), .in2(DataOut2), .in1(DataOut1), .in0(DataOut0), 
	                    .sel(AddrS), .out(Rs));
	Mux_8to1 MUX2[15:0](.in7(DataOut7), .in6(DataOut6), .in5(DataOut5), .in4(DataOut4), 
	                    .in3(DataOut3), .in2(DataOut2), .in1(DataOut1), .in0(DataOut0), 
	                    .sel(AddrT), .out(Rt));
endmodule
