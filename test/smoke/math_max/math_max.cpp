#include <cmath>
#include <algorithm>
#include <stdio.h>
using namespace std;

#define SUM 8
int main(int argc, char **argv)
{
  int intNum1 = 1;
  int intNum2 = 2;
  int max_num = 0;

  max_num += max(intNum1, intNum2);

  size_t sizetNum1 = 1;
  size_t sizetNum2 = 2;
  max_num += max(sizetNum1, sizetNum2);

  unsigned long ulNum1 = 1;
  unsigned long ulNum2 = 2;
  max_num += max(ulNum1, ulNum2);

  unsigned int uiNum1 = 1;
  unsigned int uiNum2 = 2;
  max_num += max(uiNum1, uiNum2);

  if(max_num != SUM){
    printf("Failed: max_num is %d, but should equal %d\n", max_num, SUM);
    return 1;
  }else
    printf("Success\n");
  return 0;
}
