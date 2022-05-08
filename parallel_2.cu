#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <float.h>

__global__ void prime(bool *is_prime, int N) {
    int id = threadIdx.x;
    if(id < 2) {
        is_prime[id] = false;
    }
    else if(id == 2) {
        is_prime[id] = true;
    }
    else {
        for(int i = 2; i < N; i++) {
            if(id % i == 0) {
                is_prime[id] = false;
                return;
            }
        }
    }
}

__global__ void sum_primes(bool *is_prime, float *sum, int N) {
    int id = threadIdx.x;
    extern __shared__ float s[];
    if(id == 0) {
        s[id] = 0;
    }
    else if(is_prime[id]) {
        printf("%d is prime\n", id);
        s[id] = s[id - 1] + id;
    }
    else {
        s[id] = s[id - 1];
    }
    __syncthreads();
    if(id == N - 1) {
        *sum = s[id];
    }
}

int main(int argc, char *argv[]) {
    if(argc != 2) {
        printf("Usage: %s <number>\n", argv[0]);
        return 1;
    }
    int N = atoi(argv[1]);
    bool *is_prime = (bool *)malloc(N * sizeof(bool));

    for(int i = 0; i < N; i++) {
        is_prime[i] = true;
    }
    int limit = (int)sqrt(N);
    float *sum = (float *)malloc(sizeof(float));
    *sum = 0;
    float *sum_gpu;
    cudaMalloc((void **)&sum_gpu, sizeof(float));
    cudaMemcpy(sum_gpu, sum, sizeof(float), cudaMemcpyHostToDevice);

    bool *is_prime_gpu;
    cudaMalloc(&is_prime_gpu, N * sizeof(bool));
    cudaMemcpy(is_prime_gpu, is_prime, N * sizeof(bool), cudaMemcpyHostToDevice);

    prime<<<1,N>>>(is_prime_gpu, limit);
    cudaMemcpy(is_prime, is_prime_gpu, N * sizeof(bool), cudaMemcpyDeviceToHost);

    bool *is_prime_gpu_2;
    cudaMalloc(&is_prime_gpu_2, N * sizeof(bool));
    cudaMemcpy(is_prime_gpu_2, is_prime, N * sizeof(bool), cudaMemcpyDeviceToHost);
    sum_primes<<<1,N,N>>>(is_prime_gpu, sum_gpu, N);
    cudaMemcpy(sum, sum_gpu, sizeof(float), cudaMemcpyDeviceToHost);

    printf("Sum of primes below %d: %f\n", N, *sum);

    // printf("Sum of primes: %f\n", sum);
}