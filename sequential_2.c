#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

int main(int argc, char** argv)
{
    if (argc != 2) {
        printf("Usage: %s <Number of elements>\n", argv[0]);
        return 1;
    }
    
    int N = atoi(argv[1]); //upper limit
    int sum = 2;
    bool is_prime;
    int i, j;

    //i is the current number, all primes must be less than N
    for(i = 3; i < N; i++) {
        is_prime = true;
        for(j = 2; j <= (int)sqrt(i); j++) {
            if(i % j == 0) {
                is_prime = false;
                break;
            }
        }
        if(is_prime) {
            sum += i;
        }
    }
    printf("sum of primes less than %d = %d\n", N, sum);
    return 0;
}