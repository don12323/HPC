#!/bin/bash

make clean

version=02_gol_cpu_openmp_loop
makeversion=cpu_openmp_loop
# Compile with profiler enabled
make ${makeversion}_cc PROFILER=ON COMPILERTYPE=CRAY


#set variables
nomp=10
nxgrid=10000
nygrid=10000
nsteps=10
someversionname=loop

basename=${someversionname}-nomp-${nomp}.${nxgrid}x${nygrid}-${nsteps}

#iterate over range of chunksize
for chunk_size in {500..2000..100}; do

	#set num of omp threads	    
	export OMP_NUM_THREADS=${nomp}
	export OMP_SCHEDULE="guided,${chunk_size}"

	#run
	output=$(./bin/${version} ${nxgrid} ${nygrid} ${nsteps} 0 -1 0 0 | tail -c 12 | sed 's/ s//') 
	
	echo "${chunk_size} ${output}" >> results/guided.txt

done
