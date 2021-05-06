#include <stdio.h>
#include <iostream>

int main () {
  int no = 25;
  int nc = 1000000;
  int nv = 30;
  int nos = (no-1)*(no-1);
  double *A_reduction = new double[nos]();
  double *PA = new double[nv*nos]();
  double *CA = new double[nc*nv]();

  #pragma omp target data map(to:CA[0:(nc*nv)],PA[0:(nv*nos)]) map(A_reduction[0:nos])
  #pragma omp target teams distribute parallel for reduction(+:A_reduction[:nos]) collapse(2)
  //#pragma omp parallel for reduction(+:A_reduction[:nos]) collapse(2) //works!
  for (int op = 0; op < no-1; ++op) {
    for (int of = 0; of < no-1; ++of) {
      for (int c=0; c < nc; ++c) {
        double pc = 1;
        for (int v = 0; v < nv; ++v) {
          pc *= (CA[v+c*nv]<0)+CA[v+c*nv]*PA[v+of*nv+op*(no-1)*nv];
        }
        A_reduction[of+op*(no-1)] += pc;
      }
    }
  }
}
