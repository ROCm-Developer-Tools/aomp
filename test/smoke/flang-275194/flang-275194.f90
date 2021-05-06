program test
      integer :: i,k
      real,pointer :: x(:)
      allocate(x(10))
      k=2

     !$omp target if(k > 0) map(from:x)
      k=2
      !$omp parallel do
      do i=1, 10
         x(i)=1
      enddo
      !$omp end parallel do
     !$omp end target

end program test
