include Makefile.defs

TESTS_DIR = \
    aomp_mappings \
    DeclareSharedMemory \
    assertok_error \
    atomic \
    atomic_double \
    clang-tracekernel \
    class \
    collapse \
    complex \
    complex2 \
    d2h_slow_copy \
    data_enter_issue01 \
    data_issue_59 \
    data_share1 \
    data_share2 \
    decl_targ \
    devices \
    devito_prob1 \
    extern_init \
    firstprivate \
    firstprivate2 \
    flags \
    flang-272285 \
    flang-272521 \
    flang-272534 \
    flang-272878 \
    flang-273281 \
    flang-273284 \
    flang-274768 \
    flang-274775 \
    flang-274983 \
    flang-275472 \
    flang_2regions \
    flang_blkdata-g \
    flang_char_kind \
    flang_deviceio \
    flang_gen_sptr_prob \
    flang_isystem_prob \
    flang_klemm_map \
    flang_math \
    flang_omp_map \
    flang_omp_red_3d \
    flang_real16_prob \
    flang_reduction_offload \
    flang_red_swdev-273281 \
    flang_red_swdev-273281-spmd \
    flang_tgt_alloc_ptr \
    flang-tracekernel \
    function \
    function_overload \
    function_template \
    gdb_teams \
    global_allocate \
    helloworld \
    hip_device_compile \
    hip_rocblas \
    host_targ \
    issue_flang_libomp \
    issue_001 \
    issue_002 \
    launch_latency \
    liba_bundled \
    liba_bundled_cmdline \
    longDouble \
    lto_teams \
    ManyKernels \
    map_to_from_prob \
    map_zero_bug \
    MasterBarrier \
    math_exp \
    math_flog \
    math_max \
    math_modff \
    math_sqrt_float \
    MaxNumThrds \
    mem_foot_print \
    nativetests \
    nested_loop \
    nested_par3 \
    nest_call_par2 \
    omp_get_device_num \
    omp_get_initial \
    omp_lock \
    omp_num_teams_SPMD \
    omp_num_teams_generic \
    omp_wtime \
    OmpHipMallocManaged \
    pfspecifier \
    pfspecifier_str \
    printf_parallel_for_target \
    red_bug_51 \
    reduce \
    reduction \
    reduction_array_section \
    reduction_issue_16 \
    reduction_team \
    reduction_teams \
    reduction_teams_distribute_parallel \
    reduction_shared_array \
    reduc_map_prob \
    schedule \
    simd \
    simple_ctor \
    slices \
    snap_red \
    stream \
    targc-273738 \
    targ_declare \
    target-in-other-source \
    targets_in_loop \
    task-helper \
    taskwait_prob \
    teams \
    teams_nest \
    team_prob \
    teams512-info \
    test \
    test_offload_macros \
    thread_limit\
    threads \
    Threads1xxx \
    unique-kernel-name \
    use_device_ptr \
    use_device_addr \
    vasp1 \
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
