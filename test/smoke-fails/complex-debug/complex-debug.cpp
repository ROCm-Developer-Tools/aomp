
#include <iostream>
#include <complex>

template<typename T>
bool test_map()
{
  std::complex<T> a(0.2, 1), a_check;
  #pragma omp target map(from:a_check)
  {
    a_check = a;
  }

  if (std::abs(a - a_check) > 1e-6)
  {
    std::cout << "wrong map value check" << a_check << " correct value " << a << std::endl;
    return true;
  }
  return false;
}

template<typename RT, typename AT, typename BT>
bool test_plus(AT a, BT b)
{
  std::complex<RT> c, c_host;

  c_host = a + b;
  #pragma omp target map(from:c)
  {
    c = a + b;
  }

  if (std::abs(c - c_host) > 1e-6)
  {
    std::cout << "wrong operator + value check" << c << " correct value " << c_host << std::endl;
    return true;
  }
  return false;
}

template<typename RT, typename AT, typename BT>
bool test_minus(AT a, BT b)
{
  std::complex<RT> c, c_host;

  c_host = a - b;
  #pragma omp target map(from:c)
  {
    c = a - b;
  }

  if (std::abs(c - c_host) > 1e-6)
  {
    std::cout << "wrong operator - value check" << c << " correct value " << c_host << std::endl;
    return true;
  }
  return false;
}

template<typename RT, typename AT, typename BT>
bool test_mul(AT a, BT b)
{
  std::complex<RT> c, c_host;

  c_host = a * b;
  #pragma omp target map(from:c)
  {
    c = a * b;
  }

  if (std::abs(c - c_host) > 1e-6)
  {
    std::cout << "wrong operator * value check" << c << " correct value " << c_host << std::endl;
    return true;
  }
  return false;
}

template<typename RT, typename AT, typename BT>
bool test_div(AT a, BT b)
{
  std::complex<RT> c, c_host;

  c_host = a / b;
  #pragma omp target map(from:c)
  {
    c = a / b;
  }

  if (std::abs(c - c_host) > 1e-6)
  {
    std::cout << "wrong operator / value check" << c << " correct value " << c_host << std::endl;
    return true;
  }
  return false;
}

template<typename T>
bool test_complex()
{
  bool fail = false;
  fail |= test_map<T>();

  fail |= test_plus<T>(std::complex<T>(0, 1), std::complex<T>(0.5, 0.3));
  fail |= test_plus<T>(std::complex<T>(0, 1), T(0.5));
  fail |= test_plus<T>(T(0.5), std::complex<T>(0, 1));

  fail |= test_minus<T>(std::complex<T>(0, 1), std::complex<T>(0.5, 0.3));
  fail |= test_minus<T>(std::complex<T>(0, 1), T(0.5));
  fail |= test_minus<T>(T(0.5), std::complex<T>(0, 1));

  fail |= test_mul<T>(std::complex<T>(0, 1), std::complex<T>(0.5, 0.3));
  fail |= test_mul<T>(std::complex<T>(0, 1), T(0.5));
  fail |= test_mul<T>(T(0.5), std::complex<T>(0, 1));

  fail |= test_div<T>(std::complex<T>(0, 1), std::complex<T>(0.5, 0.3));
  fail |= test_div<T>(std::complex<T>(0, 1), T(0.5));
  fail |= test_div<T>(T(0.5), std::complex<T>(0, 1));

  return fail;
}

int main()
{
  bool fail = false;
  fail |= test_complex<float>();
  fail |= test_complex<double>();
  std::cout << ((fail) ? "FAIL\n" :"Success!\n");
  return fail;
}
