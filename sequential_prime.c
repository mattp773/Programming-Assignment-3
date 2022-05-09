#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <float.h>

typedef struct primes {
    long number;
    bool is_prime;
}primes;

int main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: %s <Number of elements>\n", argv[0]);
        return 1;
    }
    
    long N = atol(argv[1]); //upper limit
    double sum = 0;
    struct primes *array = malloc(N * sizeof(primes));
    long i, j;

    //i is the current number, all primes must be less than N
    for(i = 2; i < N; i++) {
        array[i].is_prime = true;
            for(j = 2; j <= (long)sqrt((float)i); j++) {
                if(i % j == 0) {
                    array[i].is_prime = false;
                    break;
                }
            }
            if(array[i].is_prime) {
                sum += i;
            }
        }
    if(printf("Sum of primes less than %ld = %.0f\n", N, sum) < 0) {
        printf("error printing sum\n");
        return 1;
    }
    return 0;
}