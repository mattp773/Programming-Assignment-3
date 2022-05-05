CC=gcc
CFLAGS=-Wall -Wextra -Werror -O
ALL: sequential random_array_gen

sequential: sequential.c
	$(CC) $(CFLAGS) -o sequential sequential.c

random_array_gen: random_array_gen.c
	$(CC) $(CFLAGS) -o random_array_gen random_array_gen.c

clean:
	rm -f sequential.exe random_array_gen.exe *.o