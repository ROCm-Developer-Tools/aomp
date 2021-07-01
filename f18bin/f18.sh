#!/bin/bash
#
#  f18.sh: A simulated f18 driver
#          This can be invoked from the f18 binary with
#          export F18_FC=$thisdir/f18.sh
#
#  Written by Greg Rodgers  Gregory.Rodgers@amd.com
#
PROGVERSION="X.Y-Z"
#
# Copyright (c) 2021 ADVANCED MICRO DEVICES, INC.
# 
# AMD is granting you permission to use this software and documentation (if any) (collectively, the 
# Materials) pursuant to the terms and conditions of the Software License Agreement included with the 
# Materials.  If you do not have a copy of the Software License Agreement, contact your AMD 
# representative for a copy.
# 
# You agree that you will not reverse engineer or decompile the Materials, in whole or in part, except for 
# example code which is provided in source code form and as allowed by applicable law.
# 
# WARRANTY DISCLAIMER: THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
# KIND.  AMD DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT 
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
# PURPOSE, TITLE, NON-INFRINGEMENT, THAT THE SOFTWARE WILL RUN UNINTERRUPTED OR ERROR-
# FREE OR WARRANTIES ARISING FROM CUSTOM OF TRADE OR COURSE OF USAGE.  THE ENTIRE RISK 
# ASSOCIATED WITH THE USE OF THE SOFTWARE IS ASSUMED BY YOU.  Some jurisdictions do not 
# allow the exclusion of implied warranties, so the above exclusion may not apply to You. 
# 
# LIMITATION OF LIABILITY AND INDEMNIFICATION:  AMD AND ITS LICENSORS WILL NOT, 
# UNDER ANY CIRCUMSTANCES BE LIABLE TO YOU FOR ANY PUNITIVE, DIRECT, INCIDENTAL, 
# INDIRECT, SPECIAL OR CONSEQUENTIAL DAMAGES ARISING FROM USE OF THE SOFTWARE OR THIS 
# AGREEMENT EVEN IF AMD AND ITS LICENSORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH 
# DAMAGES.  In no event shall AMD's total liability to You for all damages, losses, and 
# causes of action (whether in contract, tort (including negligence) or otherwise) 
# exceed the amount of $100 USD.  You agree to defend, indemnify and hold harmless 
# AMD and its licensors, and any of their directors, officers, employees, affiliates or 
# agents from and against any and all loss, damage, liability and other expenses 
# (including reasonable attorneys' fees), resulting from Your use of the Software or 
# violation of the terms and conditions of this Agreement.  
# 
# U.S. GOVERNMENT RESTRICTED RIGHTS: The Materials are provided with "RESTRICTED RIGHTS." 
# Use, duplication, or disclosure by the Government is subject to the restrictions as set 
# forth in FAR 52.227-14 and DFAR252.227-7013, et seq., or its successor.  Use of the 
# Materials by the Government constitutes acknowledgement of AMD's proprietary rights in them.
# 
# EXPORT RESTRICTIONS: The Materials may be subject to export restrictions as stated in the 
# Software License Agreement.
# 
function usage(){
/bin/cat 2>&1 <<"EOF" 

   f18.sh: Compile fortran source using f18 compiler

   Usage: f18.sh [ options ] filename.f90

   Options without values:
    -ll       Generate LLVM IR
    -g        Generate debug information
    -version  Display version of f18 then exit
    -v        Verbose messages
    -vv       very Verbose messages, pass -v to commands
    -n        Dryrun, do nothing, show commands that would execute
    -h        Print this help message
    -k        Keep temporary files

   Options with values:
    -I         <include dir>    Provide one directory per -I option
    -opt       <LLVM opt>       LLVM optimization level
    -o         <outfilename>    Default=<filename>.<ft> ft=hsaco
    -t         <tdir>           Temporary directory or intermediate files
                                Default=/tmp/f18-tmp-$$

   Copyright (c) 2020 ADVANCED MICRO DEVICES, INC.

EOF
   exit 0 
}

DEADRC=12

#  Utility Functions
function do_err(){
   if [ $NEWTMPDIR ] ; then 
      [ $VV ] && echo 
      if [ $KEEPTDIR ] ; then 
         [ $VERBOSE ] && echo "#Info:  Temp files copied to $OUTDIR/$TMPNAME"
         cp -rp $TMPDIR $OUTDIR
      fi
      [ $VERBOSE ] && echo "#Info:  Removing temp files from $TMPDIR"
      rm -rf $TMPDIR
   else 
      if [ $KEEPTDIR ] ; then 
         [ $VV ] && echo 
         [ $VERBOSE ] && echo "#Info:  Temp files kept in $TMPDIR"
      fi 
   fi
   [ $VV ] && echo 
   [ $VERBOSE ] && echo "#Info:  Done"
   exit $1
}

function version(){
   echo $PROGVERSION
   exit 0
}

function runcmd(){
   THISCMD=$1
   if [ $DRYRUN ] ; then
      echo "$THISCMD"
   else 
      [ $VV ] && echo "$THISCMD"
      $THISCMD
      rc=$?
      if [ $rc != 0 ] ; then 
         echo "ERROR:  The following command failed with return code $rc."
         echo "        $THISCMD"
         do_err $rc
      fi
   fi
}

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

#  --------  The main code starts here -----
INCLUDES=""
PASSTHRUARGS=""
INPUTFILES=""
EXTRA_BBC_ARGS=""
CPP=0
#  Argument processing
while [ $# -gt 0 ] ; do
   case "$1" in
      -q)               QUIET=true;;
      --quiet)          QUIET=true;;
      -k)               KEEPTDIR=true;;
      -n)               DRYRUN=true;;
      -c)               GEN_OBJECT_ONLY=true;;
      -g)               GEN_DEBUG=true;;
      -ll)              GENLL=true;;
      -s)               GENASM=true;;
      -I)               INCLUDES="$INCLUDES -I $2"; shift ;;
      -O)               LLVMOPT=$2; shift ;;
      -O3)              LLVMOPT=3 ;;
      -O2)              LLVMOPT=2 ;;
      -O1)              LLVMOPT=1 ;;
      -O0)              LLVMOPT=0 ;;
      -o)               OUTFILE=$2; shift ;;
      -r8)		EXTRA_BBC_ARGS="$EXTRA_BBC_ARGS -r8";;
      -i8)		EXTRA_BBC_ARGS="$EXTRA_BBC_ARGS -i8";;
      -cpp)		CPP=1 ;;
      -D*)		CPP_ARGS="$CPP_ARGS $1" ;;
      -t)               TMPDIR=$2; shift ;;
      -h)               usage ;;
      -help)            usage ;;
      --help)           usage ;;
      -version)         version ;;
      --version)        version ;;
      -v)               VERBOSE=true;;
      -vv)              VV=true;VFLAG="-v";;
      --)               shift ;;
      *)
        dash=${1:0:1}
        if [ $dash == "-" ] ; then
           PASSTHRUARGS+=" $1"
        else
           INPUTFILES+=" $1"
        fi
   esac
   shift
done

fcount=0
for __input_file in `echo $INPUTFILES` ; do
   fcount=$(( fcount + 1 ))
   if [ $fcount == 1 ] ; then
      FIRST_INPUT_FILE_NAME=$__input_file
   fi
   if [ ! -e "$__input_file" ] ; then
      echo "ERROR:  The file $__input_file does not exist."
      exit $DEADRC
   fi
done
if [ -z "$FIRST_INPUT_FILE_NAME" ]  ; then
   echo "ERROR:  No File specified."
   exit $DEADRC
fi

thisdir=$(getdname $0)
[ ! -L "$thisdir/f18.sh" ] || thisdir=$(getdname `readlink "$thisdir/f18.sh"`)

F18=${F18:-$HOME/rocm/f18}
if [ ! -d $F18 ] ; then
   echo "ERROR: F18 not found at $F18"
   echo "       Please install F18  or correctly set env-var F18"
   exit 1
fi

LLVMOPT=${LLVMOPT:-2}

if [ $VV ]  ; then 
   VERBOSE=true
fi


RUNDATE=`date`

# Parse FIRST_INPUT_FILE_NAME for filetype, directory, and filename
INPUT_FTYPE=${FIRST_INPUT_FILE_NAME##*\.}
INDIR=$(getdname $FIRST_INPUT_FILE_NAME)
FILENAME=${FIRST_INPUT_FILE_NAME##*/}
# FNAME has the filetype extension removed, used for naming intermediate filenames
FNAME=${FILENAME%.*}

if [ -z $OUTFILE ] ; then
#  Output file not specified so use input directory
   OUTDIR=$INDIR
   if [ $GEN_OBJECT_ONLY ] ; then
      OUTFILE=${FNAME}.o
   else
      OUTFILE="a.out"
   fi
else
#  Use the specified OUTFILE
   OUTDIR=$(getdname $OUTFILE)
   OUTFILE=${OUTFILE##*/}
fi

TMPNAME="f18-tmp-$$"
TMPDIR=${TMPDIR:-/tmp/$TMPNAME}
if [ -d $TMPDIR ] ; then 
   KEEPTDIR=true
else 
   if [ $DRYRUN ] ; then
      echo "mkdir -p $TMPDIR"
   else
      mkdir -p $TMPDIR
      NEWTMPDIR=true
   fi
fi

# Be sure not to delete the output directory
if [ $TMPDIR == $OUTDIR ] ; then 
    echo "SAFETY:  Will not delete $OUTDIR"
   KEEPTDIR=true
fi
if [ ! -d $TMPDIR ] && [ ! $DRYRUN ] ; then 
   echo "ERROR:  Directory $TMPDIR does not exist or could not be created"
   exit $DEADRC
fi 
if [ ! -d $OUTDIR ] && [ ! $DRYRUN ]  ; then 
   echo "ERROR:  The output directory $OUTDIR does not exist"
   exit $DEADRC
fi 

#  Print Header block
if [ $VERBOSE ] ; then 
   [ $VV ] && echo 
   echo "#Info:  F18 Version:	$PROGVERSION" 
   echo "#Info:  F18 Path:	$F18"
   echo "#Info:  Run date:	$RUNDATE" 
   echo "#Info:  Input file:	$INDIR/$FILENAME"
   echo "#Info:  Output file:	$OUTDIR/$OUTFILE"
   [ $KEEPTDIR ] &&  echo "#Info:  Temp dir:	$TMPDIR" 
fi 

rc=0


# Set extra libs that may be needed
EXTRA_LIBS="-L $HOME/rocm/aomp/lib -lpgmath"
# EXTRA_LIBS=""
BBC_ARGS="-module-suffix .f18.mod -intrinsic-module-directory $F18/include/flang $EXTRA_BBC_ARGS"

# For firdev developers only
# Set F18_USE_BUILD_BIN if you dont want run out of install binaries
F18_USE_BUILD_BIN=${F18_USE_BUILD_BIN:-0}
if [ $F18_USE_BUILD_BIN == 0 ] ; then
   F18BIN=${F18BIN:-$F18/bin}
   F18LIB=${F18LIB:-$F18/lib}
else
   # F18_REPOS: LOcation of F18 repositories
   F18_REPOS=${F18_REPOS:-$HOME/git/f18}
   # F18_PROJECT_REPO_NAME:  Directory name for the f18 monorepo
   F18_PROJECT_REPO_NAME=${F18_PROJECT_REPO_NAME:-firdev-llvm-project}
   # F18_BUILD: cmake build location for F18
   F18_BUILD=${F18_BUILD:-$F18_REPOS/build/$F18_PROJECT_REPO_NAME}
   F18BIN=$F18_BUILD/bin
   F18LIB=$F18_BUILD/lib
fi

# Set the name of the c and c++ compilers
F18CC=${F18CC:-$F18BIN/clang}
F18CXX=${F18CXX:-$F18BIN/clang++}

# Loop through all the input files 
objfilelist=" "
for __input_file in `echo $INPUTFILES` ; do
   filetype=${__input_file##*\.}
   if [ $filetype == "o" ] ; then 
      objfilelist="$objfilelist $__input_file"
   else
      FILENAME=${__input_file##*/}
      strippedname=`echo $FILENAME | sed -e "s/\.f$//" -e "s/\.f90$//" -e "s/\.f95$//"`
      if [ "X$__input_file" = "X$strippedname" ] ; then 
        echo "ERROR: unknown suffix $filetype"
        do_err $DEADRC
      fi
      # the bbc phase includes parsing, semantic analysis, producing FIR, and lastly MLIR
      [ $VV ] && echo 
      [ $VERBOSE ] && echo "#Step:  bbc - Parse and create mlir for $__input_file"
      if [ $CPP -eq 0 ] ; then
        runcmd "$F18BIN/bbc $BBC_ARGS $__input_file -o $TMPDIR/$strippedname.mlir"
      else
        runcmd "cpp -traditional-cpp $CPP_ARGS $__input_file -o $TMPDIR/$strippedname.cpp.$filetype"
        runcmd "$F18BIN/bbc $BBC_ARGS $TMPDIR/$strippedname.cpp.$filetype -o $TMPDIR/$strippedname.mlir"
      fi

      # the tco phase takes in MLIR and lowers it to llvm IR
      [ $VV ] && echo 
      [ $VERBOSE ] && echo "#Step:  tco - Convert mlir to LLVM IR"
      runcmd "$F18BIN/tco $TMPDIR/$strippedname.mlir -o $TMPDIR/$strippedname.ll"
      # convert LLVM IR to assembly
      [ $VV ] && echo 
      [ $VERBOSE ] && echo "#Step:  llc - Compile llvm IR to assembler"
      runcmd "$F18BIN/llc $TMPDIR/$strippedname.ll -o $TMPDIR/$strippedname.s"
      # convert assembly to .o
      [ $VV ] && echo 
      [ $VERBOSE ] && echo "#Step:  asm - Create object from assembly"
      if [ $GEN_OBJECT_ONLY ] ; then
         runcmd "$F18CC $VFLAG -c $TMPDIR/$strippedname.s -o $OUTFILE "
      else
         runcmd "$F18CC $VFLAG -c $TMPDIR/$strippedname.s -o $TMPDIR/$strippedname.o"
         objfilelist="$objfilelist $TMPDIR/$strippedname.o"
      fi
   fi
done

if [ ! $GEN_OBJECT_ONLY ] ; then
   [ $VERBOSE ] && echo "#Step:  Link objects with c main to create $OUTFILE"
   runcmd "$F18CXX $VFLAG -no-pie -L $F18LIB -lFortranRuntime $objfilelist $mymaino -lFortranRuntime -lFortranDecimal -lFortran_main $EXTRA_LIBS -o $OUTFILE"
fi

do_err 0
exit 0
