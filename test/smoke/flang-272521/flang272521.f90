program loop_test

      implicit none
      integer   :: i
      complex   :: C
      C=(0,0)

      !$OMP TARGET PARALLEL DO REDUCTION(+:C) MAP(TOFROM: C)
      do i=1, 10
         C=C+(1,1)
      end do
      !$OMP END TARGET PARALLEL DO

      !$OMP TARGET PARALLEL DO REDUCTION(+:C) MAP(TOFROM: C)
      do i=1, 10
         C=C+(1,1)
      end do
      !$OMP END TARGET PARALLEL DO

      write(*, *) "C= ", C

end program loop_test
