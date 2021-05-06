#!/bin/bash
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

patchrepo $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME

# Setup AOMP variables
 AOMP=${AOMP:-/usr/lib/aomp}

# Use function to set and test AOMP_GPU
setaompgpu

DEVICE_ARCH=${DEVICE_ARCH:-$AOMP_GPU}
DEVICE_TARGET=${DEVICE_TARGET:-amdgcn-amd-amdhsa}

echo DEVICE_ARCH   = $DEVICE_ARCH
echo DEVICE_TARGET = $DEVICE_TARGET

pushd $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME
rm -f runtime-fails.txt
rm -f compile-fails.txt
rm -f passing-tests.txt

skip_list="t-reduction t-unified-reduction"
# Move tests to avoid soft hang
if [ "$SKIP_TESTS" != 0 ]; then
  for omp_test in $skip_list; do
    if [ -d $omp_test ]; then
      mv $omp_test test-$omp_test-fail
    fi
  done
fi

log=$(date --iso-8601=minutes).log

env TARGET="-fopenmp-targets=$DEVICE_TARGET -fopenmp -Xopenmp-target=$DEVICE_TARGET -march=$DEVICE_ARCH" HOSTRTL=$AOMP/lib/libdevice TARGETRTL=$AOMP/lib GLOMPRTL=$AOMP/lib LLVMBIN=$AOMP/bin make -i 2>&1 | tee omptests_run_$log

# Get Results
compile_fails=0
runtime_fails=0

# Count tests that start with t- or test-
total_tests=$(ls | grep "\(^t\-*\|^test\-\)" | wc -l)

# Count compile/runtime fails and successful tests
for directory in ./t-*/; do
  pushd $directory > /dev/null
  testname=`basename $(pwd)`
  diff results/stdout expected > /dev/null
  return_code=$?
  if [ $return_code != 0 ] && [ -e results/a.out ]; then
    echo $testname >> $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME/runtime-fails.txt
  elif ! [[ -e results/a.out ]]; then
    echo $testname >> $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME/compile-fails.txt
  else
    if [ -e results/a.out ]; then
      echo $testname >> $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME/passing-tests.txt
    fi
  fi
  popd > /dev/null
done

# Add skip_list tests to runtime fails
for omp_test in $skip_list; do
  echo $omp_test >> $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME/runtime-fails.txt
done

# Count compile failures
echo
echo -----Compile Fails-----
if [ -e compile-fails.txt ]; then
  cat compile-fails.txt
  compile_fails=$(wc -l < compile-fails.txt)
fi

# Count runtime failures
# Add tests that were skipped to avoid soft hang
echo
echo -----Runtime Fails-----
runtime_fails=$(ls | grep "^test\-" | wc -l)
if [ -e runtime-fails.txt ]; then
  echo
  cat runtime-fails.txt
  ((runtime_fails=$(wc -l < runtime-fails.txt)))
fi

echo
echo -----Passing Tests-----
if [ -e passing-tests.txt ]; then
  cat passing-tests.txt
  passing_tests=$(wc -l < passing-tests.txt)
else
  passing_tests=0
fi

# Get final pass rate
if [ "$passing_tests" == "$total_tests" ]; then
  pass_rate=100
else
  # The calculation results in extra zeros that can be removed with sed
  pass_rate=`bc -l <<< "scale=4; ($passing_tests/$total_tests) * 100" | sed -E "s/([0-9]+\.[0-9]+)00/\1/g"`
fi

echo
echo ----- Results -----
echo Compile Fails: $compile_fails
echo Runtime Fails: $runtime_fails

echo Successful Tests: $passing_tests/$total_tests
echo Pass Rate: $pass_rate%
echo -------------------
echo

# Log Results
{
  echo
  echo ----- Results -----
  echo Compile Fails: $compile_fails
  echo Runtime Fails: $runtime_fails

  echo Successful Tests: $passing_tests/$total_tests
  echo Pass Rate: $pass_rate%
  echo -------------------
  echo
} >> omptests_run_$log
popd
removepatch $AOMP_REPOS_TEST/$AOMP_OMPTESTS_REPO_NAME
