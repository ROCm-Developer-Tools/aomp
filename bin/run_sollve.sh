#!/bin/bash
# 
#  run_sollve.sh: 
#
# --- Start standard header to set build environment variables ----

function getdname(){
   local __DIRN=`dirname "$1"`
   if [ "$__DIRN" = "." ] ; then
      __DIRN=$PWD;
   else
      if [ ${__DIRN:0:1} != "/" ] ; then
         if [ ${__DIRN:0:2} == ".." ] ; then
               __DIRN=`dirname $PWD`/${__DIRN:3}
         else
            if [ ${__DIRN:0:1} = "." ] ; then
               __DIRN=$PWD/${__DIRN:2}
            else
               __DIRN=$PWD/$__DIRN
            fi
         fi
      fi
   fi
   echo $__DIRN
}
thisdir=$(getdname $0)
[ ! -L "$0" ] || thisdir=$(getdname `readlink "$0"`)
. $thisdir/aomp_common_vars
# --- end standard header ----

if [ "$ROCMASTER" == "1" ] || [ "$EPSDB" == "1" ]; then
  ./clone_aomp_test.sh
  pushd $AOMP_REPOS_TEST/$AOMP_SOLVV_REPO_NAME
    # Lock at specific hash for consistency
    git reset --hard 0fbdbb9f7d3b708eb0b5458884cfbab25103d387
  popd
fi

if [ "$ROCMASTER" == "1" ]; then
  export AOMP=/opt/rocm/aomp
elif [ "$EPSDB" == "1" ]; then
  export AOMP=/opt/rocm/llvm
fi

# Setup AOMP variables
AOMP=${AOMP:-/usr/lib/aomp}

# Use function to set and test AOMP_GPU
setaompgpu

export MY_SOLLVE_FLAGS="-fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=$AOMP_GPU"

pushd $AOMP_REPOS_TEST/$AOMP_SOLVV_REPO_NAME

rm -rf results_report45
rm -rf results_report50
rm -rf combined-results.txt

make tidy

# Run OpenMP 4.5 Tests
make CC=$AOMP/bin/clang CXX=$AOMP/bin/clang++ FC=$AOMP/bin/flang CFLAGS="-lm $MY_SOLLVE_FLAGS" CXXFLAGS="$MY_SOLLVE_FLAGS" FFLAGS="$MY_SOLLVE_FLAGS" LOG=1 LOG_ALL=1 VERBOSE_TESTS=1 VERBOSE=1 all

echo "--------------------------- OMP 4.5 Results ---------------------------" >> combined-results.txt
echo "--------------------------- OMP 4.5 Results ---------------------------" > abrev.combined-results.txt
make report_html
make report_summary >> combined-results.txt
make report_summary  | tail -5 >> abrev.combined-results.txt

mv results_report results_report45

# Run OpenMP 5.0 Tests
export MY_SOLLVE_FLAGS="$MY_SOLLVE_FLAGS -fopenmp-version=50"
make tidy
make CC=$AOMP/bin/clang CXX=$AOMP/bin/clang++ FC=$AOMP/bin/flang CFLAGS="-lm $MY_SOLLVE_FLAGS" CXXFLAGS="$MY_SOLLVE_FLAGS" FFLAGS="$MY_SOLLVE_FLAGS"  OMP_VERSION=5.0 LOG=1 LOG_ALL=1 VERBOSE_TESTS=1 VERBOSE=1 all

echo "--------------------------- OMP 5.0 Results ---------------------------" >> combined-results.txt
echo "--------------------------- OMP 5.0 Results ---------------------------" >> abrev.combined-results.txt
make report_html
make report_summary >> combined-results.txt
make report_summary  | tail -5 >> abrev.combined-results.txt
mv results_report results_report50
cat combined-results.txt
pwd
cat abrev.combined-results.txt
popd

if [ "$ROCMASTER" == "1" ]; then
  ./check_sollve.sh
elif [ "$EPSDB" == "1" ]; then
  EPSDB=1 ./check_sollve.sh
fi
