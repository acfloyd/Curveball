all: game_code.s

game_code.s: curveball.c curveball.h opponent.c opponent.h paddle.c paddle.h ball.c ball.h
	gcc -O2 -S -c *.c
	gcc -c -g -Wa,-a,-ad -O2 *.c > game_code.lst
	
clean:
	rm -rf *.s game_code.lst *.o
