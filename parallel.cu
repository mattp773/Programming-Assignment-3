#include <stdio.h>
#include <stdlib.h>
#include <math.h>


__global__ void add_set(float *arr, float *sums, int size) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    printf("id = %d\n", id);
    if(id < size) {
        sums[blockIdx.x] += arr[id];
        __syncthreads();
    }
}

__global__ void find_largest_sum(float *sums, float *largest_sum, int size) {
    for(int i = 0; i < size; i++) {
        if(sums[i] > *largest_sum) {
            *largest_sum = sums[i];
        }
    }
}


int main(int argc, char *argv[])
{
    if (argc != 2) {
        printf("Usage: %s <Number of elements>\n", argv[0]);
        return 1;
    }
    
    FILE* fp = fopen("input.txt", "r");
    int N = atoi(argv[1]), size = 0, i;
    float curr, *arr = (float *)malloc(sizeof(float) * size);
    
    while (!feof(fp)) {
        fscanf(fp, "%f", &curr);
        size++;
    }
    rewind(fp);

    for (i = 0; i < size; i++) {
        fscanf(fp, "%f", &arr[i]);
    }

    fclose(fp);
    printf("done reading file\n");

    int num_blocks = size - N + 1;
    int num_threads = N;

    float *sums = (float *)malloc(sizeof(float) * num_blocks);
    float *sums_gpu;
    cudaMalloc(&sums_gpu, sizeof(float) * num_blocks);
    
    float *arr_gpu;
    cudaMalloc(&arr_gpu, sizeof(float) * N);
    cudaMemcpy(arr_gpu, arr, sizeof(float) * size, cudaMemcpyHostToDevice);
    add_set<<<num_blocks, num_threads>>>(arr_gpu, sums_gpu, size);

    // cudaMemcpy(sums, sums_gpu, sizeof(float) * num_blocks, cudaMemcpyDeviceToHost);

    // float *sums_gpu_2;
    // cudaMalloc(&sums_gpu_2, sizeof(float) * num_blocks);
    // cudaMemcpy(sums_gpu_2, sums, sizeof(float) * num_blocks, cudaMemcpyDeviceToHost);

    // float *largest_sum = (float *)malloc(sizeof(float));
    // float *largest_sum_gpu;
    // cudaMalloc(&largest_sum_gpu, sizeof(float));
    // find_largest_sum<<<1,1>>>(sums_gpu_2, largest_sum_gpu, num_blocks);
    // cudaMemcpy(largest_sum, largest_sum_gpu, sizeof(float), cudaMemcpyDeviceToHost);

    // printf("Largest sum: %f\n", *largest_sum);

    return 0;
}