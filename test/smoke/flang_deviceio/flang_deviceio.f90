program ftest
     use omp_lib
     use f90deviceio

     !$omp target
     if (omp_get_thread_num() .eq. 2) then
       call f90print("Hello from gpu")
       call f90printi("Hello from gpu",2)
       call f90printf("Hello from gpu", 3.0)
       call f90printd("Hello from gpu", 4.0D0)
     endif
     !$omp end target

end program ftest

