AOMP - Examples to demonstrate use of Clang HIP in AOMP
=======================================================

The AOMP compiler supports several accelerated programming models.
AOMP includes a HIP front end. This allows HIP code to be compiled
by the AOMP compiler, which will produce a binary containing code
generated for the specified target GPU, as well as host code. The
examples in this directory demonstrate how to use AOMP to compile HIP
code to an executable.

To compile an example simply run 'make', and to run 'make run'. For
more information and other options use 'make help'

Examples:
vectorAdd  - adds two vectors
writeIndex - Write the thread index into an array element
matrixmul  - simple implementation of matrix multiplication
writeIndex_amode - Same as writeIndex but but uses automatic mode

### About this file

This is the README.md file for
https:/github.com/ROCM-Developer-Tools/aomp/examples/hip

