/* From: https://github.com/mvx24 
 * Find the sum of all primes below 2 million (Project Euler #10).
 * This can take a while! *spoiler* 142913828922
 * For below 2k: 277050 (0.09s via nvcc, 19 hours via kcc!)
 */

#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>

#define THREADS_PER_BLOCK 512

// Kernel that executes on the CUDA device
__global__ void sum_primes(int* firstPrimes, size_t n, unsigned long long* blockSums, int TOTAL_THREADS, int START_NUMBER) {
      __shared__ int blockPrimes[THREADS_PER_BLOCK];
      int i;
      int idx;
      int num;

      idx = blockIdx.x * blockDim.x + threadIdx.x;
      if (idx < TOTAL_THREADS) {
            // The number to test
            // printf("idx: %d\n", idx);
            if(START_NUMBER % 2 != 0 ) {
                num = START_NUMBER + (idx * 2);
            }
            else
                num = (START_NUMBER - 1) + (idx * 2);
            // printf("testing %d\n", num);
            for (i = 0; i < n; ++i) {
                  if(!(num % firstPrimes[i])) break;
            }
            if (i == n) {
                  blockPrimes[threadIdx.x] = num;
                //   printf("%d is prime\n", num);
            }
            else
                  blockPrimes[threadIdx.x] = 0;
      } else {
            blockPrimes[threadIdx.x] = 0;
      }

      __syncthreads();

      if (threadIdx.x == 0) {
            // sum all the results from the block
            blockSums[blockIdx.x] = 0;
            for (i = 0; i < blockDim.x; ++i)
                  blockSums[blockIdx.x] += blockPrimes[i];
      }
}

// main routine that executes on the host
int main(int argc, char *argv[]) {
      //host

      if(argc != 2) {
            printf("Usage: %s <number>\n", argv[0]);
            return 1;
      }

      int END_NUMBER = atoi(argv[1]);
      int START_NUMBER = (int)sqrt((double)END_NUMBER) + 1;
      const int n = pow(2, (ceil(log2(START_NUMBER)) + 1));
      const int TOTAL_THREADS = ((END_NUMBER + 2 - START_NUMBER) / 2);

    //   printf("total threads: %d\n", TOTAL_THREADS);
    //   printf("end number: %d\n", END_NUMBER);
    //     printf("start number: %d\n", START_NUMBER);
    //     printf("n: %d\n", n);

    //   if(TOTAL_THREADS < 512) {
    //     THREADS_PER_BLOCK = TOTAL_THREADS;
    //   }

      int *primes = (int *)malloc((n + 1) * sizeof(int));

      unsigned long long *primeSums;
      int i, j, index;
      int blockSize, nblocks;
      unsigned long long sum;
      size_t len;

      //device
      int* primesDevice;
      unsigned long long* primeSumsDevice;

      // Find all the primes less than the square root of 2 million ~1414
      primes[0] = 2;
      index = 1;
      sum = 2;
      for (i = 3; i != START_NUMBER; ++i) {
            for (j = 0; j != index; ++j) {
                  if (!(i % primes[j])) break;
            }
            if (j == index) {
                  primes[index++] = i;
                //   printf("%d is prime\n", i);
                  sum += i;
            }
      }
      len = index;

      cudaMalloc((void**) &primesDevice, len * sizeof(int));
      cudaMemcpy(primesDevice, primes, len * sizeof(int), cudaMemcpyHostToDevice);

      blockSize = THREADS_PER_BLOCK;
      nblocks = TOTAL_THREADS/blockSize + !!(TOTAL_THREADS % blockSize);
    //   printf("nblocks: %d\n", nblocks);
    //   printf("blockSize: %d\n", blockSize);
      cudaMalloc((void**) &primeSumsDevice, nblocks * sizeof(unsigned long long));

      sum_primes <<< nblocks, blockSize >>> (primesDevice, index, primeSumsDevice, TOTAL_THREADS, START_NUMBER);

      // Retrieve result from device and store it in host array
      primeSums = (unsigned long long*) malloc(nblocks * sizeof(unsigned long long));
      cudaMemcpy(primeSums, primeSumsDevice, nblocks * sizeof(unsigned long long), cudaMemcpyDeviceToHost);
      for (i = 0; i != nblocks; ++i) {
            sum += primeSums[i];
            //printf("%llu\t", primeSums[i]);
      }

      // Cleanup
      free(primeSums);
      cudaFree(primeSumsDevice);
      cudaFree(primesDevice);

      // Print results
      printf("Sum of primes less than %d = %llu\n",END_NUMBER, sum);
}