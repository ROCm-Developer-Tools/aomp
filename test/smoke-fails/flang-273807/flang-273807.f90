MODULE unit_test_acc_parallel
#define rstd 8

implicit none
contains
   SUBROUTINE print_time(title, T1, T2, iter)
      character(len = 3) :: title
      ! Time measurement
      real    ::  T1, T2
      integer :: iter
      print *, "///",title, "///////////////////"
      print *, "  total:", T2-T1
      print *, "   iter:", ITER
      print *, "average:", (T2-T1)/ITER
      print *, "/////////////////////////"
   
   END SUBROUTINE print_time

   SUBROUTINE compute_cpu(io_data)
      REAL(rstd), INTENT(INOUT), DIMENSION(:,:,:) :: io_data
      integer:: i, j, k
      REAL(rstd) :: A(3,3), a11,a12,a13,a21,a22,a23,a31,a32,a33
      REAL(rstd) :: x1,x2,x3
      do i = 1, SIZE(io_data, 1)
         do j = 1, SIZE(io_data, 2)
            do k = 1, SIZE(io_DATA, 3)       
               A(1,1)=i;  A(1,2)=j; A(1,3)=k
               A(2,1)=j;  A(2,2)=j; A(2,3)=k
               A(3,1)=k;  A(3,2)=k; A(3,3)=k

!              CALL determinant(A(1,1),A(2,1),A(3,1),A(1,2),A(2,2),A(3,2),A(1,3),A(2,3),A(3,3),det)      
               a11=A(1,1) ; a12=A(2,1) ; a13=A(3,1)
               a21=A(1,2) ; a22=A(2,2) ; a23=A(3,2)
               a31=A(1,3) ; a32=A(2,3) ; a33=A(3,3)
      
               x1 =  a11 * (a22 * a33 - a23 * a32)
               x2 =  a12 * (a21 * a33 - a23 * a31)
               x3 =  a13 * (a21 * a32 - a22 * a31)
               io_data(i,j,k) =  x1 - x2 + x3

               !print*, "(i, j, k): ", i, j, k
            end do
         end do
      end do
   END SUBROUTINE compute_cpu

   SUBROUTINE compute_dir(io_data, ondevice)
      REAL(rstd), INTENT(INOUT), DIMENSION(:,:,:) :: io_data
      integer:: i, j, k
      LOGICAL, value :: ondevice
      REAL(rstd) :: A(3,3), a11,a12,a13,a21,a22,a23,a31,a32,a33
      REAL(rstd) :: x1,x2,x3
      !$omp target teams distribute parallel do simd collapse(3) private(A) nowait if(ondevice) !FAIL
!      !$omp target teams distribute parallel do simd collapse(3) private(A) nowait  !PASS
      do i = 1, SIZE(io_data, 1)
         do j = 1, SIZE(io_data, 2)
            do k = 1, SIZE(io_DATA, 3)
               A(1,1)=i;  A(1,2)=j; A(1,3)=k
               A(2,1)=j;  A(2,2)=j; A(2,3)=k
               A(3,1)=k;  A(3,2)=k; A(3,3)=k

!              CALL determinant(A(1,1),A(2,1),A(3,1),A(1,2),A(2,2),A(3,2),A(1,3),A(2,3),A(3,3),det)      
               a11=A(1,1) ; a12=A(2,1) ; a13=A(3,1)
               a21=A(1,2) ; a22=A(2,2) ; a23=A(3,2)
               a31=A(1,3) ; a32=A(2,3) ; a33=A(3,3)
      
               x1 =  a11 * (a22 * a33 - a23 * a32)
               x2 =  a12 * (a21 * a33 - a23 * a31)
               x3 =  a13 * (a21 * a32 - a22 * a31)
               io_data(i,j,k) =  x1 - x2 + x3
               !print*, "(i, j, k): ", i, j, k
            end do
         end do
      end do
      !$omp end target teams distribute parallel do
   END SUBROUTINE compute_dir
END MODULE unit_test_acc_parallel


program unit_test_1
#define WARM 10
#define ITER 100
#define i_len 50
#define j_len 50
#define k_len 50
use unit_test_acc_parallel

implicit none
   REAL(rstd) :: io_data(i_len, j_len, k_len)
   REAL(rstd) :: io_data_dir(i_len, j_len, k_len)
   integer:: i, j, k
   double precision :: error
   double precision, parameter :: error_max = 1.0d-10
   double precision :: speedup = 0
   real :: T1 = 0, T2 = 0

   do i = 1, WARM
!      CALL compute_cpu(io_data)
   end do

   call cpu_time(T1)
   do i = 1, ITER
      CALL compute_cpu(io_data)
   end do
   call cpu_time(T2)

   speedup = T2-T1       
   call print_time("CPU", T1, T2, ITER)

   !$omp target data map(tofrom: io_data_dir)
   do i = 1, WARM
     CALL compute_dir(io_data_dir, .TRUE.)
   end do

   call cpu_time(T1)
   do i = 1, ITER
     CALL compute_dir(io_data_dir, .TRUE.)
   end do
   call cpu_time(T2)
   !$omp taskwait
   call print_time("GPU", T1, T2, ITER)
   !$omp end target data

   speedup = speedup / (T2-T1)
   print *,"\n speedup ratio:", speedup

   ! Verification
   do i = 1, i_len
      do j = 1, j_len
         do k = 1, k_len
            error = abs(io_data_dir(i,j,k) - io_data(i,j,k))
            if( error .gt. error_max ) then
               write(*,*) "Accuracy Verification FAILED! Error bigger than max! Error = ", error, " i = ", i, " j = ", j," io_data_dir = ",&
               io_data_dir(i,j,k), " y = ", io_data(i,j,k)
               call exit
            endif
         end do
      end do
   end do
   write(*,*) "Accuracy Verification PASSED!"
end program unit_test_1
