#include <stdio.h>
#include <stdlib.h>
#include <cuda.h> // automatically included when compiling with nvcc

#define THREADS_PER_BLOCK 512

// kernel executed on device (GPU)
__global__ void sum_primes(int* primes, size_t n, unsigned long long* blockSums, int TOTAL_THREADS, int START_NUMBER) {
      // shared array of primes between threads of same block
      __shared__ int blockPrimes[THREADS_PER_BLOCK];
      
      // unique thread index determined by block dimensions
      int idx = blockIdx.x * blockDim.x + threadIdx.x;

      int i;
      int num;
      if (idx < TOTAL_THREADS) {
            if(START_NUMBER % 2 != 0 ) {
                num = START_NUMBER + (idx * 2);
            }
            else {
                num = (START_NUMBER - 1) + (idx * 2);
            }
            for (i = 0; i < n; ++i) {
                  if(!(num % primes[i])){ 
                        break; 
                  }
            }
            if (i == n) {
                  blockPrimes[threadIdx.x] = num; //add in prime
            }
            else {
                  blockPrimes[threadIdx.x] = 0; //not prime
            }
      } 
      else {
            blockPrimes[threadIdx.x] = 0;
      }

      __syncthreads(); // allows all threads of the block to "catch up"

      if (threadIdx.x == 0) {
            // loop and add up prime results from the block
            blockSums[blockIdx.x] = 0;
            for (i = 0; i < blockDim.x; ++i){
                  blockSums[blockIdx.x] += blockPrimes[i];
            }
      }
}

// main executed on host (CPU)
int main(int argc, char *argv[]) {
      // input error checking
      if(argc != 2) {
            printf("Usage: %s <number>\n", argv[0]);
            return 1;
      }

      // host variables
      int END_NUMBER = atoi(argv[1]);
      int START_NUMBER = (int)sqrt((double)END_NUMBER) + 1;
      const int n = pow(2, (ceil(log2(START_NUMBER)) + 1));
      const int TOTAL_THREADS = ((END_NUMBER + 2 - START_NUMBER) / 2);

      // host arrays
      int *primes = (int *)malloc((n + 1) * sizeof(int));
      unsigned long long *primeSums;

      // device arrays
      int* primesDevice;
      unsigned long long* primeSumsDevice;

      // develop primes host array to be passed to device for computation
      primes[0] = 2;
      int index = 1;
      int j;
      unsigned long long sum = 0;
      if(END_NUMBER < 3) {
            sum = 0;
      }
      else {
            sum = 2;
            for (int i = 3; i < START_NUMBER; ++i) {
                  for (j = 0; j < index; ++j) {
                        if (!(i % primes[j])) break;
                  }
                  if (j == index) {
                        primes[index++] = i;
                        sum += i;
                  }
            }
            size_t len = index;

            // initialize GPU by setting block size and number of blocks
            int blockSize = THREADS_PER_BLOCK;
            int nblocks = TOTAL_THREADS/blockSize + !!(TOTAL_THREADS % blockSize);

            // allocate prime numbers variable on device
            cudaMalloc((void**) &primesDevice, len * sizeof(int));

            // copy prime numbers from host to device variable
            cudaMemcpy(primesDevice, primes, len * sizeof(int), cudaMemcpyHostToDevice);

            // allocate sum of prime numbers variable on device
            cudaMalloc((void**) &primeSumsDevice, nblocks * sizeof(unsigned long long));

            // call the kernel with args
            sum_primes <<< nblocks, blockSize >>> (primesDevice, index, primeSumsDevice, TOTAL_THREADS, START_NUMBER);

            // allocate sum of prime numbers variable on host
            primeSums = (unsigned long long*) malloc(nblocks * sizeof(unsigned long long));
            
            // copy results from device back to host
            cudaMemcpy(primeSums, primeSumsDevice, nblocks * sizeof(unsigned long long), cudaMemcpyDeviceToHost);
            
            // add up the prime sums in the array of prime sums produced by the device
            for (int i = 0; i != nblocks; ++i) {
                  sum += primeSums[i];
            }

            // free allocated memory
            free(primeSums);
            cudaFree(primeSumsDevice);
            cudaFree(primesDevice);
      }
      // Print results
      printf("Sum of primes less than %d = %llu\n",END_NUMBER, sum);
}