program t273959
! testing presence of NOWAIT clause on an omp target update directive
! NOTE: test may fail at runtime once NOWAIT is supported and working
  integer, parameter :: nsize=100
  real p(nsize), v1(nsize), v2(nsize)
  call vec_mult(p, v1, v2, nsize)
  if (p(nsize) .gt. 8.5764 .and. p(nsize).lt. 8.5766) then
    write(6,*) "Success"
  else
    write(6,*) "FAILED"
  end if
end program

subroutine init(p,v1,v2,n)
  real p(n), v1(n), v2(n)
  p = 0.0
  v1 = 3.14
  v2 = 1.0
  return
end subroutine init

subroutine init_again(v1,v2,n)
  real v1(n), v2(n)
  v1 = 2.71828
  v2 = 2.0
  return
end subroutine init_again

subroutine vec_mult(p, v1, v2, N)
  real :: p(N), v1(N), v2(N)
  integer :: i

  call init(p, v1, v2, N)
!$omp target data map(to: v1, v2) map(from: p)
!$omp target
!$omp parallel do
  do i=1,N
  p(i) = v1(i) * v2(i)
  end do
  !$omp end target
  call init_again(v1, v2, N)
!$omp target update to(v1, v2) nowait
!$omp target
!$omp parallel do
  do i=1,N
  p(i) = p(i) + v1(i) * v2(i)
  end do
!$omp end target
!$omp end target data
  call output(p, N)
end subroutine

subroutine output (p,n)
  real p(n)
  write(6,*) p(1), p(n)
  return
end
