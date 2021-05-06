MODULE test7_m
  IMPLICIT NONE
  PRIVATE :: outer_p
  TYPE outer
    REAL,POINTER :: C(:,:)
  END TYPE outer
  TYPE (outer), ALLOCATABLE, SAVE :: outer_p(:)
CONTAINS
  SUBROUTINE TEST7
    !use test7_m
    TYPE (outer), ALLOCATABLE :: outer1(:)
    ALLOCATE(outer1(1))
    ALLOCATE(outer_p(1))
    ! ...
    ! Do work
    ! ...
    DEALLOCATE(outer_p)
    DEALLOCATE(outer1)
  END SUBROUTINE
END module test7_m
program foob
  use test7_m
  call test7
end program foob
