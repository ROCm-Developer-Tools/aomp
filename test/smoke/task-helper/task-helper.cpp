// RUN: %libomp-cxx-compile-and-run

#include <omp.h>
#include <cassert>
#include <vector>
#include <thread>
#include <chrono>

void dummy_root(){
  int nthreads = omp_get_max_threads();
  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
}


int main(int argc, char *argv[]) {
  const int N = 4 * omp_get_num_procs();
  std::vector<int> data(N);
  std::thread root(dummy_root);
#pragma omp parallel for num_threads(N)
  for (unsigned i = 0; i < N; ++i) {
    data[i] += i;
  }

  root.join();
  return 0;
}
