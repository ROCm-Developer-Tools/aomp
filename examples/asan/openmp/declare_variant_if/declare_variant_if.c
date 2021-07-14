#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <omp.h>

//  --- start of saxpy header with variants ---
int saxpy(int, float, float *, float *);
int amdgcn_saxpy(int, float, float *, float *);
int nvptx_saxpy(int, float, float *, float *);

#pragma omp declare variant(nvptx_saxpy) \
  match(device = {arch(nvptx, nvptx64)}, implementation = {extension(match_any)})
#pragma omp declare variant( amdgcn_saxpy )  \
  match(device = {arch(amdgcn)}, implementation = {extension(match_any)})
int saxpy(int n, float s, float *x, float *y)    // base function
{
   printf("saxpy: Running on host . IsHost:%d\n", omp_is_initial_device());
   #pragma omp parallel for
   for(int i=0; i<n; i++) y[i] = s*x[i] + y[i];
   return 1;
}
int amdgcn_saxpy(int n, float s, float *x, float *y)    //function variant
{
   printf("amdgcn_saxpY: Running on amdgcn device. IsHost:%d\n", omp_is_initial_device());
   #pragma omp teams distribute parallel for
   for(int i=0; i<=n; i++) { y[i] = s*x[i] + y[i]; }
   return 0;
}
int nvptx_saxpy(int n, float s, float *x, float *y)    //function variant
{
   printf("nvptx_saxpy: Running on nvptx device. IsHost:%d\n",omp_is_initial_device());
   #pragma omp teams distribute parallel for
   for(int i=0; i<n; i++) y[i] = s*x[i] + y[i];
   return 0;
}
//  --- end of saxpy header with variants ----

#define N 128
#define THRESHOLD  127
int main() {
   static float x[N],y[N] __attribute__ ((aligned(64)));
   float s=2.0;
   int return_code = 0 ;

   for(int i=0; i<N; i++){ x[i]=i+1; y[i]=i+1; } // initialize

   printf("Calling saxpy with high threshold for device execution\n");
   #pragma omp target if (N>(THRESHOLD*2))
   return_code = saxpy(N,s,x,y);

   printf("Calling saxpy with low threshold for device execution\n");
   #pragma omp target if (N>THRESHOLD)
   return_code = saxpy(N,s,x,y);

   printf("y[0],y[N-1]: %5.0f %5.0f\n",y[0],y[N-1]); //output: y...   5 640

   return return_code;
}
