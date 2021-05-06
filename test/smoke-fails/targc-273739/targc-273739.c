#include <omp.h>
#include <stdio.h>


int main (){

  omp_set_default_device(0);
  double *x_d, *y_d;
  //allocate memory on the device
  size_t N = 1024*1024*10;
  int use_device = 1;
  int chunk = 1;

  x_d = (double*) omp_target_alloc(N*sizeof(double), omp_get_initial_device() );
  y_d = (double*) omp_target_alloc(N*sizeof(double), omp_get_initial_device() );

  printf("x_d = %p\n",x_d);
  printf("y_d = %p\n",y_d);


  #pragma omp target teams distribute parallel for num_teams(120*4) thread_limit(512) schedule(static,chunk) is_device_ptr(x_d,y_d) if(target:use_device)
  for (size_t i = 0; i < N; ++i){
     x_d[i] = 0.0001*i;
     y_d[i] = 0.00003*i;
  }

  omp_target_free( x_d,omp_get_initial_device() );
  omp_target_free( y_d,omp_get_initial_device() );


  return 0;
}
