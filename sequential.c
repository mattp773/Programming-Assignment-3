#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv)
{

    if (argc != 2) {
        printf("Usage: %s <Number of elements>\n", argv[0]);
        return 1;
    }
    FILE* fp = fopen("input.txt", "r");

    int N = atoi(argv[1]);
    float curr;
    int k = 0;
    float sum = 0;
    float max_sum = 0;
    int size = 0;
    int i;

    while (!feof(fp)) {
        fscanf(fp, "%f", &curr);
        size++;
    }
    rewind(fp);

    float* arr = malloc(sizeof(float) * size);

    for (i = 0; i < size; i++) {
        fscanf(fp, "%f", &arr[i]);
    }

    while (k + N <= size) {
        for (i = k; i < k + N; i++) {
            sum += arr[i];
        }
        if (sum > max_sum) {
            max_sum = sum;
        }
        k++;
        sum = 0;
    }
    fclose(fp);
    printf("max sum = %f\n", max_sum);
    return 0;
}