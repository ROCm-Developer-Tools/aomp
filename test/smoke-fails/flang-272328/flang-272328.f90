module test_m
        implicit none

        public test_type

        type test_type
                integer, pointer :: p1(:)
        end type
end module

program loop_test
      use test_m

      implicit none
      integer   :: i, C
      integer, pointer :: t1(:)

      type(test_type), target   :: obj
      C=0
      allocate(obj%p1(10))

      do i=1, 10
         obj%p1(i)=i
      end do

      !$OMP TARGET MAP(TOFROM: C) MAP(TO: obj,obj%p1)
      !$OMP PARALLEL DO REDUCTION(+:C)
      do i=1, 10
         C=C+obj%p1(i)
      end do
      !$OMP END PARALLEL DO
      !$OMP END TARGET

      write(*, *) "C= ", C

end program loop_test
