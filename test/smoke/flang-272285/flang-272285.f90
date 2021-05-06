program add_real
      implicit none
      INTEGER, PARAMETER      :: np=100
      REAL, DIMENSION(np)   :: A, B
      INTEGER:: i

      DO i=1, np
         A(i)=1
         B(i)=1
      END DO

      !$OMP PARALLEL DO REDUCTION(+:A)
      DO i=1, np
         A(i)=A(i)+B(i)
      END DO
      !$OMP END PARALLEL DO

      DO i=1, np
         IF (A(i) .NE. 2) THEN
           WRITE(*, *) "ERROR AT INDEX ", i, "EXPECT 2 BUT RECEIVED", A(i)
         ENDIF
      END DO

end program add_real
