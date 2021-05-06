program test
         integer :: i,j
         complex :: M,N
         complex,pointer :: A(:)
  
        allocate(A(10))
        M=(0,0)
 
        do i=1, 10
          A(i)=(1,1)
        enddo
 
!$omp target teams distribute map(to:A) map(tofrom:M) reduction(+:M)
       do i=1, 10
       N=(0,0)
!$omp parallel do reduction(+:N)
         do j=1, 10
           N=N+A(j)
         enddo
!$omp end parallel do
         M=M+N
      enddo
!$omp end target teams distribute

       write(*, *), "M=", M

end program test
