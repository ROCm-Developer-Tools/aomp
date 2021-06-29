#include <malloc.h>
#include <iostream>
#include <omp.h>

// 1 page worth of int32_t
#define N 1024

#pragma omp requires unified_shared_memory

// use memalign to make sure malloc'ed addresses are aligned to page size
// this prevents two allocations to end up in the same page, making possible
// to test. This is not a requirement for users
#define PAGESIZE 4096

int main() {
  int err = 0;
  int n = N;
  int32_t *a = (int32_t *) memalign(PAGESIZE, n*sizeof(int));
  int32_t *b = (int32_t *) memalign(PAGESIZE, n*sizeof(int));

  // 'a' is not yet mapped, then not yet memadvise'd to be coarse grain and registered as such
  err = err || omp_is_coarse_grain_mem_region(a, n*sizeof(int));

  #pragma omp target data map(to:a[:n])
  {
    // same region
    err = err || !omp_is_coarse_grain_mem_region(a, n*sizeof(int));

    // subset of 'a' memory region
    err = err || !omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int));

    // partially contained
    // 10* to make sure the malloc'ed pointer does not span two pages
    // It cannot span three pages because its size is precisely one page
    err = err || omp_is_coarse_grain_mem_region(&a[n/2], 10*n*sizeof(int));

    // unmapped data
    err = err || omp_is_coarse_grain_mem_region(b, n*sizeof(int));
  }

  // after first data mapping region, 'a' is still mapped
  // same region
  err = err || !omp_is_coarse_grain_mem_region(a, n*sizeof(int));

  // subset of 'a' memory region
  err = err || !omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int));

  // partially contained
  // 10* to make sure the malloc'ed pointer does not span two pages
  // It cannot span three pages because its size is precisely one page
  err = err || omp_is_coarse_grain_mem_region(&a[n/2], 10*n*sizeof(int));

  // unmapped data
  err = err || omp_is_coarse_grain_mem_region(b, n*sizeof(int));

  #pragma omp target data map(to:b[:n])
  {
    // same region
    err = err || !omp_is_coarse_grain_mem_region(a, n*sizeof(int));

    // subset of 'a' memory region
    err = err || !omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int));

    // partially contained
    // 10* to make sure the malloc'ed pointer does not span two pages
    // It cannot span three pages because its size is precisely one page
    err = err || omp_is_coarse_grain_mem_region(&a[n/2], 10*n*sizeof(int));

    // 'b' is now mapped
    err = err || !omp_is_coarse_grain_mem_region(b, n*sizeof(int));
  }

  // after data mapping regions, 'a' and 'b' are still mapped
  // same region
  err = err || !omp_is_coarse_grain_mem_region(a, n*sizeof(int));

  // subset of 'a' memory region
  err = err || !omp_is_coarse_grain_mem_region(a+10, n/2*sizeof(int));

  // partially contained
  // 10* to make sure the malloc'ed pointer does not span two pages
  // It cannot span three pages because its size is precisely one page
  err = err || omp_is_coarse_grain_mem_region(&a[n/2], 10*n*sizeof(int));

  // 'b' is now mapped
  err = err || !omp_is_coarse_grain_mem_region(b, n*sizeof(int));

  // needed to make clang gen call to tgt_register_requires
  #pragma omp target
  {
  }

  if(err) std::cout << "There was an error" << std::endl;

  return err;
}
