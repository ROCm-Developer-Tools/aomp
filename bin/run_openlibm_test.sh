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

patchrepo $AOMP_REPOS_TEST/$AOMP_OPENLIBM_REPO_NAME

# Setup AOMP variables
 AOMP=${AOMP:-/usr/lib/aomp}

# Use function to set and test AOMP_GPU
setaompgpu

DEVICE_ARCH=${DEVICE_ARCH:-$AOMP_GPU}
DEVICE_TARGET=${DEVICE_TARGET:-amdgcn-amd-amdhsa}

cd $AOMP_REPOS_TEST/$AOMP_OPENLIBM_REPO_NAME/test

function runlibmtest(){
   make $test_name
   if [ ! -f $test_name ] ; then 
      echo "ERROR:  Could not build $_testnname"
      exit 1
   fi
   echo 
   echo Running test $test_name
   _logfile=/tmp/${test_name}$$.log
   ./$test_name >$_logfile
   if [ $? != 0 ] ; then 
      echo "WARNING: Errors occured in $AOMP_REPOS_TEST/$AOMP_OPENLIBM_REPO_NAME/test/$test_name"
   fi
   cases=`grep "test cases" $_logfile | cut -d" " -f3`
   exceptions=`grep "test cases" $_logfile | cut -d" " -f7`
   _total_tests=$(( cases + exceptions ))
   _errors=`grep "errors occurred" $_logfile | cut -d" " -f3`
   _total_pass=$(( _total_tests - _errors ))
   _pass_rate=$(( ( _total_pass * 100 ) / _total_tests ))
   echo
   echo "Openlibm test:   $test_name"
   echo "  Total tests:   $_total_tests"
   echo "  Errors:        $_errors"
   echo "  Passing tests: $_total_pass"
   echo "  Pass rate:     ${_pass_rate}%"
   echo "  Logfile        $_logfile"
   echo

   rm $AOMP_REPOS_TEST/$AOMP_OPENLIBM_REPO_NAME/test/$test_name
}

test_name="test-float-offload"
runlibmtest
test_name="test-double-offload"
runlibmtest

removepatch $AOMP_REPOS_TEST/$AOMP_OPENLIBM_REPO_NAME
exit 0
