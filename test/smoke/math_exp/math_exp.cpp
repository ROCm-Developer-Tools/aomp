#include <complex>
#include <cmath>
#include <iostream>
#include <omp.h>
using namespace std;

int main(int argc, char **argv)
{
  std::complex<float> inp(11.0f,1.0f);
  std::complex<float> res;
  #pragma omp target map(from: res) map(to:inp)
  {
    res = exp(inp);
  }
  std::complex<float> host_res = exp(inp);
  cout << "device:" << res << "  host:" << host_res << "\n";

  std::complex<double> dinp(11.0,1.0);
  std::complex<double> dres;
  #pragma omp target map(from: dres) map(to:dinp)
  {
    dres = exp(dinp);
  }
  std::complex<double> host_dres = exp(dinp);
  cout << "device:" << dres << "  host:" << host_dres << "\n";
  return 0;
}
