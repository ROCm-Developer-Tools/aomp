#include <cstdint>
#include <stdlib.h>
#include <stdio.h>

#define N 10

int main() {
  int err = 1;
  int8_t a = 1;
  int16_t b = 1;
  int32_t c = 2;
  int64_t d = 3;
  uint8_t e = 3;
  uint16_t f = 3;
  uint32_t g = 3;
  uint64_t h = 3;
  int_fast8_t j = 3;
  int_fast16_t k = 3;
  int_fast32_t l = 3;
  int_fast64_t m = 3;
  float n = 3.0;
  double o = 3.0;
  double p = 3.0L;
  int8_t q = 3;
  int8_t r = 3;
  int8_t s = 3;
  int8_t t = 3;
  int8_t u = 3;
  int8_t v = 3;
  int8_t w = 3;
  int8_t x = 3;
  int8_t y = 3;
  int8_t z = 3;
  int lb = 1;
  int ub = 10;
  double *X = (double *) malloc(N*sizeof(double));

  // all scalars are implicitly passed as firstprivate
  #pragma omp target map(tofrom: X[:N])
  {
    X[0] = a+b+c+d+e+f+g+h+j+k+l+m+n+o+p+q+r+s+t+u+v+w+z+y+z;
    #pragma omp for
    for(int i = lb; i < ub; i++)
      X[i] = a;
  }

  if(X[0] != a+b+c+d+e+f+g+h+j+k+l+m+n+o+p+q+r+s+t+u+v+w+z+y+z) {
    err = 1;
    printf("err, X = %lf\n", X[0]);
  } else {
    err = 0;
  }

  for(int i = lb; i < ub; i++)
    if (X[i] != (double)a) err = 1;

  free(X);

  return err;
}
