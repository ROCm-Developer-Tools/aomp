module mytest
        interface
        subroutine fib(N)
        integer :: N
end subroutine fib
end interface
end module

subroutine fib(N)
        integer :: N
        !$omp declare target
        N=10

end subroutine
