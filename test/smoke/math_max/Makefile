include ../Makefile.defs

TESTNAME        = math_max
TESTSRC_MAIN    = math_max.cpp
TESTSRC_AUX     =
TESTSRC_ALL     = $(TESTSRC_MAIN) $(TESTSRC_AUX)

CLANG           = clang++
OMP_BIN         = $(AOMP)/bin/$(CLANG)
CC              = $(OMP_BIN) $(VERBOSE)
EXTRA_CFLAGS    =
EXTRA_LDFLAGS   =
EXTRA_OMP_FLAGS =

include ../Makefile.rules
