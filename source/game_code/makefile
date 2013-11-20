all: game_code.out

game_code.out: curveball.c curveball.h opponent.c opponent.h paddle.c paddle.h ball.c ball.h
	gcc *.c -o game_code.out
	gcc -S -c *.c
	gcc -c -g -Wa,-a,-ad *.c > game_code.lst
	
clean:
	rm -rf *.s game_code.lst *.o game_code.out test.txt
