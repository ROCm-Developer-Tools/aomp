program loop_test

      implicit none
      integer   :: i
      ! cange type from complex to doub le and it passes
      !double precision   :: C
      complex :: C
      C=(0,0)

      !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO REDUCTION(+:C) MAP(TOFROM: C) NUM_TEAMS(1)
      do i=1, 10000000
         C=C+(1,1)
      end do
      !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO

      !$OMP TARGET TEAMS DISTRIBUTE PARALLEL DO REDUCTION(+:C)
      do i=1, 10
         C=C+1
      end do
      !$OMP END TARGET TEAMS DISTRIBUTE PARALLEL DO

      write(*, *) "C= ", C

end program loop_test
