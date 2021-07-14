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

#define N 10

__device__ int foo(int i) { return i + 1; }

__global__ void addVector(int *vectorA, int *vectorB, int *vectorC) {
  int i = hipBlockIdx_x;
  if (i < N+100) {
    vectorC[i] = vectorA[i] + vectorB[i] + foo(i);
  }
}

void printVector(int *vector) {
  printf("[");
  bool first = true;
  for (int i = 0; i < N; ++i) {
    if (first) {
      printf("%d", vector[i]);
      first = false;
    } else {
      printf(", %d", vector[i]);
    }
  }
  printf("]");
}

void printHipError(hipError_t error) {
  printf("Hip Error: %s\n", hipGetErrorString(error));
}

void randomizeVector(int *vector) {
  for (int i = 0; i < N; ++i)
    vector[i] = rand() % 10;
}

void clearVector(int *vector) {
  for (int i = 0; i < N; ++i)
    vector[i] = 0;
}

int checkVector(int *vectorA, int *vectorB, int *vectorC){
  int errors = 0;
  for (int i = 0; i < N; ++i){
    if(vectorC[i] != (vectorA[i] + vectorB[i] + i + 1))
       errors++;
  }
  return errors;
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
  int hostSrcVecA[N];
  int hostSrcVecB[N];
  int hostDstVec[N];

  if (!haveComputeDevice()) {
    printf("No compute device available\n");
    return 0;
  }

  randomizeVector(hostSrcVecA);
  randomizeVector(hostSrcVecB);
  clearVector(hostDstVec);

  printf("  A: ");
  printVector(hostSrcVecA);
  printf("\n  B: ");
  printVector(hostSrcVecB);
  printf("\n");

  int *deviceSrcVecA = NULL;
  int *deviceSrcVecB = NULL;
  int *deviceDstVec = NULL;

  bool vectorAAllocated =
      hipCallSuccessful(hipMalloc((void **)&deviceSrcVecA, N * sizeof(int)));
  bool vectorBAllocated =
      hipCallSuccessful(hipMalloc((void **)&deviceSrcVecB, N * sizeof(int)));
  bool vectorCAllocated =
      hipCallSuccessful(hipMalloc((void **)&deviceDstVec, N * sizeof(int)));

  if (vectorAAllocated && vectorBAllocated && vectorCAllocated) {
    bool copiedSrcVecA = hipCallSuccessful(hipMemcpy(
        deviceSrcVecA, hostSrcVecA, N * sizeof(int), hipMemcpyHostToDevice));
    bool copiedSrcVecB = hipCallSuccessful(hipMemcpy(
        deviceSrcVecB, hostSrcVecB, N * sizeof(int), hipMemcpyHostToDevice));

    if (copiedSrcVecA && copiedSrcVecB) {
      addVector<<<N, 1, 0, 0>>>(deviceSrcVecA, deviceSrcVecB, deviceDstVec);

      if (hipCallSuccessful(hipMemcpy(hostDstVec, deviceDstVec, N * sizeof(int),
                                      hipMemcpyDeviceToHost))) {
        printf("Sum: ");
        printVector(hostDstVec);
        printf("\n");
      } else {
        printf("Unable to copy memory from device to host\n");
      }
    }
  }

  if (vectorAAllocated)
    hipFree(deviceSrcVecA);
  if (vectorBAllocated)
    hipFree(deviceSrcVecB);
  if (vectorCAllocated)
    hipFree(deviceDstVec);

  //Check final vector
  int errors = checkVector(hostSrcVecA, hostSrcVecB, hostDstVec);
  if (errors){
    printf("Fail!\n");
    return 1;
  }
  printf ("Success!\n");
  return 0;
}
