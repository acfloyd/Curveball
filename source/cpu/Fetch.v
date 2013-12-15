module Fetch(clk, rst, Stall, FetchStall, TruePC, NotBranchOrJump, NextPC, 
             Instruct, InstructToControl, Halt);
    input clk, rst, Stall, NotBranchOrJump, FetchStall, Halt;
    input [15:0] TruePC;
    output [15:0] NextPC, InstructToControl, Instruct;

    reg [15:0] PC;
    wire [15:0] MuxOut, NextPCRegIn, InstructRegIn;

    simple_rom #(731,"instructions.txt") mem(MuxOut, InstructRegIn);

    always @ (posedge clk, posedge rst) begin
        if(rst) PC <= 16'd0;
        else if (Halt) PC <= 16'd0;
        else if (Stall | FetchStall) PC <= PC;
        else PC <= NextPCRegIn;
    end

    assign MuxOut = (NotBranchOrJump) ? PC : TruePC;
    assign NextPCRegIn = MuxOut + 1;


    assign InstructToControl = InstructRegIn;
    
    FetchReg FETCHREG(.clk(clk), .rst(rst), .Stall(Stall | FetchStall | Halt), .NextPCIn(NextPCRegIn), 
                      .InstructIn(InstructRegIn), .NextPCOut(NextPC), .InstructOut(Instruct));

endmodule