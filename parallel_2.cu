#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <float.h>

typedef struct nums {
    int value;
    bool isPrime;
} nums;

#define blockSize (256)

__global__ void prime(struct nums *is_prime) {
    int id = threadIdx.x;
    if(id == 0 || id == 1) {
        is_prime[id].isPrime = false;
        is_prime[id].value = 0;
        return;
    }
    for(int i = 2; i <= (int)sqrt((float)id); i++) {
        if(id % i == 0) {
            is_prime[id].isPrime = false;
            is_prime[id].value = 0;
            return;
        }
    }
    
}

__global__ void sum_primes(struct nums *is_prime, float *sum, int N) {
    int id = threadIdx.x;
    float sum_1 = 0;
    for(int i = id; i < N; i+= blockSize) {
        // printf("value at %d is %d\n", i, is_prime[i].value);
        sum_1 += is_prime[i].value;
    }
    __shared__ float r[blockSize];
    r[id] = sum_1;
    __syncthreads();
    for(int size = blockSize/2; size > 0; size /= 2) {
        if(id < size) {
            r[id] += r[id + size];
        }
        __syncthreads();
    }
    if(id == 0) {
        *sum = r[0];
    }
}

int main(int argc, char *argv[]) {
    if(argc != 2) {
        printf("Usage: %s <number>\n", argv[0]);
        return 1;
    }
    int N = atoi(argv[1]);
    struct nums *is_prime = (nums *)malloc(N * sizeof(nums));

    for(int i = 0; i < N; i++) {
        is_prime[i].value = i;
        // printf("is_prime[%d].value = %d\n", i, is_prime[i].value);
        is_prime[i].isPrime = true;
    }

    
    float *sum = (float *)malloc(sizeof(float));
    *sum = 0;
    float *sum_gpu;
    cudaMalloc((void **)&sum_gpu, sizeof(float));
    cudaMemcpy(sum_gpu, sum, sizeof(float), cudaMemcpyHostToDevice);

    nums *is_prime_gpu;
    cudaMalloc(&is_prime_gpu, N * sizeof(nums));
    cudaMemcpy(is_prime_gpu, is_prime, N * sizeof(nums), cudaMemcpyHostToDevice);

    prime<<<1,N>>>(is_prime_gpu);
    cudaMemcpy(is_prime, is_prime_gpu, N * sizeof(nums), cudaMemcpyDeviceToHost);

    for(int i = 0; i < N; i++) {
       
            // printf("%d is prime\n", is_prime[i].value);
            *sum += is_prime[i].value;
    }

    // nums *is_prime_gpu_2;
    // cudaMalloc(&is_prime_gpu_2, N * sizeof(nums));
    // cudaMemcpy(is_prime_gpu_2, is_prime, N * sizeof(nums), cudaMemcpyDeviceToHost);
    // sum_primes<<<1,blockSize>>>(is_prime_gpu, sum_gpu, N);
    // cudaMemcpy(sum, sum_gpu, sizeof(float), cudaMemcpyDeviceToHost);

    printf("Sum of primes below %d: %.0f\n", N, *sum);

    // printf("Sum of primes: %f\n", sum);
}