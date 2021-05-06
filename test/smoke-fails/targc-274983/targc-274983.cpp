#include <omp.h>
#include <stdio.h>

int main(){
    int N;
    double *x;
    N = 128;
    x = new double[N];

    for (int i = 0; i < N; ++i) x[i] = 1.0;

    #pragma omp target enter data  map(to:x[0:N])

    for (int i = 0; i < N; ++i) x[i] = 2.0;

    #pragma omp target data  map(to:N) use_device_ptr(x)
    {
      printf("in target data: x[1] = %g\n",x[1]);
    }
    printf("outside target data: x[1] = %g\n",x[1]);
    #pragma omp target exit data map(release:x[0:N])

    delete[] x;
        return 0;

}
