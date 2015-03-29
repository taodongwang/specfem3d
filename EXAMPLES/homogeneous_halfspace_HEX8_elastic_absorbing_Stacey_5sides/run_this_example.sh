#!/bin/bash

echo "running example: `date`"
currentdir=`pwd`

echo
echo "(will take about 15 minutes)"
echo

# sets up directory structure in current example directory
echo
echo "   setting up example..."
echo

rm -f -r OUTPUT_FILES

mkdir -p bin
mkdir -p OUTPUT_FILES
mkdir -p OUTPUT_FILES/DATABASES_MPI

cd ../../

rm -fr DATA/*
cd $currentdir
cp -fr DATA/* ../../DATA/.

# links executables
cd bin/
rm -f *
cp ../../../bin/xdecompose_mesh .
cp ../../../bin/xgenerate_databases .
cp ../../../bin/xspecfem3D .
cd ../

# stores setup
cp DATA/Par_file OUTPUT_FILES/
cp DATA/CMTSOLUTION OUTPUT_FILES/
cp DATA/STATIONS OUTPUT_FILES/

# get the number of processors, ignoring comments in the Par_file
NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

# decomposes mesh using the pre-saved mesh files in MESH-default
echo
echo "  decomposing mesh..."
echo
./bin/xdecompose_mesh $NPROC ./MESH-default ./OUTPUT_FILES/DATABASES_MPI/

# runs database generation
echo
echo "  running database generation on $NPROC processors..."
echo
mpirun -np $NPROC ./bin/xgenerate_databases

# runs simulation
echo
echo "  running solver on $NPROC processors..."
echo
mpirun -np $NPROC ./bin/xspecfem3D

echo
echo "see results in directory: OUTPUT_FILES/"
echo
echo "done"
date


