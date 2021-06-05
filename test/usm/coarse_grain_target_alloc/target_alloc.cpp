#include <iostream>
#include <omp.h>

// 4KB of int32_t's
#define N 1024

#pragma omp requires unified_shared_memory

using namespace std;

int main() {
  int n = N;
  int *a = (int *)omp_target_alloc(n*sizeof(int), omp_get_default_device());
  int *b = new int[n*sizeof(int)];
  int err = 1;

  // same
  if ((err = omp_is_coarse_grain_mem_region(a, n*sizeof(int))))
    cout << "Memory region is correctly registered as coarse grain" << endl;
  else
    cout << "Memory region is *not* correctly registered as coarse grain" << endl;

  // subset
  if ((err = omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int))))
    cout << "Memory region is correctly registered as coarse grain" << endl;
  else
    cout << "Memory region is *not* correctly registered as coarse grain" << endl;

  // partially contained
  // 10* to make sure the malloc'ed pointer does not span two pages
  // It cannot span three pages because its size is precisely one page
  if (!(err = omp_is_coarse_grain_mem_region(&a[n/2], 10*n*sizeof(int))))
    cout << "Memory region is correctly registered as not coarse grain" << endl;
  else
    cout << "Memory region is *not* correctly registered as not coarse grain" << endl;

  // completely separated
  if (!(err = omp_is_coarse_grain_mem_region(b, n*sizeof(int))))
    cout << "Memory region is correctly registered as not coarse grain" << endl;
  else
    cout << "Memory region is *not* correctly registered as not coarse grain" << endl;

  // needed, otherwise clang will not gen tgt_register_requires call for usm mode
  #pragma omp target
  {
  }

  return !err;
}
