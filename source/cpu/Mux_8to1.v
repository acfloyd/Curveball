module Mux_8to1(in7, in6, in5, in4, in3, in2, in1, in0, sel, out);
	input in7, in6, in5, in4, in3, in2, in1, in0;
	input [2:0] sel;
	output out;

	wire [7:0] in;
	wire [3:0] outA;
	wire [1:0] outB;

	assign in = {in7, in6, in5, in4, in3, in2, in1, in0};
	assign outA = sel[2] ? in[7:4] : in[3:0];
	assign outB = sel[1] ? outA[3:2] : outA[1:0];
	assign out = sel[0] ? outB[1] : outB[0];

endmodule
