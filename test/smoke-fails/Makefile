include ../Makefile.defs

TESTS_DIR = \
    alloc_cgroup \
    alt_clang \
    alt_veclib \
    ancestorF \
    bugz-50967 \
    bugz-50968 \
    clang-282491-1 \
    clang-282491-2 \
    clang-282491-3 \
    clang-279673 \
    clang-273738 \
    clang-273739 \
    clang-280954 \
    clang-284324 \
    closed_bug1 \
    flang-collapseNR \
    flang-251450 \
    flang-272534-2 \
    flang-272534-3 \
    clang-274983-2 \
    flang-274983-2 \
    flang-274773 \
    flang-274775-critDcmplx \
    flang-274775-redDcmplx \
    flang-273807 \
    flang-273990-1 \
    flang-273759 \
    flang-273760 \
    flang-273805 \
    flang-275472 \
    flang-275472-O0 \
    flang-278342 \
    flang-280342 \
    flang-288160 \
    flang-288183 \
    flang-288446 \
    flang-288452 \
    flang-288613 \
    flang-288613-2 \
    flang-288613-3 \
    flang-288625 \
    flang-288641 \
    flang-289039 \
    flang_atomic_hint \
    flang-cmplx-fib \
    flang_dev_write \
    lds-prob1 \
    lds-prob2 \
    lds-prob3 \
    lds-prob4 \
    lds-prob5 \
    loop_order \
    omp_loop \
    reduction_array \
    requires_directive \
    targ_static \
    targc-272328 \
    targc-273739 \
    targc-274983 \
    target_teams_reduction \
    tasks

all:
	@for test_dir in $(TESTS_DIR); do \
	  echo; \
	  test_name=`grep "TESTNAME *=" $$test_dir/Makefile | sed "s/.*= *//"`; \
	  echo "TEST_DIR: $$test_dir\tTEST_NAME: $$test_name\tMAKE: $(MAKE) -C $$test_dir"; \
	  $(MAKE) -C $$test_dir; \
	done

run run_obin run_sbin run_llbin clean clean_log llbin sbin obin:
	@for test_dir in $(TESTS_DIR); do \
	  echo $$nnn; \
	  test_name=`grep "TESTNAME *=" $$test_dir/Makefile | sed "s/.*= *//"`; \
	  echo "TEST_DIR: $$test_dir\tTEST_NAME: $$test_name\tMAKE: $(MAKE) -C $$test_dir $@"; \
	  $(MAKE) -C $$test_dir $@; \
	done

check:
	 @for test_dir in $(TESTS_DIR); do \
          echo $$nnn; \
          test_name=`grep "TESTNAME *=" $$test_dir/Makefile | sed "s/.*= *//"`; \
          echo "TEST_DIR: $$test_dir\tTEST_NAME: $$test_name\tMAKE: $(MAKE) -C $$test_dir $@"; \
          $(MAKE) -C $$test_dir $@; \
        done

.ll .ll.s .ll.o .s .s.o .o:
	@for test_dir in $(TESTS_DIR); do \
	  echo $$nnn; \
	  test_name=`grep "TESTNAME *=" $$test_dir/Makefile | sed "s/.*= *//"`; \
	  echo "TEST_DIR: $$test_dir\tTEST_NAME: $$test_name\tMAKE: $(MAKE) -C $$test_dir $$test_name$@"; \
	  $(MAKE) -C $$test_dir $$test_name$@; \
	done

help:
	@echo 
	@echo "LLVM Tool Chain:	$(AOMP)/bin"
	@echo "Offload Targets:	$(TARGET)"
	@echo "Host Target:		$(AOMP_CPUTARGET)"
	@echo "Application Dirs:	$(TESTS_DIR)"
	@echo 
	@echo "This Makefile supports the following flags:"
	@echo 
	@echo "	make llbin      // Link pass only"
	@echo "	make run_llbin  // Execute llbin"
	@echo 
	@echo "	make sbin       // Link pass only"
	@echo "	make run_sbin   // Execute sbin"
	@echo 
	@echo "	make obin       // Link pass only"
	@echo "	make run_obin   // Execute obin"
	@echo 
	@echo "	make .ll        // Compile pass only             : -c -S -emit-llvm"
	@echo "	make .ll.s      // Backend pass only             : -c -S"
	@echo "	make .ll.o      // Assemble pass only            : -c"
	@echo "	make .s         // Compile & Backend passes      : -c -S"
	@echo "	make .s.o       // Assemble pass only            : -c"
	@echo "	make .o         // Compile, Backend, Assemble    : -c"
	@echo 
	@echo "	make            // All passes, build all examples from Application Dirs"
	@echo "	make run        // Execute all binaries from Application Dirs"
	@echo 
	@echo "	make clean"
	@echo "	make clean_log"
	@echo "	make help"
	@echo 
	@echo " Environment variables to control compilation & execution"
	@echo "    VERBOSE=1        See lots of compiler messages and driver actions"
	@echo "    TEMPS=1          Do not delete intermediate files"
	@echo "    OFFLOAD_DEBUG=1  See Runtime diagnostics for each call to libomptarget API"
	@echo "    TARGET=          Override Makefile target"
	@echo
	@echo " Compile Environment:  $(SETENV)"
	@echo
	@echo " Run Environment:      $(RUNENV)"
	@echo
	@echo " Compile Flags:        $(CFLAGS) $(EXTRA_CFLAGS)"
	@echo
	@echo " OMP Compile Flags:    $(OMP_FLAGS) $(EXTRA_OMP_FLAGS)"
	@echo
	@echo " Link Flags:           $(LINK_FLAGS) $(EXTRA_LDFLAGS)"
	@echo
