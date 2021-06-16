#include <iostream>

#include <omp.h>

// fit a and b perfectly inside a single page
#define N 4096/4

using namespace std;

#pragma omp requires unified_shared_memory

int main() {
  bool err = false;
  int n = N;
  int *a = (int *)malloc(n*sizeof(int));
  int *b = (int *)malloc(n*sizeof(int));

  #pragma omp target data map(a[:n])
  {
    // a[0:n] is coarse grain
    err = err || !omp_target_is_high_bw_memory(a, n*sizeof(int));
    if (!err) cout << "1. correct\n";
    // a[0:2*n] is not all coarse grain, as n = pageSize
    err = err || omp_target_is_high_bw_memory(a, n*sizeof(int)*2);
    if (!err) cout << "2. correct\n";
    // b was not mapped: it is in fine grain memory
    err = err || omp_target_is_high_bw_memory(b, n*sizeof(int));
    if (!err) cout << "3. correct\n";
  }

  if(err) cout << "Something went wrong\n";
  else cout << "All good\n";

  #pragma omp target
  {
    printf("Hello, world!\n");
  }

  return err;
}
