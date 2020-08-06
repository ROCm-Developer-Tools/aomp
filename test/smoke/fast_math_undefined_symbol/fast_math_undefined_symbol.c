#include <math.h>
#include <omp.h>

// Manually reduced from devito tti benchmark
// python3 benchmark.py bench -P acoustic -bm O2 -d 256 256 256 -so 2 --tn 50 --autotune offLD_LIBRARY_PATH=/home/amd/rocm/aomp/lib python3 benchmark.py bench -P tti -bm O2 -d 256 256 256 -so 2 --tn 50 --autotune off
// Fails to compile with "lld: error: undefined symbol: cosf"

struct dataobj
{
  void * data;
  int * size;
};

__attribute__((used))
int ForwardTTI(   struct dataobj * phi_vec,   const int x, const int x_size,  const int y, const int y_size,  const int z, const int z_size)
{


  float (* phi)[phi_vec->size[1]] = (float (*)[phi_vec->size[1]]) phi_vec->data;

  float (*r21)[y_size + 1][z_size + 1];
  posix_memalign((void**)&r21, 64, sizeof(float[x_size + 1][y_size + 1][z_size + 1]));
  #pragma omp target enter data map(alloc: r21[0:x_size + 1][0:y_size + 1][0:z_size + 1])
  float (*r20)[y_size + 1][z_size + 1];
  posix_memalign((void**)&r20, 64, sizeof(float[x_size + 1][y_size + 1][z_size + 1]));
  #pragma omp target enter data map(alloc: r20[0:x_size + 1][0:y_size + 1][0:z_size + 1])
  float (*r17)[y_size + 1][z_size + 1];
  posix_memalign((void**)&r17, 64, sizeof(float[x_size + 1][y_size + 1][z_size + 1]));
  #pragma omp target enter data map(alloc: r17[0:x_size + 1][0:y_size + 1][0:z_size + 1])

  #pragma omp target parallel 
  {
    r21[x][y][z] = cos(phi[x + 2][y + 2]);
    r20[x][y][z] = sin(phi[x + 2][y + 2]);
    r17[x][y][z] = sqrt(phi[x + 2][y + 2]);
  }

  return 0;
}

int main()
{
  return &ForwardTTI == 0;
}
