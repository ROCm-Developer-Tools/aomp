#include <stdio.h>
#include <omp.h>
#pragma omp declare target
void hostrpc_fptr0(void* fun_ptr);
#pragma omp end declare target

//  A host function will synchronously call from a device as a function pointer
void myfun() {
  fprintf(stderr, " This is myfun writing to stderr \n");
}
int main()
{
  int N = 10;

  int a[N];
  int b[N];

  int i;

  for (i=0; i<N; i++){
    a[i]=0;
    b[i]=i;
  }
  //void (*fun_ptr)(int) = &myfun;
  void (*fun_ptr)() = &myfun;

  printf("Testing myfun execution as a function pointer \n");
  (*fun_ptr)();

  printf("Testing myfun execution from device using hostrpc_fptr0\n");
  #pragma omp target parallel for map(from: a[0:N]) map(to: b[0:N]) is_device_ptr(fun_ptr)
  for (int j = 0; j< N; j++) {
    a[j+1]=b[j];
    hostrpc_fptr0(fun_ptr);
  }

  printf("Testing the host fallback of hostrpc_fptr0 \n");
  hostrpc_fptr0(fun_ptr);

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

