program TargetPrint
    implicit none
     print*,'Starting'
    !$OMP  target
      write(6,*) "HelloWorld"
    !$OMP END TARGET
    print*, 'ending'
end program TargetPrint

