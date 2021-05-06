! example of simple Fortran AMD GPU offloading
program main
  parameter (nsize=200)
  parameter (num_loops=10)
  real a(nsize), b(nsize), c(nsize), a_cpu(nsize)
  integer i

  do i=1,nsize
    a(i) = 0
    a_cpu(i) = 0
    b(i) = i
    c(i) = 10
  end do

  do j=1,num_loops
      do i=1,nsize
          a_cpu(i) = a_cpu(i) + b(i) * c(i) + i
      end do
  end do

  !$omp target update to(a,b,c)

  !$omp target parallel do ordered(2)
  do j=1,num_loops
      do i=1,nsize
          a(i) = a(i) + b(i) * c(i) + i
      end do
  end do

  !$omp target update from(a)

  do i=1,nsize
      if (a(i).ne.a_cpu(i)) then
          print *, "[Error] : a(", i ,") <> a_cpu(", i, ") ==> ", a(i), " <> ", a_cpu(i)
          exit
      endif
  end do
  return
end
