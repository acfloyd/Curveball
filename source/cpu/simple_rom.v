module simple_rom(addr, rdata);
  	parameter NUM_ADDRESSES = 16;
  	parameter ROM_DATA_FILE = "instructions.txt";
    input [15:0] addr;
    output [15:0] rdata;

    reg [15:0] MY_ROM [0:NUM_ADDRESSES-1];
    initial $readmemb(ROM_DATA_FILE, MY_ROM);
    assign rdata = MY_ROM[addr];	
endmodule
