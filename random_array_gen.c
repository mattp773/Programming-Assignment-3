#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char** argv)
{
    if (argc != 2) {
        printf("Usage: %s <size / 1000>\n", argv[0]);
        return 1;
    }
    int size = atoi(argv[1]);
    srand(time(NULL));
    float n = RAND_MAX;
    float x;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < 1000; j++) {
            x = (100 * (rand() / n));
            printf("%f\n", x);
        }
    }
    return 0;
}

// note that this can take a while (like 20+ minutes) to generate 10,000,000+ random numbers, but that is what the lab writeup calls for
