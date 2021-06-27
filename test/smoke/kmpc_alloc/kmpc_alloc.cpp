#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

extern "C" {
void *__kmpc_impl_malloc(size_t) {
  printf("Called malloc on host, error\n");
  exit(1);
}
void __kmpc_impl_free(void *) {
  printf("Called free on host, error\n");
  exit(1);
}
}

// Call the kmpc_impl malloc/free hooks from devicertl

#pragma omp declare target
extern "C" {
void *__kmpc_impl_malloc(size_t);
void __kmpc_impl_free(void *);
}
#pragma omp end declare target

int main() {
#pragma omp target device(0)
  {
    void *p = __kmpc_impl_malloc(128);
    for (unsigned i = 0; i < 128; i++) {
      *(char *)p = i;
    }
    __kmpc_impl_free(p);
  }
}
