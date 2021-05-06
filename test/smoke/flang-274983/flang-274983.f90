program test
    use omp_lib
    use f90deviceio
      integer :: i
      real, pointer  :: res, x(:)

      allocate(x(128))

      do i=1, 128
         x(i)=1
      enddo

      !$omp target enter data  map(to:x)

      do i=1, 128
         x(i)=2
      enddo

      !$omp target data is_device_ptr(x)
         write(*, *) "In tagret data=", x(1)
      !$omp end target data

      !$omp target
        if (omp_get_thread_num() .eq. 0) then
          call f90printf("In tagret data=", x(1))
        endif
      !$omp end target

      write(*, *) "Outside tagret data=", x(1)

      !$omp target exit data map(release:x)

      nullify(x)

end program test
