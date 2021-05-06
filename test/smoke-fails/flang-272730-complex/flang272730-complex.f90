program loop_test

      implicit none
      integer   :: i
      complex   :: C,D
      C=(0,0)
      D=(1,2)

      !$OMP TARGET PARALLEL DO REDUCTION(+:C)
      do i=1, 10
         C=C+EXP(D)
      end do
      !$OMP  END TARGET PARALLEL DO

      write(*, *) "C= ", C

end program loop_test

