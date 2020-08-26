include ../Makefile.defs

TESTNAME     = shared_library_oom
TESTSRC_MAIN = shared_library_oom.c
TESTSRC_AUX  =
TESTSRC_ALL  = $(TESTSRC_MAIN) $(TESTSRC_AUX) foo.so

CLANG        = clang
OMP_BIN      = $(AOMP)/bin/$(CLANG)
CC           = $(OMP_BIN) $(VERBOSE)
LINK_FLAGS   = foo.so
#-ccc-print-phases
#"-\#\#\#"

include ../Makefile.rules

%.dc: shared_library_call.c
	sed  's_NAME_$@_g' $^ &> $@

%.so: %.dc
	$(SETENV) $(CC) $(CFLAGS) $(EXTRA_CFLAGS) $(OMP_FLAGS) $^ -shared -o $@

