`timescale 1ns / 10 ps 
`define EOF 32'hFFFF_FFFF 
`define NULL 0 

`define BALLADDR 4104
`define PAD1ADDR 4096
`define POSX 0
`define POSY 1
`define POSZ 2

module emulator;

integer file_in, file_out, i, j, PC, PC_next;
integer scan_file;
integer tmp;

reg rst, clk;

reg[15:0] currLine, tmpAddr;
reg signed [15:0] tmpVal, tmpVal2;
reg eof;

// TODO: need functionality for registers (ie. game state, position, etc.)

// memories
reg signed [15:0] outGrid[999:0][999:0]; // output grid for displaying to excel
reg[15:0] Dmem[16386:0];
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
        Imem[i] = currLine;
        i = i + 1;
        scan_file = $fscanf(file_in, "%b\n", currLine);
    end

    // prefill the register values to zero
    for (i = 0; i < 8; i = i + 1)
        rf[i] = 16'd0;

    // prefill the outGrid with zero
    for (i = 0; i < 1000; i = i + 1) begin
        for (j = 0; j < 1000; j = j + 1)
            outGrid[i][j] = 16'd0;
    end

    // init values for testing
    // set mouse addr
    Dmem[16385] = 195; // posX
    Dmem[16386] = 155; // posY
    // set left click on mouse
    Dmem[16384] = 1;

    // after the while loop, i reflects the number of instructions
    PC = 0;
    PC_next = 0;
    rst = 1'b0;
end

always @(posedge clk) begin
    if (!rst) begin
        PC = PC_next;
        //$display("PC: %d, %b\n", PC, currLine);
        PC_next = PC_next + 1;
        currLine = Imem[PC];

        // store the ball position values to be used for testing in excel after program halts
        //$display("PC: %d\n", PC);

/*
        if (PC > 641)
            $finish;
        if (PC == 103) begin
            $display("p1update\n");
            $display("pad1->posX: %d, posY: %d\n", Dmem[`PAD1ADDR + `POSX], Dmem[`PAD1ADDR + `POSY]);
        end
        if (PC == 95) begin
            $display("p2update\n");
            $display("pad1->posX: %d, posY: %d\n", Dmem[`PAD1ADDR + `POSX], Dmem[`PAD1ADDR + `POSY]);
        end

        if (PC == 70) begin
            $display("WAITCLICK\n");
            $display("ball->posX: %d, posY: %d, posZ: %d\n", Dmem[`BALLADDR + `POSX], Dmem[`BALLADDR + `POSY], Dmem[`BALLADDR + `POSZ]);
            $display("pad1->posX: %d, posY: %d\n", Dmem[`PAD1ADDR + `POSX], Dmem[`PAD1ADDR + `POSY]);
            $display("r0: %d, r5: %d\n", rf[0], rf[5]);

            if (Dmem[`PAD1ADDR + `POSX] == 1)
                $finish;
        end

        if (PC == 602) begin
            $display("INTERSECT\n");
            $display("ball->posX: %d, posY: %d, posZ: %d\n", Dmem[`BALLADDR + `POSX], Dmem[`BALLADDR + `POSY], Dmem[`BALLADDR + `POSZ]);
            $display("pad1->posX: %d, posY: %d\n", Dmem[`PAD1ADDR + `POSX], Dmem[`PAD1ADDR + `POSY]);
        end

        if (PC == 608)
            $display("N2AA\n");
        if (PC == 614)
            $display("N3AA\n");
        if (PC == 620)
            $display("N4AA\n");
        if (PC == 624)
            $display("r6: %d, r4: %d, r5: %d\n", rf[6], rf[4], rf[5]);
        if (PC == 626)
            $display("N5AA\n");
        if (PC == 114)
            $display("N6AA, r1: %d, r2: %d, r3: %d\n", rf[1], rf[2], rf[3]);
*/
        if (PC == 121) begin // if at BUPDATE
            $display("BUPDATE: first: %d, ball->posX: %d, posY: %d, posZ: %d\n", Dmem[11], Dmem[`BALLADDR + `POSX], Dmem[`BALLADDR + `POSY], Dmem[`BALLADDR + `POSZ]);
            outGrid[Dmem[`BALLADDR + `POSX]][Dmem[`BALLADDR + `POSZ]] = Dmem[`BALLADDR + `POSY];
        end

        case (currLine[15:11])
            // ADDI
            5'b00000: begin
                tmpVal = rf[currLine[10:8]];
                tmpVal2 = {{11{currLine[4]}}, currLine[4:0]};
                rf[currLine[7:5]] = tmpVal + tmpVal2;
                //rf[currLine[7:5]] = rf[currLine[10:8]] + {{11{currLine[4]}}, currLine[4:0]};
            end
            // SUBI
            5'b00001: begin
                tmpVal = rf[currLine[10:8]];
                tmpVal2 = {{11{currLine[4]}}, currLine[4:0]};
                rf[currLine[7:5]] = tmpVal - tmpVal2;
                //rf[currLine[7:5]] = rf[currLine[10:8]] - {{11{currLine[4]}}, currLine[4:0]};
            end
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
                rf[currLine[10:8]] = {{8{currLine[7]}}, currLine[7:0]};
            // SLBI
            5'b01101: 
                rf[currLine[10:8]] = (rf[currLine[10:8]] << 8) | {{8{1'b0}}, currLine[7:0]};
            // STI
            5'b01110: 
                Dmem[{{8{1'b0}}, currLine[7:0]}] = rf[currLine[10:8]];
            // LDI
            5'b01111: 
                rf[currLine[10:8]] = Dmem[{{8{1'b0}}, currLine[7:0]}];
            5'b10000: begin
                case(currLine[1:0])
                    // ADD
                    2'b00: begin
                        tmpVal = rf[currLine[10:8]];
                        tmpVal2 = rf[currLine[7:5]];
                        rf[currLine[4:2]] = tmpVal + tmpVal2;
                        //rf[currLine[4:2]] = rf[currLine[10:8]] + rf[currLine[7:5]];
                    end
                    // SUB    
                    2'b01: begin
                        tmpVal = rf[currLine[10:8]];
                        tmpVal2 = rf[currLine[7:5]];
                        rf[currLine[4:2]] = tmpVal - tmpVal2;
                        //rf[currLine[4:2]] = rf[currLine[10:8]] - rf[currLine[7:5]];
                    end
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
                    2'b11: begin
                        tmpVal = rf[currLine[10:8]];
                        tmpVal2 = {{12{1'b0}}, rf[currLine[7:5]][3:0]};
                        rf[currLine[4:2]] = tmpVal >>> tmpVal2;
                        //rf[currLine[4:2]] = rf[currLine[10:8]] >>> {{12{1'b0}}, rf[currLine[7:5]][3:0]};
                    end    
                endcase
            end
            5'b10011: begin
                // these don't work because they are not signed
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
                tmpVal = rf[currLine[10:8]];
                if (tmpVal < 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // BLEZ
            5'b10111: begin
                tmpVal = rf[currLine[10:8]];
                if (tmpVal <= 0)
                    PC_next = PC_next + {{8{currLine[7]}}, currLine[7:0]};
            end
            // J
            5'b11000: begin
                tmpVal = {{5{currLine[10]}}, currLine[10:0]};
                PC_next = PC_next + tmpVal;
            end
            // JR
            5'b11001: begin
                tmpVal = {{8{currLine[7]}}, currLine[7:0]};
                PC_next = rf[currLine[10:8]] + tmpVal;
            end
            // JAL
            5'b11010: begin
                rf[7] = PC_next;
                tmpVal = {{5{currLine[10]}}, currLine[10:0]};
                PC_next = PC_next + tmpVal;
            end
            // JALR
            5'b11011: begin
                rf[7] = PC_next;
                tmpVal = {{8{currLine[7]}}, currLine[7:0]};
                PC_next = rf[currLine[10:8]] + tmpVal;
            end
            // HALT
            5'b11100: begin
                $display("halt seen at: PC = %d\n", PC);
                $display("first: %h, ball->posX: %h, posY: %h, posZ: %h\n", Dmem[11], Dmem[`BALLADDR + `POSX], Dmem[`BALLADDR + `POSY], Dmem[`BALLADDR + `POSZ]);
                $display("ball velX: %h, velY: %h, velZ: %h, accX: %h, accY: %h, xStat: %h, yStat: %h\n", Dmem[0], Dmem[1], Dmem[2], Dmem[3], Dmem[4], Dmem[5], Dmem[6]);
                // print the register file contents to a file
                file_out = $fopen("rf.dat");
                for (i = 0; i < 8; i = i + 1) begin
                    $fwrite(file_out, "%d: 0x%x\n", i, rf[i]);
                end
                $fclose(file_out);

                // print the data memory and its contents
                file_out = $fopen("Dmem.dat");
                for (i = 0; i < 16386; i = i + 1) begin
                    $fwrite(file_out, "%d: 0x%x\n", i, Dmem[i]);
                end
                $fclose(file_out);

                // print the excel import file
                tmpVal = 0;
                file_out = $fopen("excelDat.csv");
                $fwrite(file_out, "%-4d", tmpVal);
                for (i = 0; i < 1000; i = i + 1) begin
                    tmpVal = i;
                    $fwrite(file_out, "%-4d", tmpVal);
                end
                $fwrite(file_out, "\n");

                for (i = 0; i < 1000; i = i + 1) begin
                    tmpVal = i;
                    $fwrite(file_out, "%-4d", tmpVal);
                    for (j = 0; j < 1000; j = j + 1) begin
                        $fwrite(file_out, "%-4d", outGrid[i][j]);
                    end
                    $fwrite(file_out, "\n");
                end
                $fclose(file_out);

                $finish;
            end
            // NOP
            5'b11101: begin
                // this does nothing
            end
            // ST
            5'b11110: begin
                tmpAddr = rf[currLine[10:8]] + {{12{currLine[4]}}, currLine[4:0]};
                Dmem[tmpAddr] = rf[currLine[7:5]];
            end
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
