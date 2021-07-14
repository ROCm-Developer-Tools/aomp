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

__device__ long long int *stuff;

__global__ void writeIndex(int *b, int n);

void printArray(int *array) {
  printf("[");
  bool first = true;
  for (int i = 0; i < N; ++i) {
    if (first) {
      printf("%d", array[i]);
      first = false;
    } else {
      printf(", %d", array[i]);
    }
  }
  printf("]");
}

int checkArray(int *array){
  int errors = 0;
  for(int i = 0; i < N; ++i){
    if(array[i] != i)
      errors++;
  }
  return errors;
}

void printHipError(hipError_t error) {
  printf("Hip Error: %s\n", hipGetErrorString(error));
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
  int hostArray[N];

  if (!haveComputeDevice()) {
    printf("No compute device available\n");
    return 0;
  }

  for (int i = 0; i < N; ++i)
    hostArray[i] = 0;

  printf("Array content before kernel:\n");
  printArray(hostArray);
  printf("\n");

  int *deviceArray;
  if (!hipCallSuccessful(hipMalloc((void **)&deviceArray, N * sizeof(int)))) {
    printf("Unable to allocate device memory\n");
    return 0;
  }

  hipLaunchKernelGGL((writeIndex), dim3(N), dim3(1), 0, 0, deviceArray, N);

  if (hipCallSuccessful(hipMemcpy(hostArray, deviceArray, N * sizeof(int),
                                  hipMemcpyDeviceToHost))) {
    printf("Array content after kernel:\n");
    printArray(hostArray);
    printf("\n");
  } else {
    printf("Unable to copy memory from device to host\n");
  }

  hipFree(deviceArray);

  int errors = checkArray(hostArray);

  if(errors){
    printf("Fail!\n");
    return 1;
  }
  printf("Success!\n");
  return 0;
}
