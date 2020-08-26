#include <omp.h>
#include <stdio.h>

// This test was intended to create eight shared libraries, each containing a
// single target region, then call them in sequence. That would be an out of
// memory error on vega with the current deviceRTL if each library contains it's
// own copy of all the device code. However, clang asserts/crashes while trying
// to construct the first shared library so we should fix that first.

void foo(void);

int main() { foo(); }
