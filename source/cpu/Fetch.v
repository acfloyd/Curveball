module Fetch(clk, rst, Stall, TruePC, NotBranchOrJump, NextPC, Instruct);
    input clk, rst, Halt, Stall, NotBranchOrJump;
    input [15:0] TruePC;
    output [15:0] NextPC, Instruct;

    reg [15:0] PC;
    wire [15:0] MuxOut, NextPCRegIn, InstructRegIn;

    always @ (posedge clk, posedge rst) begin
        if(rst)
            PC <= 16'd0;
        else if (Stall) 
            PC <= PC;
        else begin
            PC <= NextPCRegIn;
        end
    end

    assign MuxOut = (NotBranchOrJump) ? PC : TruePC;
    assign NextPCRegIn = MuxOut + 1;

    //Instruction Memory
    IMEM IMEM(.ADDRA(MuxOut), .CLKA(clk), .DOUTA(InstructRegIn));

    FetchReg FETCHREG(.clk(clk), .rst(rst), .stall(Stall), .NextPCIn(NextPCRegIn), 
                      .InstructIn(InstructRegIn), .NextPCOut(NextPC), .InstructOut(Instruct));

endmodule