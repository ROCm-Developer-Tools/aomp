program t273762
! openmp simd clause not supported
  real, dimension(10)::a,b,c
  integer nsize

  nsize = 10
  b=1.0
  c=2.0

  !$omp target update to(b,c)
  !$omp target teams distribute parallel do simd map(from:a) simdlen(64)
    do i=1,nsize
      a(i) = b(i) * c(i) + i
    end do
  !$omp target update from(a)
end program
 
