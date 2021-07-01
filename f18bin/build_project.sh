#!/bin/bash
# 
#  build_project.sh:  Script to build the llvm, clang , mlir, flang, lld, and openmp  components of the F18 compiler. 
#                  of the f18 compiler. 
#
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
. $thisdir/f18_common_vars
# --- end standard header ----

INSTALL_PROJECT=${INSTALL_PROJECT:-$F18_INSTALL_DIR}

WEBSITE="http\:\/\/github.com\/ROCm-Developer-Tools\/aomp"

if [ "$F18_PROC" == "ppc64le" ] ; then
   echo "ERROR: ppc64le not supported yet"
   exit 1
   TARGETS_TO_BUILD="AMDGPU;${F18_NVPTX_TARGET}PowerPC"
fi
if [ "$F18_PROC" == "aarch64" ] ; then
   TARGETS_TO_BUILD="AMDGPU;${F18_NVPTX_TARGET}AArch64"
else
   TARGETS_TO_BUILD="AMDGPU;${F18_NVPTX_TARGET}X86"
fi

#When building from release source (no git), turn off test items that are not distributed
if [ "$F18_CHECK_GIT_BRANCH" == 1 ] ; then
   DO_TESTS=""
else
   DO_TESTS="-DLLVM_BUILD_TESTS=OFF -DLLVM_INCLUDE_TESTS=OFF -DCLANG_INCLUDE_TESTS=OFF"
fi

# FOr now do no tests
DO_TESTS=""

#  No rocm components yet needed but tag the release name just for future 
if [ $F18_STANDALONE_BUILD == 1 ] ; then
   standalone_word="_STANDALONE"
else
   standalone_word=""
fi

MYCMAKEOPTS="-DLLVM_ENABLE_PROJECTS=mlir;clang;lld;openmp;flang  -DFLANG_BUILD_NEW_DRIVER=On  -DBUILD_SHARED_LIBS=On -DCMAKE_INSTALL_PREFIX=$F18_INSTALL_DIR -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DLLVM_INSTALL_UTILS=On -DCMAKE_CXX_STANDARD=17 -DLLVM_TARGETS_TO_BUILD=$TARGETS_TO_BUILD $F18_ORIGIN_RPATH -DLLVM_VERSION_SUFFIX=_F18${standalone_word}_$F18_VERSION_STRING -DCLANG_VENDOR=F18${standalone_word}_$F18_VERSION_STRING -DBUG_REPORT_URL='https://github.com/ROCm-Developer-Tools/aomp' -DLLVM_INCLUDE_BENCHMARKS=OFF $DO_TESTS"


if [ "$1" == "-h" ] || [ "$1" == "help" ] || [ "$1" == "-help" ] ; then 
  help_build_aomp
fi

if [ $F18_STANDALONE_BUILD == 1 ] ; then 
   if [ ! -L $F18 ] ; then 
     if [ -d $F18 ] ; then 
        echo "ERROR: Directory $F18 is a physical directory."
        echo "       It must be a symbolic link or not exist"
        exit 1
     fi
   fi
fi

REPO_BRANCH=$F18_PROJECT_REPO_BRANCH
REPO_DIR=$F18_REPOS/$F18_PROJECT_REPO_NAME
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

# Fix the banner to print the F18 version string. 
if [ $F18_STANDALONE_BUILD == 1 ] ; then
   cd $F18_REPOS/$F18_PROJECT_REPO_NAME
   if [ "$F18_CHECK_GIT_BRANCH" == 1 ] ; then
      MONO_REPO_ID=`git log | grep -m1 commit | cut -d" " -f2`
   else
      MONO_REPO_ID="build_from_release_source"
   fi
   SOURCEID="Source ID:$F18_VERSION_STRING-$MONO_REPO_ID"
   TEMPCLFILE="/tmp/clfile$$.cpp"
   ORIGCLFILE="$F18_REPOS/$F18_PROJECT_REPO_NAME/llvm/lib/Support/CommandLine.cpp"
   if [ $COPYSOURCE ] ; then
      BUILDCLFILE="$BUILD_DIR/$F18_PROJECT_REPO_NAME/llvm/lib/Support/CommandLine.cpp"
   else
      BUILDCLFILE=$ORIGCLFILE
   fi

   sed "s/LLVM (http:\/\/llvm\.org\/):/F18-${F18_VERSION_STRING} ($WEBSITE):\\\n $SOURCEID/" $ORIGCLFILE > $TEMPCLFILE
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
   echo "This is a FRESH START. ERASING any previous builds in $BUILD_DIR/build/$F18_PROJECT_REPO_NAME"
   echo "Use ""$0 nocmake"" or ""$0 install"" to avoid FRESH START."
   rm -rf $BUILD_DIR/build/$F18_PROJECT_REPO_NAME
   mkdir -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME

   if [ $COPYSOURCE ] ; then 
      #  Copy/rsync the git repos into /tmp for faster compilation
      mkdir -p $BUILD_DIR
      echo
      echo "WARNING!  BUILD_DIR($BUILD_DIR) != F18_REPOS($F18_REPOS)"
      echo "SO REPLICATING F18_REPOS/$F18_PROJECT_REPO_NAME  TO: $BUILD_DIR"
      echo
      echo "rsync -a $exclude_cmdline --delete $F18_REPOS/$F18_PROJECT_REPO_NAME $BUILD_DIR"
      rsync -a $exclude_cmdline --delete $F18_REPOS/$F18_PROJECT_REPO_NAME $BUILD_DIR 2>&1
   fi

else
   if [ ! -d $BUILD_DIR/build/$F18_PROJECT_REPO_NAME ] ; then 
      echo "ERROR: The build directory $BUILD_DIR/build/$F18_PROJECT_REPO_NAME does not exist"
      echo "       run $0 without nocmake or install options. " 
      exit 1
   fi
fi

if [ $F18_STANDALONE_BUILD == 1 ] ; then
   cd $BUILD_DIR/build/$F18_PROJECT_REPO_NAME
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

cd $BUILD_DIR/build/$F18_PROJECT_REPO_NAME

if [ "$1" != "nocmake" ] && [ "$1" != "install" ] ; then
   echo
   echo " -----Running cmake ---- " 
   if [ $COPYSOURCE ] ; then
       echo ${F18_CMAKE} $MYCMAKEOPTS  $BUILD_DIR/$F18_PROJECT_REPO_NAME/llvm
       ${F18_CMAKE} $MYCMAKEOPTS  $BUILD_DIR/$F18_PROJECT_REPO_NAME/llvm 2>&1
    else
       echo ${F18_CMAKE} $MYCMAKEOPTS  $F18_REPOS/$F18_PROJECT_REPO_NAME/llvm
       ${F18_CMAKE} $MYCMAKEOPTS  $F18_REPOS/$F18_PROJECT_REPO_NAME/llvm 2>&1
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
   if [ $F18_STANDALONE_BUILD == 1 ] ; then 
      echo " "
      echo "------ Linking $INSTALL_PROJECT to $F18 -------"
      if [ -L $F18 ] ; then 
         $SUDO rm $F18
      fi
      $SUDO ln -sf $INSTALL_PROJECT $F18
   fi
   # add executables forgot by make install but needed for testing
   echo add executables forgot by make install but needed for testing
   $SUDO cp -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME/bin/llvm-lit $F18/bin/llvm-lit
   $SUDO cp -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME/bin/FileCheck $F18/bin/FileCheck
   $SUDO cp -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME/bin/count $F18/bin/count
   $SUDO cp -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME/bin/not $F18/bin/not
   $SUDO cp -p $BUILD_DIR/build/$F18_PROJECT_REPO_NAME/bin/yaml-bench $F18/bin/yaml-bench
   $SUDO cp -p $thisdir/f18.sh $F18/bin/f18.sh
   # get the mygpu utility for makefiles 
   echo  cp -p $F18_REPOS/$F18_EXTRAS_REPO_NAME/utils/bin/mygpu $F18/bin/mygpu 
   $SUDO cp -p $F18_REPOS/$F18_EXTRAS_REPO_NAME/utils/bin/mygpu $F18/bin/mygpu 
   $echo cp -p $F18_REPOS/$F18_EXTRAS_REPO_NAME/utils/bin/gputable.txt $F18/bin/gputable.txt
   $SUDO cp -p $F18_REPOS/$F18_EXTRAS_REPO_NAME/utils/bin/gputable.txt $F18/bin/gputable.txt
   echo
   echo "SUCCESSFUL INSTALL to $INSTALL_PROJECT with link to $F18"
   echo
else 
   echo 
   echo "SUCCESSFUL BUILD, please run:  $0 install"
   echo "  to install into $F18"
   echo 
fi
