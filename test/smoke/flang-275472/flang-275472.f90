program test
integer :: i
real(8), target :: x(10)
real(8), pointer :: x_d(:)

do i=1, 10
x(i)=1
enddo

!$omp target data map(tofrom:x)
 
x_d => x

!$omp target map(from:x_d)
x(1) = 7
!$omp end target 
!$omp end target data

print *, "Expected value for x_d(1) : 7.000000000000000"
write (*,*) "x_d(1)", x_d(1)
print *, "Expected value for x(1) : 7.000000000000000"
write (*,*) "x(1)", x(1)

end program test
