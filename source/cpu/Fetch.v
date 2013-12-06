module Fetch(clk, rst, Stall, FetchStall, TruePC, NotBranchOrJump, NextPC, 
             Instruct, InstructToControl, Halt);
    input clk, rst, Stall, NotBranchOrJump, FetchStall, Halt;
    input [15:0] TruePC;
    output [15:0] NextPC, InstructToControl, Instruct;

    reg [15:0] PC;
    wire [15:0] MuxOut, NextPCRegIn, InstructRegIn;
    
    //TEMP INSTRUCT MEM

    simple_rom #(13,"instructions.txt") mem(MuxOut, InstructRegIn);

    /*reg [15:0] mem [0:19];
    initial begin
        $readmemb("instructions.txt", mem);
    end*/

    always @ (posedge clk, posedge rst) begin
        if(rst) PC <= 16'd0;
        else if (Halt) PC <= 16'd0;
        else if (Stall | FetchStall) PC <= PC;
        else PC <= NextPCRegIn;
    end

    assign MuxOut = (NotBranchOrJump) ? PC : TruePC;
    assign NextPCRegIn = MuxOut + 1;

    //Instruction Memory
    //IMEM IMEM(.ADDRA(MuxOut), .CLKA(clk), .DOUTA(InstructRegIn));
    
    //TEMP INSTRUCT MEM
    //assign InstructRegIn = mem[MuxOut];
    assign InstructToControl = InstructRegIn;
    
    FetchReg FETCHREG(.clk(clk), .rst(rst), .Stall(Stall | FetchStall | Halt), .NextPCIn(NextPCRegIn), 
                      .InstructIn(InstructRegIn), .NextPCOut(NextPC), .InstructOut(Instruct));

endmodule