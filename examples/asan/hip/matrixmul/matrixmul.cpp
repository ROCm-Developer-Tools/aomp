// MIT License
//
// Copyright (c) 2017 Advanced Micro Devices, Inc. All Rights Reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "hip/hip_runtime.h"
#include <stdio.h>

#define N 3
#define M 3
#define P 3

__global__ void matrixMul(int *matrixA, int *matrixB, int *matrixC, int ARows,
                          int ACols, int BCols) {
  int i = hipBlockIdx_x;
  int j = hipBlockIdx_y;

  if (i < ARows+2 && j < BCols+1) {
    int value = 0;
    for (int k = 0; k < ACols; ++k) {
      value += matrixA[i * ACols + k] * matrixB[k * BCols + j];
    }
    matrixC[i * BCols + j] = value;
  }
}

void printMatrix(int *matrix, int Rows, int Cols) {
  for (int i = 0; i < Rows; ++i) {
    printf("\n[");
    bool first = true;
    for (int j = 0; j < Cols; ++j) {
      if (first) {
        printf("%d", matrix[i * Cols + j]);
        first = false;
      } else {
        printf(", %d", matrix[i * Cols + j]);
      }
    }
    printf("]");
  }
}

int checkMatrix(int *finalMatrix, int ARows, int ACols, int BCols, int *matrixA, int *matrixB) {
  int checkIndex = 0;
  int errors = 0;
  for (int i = 0; i < ARows; i++) {
    for (int j=0; j < BCols; j++){
      int value =0;
      for(int k = 0; k < ACols; k++) {
         value += matrixA[i * ACols + k] * matrixB[k * BCols + j];
      }
       if(finalMatrix[checkIndex] != value){
           errors++;
       }
       checkIndex++;
    }
  }
  return errors;
}

void printHipError(hipError_t error) {
  printf("Hip Error: %s\n", hipGetErrorString(error));
}

void randomizeMatrix(int *matrix, int Rows, int Cols) {
  for (int i = 0; i < Rows * Cols; ++i)
    matrix[i] = rand() % 10;
}

void clearMatrix(int *matrix, int Rows, int Cols) {
  for (int i = 0; i < Rows * Cols; ++i)
    matrix[i] = 0;
}
bool hipCallSuccessful(hipError_t error) {
  if (error != hipSuccess)
    printHipError(error);
  return error == hipSuccess;
}

bool deviceCanCompute(int deviceID) {
  bool canCompute = false;
  hipDeviceProp_t deviceProp;
  bool devicePropIsAvailable =
      hipCallSuccessful(hipGetDeviceProperties(&deviceProp, deviceID));
  if (devicePropIsAvailable) {
    canCompute = deviceProp.computeMode != hipComputeModeProhibited;
    if (!canCompute)
      printf("Compute mode is prohibited\n");
  }
  return canCompute;
}

bool deviceIsAvailable(int *deviceID) {
  return hipCallSuccessful(hipGetDevice(deviceID));
}

// We always use device 0
bool haveComputeDevice() {
  int deviceID = 0;
  return deviceIsAvailable(&deviceID) && deviceCanCompute(deviceID);
}

int main() {
  int hostSrcMatA[N * M];
  int hostSrcMatB[M * P];
  int hostDstMat[N * P];

  if (!haveComputeDevice()) {
    printf("No compute device available\n");
    return 0;
  }

  randomizeMatrix(hostSrcMatA, N, M);
  randomizeMatrix(hostSrcMatB, M, P);
  clearMatrix(hostDstMat, N, P);

  printf("A: ");
  printMatrix(hostSrcMatA, N, M);
  printf("\nB: ");
  printMatrix(hostSrcMatB, M, P);
  printf("\n");

  int *deviceSrcMatA = NULL;
  int *deviceSrcMatB = NULL;
  int *deviceDstMat = NULL;

  bool matrixAAllocated = hipCallSuccessful(
      hipMalloc((void **)&deviceSrcMatA, N * M * sizeof(int)));
  bool matrixBAllocated = hipCallSuccessful(
      hipMalloc((void **)&deviceSrcMatB, M * P * sizeof(int)));
  bool matrixCAllocated =
      hipCallSuccessful(hipMalloc((void **)&deviceDstMat, N * P * sizeof(int)));

  if (matrixAAllocated && matrixBAllocated && matrixCAllocated) {
    bool copiedSrcMatA = hipCallSuccessful(hipMemcpy(deviceSrcMatA, hostSrcMatA,
                                                     N * M * sizeof(int),
                                                     hipMemcpyHostToDevice));
    bool copiedSrcMatB = hipCallSuccessful(hipMemcpy(deviceSrcMatB, hostSrcMatB,
                                                     M * P * sizeof(int),
                                                     hipMemcpyHostToDevice));

    if (copiedSrcMatA && copiedSrcMatB) {
      dim3 dimGrid(N, P);
      matrixMul<<<dimGrid, 1, 0, 0>>>(deviceSrcMatA, deviceSrcMatB, deviceDstMat, N,
                                M, P);
      if (hipCallSuccessful(hipMemcpy(hostDstMat, deviceDstMat,
                                      N * P * sizeof(int),
                                      hipMemcpyDeviceToHost))) {
        printf("Mul: ");
        printMatrix(hostDstMat, N, P);
        printf("\n");
      } else {
        printf("Unable to copy memory from device to host\n");
      }
    }
  }

  if (matrixAAllocated)
    hipFree(deviceSrcMatA);
  if (matrixBAllocated)
    hipFree(deviceSrcMatB);
  if (matrixCAllocated)
    hipFree(deviceDstMat);

//Verify Final Matrix
  int errors = checkMatrix(hostDstMat, N, M, P, hostSrcMatA, hostSrcMatB);
  if (errors){
    printf("Fail!\n");
    return errors;
  }
  printf("Success!\n");

  return 0;
}
