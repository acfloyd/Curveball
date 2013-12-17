#!/bin/bash
rm -rf game_code.bin

./assembler.pl $1

mv game_code.bin ../source/cpu/

