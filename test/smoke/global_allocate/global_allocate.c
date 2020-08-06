#include <omp.h>
#include <stdint.h>
#include <stdio.h>

#pragma omp declare target
char *global_allocate(uint32_t bufsz);
int global_free(char *ptr);
#pragma omp end declare target

int main() {

  // Succeeds
#pragma omp target device(0)
  {
    char *data = (char *)global_allocate(16);
    data[0] = 10;
    data[1] = 20 * data[0];
    global_free(data);
  }

  if (omp_get_num_devices() > 1) {
    // Crashes with GPU memory error
    // Global allocate assumes a single gpu system
#pragma omp target device(1)
    {
      char *data = (char *)global_allocate(16);
      data[0] = 10;
      data[1] = 20 * data[0];
      global_free(data);
    }
  }
  printf("Success\n");
  return 0;
}
