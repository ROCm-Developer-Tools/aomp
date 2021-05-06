program test

      USE hip_profiling,       ONLY:roctxRangePushA, &
                                  roctxRangePop, &
                                  roctxMarkA
      USE iso_c_binding,       ONLY: c_null_char

      implicit none
      integer :: i, j, k, N1, N2
      real,pointer :: A(:),B(:),C(:)
      integer :: ret
      N1=1000
      N2=1000

      allocate(A(N1))
      allocate(B(N1))
      allocate(C(N2))

      do i=1, N1
         A(i)=1
         B(i)=1
      enddo

      do i=1, N2
         C(i)=0
      enddo

      ret = roctxRangePushA("message"//c_null_char)
      !$omp target enter data map(to:A,B,C)

      !$omp target teams distribute parallel do collapse(2)
      do i=1, N2
         do j=1, N1
            C(i)=A(j)+B(j)
         enddo
      enddo
      !$omp end target teams distribute parallel do

      !$omp target update from(C)
      !$omp target exit data map(delete:A,B,C)
   call roctxRangePop()


      do i=1, N2
         if(C(i) .ne. 2) then
            !write(*, *), C(i)
            write(*, *), "wrong result"
            exit
         endif
      enddo
           

end program test

