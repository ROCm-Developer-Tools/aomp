/*
 * This is written to be equivalent to flang-tracekernel, just written
 * in C. The intent is to track any qualitative code generation
 * difference between clang and flang. 
 */

#include <stdio.h>
#include <omp.h>

#define N1 1000
#define N2 1000

int main() {
  float *A, *B, *C;

  A = (float*)malloc(N1 * sizeof(float));
  B = (float*)malloc(N1 * sizeof(float));
  C = (float*)malloc(N2 * sizeof(float));

  for (int i = 0; i < N1; ++i) {
    A[i] = 1;
    B[i] = 1;
  }

  for (int i = 0; i < N2; ++i) {
    C[i] = 0;
  }

#pragma omp target enter data map(to: A[0:N1],B[0:N1],C[0:N2])
#pragma omp target teams distribute parallel for collapse(2)
  for (int i = 0; i < N2; ++i) {
    for (int j = 0; j < N1; ++j) {
      C[i] = A[j] + B[j];
    }
  }
#pragma omp target update from(C[0:N2])
#pragma omp target exit data map(delete:A[0:N1],B[0:N1],C[0:N2])

  for (int i = 0; i < N2; ++i) {
    if (C[i] != 2) {
      fprintf(stderr, "wrong result ");
    }
  }
  free(A);
  free(B);
  free(C);
}
