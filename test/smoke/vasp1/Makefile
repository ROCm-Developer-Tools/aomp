include ../../Makefile.defs

TESTNAME     = vasp1
TESTSRC_MAIN = vasp1.cpp
TESTSRC_AUX  =
TESTSRC_ALL  = $(TESTSRC_MAIN) $(TESTSRC_AUX)

CLANG        = clang++
OMP_BIN      = $(AOMP)/bin/$(CLANG)
CC           = $(OMP_BIN) $(VERBOSE)
#-ccc-print-phases
#"-\#\#\#"
include ../Makefile.rules

run: $(TESTNAME)
	LIBOMPTARGET_KERNEL_TRACE=1 \
	$(RUNENV) ./$(TESTNAME) 1

