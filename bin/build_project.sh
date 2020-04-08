#!/bin/bash
# 
#  build_project.sh:  Script to build the llvm, clang , and lld components of the AOMP compiler. 
#                  This clang 9.0 compiler supports clang hip, OpenMP, and clang cuda
#                  offloading languages for BOTH nvidia and Radeon accelerator cards.
#                  This compiler has both the NVPTX and AMDGPU LLVM backends.
#                  The AMDGPU LLVM backend is referred to as the Lightning Compiler.
#
# See the help text below, run 'build_project.sh -h' for more information. 
#
BUILD_TYPE=${BUILD_TYPE:-Release}

# --- Start standard header ----
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
. $thisdir/aomp_common_vars
# --- end standard header ----

INSTALL_PROJECT=${INSTALL_PROJECT:-$AOMP_INSTALL_DIR}

WEBSITE="http\:\/\/github.com\/ROCm-Developer-Tools\/aomp"

GCC=`which gcc`
GCPLUSCPLUS=`which g++`
if [ "$AOMP_PROC" == "ppc64le" ] ; then
   COMPILERS="-DCMAKE_C_COMPILER=/usr/bin/gcc-7 -DCMAKE_CXX_COMPILER=/usr/bin/g++-7"
   TARGETS_TO_BUILD="AMDGPU;${AOMP_NVPTX_TARGET}PowerPC"
else
   COMPILERS="-DCMAKE_C_COMPILER=$GCC -DCMAKE_CXX_COMPILER=$GCPLUSCPLUS"
   if [ "$AOMP_PROC" == "aarch64" ] ; then
      TARGETS_TO_BUILD="AMDGPU;${AOMP_NVPTX_TARGET}AArch64"
   else
      TARGETS_TO_BUILD="AMDGPU;${AOMP_NVPTX_TARGET}X86"
   fi
fi

# When building from release source (no git), turn off test items that are not distributed
if [ "$AOMP_CHECK_GIT_BRANCH" == 1 ] ; then
   DO_TESTS=""
else
   DO_TESTS="-DLLVM_BUILD_TESTS=OFF -DLLVM_INCLUDE_TESTS=OFF -DCLANG_INCLUDE_TESTS=OFF"
fi
MYCMAKEOPTS="-DLLVM_BUILD_LLVM_DYLIB:STRING=ON -DLLVM_LINK_LLVM_DYLIB=ON -DLLVM_ENABLE_PROJECTS=clang;lld;compiler-rt -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX=$INSTALL_PROJECT -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_TARGETS_TO_BUILD=$TARGETS_TO_BUILD $COMPILERS -DLLVM_VERSION_SUFFIX=_AOMP_Version_$AOMP_VERSION_STRING -DBUG_REPORT_URL='https://github.com/ROCm-Developer-Tools/aomp' -DLLVM_ENABLE_BINDINGS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF $DO_TESTS $AOMP_ORIGIN_RPATH"

if [ "$1" == "-h" ] || [ "$1" == "help" ] || [ "$1" == "-help" ] ; then 
  help_build_aomp
fi

if [ $AOMP_STANDALONE_BUILD == 1 ] ; then 
   if [ ! -L $AOMP ] ; then 
     if [ -d $AOMP ] ; then 
        echo "ERROR: Directory $AOMP is a physical directory."
        echo "       It must be a symbolic link or not exist"
        exit 1
     fi
   fi
fi

REPO_BRANCH=$AOMP_PROJECT_REPO_BRANCH
REPO_DIR=$AOMP_REPOS/$AOMP_PROJECT_REPO_NAME
checkrepo

# Make sure we can update the install directory
if [ "$1" == "install" ] ; then 
   $SUDO mkdir -p $INSTALL_PROJECT
   $SUDO touch $INSTALL_PROJECT/testfile
   if [ $? != 0 ] ; then 
      echo "ERROR: No update access to $INSTALL_PROJECT"
      exit 1
   fi
   $SUDO rm $INSTALL_PROJECT/testfile
fi

# Fix the banner to print the AOMP version string. 
if [ $AOMP_STANDALONE_BUILD == 1 ] ; then
   cd $AOMP_REPOS/$AOMP_PROJECT_REPO_NAME
   if [ "$AOMP_CHECK_GIT_BRANCH" == 1 ] ; then
      MONO_REPO_ID=`git log | grep -m1 commit | cut -d" " -f2`
   else
      MONO_REPO_ID="build_from_release_source"
   fi
   SOURCEID="Source ID:$AOMP_VERSION_STRING-$MONO_REPO_ID"
   TEMPCLFILE="/tmp/clfile$$.cpp"
   ORIGCLFILE="$AOMP_REPOS/$AOMP_PROJECT_REPO_NAME/llvm/lib/Support/CommandLine.cpp"
   if [ $COPYSOURCE ] ; then
      BUILDCLFILE="$BUILD_DIR/$AOMP_PROJECT_REPO_NAME/llvm/lib/Support/CommandLine.cpp"
   else
      BUILDCLFILE=$ORIGCLFILE
   fi

   sed "s/LLVM (http:\/\/llvm\.org\/):/AOMP-${AOMP_VERSION_STRING} ($WEBSITE):\\\n $SOURCEID/" $ORIGCLFILE > $TEMPCLFILE
   if [ $? != 0 ] ; then
      echo "ERROR sed command to fix CommandLine.cpp failed."
      exit 1
   fi
   exclude_cmdline="--exclude CommandLine.cpp"
else
   exclude_cmdline=""
fi

# Skip synchronization from git repos if nocmake or install are specified
if [ "$1" != "nocmake" ] && [ "$1" != "install" ] ; then
   echo 
   echo "This is a FRESH START. ERASING any previous builds in $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME"
   echo "Use ""$0 nocmake"" or ""$0 install"" to avoid FRESH START."
   rm -rf $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME
   mkdir -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME

   if [ $COPYSOURCE ] ; then 
      #  Copy/rsync the git repos into /tmp for faster compilation
      mkdir -p $BUILD_DIR
      echo
      echo "WARNING!  BUILD_DIR($BUILD_DIR) != AOMP_REPOS($AOMP_REPOS)"
      echo "SO REPLICATING AOMP_REPOS/$AOMP_PROJECT_REPO_NAME  TO: $BUILD_DIR"
      echo
      echo "rsync -a $exclude_cmdline --delete $AOMP_REPOS/$AOMP_PROJECT_REPO_NAME $BUILD_DIR"
      rsync -a $exclude_cmdline --delete $AOMP_REPOS/$AOMP_PROJECT_REPO_NAME $BUILD_DIR 2>&1
   fi

else
   if [ ! -d $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME ] ; then 
      echo "ERROR: The build directory $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME does not exist"
      echo "       run $0 without nocmake or install options. " 
      exit 1
   fi
fi

if [ $AOMP_STANDALONE_BUILD == 1 ] ; then
   cd $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME
   if [ -f $BUILDCLFILE ] ; then
      # only copy if there has been a change to the source.
      diff $TEMPCLFILE $BUILDCLFILE >/dev/null
      if [ $? != 0 ] ; then
         echo "Updating $BUILDCLFILE with corrected $SOURCEID"
         cp $TEMPCLFILE $BUILDCLFILE
      else
         echo "File $BUILDCLFILE already has correct $SOURCEID"
      fi
   else
      echo "Updating $BUILDCLFILE with $SOURCEID"
      cp $TEMPCLFILE $BUILDCLFILE
   fi
   rm $TEMPCLFILE
fi

cd $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME

if [ "$1" != "nocmake" ] && [ "$1" != "install" ] ; then
   echo
   echo " -----Running cmake ---- " 
   if [ $COPYSOURCE ] ; then
       echo ${AOMP_CMAKE} $MYCMAKEOPTS  $BUILD_DIR/$AOMP_PROJECT_REPO_NAME/llvm
       ${AOMP_CMAKE} $MYCMAKEOPTS  $BUILD_DIR/$AOMP_PROJECT_REPO_NAME/llvm 2>&1
    else
       echo ${AOMP_CMAKE} $MYCMAKEOPTS  $AOMP_REPOS/$AOMP_PROJECT_REPO_NAME/llvm
       ${AOMP_CMAKE} $MYCMAKEOPTS  $AOMP_REPOS/$AOMP_PROJECT_REPO_NAME/llvm 2>&1
   fi
   if [ $? != 0 ] ; then 
      echo "ERROR cmake failed. Cmake flags"
      echo "      $MYCMAKEOPTS"
      exit 1
   fi
fi

echo
echo " -----Running make ---- " 
echo make -j $NUM_THREADS 
make -j $NUM_THREADS 
if [ $? != 0 ] ; then 
   echo "ERROR make -j $NUM_THREADS failed"
   exit 1
fi

if [ "$1" == "install" ] ; then
   echo " -----Installing to $INSTALL_PROJECT ---- " 
   $SUDO make install 
   if [ $? != 0 ] ; then 
      echo "ERROR make install failed "
      exit 1
   fi
   $SUDO make install/local
   if [ $? != 0 ] ; then 
      echo "ERROR make install/local failed "
      exit 1
   fi
   if [ $AOMP_STANDALONE_BUILD == 1 ] ; then 
      echo " "
      echo "------ Linking $INSTALL_PROJECT to $AOMP -------"
      if [ -L $AOMP ] ; then 
         $SUDO rm $AOMP   
      fi
      $SUDO ln -sf $INSTALL_PROJECT $AOMP   
   fi
   # add executables forgot by make install but needed for testing
   echo add executables forgot by make install but needed for testing
   $SUDO cp -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME/bin/llvm-lit $AOMP/bin/llvm-lit
   $SUDO cp -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME/bin/FileCheck $AOMP/bin/FileCheck
   $SUDO cp -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME/bin/count $AOMP/bin/count
   $SUDO cp -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME/bin/not $AOMP/bin/not
   $SUDO cp -p $BUILD_DIR/build/$AOMP_PROJECT_REPO_NAME/bin/yaml-bench $AOMP/bin/yaml-bench
   echo
   echo "SUCCESSFUL INSTALL to $INSTALL_PROJECT with link to $AOMP"
   echo
else 
   echo 
   echo "SUCCESSFUL BUILD, please run:  $0 install"
   echo "  to install into $AOMP"
   echo 
fi
