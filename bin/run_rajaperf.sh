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

function cmake_warning(){
  echo "-----------------------------------------------------------------------------------------------------"
  echo "Warning!! It is recommended to build Raja with a cmake version between 3.9 and and 3.16.8 (inclusive)."
  echo "Raja Performance Suite may fail to build otherwise."
  echo "HIT ENTER TO CONTINUE or CTRL-C TO CANCEL"
  echo "-----------------------------------------------------------------------------------------------------"
  read
}

# Setup AOMP variables
AOMP=${AOMP:-/usr/lib/aomp}

# Use function to set and test AOMP_GPU
setaompgpu

# Check cmake version
cmake_regex="(([0-9])+\.([0-9]+)\.[0-9]+)"
cmake_ver_str=$($AOMP_CMAKE  --version)
if [[ "$cmake_ver_str" =~ $cmake_regex ]]; then
  cmake_ver=${BASH_REMATCH[1]}
  cmake_major_ver=${BASH_REMATCH[2]}
  cmake_minor_ver=${BASH_REMATCH[3]}
  echo "Cmake found: version $cmake_ver"
  if [ "$cmake_major_ver" != "3" ]; then
    cmake_warning
  elif (( $(echo "$cmake_minor_ver > 16"| bc -l) ||  $(echo "$cmake_minor_ver < 9" | bc -l) )); then
    cmake_warning
  fi
else
  echo "ERROR: No cmake found, exiting..."
  return 1
fi

# Apply patches
patchrepo $AOMP_REPOS_TEST/RAJAPerf/tpl/RAJA
patchrepo $AOMP_REPOS_TEST/RAJAPerf

# Begin configuration
pushd $AOMP_REPOS_TEST/RAJAPerf
BUILD_SUFFIX=aomp_omptarget
rm -rf build_${BUILD_SUFFIX} >/dev/null
mkdir build_${BUILD_SUFFIX}
pushd build_${BUILD_SUFFIX}

$AOMP_CMAKE \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER=${AOMP}/bin/clang++ \
  -DENABLE_CUDA=Off \
  -DENABLE_OPENMP=On \
  -DENABLE_TARGET_OPENMP=On \
  -DOpenMP_CXX_FLAGS="-fopenmp;-fopenmp-targets=amdgcn-amd-amdhsa;-Xopenmp-target=amdgcn-amd-amdhsa;-march=${AOMP_GPU}" \
  -DENABLE_ALL_WARNINGS=Off \
  -DCMAKE_INSTALL_PREFIX=../install_${BUILD_SUFFIX} \
  "$@" \
  ..

make -j $NUM_THREADS

# Do not continue if build fails
if [ $? != 0 ]; then
  echo "ERROR: Make returned non-zero, exiting..."
  exit 1
fi

popd
popd

pushd $AOMP_REPOS_TEST/RAJAPerf
build_aomp_omptarget/bin/raja-perf-omptarget.exe --show-progress
popd

# Remove patches
removepatch $AOMP_REPOS_TEST/RAJAPerf/tpl/RAJA
removepatch $AOMP_REPOS_TEST/RAJAPerf

