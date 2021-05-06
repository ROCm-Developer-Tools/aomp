#include <stdio.h>
#include <omp.h>

#define N (2)
int A=0;
int main(void) {

  int fail = 0;

  int num_teams = 2;
  fprintf(stderr, "Using num_teams %d\n", num_teams);
  #pragma omp target teams distribute num_teams(num_teams) map(tofrom:A)
  for (int k=0;k < num_teams; k++) {
    #pragma omp parallel
    for (int i=0; i < N; i++) {
      #pragma single
      {
        #pragma omp task
        for (int j=0; j <N; j++) {
	  A = 1;//printf("Howdy task0\n");
	}
        #pragma omp task
        for (int j=0; j <N; j++) {
	  A=2;//printf("Howdy task1\n");
	}
      }
    }
  } 
  printf("Succeeded\n");
  return 0;
}

