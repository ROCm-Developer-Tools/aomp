#include <stdio.h>
#include <omp.h>

int arr[100];
int nt =12;
int iid, gid, gdd, gdn;
int main()
{
  fprintf(stderr, "Omp host get_num_devices %d\n", omp_get_num_devices());
#pragma omp target map(tofrom: iid, gid, gdd, gdn)
  { iid = omp_is_initial_device();
    gid = omp_get_initial_device();
    gdd = omp_get_default_device();
    gdn = omp_get_device_num();
  }
  fprintf(stderr, "Omp target omp_is_initial_device %d\n", iid);
  fprintf(stderr, "Omp target omp_get_initial_device %d\n", gid);
  fprintf(stderr, "Omp target omp_get_default_device %d\n", gdd);
  fprintf(stderr, "Omp target omp_get_device_num %d\n", gdn);

#pragma omp target teams distribute parallel for num_threads(nt)
  for (int i=0; i<100;i++)
    arr[i] =i;

//Verify
  int errors = 0;
  for (int i=0; i<100;i++){
    if(arr[i] != i)
			errors++;
}
  if(!errors){
    fprintf(stderr, "Success\n");
    return 0;
  } else{
    fprintf(stderr, "Failed\nErrors: %d\n", errors);
    return 1;
  }
}

