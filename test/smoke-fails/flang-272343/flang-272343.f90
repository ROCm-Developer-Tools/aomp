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
    integer, pointer :: p2(:)
    type(test_type), target   :: obj
    C=10
    allocate(obj%p1(100))

    do i=1, 100
        obj%p1(i)=i
    end do
    
    do i=1, 10
        write(*, *) "p1=", obj%p1(i)
    end do

    ! Extra pointer for current workaround
    allocate(p2(100))
    p2=>obj%p1

    !$OMP TARGET ENTER DATA MAP(TO: obj, obj%p1)
    !!$OMP TARGET ENTER DATA MAP(TO: p2)
    !$OMP TARGET PARALLEL DO REDUCTION(+:C)
    do i=1, 100
        C=C+obj%p1(i)
        !C=C+p2(i)
    end do
    !$OMP END TARGET PARALLEL DO
    !$OMP TARGET EXIT DATA MAP(RELEASE:obj, obj%p1)
    !!$OMP TARGET EXIT DATA MAP(RELEASE: p2)

    write(*, *) "C= ", C

end program loop_test

