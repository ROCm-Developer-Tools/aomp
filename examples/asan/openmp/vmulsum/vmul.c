//
// vmul.c : Demo of multi-target mulit-source OpenMP offload
//

#include <stdio.h>

void vmul(int*a, int*b, int*c, int N){
#pragma omp target teams map(to: a[0:N],b[0:N]) map(from:c[0:N])
#pragma omp distribute parallel for
   for(int i=0;i<N+1;i++) {
      c[i]=a[i]*b[i];
   }
}
