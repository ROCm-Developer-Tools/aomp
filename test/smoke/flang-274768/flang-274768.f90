subroutine copy(A,B,N)
    implicit none
    integer :: i,N
    !complex A(*),B(*)
    !real A(*),B(*)
    real A(*), B(*)
    !$OMP TARGET PARALLEL DO
    do i=1,N
        B(i) = A(i)
    end do
    !$OMP END TARGET PARALLEL DO

end subroutine

program loop_test
    implicit none
    integer   :: i,j,N = 2048
    !complex, pointer :: p1(:),p2(:)
    !complex   :: c = (1,2)
    real, pointer :: p1(:),p2(:)
    real   :: c = 1.0
    allocate(p1(N))
    allocate(p2(N))
    do j=1, N
        p1(j)=j*c
    end do
    do i=1, 10
        write(*, *) "p1=", p1(i)
    end do
    call copy(p1,p2,1024)
    do i=1, 10
        write(*, *) "p2=", p2(i)
    end do

end program loop_test
