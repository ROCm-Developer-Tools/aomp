#-----------------------------------------------------------------------
#
#  Makefile: Cuda clang demo Makefile for both amdgcn and nvptx targets.
#            amdgcn GPU targets begin with "gfx". nvptx targets begin
#            with sm_.  Example: To build and run on k4000 do this:
#
#            export AOMP_GPU=sm_30
#            make run
#
#  Run "make help" to see other options for this Makefile

TESTNAME = vmulsum
TESTSRC  = main.c vsum.c vmul.c

UNAMEP = $(shell uname -m)
AOMP_CPUTARGET = $(UNAMEP)-pc-linux-gnu
ifeq ($(UNAMEP),ppc64le)
  AOMP_CPUTARGET = ppc64le-linux-gnu
endif

# --- Standard Makefile check for AOMP installation ---
ifeq ("$(wildcard $(AOMP))","")
  ifneq ($(AOMP),)
    $(warning AOMP not found at $(AOMP))
  endif
  AOMP = $(HOME)/rocm/aomp
  ifeq ("$(wildcard $(AOMP))","")
    $(warning AOMP not found at $(AOMP))
    AOMP = /usr/lib/aomp
    ifeq ("$(wildcard $(AOMP))","")
      $(warning AOMP not found at $(AOMP))
      $(error Please install AOMP or correctly set env-var AOMP)
    endif
  endif
endif
# --- End Standard Makefile check for AOMP installation ---

INSTALLED_GPU  = $(shell $(AOMP)/bin/mygpu -d gfx900)# Default AOMP_GPU is gfx900 which is vega
AOMP_GPU       ?= $(INSTALLED_GPU)
CC              = $(AOMP)/bin/clang

ifeq (sm_,$(findstring sm_,$(AOMP_GPU)))
  AOMP_GPUTARGET = nvptx64-nvidia-cuda
else
  AOMP_GPUTARGET = amdgcn-amd-amdhsa
endif

# Sorry, clang openmp requires these complex options
CFLAGS = -O3 -target $(AOMP_CPUTARGET) -fopenmp -fopenmp-targets=$(AOMP_GPUTARGET) -Xopenmp-target=$(AOMP_GPUTARGET) -march=$(AOMP_GPU)
ASAN_FLAGS = -fsanitize=address -fgpu-sanitize -fgpu-rdc -shared-libsan

ifeq ($(OFFLOAD_DEBUG),1)
  $(info    DEBUG Mode ON)
  CCENV  = env LIBRARY_PATH=$(AOMP)/lib-debug
  RUNENV = LIBOMPTARGET_DEBUG=1
endif

ifeq ($(VERBOSE),1)
  $(info    Compilation VERBOSE Mode ON)
  CFLAGS += -v
endif

ifeq ($(TEMPS),1)
  $(info    Compilation and linking save-temp Mode ON)
  CFLAGS += -save-temps
endif

ifeq (sm_,$(findstring sm_,$(AOMP_GPU)))
  CUDA   ?= /usr/local/cuda
  LFLAGS += -L$(CUDA)/targets/$(UNAMEP)-linux/lib -lcudart
endif

CFLAGS += $(EXTRA_CFLAGS)

# ----- Demo compile and link in one step, no object code saved
$(TESTNAME): $(TESTSRC)
	$(CCENV) $(CC) $(CFLAGS) $(ASAN_FLAGS) $(LFLAGS) $^ -o $@

run: $(TESTNAME)
	$(RUNENV) ./$(TESTNAME)

#  ----   Demo compile and link in two steps, object saved
main.o: main.c
	$(CCENV) $(CC) -c $(CFLAGS) $(ASAN_FLAGS) $^ -o $@
vsum.o: vsum.c
	$(CCENV) $(CC) -c $(CFLAGS) $(ASAN_FLAGS) $^ -o $@
vmul.o: vmul.c
	$(CCENV) $(CC) -c $(CFLAGS) $(ASAN_FLAGS) $^ -o $@
obin:	main.o vsum.o vmul.o
	$(CCENV) $(CC) $(CFLAGS) $(LFLAGS) $(ASAN_FLAGS) $^ -o $@

run_obin: obin
	$(RUNENV) ./obin

help:
	@echo
	@echo "Source[s]:		$(TESTSRC)"
	@echo "Application binary:    	$(TESTNAME)"
	@echo "Target GPU:		$(AOMP_GPU)"
	@echo "Target triple:		$(AOMP_GPUTARGET)"
	@echo "AOMP compiler: 		$(CC)"
	@echo "Compile flags:		$(CFLAGS)"
ifeq (sm_,$(findstring sm_,$(AOMP_GPU)))
	@echo "CUDA installation:	$(CUDA)"
endif
	@echo
	@echo "This Makefile supports these targets:"
	@echo
	@echo " make			// Builds $(TESTNAME) "
	@echo " make run		// Executes $(TESTNAME) "
	@echo
	@echo " make main.o"
	@echo " make vsum.o"
	@echo " make vmul.o"
	@echo " make obin		// Link object files to build binary "
	@echo " make run_obin		// Execute obin "
	@echo
	@echo " make clean"
	@echo " make help"
	@echo
	@echo "Environment variables used by this Makefile:"
	@echo "  AOMP_GPU=<GPU>       Target GPU, e.g sm_30, default=gfx900. To build for"
	@echo "                       Nvidia GPUs, set AOMP_GPU=sm_60 or appropriate sm_"
	@echo "  AOMP=<dir>           AOMP install dir, default=/usr/lib/aomp"
	@echo "  EXTRA_CFLAGS=<args>  extra arguments for compiler"
	@echo "  OFFLOAD_DEBUG=n      if n=1, compile and run in Debug mode"
	@echo "  VERBOSE=n            if n=1, add verbose output"
	@echo "  TEMPS=1              do not delete intermediate files"
ifeq (sm_,$(findstring sm_,$(AOMP_GPU)))
	@echo "  CUDA=<dir>           CUDA install dir, default=/usr/local/cuda"
endif
	@echo

# Cleanup anything this makefile can create
clean:
	rm -f $(TESTNAME) obin *.i *.ii *.bc *.lk a.out-* *.ll *.s *.o *.cubin
