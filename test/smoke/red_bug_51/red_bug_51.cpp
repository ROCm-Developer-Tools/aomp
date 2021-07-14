#include <iostream>

int main()
{
  int counts1 = 0;
  int counts2 = 0;

  #pragma omp target map(from:counts1)
  {
    int counts_team = 0;
    #pragma omp parallel
    {
      #pragma omp for
      for (int i=0; i<4; i++)
        #pragma omp atomic
        counts_team += 1;
    }
    counts1 = counts_team;
  }

  #pragma omp target map(from:counts2)
  {
    int counts_team = 0;
    #pragma omp parallel
    {
      #pragma omp for reduction(+:counts_team)
      for (int i=0; i<4; i++)
        counts_team += 1;
    }
    counts2 = counts_team;
  }

  if (counts1 != 4)
    std::cout << " wrong counts1 = " << counts1 << " should be 4!" << std::endl;
  if (counts2 != 4)
    std::cout << " wrong counts2 = " << counts2 << " should be 4!" << std::endl;
  if (counts1 !=4 || counts2 != 4) {
    std::cout << "Failed" << std::endl;
    return 1;
  }
  return 0;
}

