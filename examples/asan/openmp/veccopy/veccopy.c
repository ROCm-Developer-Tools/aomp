#include <stdio.h>
#include <omp.h>

int main()
{
  int N = 100000;

  int a[N];
  int b[N];

  int i;

  for (i=0; i<N; i++){
    a[i]=0;
    b[i]=i;
  }

#pragma omp target parallel for map(from: a[0:N]) map(to: b[0:N])
  {
    for (int j = 0; j <= N; j++)
      a[j]=b[j];
  }

  int rc = 0;
  for (i=0; i<N; i++)
    if (a[i] != b[i] ) {
      rc++;
      printf ("Wrong value: a[%d]=%d\n", i, a[i]);
    }

  if (!rc){
    printf("Success\n");
    return EXIT_SUCCESS;
  } else{
    printf("Failure\n");
    return EXIT_FAILURE;
  }
}

