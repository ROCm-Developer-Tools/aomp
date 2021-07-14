#-----------------------------------------------------------------------
#
#  Makefile: Cuda clang demo Makefile for both amdgcn and nvptx targets.
#            amdgcn targets begin with gfx. nvptx targets begin with sm_
#
#  Run "make help" to see how to use this Makefile
#
#-----------------------------------------------------------------------
# MIT License
# Copyright (c) 2017 Advanced Micro Devices, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

TESTNAME =matrixmul
FILETYPE =cpp

UNAMEP = $(shell uname -m)
AOMP_CPUTARGET = $(UNAMEP)-pc-linux-gnu
ifeq ($(UNAMEP),ppc64le)
  AOMP_CPUTARGET = ppc64le-linux-gnu
endif
ifeq ($(AOMP),)
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
endif
ifeq ($(CUDA),)
CUDA = /usr/local/cuda
endif
ifeq ($(AOMP_GPU),)
INSTALLED_GPU  = $(shell $(AOMP)/bin/mygpu -d gfx900) # Default AOMP_GPU is gfx900 which is vega
AOMP_GPU       ?= $(INSTALLED_GPU)
endif
ifeq ($(TARGETS),)
TARGETS =--offload-arch=$(AOMP_GPU)
endif

CC       =$(AOMP)/bin/clang++
ASAN_FLAGS = -fsanitize=address -fgpu-sanitize -fgpu-rdc -shared-libsan

# Add cudart only if we have an Nvidia sm_ target
ifeq (sm_,$(findstring sm_,$(TARGETS)))
  LFLAGS +=-L$(CUDA)/targets/$(UNAMEP)-linux/lib -lcudart -Wl,-rpath,$(CUDA)/targets/$(UNAMEP)-linux/lib
  CFLAGS +=-x cuda -I$(CUDA)/include -std=c++11
else
  AOMPHIP ?= $(AOMP)
  VERS = $(shell $(AOMP)/bin/clang --version | grep -oP '(?<=clang version )[0-9.]+')
  ifeq ($(shell expr $(VERS) \>= 12.0), 1)
    RPTH = -Wl,-rpath,$(AOMPHIP)/lib
  endif
  HIPLIBS = -L $(AOMPHIP)/hip -L $(AOMPHIP)/lib $(RPTH)
  CFLAGS += -x hip  $(HIPLIBS) -lamdhip64 -std=c++11
endif

# ----- Demo compile and link in one step, no object code saved
$(TESTNAME): $(TESTNAME).$(FILETYPE)
	$(CC) $(CFLAGS) $(TARGETS) $(ASAN_FLAGS) $(LFLAGS) $^ -o $@

run: $(TESTNAME)
	./$(TESTNAME)

#  ----   Demo compile and link in two steps, object saved
$(TESTNAME).o: $(TESTNAME).$(FILETYPE)
	$(CC) -c $(CFLAGS) $(TARGETS) $(ASAN_FLAGS) $^

obin:	$(TESTNAME).o
	$(CC) $(LFLAGS) $(ASAN_FLAGS) $^ -o obin

run_obin: obin
	./obin

#  ----   Demo compile to intermediates LLVMIR or assembly
$(TESTNAME).ll: $(TESTNAME).$(FILETYPE)
	$(CC) -c -S -emit-llvm $(CFLAGS) $(TARGETS) $(ASAN_FLAGS) $^

$(TESTNAME).s: $(TESTNAME).$(FILETYPE)
	$(CC)  -c -S $(CFLAGS) $(TARGETS) $(ASAN_FLAGS) $^

help:
	@echo
	@echo "Makefile Help:"
	@echo "  Source:		$(TESTNAME).$(FILETYPE)"
	@echo "  Compiler: 		$(CC)"
	@echo "  Compiler flags: 	$(CFLAGS)"
	@echo
	@echo "Avalable Targets:"
	@echo "  make			// build binary $(TESTNAME)"
	@echo "  make run		// run $(TESTNAME)"
	@echo "  make $(TESTNAME).o	// compile, be, & assemble : -c"
	@echo "  make obin         	// link step only"
	@echo "  make run_obin     	// run obin "
	@echo "  make $(TESTNAME).s	// compile & backend steps : -c -S"
	@echo "  make $(TESTNAME).ll	// compile step only       : -c -S -emit-llvm"
	@echo "  make clean		// cleanup files"
	@echo "  make help 		// this help"
	@echo
	@echo "Environment Variables:"
	@echo "  AOMP      default: $(HOME)/rocm/aomp     value: $(AOMP)"
	@echo "  AOMP_GPU  default: gfx900                value: $(AOMP_GPU)"
	@echo "  CUDA      default: /usr/local/cuda       value: $(CUDA)"
	@echo "  TARGETS   default: --offload-arch=$(AOMP_GPU)"
	@echo "              value: $(TARGETS)"
	@echo
	@echo "Link Flags:"
	@echo "  Link flags: $(LFLAGS)"
	@echo

# Cleanup anything this makefile can create
clean:
	@[ -f ./$(TESTNAME) ] && rm ./$(TESTNAME) ; true
	@[ -f ./obin ] && rm ./obin ; true
	@[ -f ./$(TESTNAME).ll ] && rm *.ll ; true
	@[ -f ./$(TESTNAME).o ] && rm $(TESTNAME).o ; true
	@[ -f ./$(TESTNAME).s ] && rm *.s ; true
