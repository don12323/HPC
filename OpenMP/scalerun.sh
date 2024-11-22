#!/bin/bash

make clean

version=02_gol_cpu_openmp_loop
makeversion=cpu_openmp_loop
# Compile with profiler enabled
make ${makeversion}_cc PROFILER=ON COMPILERTYPE=CRAY 


#set variables
nxgrid=10000
nygrid=10000
nsteps=10
someversionname=loop

basename=${someversionname}-nomp-${nomp}.${nxgrid}x${nygrid}-${nsteps}

#set num of omp threads

for nomp in 1 2 4 8 16; do
	for grid in 10 100 500 800 1000 3000 5000 7000 10000; do


		export OMP_NUM_THREADS=${nomp}
		export OMP_SCHEDULE="guided"
		output=$(./bin/${version} ${grid} ${grid} ${nsteps} 0 -1 0 0 | tail -c 12 | sed 's/ s//') 
        	echo "${grid} ${output}" >> scale/chunkvstime_${nomp}_loop.txt

	done
done
for nomp in 1 2 4 8 16; do


	export OMP_NUM_THREADS=${nomp}
	export OMP_SCHEDULE="static"
	output=$(./bin/${version} ${grid} ${grid} ${nsteps} 0 -1 0 0 | tail -c 12 | sed 's/ s//') 
	echo "${nomp} ${output}" >> scale/threeadsvstime_loop.txt

done

#nomp=10
#for grid in 10 100 500 800 1000 3000 5000 7000 10000; do
#	export OM_NUM_THREADS=${nomp}
 #       output=$(./bin/${version} ${grid} ${grid} ${nsteps} 0 -1 0 0 | tail -c 12 | sed 's/ s//')  
#	echo "${grid} ${output}" >> results/gridvstime2.txt 

#done
