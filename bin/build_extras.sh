#!/bin/bash
#
#  File: build_extras.sh
#        Build the extras host and device runtimes, 
#        The install option will install components into the aomp installation. 
#        The components include:
#          gpusrv headers installed in $AOMP/include
#          gpusrv host runtime installed in $AOMP/lib
#          gpusrv device runtime installed in $AOMP/lib/libdevice
#
# MIT License
#
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
[ ! -L "$0" ] || thisdir=$(getdname `readlink "$0"`)
. $thisdir/aomp_common_vars
# --- end standard header ----

EXTRAS_REPO_DIR=$AOMP_REPOS/$AOMP_EXTRAS_REPO_NAME

BUILD_DIR=${BUILD_AOMP}

BUILDTYPE="Release"

INSTALL_EXTRAS=${INSTALL_EXTRAS:-$AOMP_INSTALL_DIR}
export LLVM_DIR=$AOMP_INSTALL_DIR 
REPO_BRANCH=$AOMP_EXTRAS_REPO_BRANCH
REPO_DIR=$AOMP_REPOS/$AOMP_EXTRAS_REPO_NAME
checkrepo

if [ "$1" == "-h" ] || [ "$1" == "help" ] || [ "$1" == "-help" ] ; then
  echo " "
  echo "Example commands and actions: "
  echo "  ./build_extras.sh                   cmake, make, NO Install "
  echo "  ./build_extras.sh nocmake           NO cmake, make,  NO install "
  echo "  ./build_extras.sh install           NO Cmake, make install "
  echo " "
  exit
fi

if [ ! -d $EXTRAS_REPO_DIR ] ; then
   echo "ERROR:  Missing repository $EXTRAS_REPO_DIR/"
   exit 1
fi

if [ ! -f $AOMP/bin/clang ] ; then
   echo "ERROR:  Missing file $AOMP/bin/clang"
   echo "        Build and install the AOMP clang compiler in $AOMP first"
   echo "        This is needed to build extras "
   echo " "
   exit 1
fi

# Make sure we can update the install directory
if [ "$1" == "install" ] ; then
   $SUDO mkdir -p $INSTALL_EXTRAS
   $SUDO touch $INSTALL_EXTRAS/testfile
   if [ $? != 0 ] ; then
      echo "ERROR: No update access to $INSTALL_EXTRAS"
      exit 1
   fi
   $SUDO rm $INSTALL_EXTRAS/testfile
fi

if [ "$1" != "nocmake" ] && [ "$1" != "install" ] ; then

  if [ -d "$BUILD_DIR/build/extras" ] ; then
     echo
     echo "FRESH START , CLEANING UP FROM PREVIOUS BUILD"
     echo rm -rf $BUILD_DIR/build/extras
     rm -rf $BUILD_DIR/build/extras
  fi

  if [ $AOMP_STANDALONE_BUILD == 1 ] ; then
    MYCMAKEOPTS="-DLLVM_DIR=$LLVM_DIR $AOMP_ORIGIN_RPATH -DCMAKE_BUILD_TYPE=$BUILDTYPE -DCMAKE_INSTALL_PREFIX=$INSTALL_EXTRAS -DROCM_DIR=$ROCM_DIR -DAOMP_STANDALONE_BUILD=$AOMP_STANDALONE_BUILD -DAOMP_VERSION_STRING=$AOMP_VERSION_STRING -DCMAKE_PREFIX_PATH=$BUILD_DIR/build/libdevice"
  else
    MYCMAKEOPTS="-DLLVM_DIR=$LLVM_DIR $AOMP_ORIGIN_RPATH -DCMAKE_BUILD_TYPE=$BUILDTYPE -DCMAKE_INSTALL_PREFIX=$INSTALL_EXTRAS -DROCM_DIR=$ROCM_DIR -DAOMP_STANDALONE_BUILD=$AOMP_STANDALONE_BUILD -DDEVICELIBS_ROOT=$DEVICELIBS_ROOT -DAOMP_VERSION_STRING=$AOMP_VERSION_STRING"
  fi

  mkdir -p $BUILD_DIR/build/extras
  cd $BUILD_DIR/build/extras

  SED_INSTALL_DIR=`echo $INSTALL_EXTRAS | sed -e 's/\//\\\\\//g' `
  export SED_INSTALL_DIR
  echo
  echo " -----Running cmake ---- "
  echo ${AOMP_CMAKE} $MYCMAKEOPTS $EXTRAS_REPO_DIR
  ${AOMP_CMAKE} $MYCMAKEOPTS $EXTRAS_REPO_DIR 
  if [ $? != 0 ] ; then
      echo "ERROR extras cmake failed. Cmake flags"
      echo "      $MYCMAKEOPTS"
      exit 1
  fi

fi

cd $BUILD_DIR/build/extras
echo
echo " -----Running make for extras ---- "
make -j $NUM_THREADS 
if [ $? != 0 ] ; then
      echo " "
      echo "ERROR: make -j $NUM_THREADS  FAILED"
      echo "To restart:"
      echo "  cd $BUILD_DIR/build/extras"
      echo "  make "
      exit 1
else
  if [ "$1" != "install" ] ; then
      echo
      echo " BUILD COMPLETE! To install extras component run this command:"
      echo "  $0 install"
      echo
  fi
fi

#  ----------- Install only if asked  ----------------------------
if [ "$1" == "install" ] ; then
      cd $BUILD_DIR/build/extras
      echo
      echo " -----Installing to $INSTALL_EXTRAS ----- "
      $SUDO make install
      if [ $? != 0 ] ; then
         echo "ERROR make install failed "
         exit 1
      fi
fi
