#include <stdio.h>
#include <math.h>

#define EPS_FLOAT 1e-7
#define EPS_DOUBLE 1e-15

#pragma omp declare target
template<typename T>
T mul(T a, T b){
  T c;
  c=a*b;
  return c;
}
#pragma omp end declare target

template<typename T>
void vmul(T *a, T *b, T *c, int N){
#pragma omp target map(to: a[0:N],b[0:N]) map(from:c[0:N])
#pragma omp teams distribute parallel for
   for(int i=0;i<=N;i++) {
      c[i]=mul(a[i],b[i]);
   }
}

int main(){
    const int N = 100000;
    int a_i[N], b_i[N], c_i[N], validate_i[N];
    float a_f[N], b_f[N], c_f[N], validate_f[N];
    double a_d[N], b_d[N], c_d[N], validate_d[N];
    int N_errors = 0;
    bool flag = false;
#pragma omp parallel for
    for(int i=0; i<N; ++i){
      a_d[i]=a_f[i]=a_i[i]=i+1;
      b_d[i]=b_f[i]=b_i[i]=i+2;
      validate_i[i]=a_i[i]*b_i[i];
      validate_f[i]=a_f[i]*b_f[i];
      validate_d[i]=a_d[i]*b_d[i];
    }

    vmul(a_i,b_i,c_i,N);
    vmul(a_f,b_f,c_f,N);
    vmul(a_d,b_d,c_d,N);

    for(int i=0; i<N; i++){
      if(c_i[i] != validate_i[i]){
         ++N_errors;
//       print 1st bad index
         if(!flag){
           printf("First fail: c_i[%d](%d) != validate_i[%d](%d)\n",i,c_i[i],i,validate_i[i]);
           flag = true;
         }
      }
    }
    flag = false;
    for(int i=0; i<N; i++){
      if(fabs(c_f[i]-validate_f[i]) > EPS_FLOAT){
        ++N_errors;
//      print 1st bad index
        if(!flag){
          printf("First fail: c_f[%d](%f) != validate_f[%d](%f)\n",i,c_f[i],i,validate_f[i]);
          flag = true;
        }
      }
    }
    flag = false;
    for(int i=0; i<N; i++){
      if(fabs(c_d[i]-validate_d[i]) > EPS_DOUBLE){
        ++N_errors;
//      print 1st bad index
        if(!flag){
          printf("First fail: c_d[%d](%f) != validate_d[%d](%f)\n",i,c_d[i],i,validate_d[i]);
          flag = true;
        }
      }
    }
    if( N_errors == 0 ){
        printf("Success\n");
        return 0;
    } else {
        printf("Total %d failures\n", N_errors);
        printf("Fail\n");
        return 1;
    }
}
