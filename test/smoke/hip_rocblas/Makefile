include ../Makefile.defs
$(warning "Warning: This test requires rocBLAS(AMD Only) to be installed in /opt/rocm-X.Y.Z/rocblas.")

TESTNAME     = hip_rocblas
TESTSRC_MAIN = hip_rocblas.cpp
TESTSRC_AUX  =
TESTSRC_ALL  = $(TESTSRC_MAIN) $(TESTSRC_AUX)
OMP_FLAGS    =  --offload-arch=${AOMP_GPU}
NEWEST_ROCM ?= $(shell ls /opt | grep -oP "rocm-[0-9].[0-9].[0-9]" | tail -1)
ifeq ($(NEWEST_ROCM),)
	$(error "Error: No ROCm detected!")
endif
AOMPROCM ?= /opt/$(NEWEST_ROCM)
$(warning "AOMPROCM = $(AOMPROCM)")
CFLAGS       = -x hip -I $(AOMPROCM)/rocblas/include/ --offload-arch=${AOMP_GPU} -std=c++11
AOMPHIP ?= $(AOMP)
VERS = $(shell $(AOMP)/bin/clang --version | grep -oP '(?<=clang version )[0-9.]+')
ifeq ($(shell expr $(VERS) \>= 12.0), 1)
  RPTH = -Wl,-rpath,$(AOMPHIP)/lib
  LLIB = -L$(AOMPHIP)/lib
endif
LINK_FLAGS =  -L $(AOMPROCM)/rocblas/lib -lrocblas -Wl,-rpath,$(AOMPROCM)/rocblas/lib $(LLIB) -lamdhip64  $(RPTH)

ifeq ($(EPSDB),1)
OMP_BIN      = $(AOMPROCM)/bin/hipcc
else
CLANG        = clang++
OMP_BIN      = $(AOMP)/bin/$(CLANG)
endif
CC           = $(OMP_BIN) $(VERBOSE)

#-ccc-print-phases
#"-\#\#\#"
#$(shell $(WARNING))
include ../Makefile.rules
