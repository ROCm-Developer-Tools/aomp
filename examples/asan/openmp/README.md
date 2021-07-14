AOMP - Examples to demonstrate use of OpenMP
==============================================

The AOMP compiler supports several accelerated programming models. OpenMP is one of these models.

Examples in this directory demonstrate how to use aomp to compile OpenMP 4.5 sources and execute the binaries on GPU.

Cd to a specific example folder and run the following commands to build and execute:

```
make
make run
```
There are many other make targets to show different ways to build the binary. Run ```make help``` to see all the possible demos as Makefile targets.

E.g. to run with some debug output set OFFLOAD_DEBUG variable:

```
env OFFLOAD_DEBUG=1 make
env OFFLOAD_DEBUG=1 make run
```

This demonstration shows the commands and output for the reduction example:

```
:/usr/lib/aomp/examples/openmp/reduction$ make
/usr/lib/aomp/bin/clang -O3 -target x86_64-pc-linux-gnu -fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx900 -fsanitize=address reduction.c -o reduction

:/usr/lib/aomp/examples/openmp/reduction$ make run
./reduction
The result is correct = 499999500000!

```

## Using is_device_ptr() with Host Pointers.

The clause is_device_ptr() on OpenMP target constructs is intended to tell OpenMP that the variable is already a device pointer so do not map it. A variable that is mapped uses a device copy of that variable.  There are at least two scenarios where you may not want a host pointer to be mapped to a device pointer.  The first is if you are using fprintf in a target region.  The fprintf function is implemented as a host service using the AOMP hostrpc services infrastructure.  In this case you do NOT want the file pointer to be mapped.  You want the host rpc services to get the actual file pointer.  So ironically, you must use the is_device_ptr(fileptr) to tell OpenMP not to map fileptr.  In other words, just leave that pointer alone in the target region.  The other scenario is when you are using any of the host functions that take a pointer to the host function.  Again, use is_device_ptr() clause to tell OpenMP not to do anything with that variable.  The examples host_function and host_varfn_function show how host functions are called from the GPU.  In both of these examples, you see the use of is_device_ptr to protect the host pointers from getting mapped.


```
