#include <stdio.h>
#include <omp.h>
#include <hostrpc.h>

// This user variable function returns a uint so declare function
// as hostrpc_varfn_uint_t .
hostrpc_varfn_uint_t my3argfn;
hostrpc_varfn_double_t mydoublefn;

//  This is an arbitrary 3 arg function
uint my3argfn(void * fnptr, ...) {
  va_list args;
  va_start(args, fnptr);
  int*a  = va_arg(args, int*);
  int i2 = va_arg(args, int);
  int i3 = va_arg(args, int);
  printf("  INSIDE my3argfn:  fnptr:%p  &a:%p int arg2:%d  int arg3:%d  \n", fnptr,a,i2,i3);
  va_end(args);
  return i2+i3;
}
//  This is an arbitrary 3 arg function
double mydoublefn(void * fnptr, ...) {
  va_list args;
  va_start(args, fnptr);
  int*a  = va_arg(args, int*);
  int i2 = va_arg(args, int);
  int i3 = va_arg(args, int);
  double rc = (double) (i2+i3) * 1.1;
  printf("  INSIDE mydoublefn:  fnptr:%p  &a:%p int arg2:%d  int arg3:%d rc:%f \n", fnptr,a,i2,i3,rc);
  va_end(args);
  return rc;
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
  hostrpc_varfn_uint_t * my_host_fn_ptr;
  my_host_fn_ptr = &my3argfn;
  hostrpc_varfn_double_t * my_host_fn_double;
  my_host_fn_double = &mydoublefn;

  printf("Testing my3argfn execution as function pointer %p  &a:%p\n",(void *) my_host_fn_ptr, &a);
  uint sim1 = my_host_fn_ptr(NULL, &a, 2, 3);
  double sim1d = my_host_fn_double(NULL, &a, 2, 3);
  printf("Return values are %d  and %f \n",sim1,sim1d);

  printf("\nTesting the host fallback of hostrpc_varfn_double:%p\n",my_host_fn_double);
  uint sim2 = hostrpc_varfn_uint(my_host_fn_ptr, &a, 4, 5);
  double  sim2d = hostrpc_varfn_double(my_host_fn_double, &a, 4, 5);
  printf("Return values are %d  and %f \n",sim2,sim2d);

  printf("\nTesting call to hostrpc_varfn_uint in target region:%p\n",my_host_fn_ptr);
  #pragma omp target parallel for map(from: a[0:N]) map(to: b[0:N]) is_device_ptr(my_host_fn_ptr,my_host_fn_double)
  for (int j = 0; j< N; j++) {
    a[j]=b[j*2];
    uint    rc=hostrpc_varfn_uint(my_host_fn_ptr, &a, j, a[j]);
    double rcd=hostrpc_varfn_double(my_host_fn_double, &a, j, a[j]);
    printf("DEVICE: fnptr:%p dfnptr:%p &a:%p j:%d a[j]:%d  hostrpc_varfn_uint return vals are %d %f\n",
      (void*) my_host_fn_ptr,
      (void*) my_host_fn_double,
      (void*) &a, j, a[j],rc,rcd);
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

