program my_fib
        use mytest
        integer :: N = 8
        !$omp declare target(fib)
        !$omp target map(tofrom: N)
        call fib(N)
        !$omp end target
        write(*, *) "N=", N
end program
 


