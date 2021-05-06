program my_fib
        integer ::i,j
        real ::sum
        real ::sum2
        real,pointer ::array(:),buffer(:)
        allocate(array(10))
        allocate(buffer(10))

        do j=1, 10
           array(j)=1
        end do

        sum2=0

        !$OMP TARGET TEAMS DISTRIBUTE MAP(TO:array) MAP(TOFROM:buffer) PRIVATE(sum,sum2)
        do i=1, 10
           sum2=0
           sum=1000
           !$OMP PARALLEL DO REDUCTION(+:sum2)
           do j=1, 10
              !sum=sum+array(j)
              sum2=sum2+array(j)
           end do
           !$OMP END PARALLEL DO

           buffer(i)=sum+sum2
        end do
        !$OMP END TARGET TEAMS DISTRIBUTE

        do i=1, 10
        write(*, *) "sum=", buffer(i)
        end do

end program
