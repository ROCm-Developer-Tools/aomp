#include <stdio.h>

#define N   1000000ll
#define SUM (N * (N-1)/2)

int main (void)
{
  long long a, i;

  #pragma omp target parallel map(tofrom: a) shared(a) private(i)
  {
    #pragma omp master
    a = 0;

    #pragma omp barrier

    #pragma omp for reduction(+:a)
    for (i = 0; i < N+1; i++) {
        a += i;
    }

    // The Sum shall be sum:[0:N]
    #pragma omp single
    {
      if (a != SUM)
        printf ("Incorrect result on target = %lld, expected = %lld!\n", a, SUM);
      else
        printf ("The result is correct on target = %lld!\n", a);
    }
  }
  if (a != SUM){
    printf("Fail!\n");
    return 1;
  }
  printf("Success!\n");

  return 0;
}
