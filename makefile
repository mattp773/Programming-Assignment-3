CC=gcc
CFLAGS=-Wall -Wextra -Werror -O
ALL: sequential_1 sequential_2 random_array_gen

sequential_1: sequential_1.c
	$(CC) $(CFLAGS) -o sequential_1 sequential_1.c

sequential_2: sequential_2.c
	$(CC) $(CFLAGS) -o sequential_2 sequential_2.c	

random_array_gen: random_array_gen.c
	$(CC) $(CFLAGS) -o random_array_gen random_array_gen.c

clean:
	rm -f sequential_1.exe sequential_2.exe random_array_gen.exe *.o