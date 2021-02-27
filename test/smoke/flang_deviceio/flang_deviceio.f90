module f90deviceio
  interface
    subroutine f90print(N)
      character(*) :: N
      !$omp declare target (f90print)
    end subroutine f90print
    subroutine f90printi(N,i)
      character(*) :: N
      integer :: i
      !$omp declare target (f90printi)
    end subroutine f90printi
    subroutine f90printf(N,f)
      character(*) :: N
      real(4) :: f
      !$omp declare target (f90printf)
    end subroutine f90printf
    subroutine f90printd(N,d)
      character(*) :: N
      real(8) :: d
      !$omp declare target (f90printd)
    end subroutine f90printd
  end interface
end module
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

