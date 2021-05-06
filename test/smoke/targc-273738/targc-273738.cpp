#include <stdio.h>
#include <omp.h>

int main(){

   int ndevices = omp_get_num_devices();

   fprintf(stderr,"ndevices = %d\n",ndevices);

   omp_set_default_device(0);

   size_t N = 1024*1024*100;
   double *x = new double[N];
   double *y = new double[N];
   double t1, t2;
   double GB = (double) N * sizeof(double)/(1024.0*1024.0*1024.0);
   int use_device = 1;
   int Niter = 5;
   int chunk, is_present;

   if (use_device) chunk = 1;
   else chunk = (N + omp_get_max_threads() - 1) / omp_get_max_threads();

   #pragma omp parallel for
   for (size_t i = 0; i < N; ++i){
           x[i] = 0.00001*i;
           y[i] = 0.00033*i;
   }

   printf("CPU: x = %p\n",x);
   is_present = omp_target_is_present((void*)x, omp_get_initial_device() );
   printf("before enter data: is_present == %d\n",is_present);
   #pragma omp target enter data map(to:x[0:N],y[0:N]) if(use_device)
   is_present = omp_target_is_present((void*)x, omp_get_initial_device() );
   printf("after enter data: is_present == %d\n",is_present);

   #pragma omp target if(target:use_device)
   {
      printf("GPU: x = %p\n",x);
   }

   #pragma omp target teams distribute parallel for if(target:use_device)
   for (size_t i = 0; i < N; ++i){
       y[i] = x[i]+y[i];
   }

   t1 = omp_get_wtime();
   for (int iter  = 0; iter < Niter; ++iter){

      #pragma omp target teams distribute parallel for num_teams(120*4) thread_limit(512) schedule(static,chunk) if(target:use_device)
      for (size_t i = 0; i < N; ++i){
         y[i] = x[i]+y[i];
      }

   }
   t2 = omp_get_wtime();
   t2 = (t2-t1)/Niter;
   if (use_device == 1)
     printf("GPU: daxpy : acheived BW = %g[GB/s]\n",GB*3.0/t2);
   else
     printf("CPU: daxpy : acheived BW = %g[GB/s]\n",GB*3.0/t2);

   t1 = omp_get_wtime();
   #pragma omp target update from(y[0:N]) if(use_device)
   t2 = omp_get_wtime();
   t2 = t2-t1;
   if (use_device) printf("update from: effective BW = %g[GB/s]\n",GB/t2);

   is_present = omp_target_is_present((void*)x, omp_get_initial_device() );

 

   printf ("x: is_present = %d\n",is_present);

   #pragma omp target exit data map(delete:x[0:N],y[0:N]) if(use_device)
   is_present = omp_target_is_present((void*)x, omp_get_initial_device() );
   printf ("x: after release is_present = %d\n",is_present);

   //expected result - code fails as y should not be present
   #pragma omp target update to(y[0:N]) if(use_device)

   //expected result x=nill  and y=nill
   #pragma omp target if(target:use_device)
   {
      printf("GPU: x = %p\n",x);
      printf("GPU: y = %p\n",x);
   }


  delete[] x;
  delete[] y;
  return 0;

}
