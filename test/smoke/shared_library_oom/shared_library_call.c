#include <stdio.h>

void NAME (void)
{
#pragma omp target
  printf("Called NAME \n");
}
