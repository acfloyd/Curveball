`timescale 1ns / 10 ps 
`define EOF 32'hFFFF_FFFF 
`define NULL 0 

module emulator;

integer file_in, file_out, i, PC, PC_next;
integer scan_file;

reg rst, clk;

reg[15:0] currLine;
reg eof;

// TODO: need functionality for registers (ie. game state, position, etc.)

// memories
reg[15:0] outGrid[99:0][99:0]; // output grid for displaying to excel
reg[7:0] Dmem[16386:0];
// the Imeme must be resized to fit the # of instructions in the input file
reg[15:0] Imem[1023:0];
reg[15:0] rf[7:0];

initial begin
    clk = 0;
    forever #10 clk =  ~clk;
end

// open a file of hex values
initial begin
    // hold rst when reading the file in
    rst = 1'b1;

    file_in = $fopen("game_code.bin", "r");
    if (file_in == `NULL) begin
        $display("data_file handle was NULL");
        $finish;
    end
    else
        $display("input file opened\n");

    // test done reading
    eof = $feof(file_in);
    if (eof != 0) begin
        $display("ERROR: I read nothing");
        $finish;
    end

    // make sure Imem structure is at least the size of the number of lines
    scan_file = $fscanf(file_in, "%b\n", currLine);
    i = 0;
    while(scan_file != `EOF) begin
        // get the next instruction
        $display("%d: 0x%x\n", i, currLine);
        Imem[i] = currLine;
        i = i + 1;
        scan_file = $fscanf(file_in, "%b\n", currLine);
    end

    // after the while loop, i reflects the number of instructions
    PC = 0;
    PC_next = 0;
    rst = 1'b0;
end

always @(posedge clk) begin
    if (!rst) begin
        PC = PC_next;
        PC_next = PC_next + 1;
        currLine = Imem[PC];

        case (currLine[15:11])
            // ADDI
            5'b00000: 
                rf[currLine[7:5]] = rf[currLine[10:8]] + {{11{currLine[4]}}, currLine[4:0]};
            // SUBI
            5'b00001:
                rf[currLine[7:5]] = rf[currLine[10:8]] - {{11{currLine[4]}}, currLine[4:0]};
            // MULTI
            5'b00010:
                rf[currLine[7:5]] = rf[currLine[10:8]] * {{11{currLine[4]}}, currLine[4:0]};
            // DIVI
            5'b00011:
                rf[currLine[7:5]] = rf[currLine[10:8]] / {{11{currLine[4]}}, currLine[4:0]};
            // ANDI
            5'b00100:
                rf[currLine[7:5]] = rf[currLine[10:8]] & {{11{1'b0}}, currLine[4:0]};
            // ORI
            5'b00101:
                rf[currLine[7:5]] = rf[currLine[10:8]] | {{11{1'b0}}, currLine[4:0]};
            // XORI
            5'b00110:
                rf[currLine[7:5]] = rf[currLine[10:8]] ^ {{11{1'b0}}, currLine[4:0]};
            // ROLI
            5'b01000: begin
                // proble not used
            end
            // SLLI
            5'b01001: 
                rf[currLine[7:5]] = rf[currLine[10:8]] << {{12{1'b0}}, currLine[3:0]};
            // SRLI
            5'b01010: 
                rf[currLine[7:5]] = rf[currLine[10:8]] >> {{12{1'b0}}, currLine[3:0]};
            // SRAI
            5'b01011: 
                rf[currLine[7:5]] = rf[currLine[10:8]] >>> {{12{1'b0}}, currLine[3:0]};
            // LBI
            5'b01100: 
                rf[currLine[7:5]] = {{8{currLine[7]}}, currLine[7:0]};
            // SLBI
            5'b01101: 
                rf[currLine[7:5]] = (rf[currLine[10:8]] << 8) | {{8{currLine[7]}}, currLine[7:0]};
            // STI
            5'b01110: 
                Dmem[{{8{1'b0}}, currLine[7:0]}] = rf[currLine[10:8]];
            // LDI
            5'b01111: 
                rf[currLine[10:8]] = Dmem[{{8{1'b0}}, currLine[7:0]}];
            5'b10000: begin
                case(currLine[1:0])
                    // ADD
                    2'b00:
                        rf[currLine[4:2]] = rf[currLine[10:8]] + rf[currLine[7:5]];
                    // SUB    
                    2'b01:
                        rf[currLine[4:2]] = rf[currLine[7:5]] - rf[currLine[10:8]];
                    // MULT
                    2'b10:
                        rf[currLine[4:2]] = rf[currLine[10:8]] * rf[currLine[7:5]];
                    // DIV
                    2'b11:
                        rf[currLine[4:2]] = rf[currLine[10:8]] / rf[currLine[7:5]];
                endcase
            end
            5'b10001: begin
                case(currLine[1:0])
                    // AND
                    2'b00:
                        rf[currLine[4:2]] = rf[currLine[10:8]] & rf[currLine[7:5]];
                    // OR
                    2'b01:
                        rf[currLine[4:2]] = rf[currLine[10:8]] | rf[currLine[7:5]];
                    // XOR
                    2'b10:
                        rf[currLine[4:2]] = rf[currLine[10:8]] ^ rf[currLine[7:5]];
                    // NOT
                    2'b11:
                        rf[currLine[4:2]] = ~rf[currLine[10:8]];
                endcase
            end
            5'b10010: begin
                case(currLine[1:0])
                    // ROL
                    2'b00: begin
                        // again, too fucking hard
                    end
                    // SLL
                    2'b01:
                        rf[currLine[4:2]] = rf[currLine[10:8]] << {{12{1'b0}}, rf[currLine[7:5]][3:0]};
                    // SRL
                    2'b10:
                        rf[currLine[4:2]] = rf[currLine[10:8]] >> {{12{1'b0}}, rf[currLine[7:5]][3:0]};
                    // SRA
                    2'b11:
                        rf[currLine[4:2]] = rf[currLine[10:8]] >>> {{12{1'b0}}, rf[currLine[7:5]][3:0]};
                endcase
            end
            5'b10011: begin
                case(currLine[1:0])
                    // SEQ
                    2'b00: begin
                        if (rf[currLine[10:8]] == rf[currLine[7:5]])
                            rf[currLine[4:2]] = 1;
                        else
                            rf[currLine[4:2]] = 0;
                    end
                    // SLT
                    2'b01: begin
                        if (rf[currLine[10:8]] < rf[currLine[7:5]])
                            rf[currLine[4:2]] = 1;
                        else
                            rf[currLine[4:2]] = 0;
                    end
                    // SLE
                    2'b10: begin
                        if (rf[currLine[10:8]] <= rf[currLine[7:5]])
                            rf[currLine[4:2]] = 1;
                        else
                            rf[currLine[4:2]] = 0;
                    end
                    // SCO
                    2'b11: begin
                        // not implemented
                    end
                endcase
            end
            // BEQZ
            5'b10100: begin
                if (rf[currLine[10:8]] == 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // BNEZ
            5'b10101: begin
                if (rf[currLine[10:8]] != 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // BLTZ
            5'b10110: begin
                if (rf[currLine[10:8]] < 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // BGEZ TODO: this shit is BOGUS, ask paul and nate
            5'b10111: begin
                if (rf[currLine[10:8]] <= 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // J
            5'b11000:
                PC_next = PC_next + {{5{currLine[10]}}, currLine[10:0]};
            // JR
            5'b11001:
                PC_next = rf[currLine[10:8]] + {{8{currLine[7]}}, currLine[7:0]};
            // JAL
            5'b11010: begin
                rf[7] = PC_next;
                PC_next = PC_next + {{5{currLine[10]}}, currLine[10:0]};
            end
            // JALR
            5'b11011: begin
                rf[7] = PC_next;
                PC_next = rf[currLine[10:8]] + {{8{currLine[7]}}, currLine[7:0]};
            end
            // HALT
            5'b11100: begin
                // print the register file contents to a file
                file_out = $fopen("rf.dat");
                for (i = 0; i < 8; i = i + 1) begin
                    $fwrite(file_out, "%d: 0x%x\n", i, rf[i]);
                end
                $fclose(file_out);

                // print the data memory and its contents
                file_out = $fopen("Dmem.dat");
                for (i = 0; i < 1024; i = i + 1) begin
                    $fwrite(file_out, "%d: 0x%x\n", i, Dmem[i]);
                end
                $fclose(file_out);
                $finish;
            end
            // NOP
            5'b11101: begin
                // this does nothing
            end
            // ST
            5'b11110:
                Dmem[rf[currLine[10:8]] + {{12{currLine[4]}}, currLine[4:0]}] = rf[currLine[7:5]];
            // LD
            5'b11111:
                rf[currLine[7:5]] = Dmem[rf[currLine[10:8]] + {{12{currLine[4]}}, currLine[4:0]}];
            default: begin
                // nothing here
            end
        endcase
    end
end

endmodule
