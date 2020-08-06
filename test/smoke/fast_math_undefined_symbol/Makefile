include ../Makefile.defs

TESTNAME     = fast_math_undefined_symbol
TESTSRC_MAIN = fast_math_undefined_symbol.c
TESTSRC_AUX  =
TESTSRC_ALL  = $(TESTSRC_MAIN) $(TESTSRC_AUX)

CLANG        = clang
OMP_BIN      = $(AOMP)/bin/$(CLANG)
CC           = $(OMP_BIN) $(VERBOSE)
CFLAGS       = -ffast-math
LINK_FLAGS   = -lm

include ../Makefile.rules
