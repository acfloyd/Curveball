module ALU_control(instruct, ALU_op, addMode, shiftMode, setFlag);
    input [15:0] instruct;
    output [2:0] ALU_op;
    output addMode, setFlag;
    output [1:0] shiftMode;
    
    wire [3:0] temp_op;
    assign temp_op = (instruct[15]) ? {instruct[12:11], instruct[1:0]} : instruct[14:11];
                      //Branches
    assign ALU_op = ((instruct[15:13] == 3'b101) || 
                      //ST LD
                     (instruct[15:12] == 4'b1111) || 
                      //Set Ifs
                     (instruct[15:11] == 5'b10011) ||
                      //Sub
                     (temp_op == 4'b0001)) ? 3'b000 :
                     temp_op[2:0];
                     
    assign addModeTemp = (instruct[15]) ? ~temp_op[1] : instruct[11];
                     
                      //SEQ  SLE
    assign addMode = (temp_op[3] & temp_op[2] & temp_op[0]) ? 1'b0 : 
                       //BNEZ  BGEZ
                    ((instruct[15] & ~instruct[14] & instruct[13] & instruct[11]) ? 1'b1 : 
                       //LD
                    ((instruct[15:11] == 5'b11111) ? 1'b1 : 
                    addModeTemp));
    assign shiftMode = temp_op[1:0];
    assign setFlag = ((instruct[15:11] == 5'b10011) || (instruct[15:13] == 3'b101));
    
endmodule
