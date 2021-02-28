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
