module Fetch(clk, rst, Stall, TruePC, NotBranchOrJump, NextPC, 
             Instruct, InstructToControl);
    input clk, rst, Stall, NotBranchOrJump;
    input [15:0] TruePC;
    output [15:0] NextPC, InstructToControl, Instruct;

    reg [15:0] PC;
    wire [15:0] MuxOut, NextPCRegIn, InstructRegIn;
    
    //TEMP INSTRUCT MEM
    reg [15:0] mem [0:34];
    initial begin
        $readmemb("text_files/instructions.txt", mem);
    end

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
    //IMEM IMEM(.ADDRA(MuxOut), .CLKA(clk), .DOUTA(InstructRegIn));
    
    //TEMP INSTRUCT MEM
    assign InstructRegIn = mem[MuxOut];
    assign InstructToControl = InstructRegIn;
    
    FetchReg FETCHREG(.clk(clk), .rst(rst), .Stall(Stall), .NextPCIn(NextPCRegIn), 
                      .InstructIn(InstructRegIn), .NextPCOut(NextPC), .InstructOut(Instruct));

endmodule