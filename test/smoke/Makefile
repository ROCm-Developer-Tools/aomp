include Makefile.defs

TESTS_DIR = \
    aomp_mappings \
    DeclareSharedMemory \
    assertok_error \
    atomic \
    atomic_double \
    class \
    collapse \
    data_enter_issue01 \
    data_issue_59 \
    data_share1 \
    data_share2 \
    decl_targ \
    devices \
    extern_init \
    fast_math_undefined_symbol \
    firstprivate \
    firstprivate2 \
    flags \
    flang_tgt_alloc_ptr \
    function \
    function_overload \
    function_template \
    gdb_teams \
    helloworld \
    hip_device_compile \
    hip_rocblas \
    issue_flang_libomp \
    issue_001 \
    issue_002 \
    launch_latency \
    liba_bundled \
    liba_bundled_cmdline \
    lto_teams \
    map_zero_bug \
    math_flog \
    math_modff \
    math_sqrt_float \
    MaxNumThrds \
    mem_foot_print \
    nativetests \
    nested_loop \
    nested_par3 \
    nest_call_par2 \
    omp_num_teams_SPMD \
    omp_num_teams_generic \
    OmpHipMallocManaged \
    pfspecifier \
    pfspecifier_str \
    red_bug_51 \
    reduce \
    reduction \
    reduction_array_section \
    reduction_issue_16 \
    reduction_team \
    reduction_teams \
    reduction_teams_distribute_parallel \
    reduc_map_prob \
    schedule \
    simd \
    snap_red \
    stream \
    targ_declare \
    targ_static \
    target-in-other-source \
    target_teams_reduction \
    tasks \
    teams \
    teams_nest \
    team_prob \
    teams512-info \
    test \
    thread_limit\
    threads \
    Threads1xxx \
    unique-kernel-name \
    use_device_ptr \
    veccopy \
    vmuldemo \
    vmulsum

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
