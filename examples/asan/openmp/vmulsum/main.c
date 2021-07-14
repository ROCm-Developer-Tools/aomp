//
// main.c: Demo of multi-target mulit-source OpenMP offload
//         Sources are main.c, vmul.c, and vsum.c
//         offload targets are nvptx64 and amdgcn
//

#include <stdio.h>

void vmul(int*a, int*b, int*c, int N);
void vsum(int*a, int*b, int*c, int N);

int main(){
   const int N = 100000;
   int a[N],b[N],p[N],pcheck[N],s[N],scheck[N];
   int flag=-1;
   for(int i=0;i<N;i++) {
      a[i]=i+1;
      b[i]=i+2;
      pcheck[i]=a[i]*b[i];
      scheck[i]=a[i]+b[i];
   }

   vmul(a,b,p,N);
   vsum(a,b,s,N);

   // check the results
   for(int i=0;i<N;i++)
      if((p[i]!=pcheck[i])|(s[i]!=scheck[i])) flag=i;

   if (flag != -1) {
      printf("Fail p[%d]=%d   pcheck[%d]=%d\n",
         flag,p[flag],flag,pcheck[flag]);
      printf("Fail s[%d]=%d   scheck[%d]=%d\n",
         flag,s[flag],flag,scheck[flag]);
      return 1;
   } else {
      printf("Success\n");
      return 0;
   }
}
