#include <stdlib.h>
#include <stdio.h>

#define N 10

int main() {
  int err = 1;
  int a = 1;
  int b = 2;
  int c = 3;
  int d = 3;
  int e = 3;
  int f = 3;
  int g = 3;
  int h = 3;
  int j = 3;
  int k = 3;
  int l = 3;
  int m = 3;
  int n = 3;
  int o = 3;
  int p = 3;
  int q = 3;
  int r = 3;
  int s = 3;
  int t = 3;
  int u = 3;
  int v = 3;
  int w = 3;
  int x = 3;
  int y = 3;
  int z = 3;
  int lb = 1;
  int ub = 10;
  int *X = (int *) malloc(N*sizeof(int));

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
    printf("err, X = %d\n", X[0]);
  } else {
    err = 0;
  }

  for(int i = lb; i < ub; i++)
    if (X[i] != a) err = 1;

  free(X);

  return err;
}
