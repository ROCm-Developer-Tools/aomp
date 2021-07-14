#-----------------------------------------------------------------------
#  Makefile: Demo simple makefile for hip with the AOMP compiler
#            This makefile uses hipcc.
#-----------------------------------------------------------------------
# MIT License
# Copyright (c) 2019 Advanced Micro Devices, Inc. All Rights Reserved.
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

AOMP ?= /usr/lib/aomp
AOMPHIP ?= $(AOMP)
DEVICE_LIB_PATH=$(AOMPHIP)/amdgcn/bitcode/

CC   =  DEVICE_LIB_PATH=$(DEVICE_LIB_PATH) $(AOMPHIP)/bin/hipcc

ASAN_FLAGS = -fsanitize=address -fgpu-sanitize -fgpu-rdc -shared-libsan

# --- Demo compile and link in one step, no object code saved
writeIndex: writeIndex.cpp kernel.cpp
	  $(CC) $(ASAN_FLAGS) $^ -o $@ -std=c++11
run: writeIndex
	LD_LIBRARY_PATH=$(AOMP)/lib ./writeIndex

# --- Demo compile and link in two steps, object saved
writeIndex.o: writeIndex.cpp
	$(CC) -c $(ASAN_FLAGS) $^
kernel.o: kernel.cpp
	$(CC) -c $(ASAN_FLAGS) $^
obin:	writeIndex.o  kernel.o
	$(CC) $(ASAN_FLAGS) $^ -o obin
run_obin: obin
	LD_LIBRARY_PATH=$(AOMP)/lib ./obin

clean:
	@[ -f ./writeIndex ] && rm ./writeIndex ; true
	@[ -f ./obin ] && rm ./obin ; true
	@[ -f ./writeIndex.o ] && rm writeIndex.o ; true
	@[ -f ./kernel.o ] && rm kernel.o ; true
