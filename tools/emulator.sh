#!/bin/bash
rm -rf work game_code.bin

./assembler.pl $1
./assembler_to_file.pl $1

vlib work
vlog emulator.v && vsim -c -do 'run -all;quit' emulator
