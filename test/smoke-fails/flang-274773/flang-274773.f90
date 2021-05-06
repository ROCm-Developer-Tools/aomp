program test
      integer :: i,j
      ! change to complex(4) and it will pass.
      !l ikely complex8 atomic issue
      complex(8) :: M,N
      complex(8),pointer :: A(:)

      allocate(A(10))
      M=(0,0)

      do i=1, 10
        A(i)=(1,1)
      enddo

!$omp target  parallel do map(to:A) map(tofrom:M) reduction(+:M)
!!$omp target  parallel do map(to:A) map(tofrom:M) private(N) reduction(+:M)
      do i=1, 10
        N=(0,0)
        do j=1, 10
          N=N+A(j)
        enddo
        M=M+N
      enddo
!$omp end target parallel do

      write(*, *), "M=", M

end program test
 


