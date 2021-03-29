#!/bin/bash
#
#  run_epsdb_aomp_test.sh
#

script_dir=$(dirname "$0")
parentdir=`eval "cd $script_dir;pwd;cd - > /dev/null"`
aompdir="$(dirname "$parentdir")"

set -x

(cd $aompdir/bin ; git checkout aomp-dev )

# we have a new Target memory manager appearing soon in aomp 12
# it seems to either cause or reveal double  free or corruption
# in lots of tests. This set to 0, disables the new TMM.
#export LIBOMPTARGET_MEMORY_MANAGER_THRESHOLD=0

export AOMPROCM=$AOMP/..


# Try using rocm_agent_enumerator for device id.
# Use bogus path to avoid using target.lst, a user-defined target list
# used by rocm_agent_enumerator.
export ROCM_TARGET_LST=/opt/nowhere
echo "RAE devices:"
$AOMPROCM/bin/rocm_agent_enumerator

# Regex skips first result 'gfx000' and selects second id.
export AOMP_GPU=$($AOMPROCM/bin/rocm_agent_enumerator | grep -m 1 -E gfx[^0]{1}.{2})

# mygpu will eventually relocate to /opt/rocm/bin, support both cases for now.
if [ "$AOMP_GPU" != "" ]; then
  echo "AOMP_GPU set with rocm_agent_enumerator."
else
  echo "AOMP_GPU is empty, use mygpu."
  if [ -a $AOMP/bin/mygpu ]; then
    export AOMP_GPU=$($AOMP/bin/mygpu)
  else
    export AOMP_GPU=$($AOMP/../bin/mygpu)
  fi
fi

echo AOMP_GPU = $AOMP_GPU
$AOMP/bin/clang --version
#ls /opt/rocm/amdgcn/bitcode
#ls $AOMP/amdgcn/bitcode
rm -f  $aompdir/test/smoke/passing-tests.txt
mkdir -p ~/git/
cd $aompdir/bin
set +x
echo "=========== clone aomp_test ==========="
./clone_aomp_test.sh > clone.log 2>&1

echo "====== helloworld ======="
cd $aompdir/test/smoke/helloworld
make clean
OMP_TARGET_OFFLOAD=MANDATORY VERBOSE=1 make run > hello.log 2>&1
tail -10 hello.log

echo "====== smoke-fails ======="
cd $aompdir/test/smoke-fails
OMP_TARGET_OFFLOAD=MANDATORY ./check_smoke_fails.sh > smoke-fails.log 2>&1
tail -34 smoke-fails.log

echo "====== smoke ======="
cd $aompdir/test/smoke
EPSDB=1 OMP_TARGET_OFFLOAD=MANDATORY ./check_smoke.sh > smoke.log 2>&1

echo $aompdir
echo

set -x
sort -f -d $aompdir/test/smoke/passing-tests.txt > $$ptests
sort -f -d $aompdir/bin/epsdb/epsdb_passes.txt > $$etests
#cat $$etests
#cat $$ptests
set +x

epasses=`diff $$etests $$ptests | grep '>' | wc -l`
echo Unexpected Passes $epasses
echo "====================="
diff $$etests $$ptests | grep '>' | sed 's/> //'
echo

efails=`diff $$etests $$ptests | grep '<' | wc -l`
echo Unexpected Fails $efails
echo "===================="
diff $$etests $$ptests | grep '<' | sed s'/< //'
echo
rm -f $$ptests $$etests

echo

echo "====== hip-openmp ==="
cd $aompdir/test/hip-openmp
AOMPHIP=$AOMP/.. ./check_hip-openmp.sh > hip-openmp.log 2>&1
tail -16 hip-openmp.log

echo "======= omp5 ==="
cd $aompdir/test/omp5
./check_omp5.sh  > omp5.log 2>&1
tail -20 omp5.log

echo "====== examples ==="
cd $aompdir/examples
EPSDB=1 AOMPHIP=$AOMP/.. ./check_examples.sh > examples.log 2>&1
tail -50 examples.log

echo "======= nekbone ======"
cd $aompdir/bin
./run_nekbone.sh > nekbone.log 2>&1
nekfails=$?
tail -7 nekbone.log

echo "======= openmpapps ==="
cd ~/git/aomp-test/openmpapps
./check_openmpapps.sh > openmpapps.log 2>&1
appfails=$?
tail -12 openmpapps.log

# sollve take about 16 minutes
echo "======= sollve ======="
cd $aompdir/bin
./run_sollve.sh > sollve.log 2>&1
tail -12 sollve.log

echo Done
echo
set -x
epsdb_status="green"
# return pass, condpass, fial status  (count)
if [ "$efails" -ge "1" ]; then
  echo "EPSDB smoke fails"
  epsdb_status="red"
#elif [ "$efails" -gt "0" ]; then
#  echo "EPSDB smoke conditional passes"
#  epsdb_status="yellow"
else
  echo "EPSDB smoke passes"
fi
if [ "$appfails" -ge "1" ]; then
  echo "EPSDB openmpapps fails"
  epsdb_status="red"
fi
if [ "$nekfails" -ge "1" ]; then
  echo "EPSDB nekbone fails"
  epsdb_status="red"
fi
echo "EPSDB Status: " $epsdb_status
Ret=$(($efails + $appfails + $nekfails))
exit $Ret

