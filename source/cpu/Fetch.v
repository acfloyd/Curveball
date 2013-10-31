module Fetch(clk, rst, Halt, TruePC, NotBranchOrJump, NextPC, Instruct);
    input clk, rst, Halt, NotBranchOrJump;
    input [15:0] TruePC;
    output [15:0] NextPC, Instruct;
    
    reg [15:0] PC;
    wire [15:0] PCIn;

    assign NextPC = PC + 1;    
    assign PCIn = (NotBranchOrJump) ? NextPC : TruePC;

    always @ (posedge clk, posedge rst) begin
        if(rst)
            PC <= 16'd0;
        else if (Halt) 
            PC <= PC;
        else begin
            PC <= PCIn;
        end
    end

    //Instruction Memory
    IMEM IMEM(.ADDRA(PCOut), .CLKA(clk), .DOUTA(Instruct));
    
endmodule
