#include <iostream>
#include <omp.h>

// 1 page worth of int32_t
#define N 1024

#pragma omp requires unified_shared_memory

int main() {
  int err = 0;
  int n = N;
  int32_t *a = (int32_t *) malloc(n*sizeof(int));

  // 'a' is not yet mapped, then not yet memadvise'd to be coarse grain and registered as such
  err = err || omp_is_coarse_grain_mem_region(a, n*sizeof(int));

  #pragma omp target data map(to:a[:n])
  {
    // same region
    err = err || !omp_is_coarse_grain_mem_region(a, n*sizeof(int));

    // shrinking already mapped memory, will result in no further
    // map action in rtl
    #pragma omp target data map(to:a[10:n/2])
    {
      err = err || !omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int));
    }
  }

  // needed to make clang gen call to tgt_register_requires
  #pragma omp target
  {
  }

  if(err) std::cout << "There was an error" << std::endl;

  return err;
}
