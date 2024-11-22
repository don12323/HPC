#!/bin/bash

make clean

version=02_gol_cpu_openmp_loop
makeversion=cpu_openmp_loop
# Compile with profiler enabled
make ${makeversion}_cc PROFILER=ON COMPILERTYPE=CRAY


#set variables
nomp=10
nxgrid=1000
nygrid=1000
nsteps=5

#set names
someversionname=loop

basename=${someversionname}-nomp-${nomp}.${nxgrid}x${nygrid}-${nsteps}

#set num of omp threads	    
export OMP_NUM_THREADS=${nomp}

#if using loop parallelism export with scheduling type
if [ "$version" == "02_gol_cpu_openmp_loop" ]; then

	export OMP_SCHEDULE="guided"

fi

#run the code
./bin/${version} ${nxgrid} ${nygrid} ${nsteps} 0 0 0 0 > log/${basename}.log



#outputs of analysis and stats are saved to stats directory
mv GOL-stats.txt stats/${basename}.stats.txt

gprof -lbp ./bin/${version} gmon.out > stats/analysis_${basename}.txt

gprof -bp ./bin/${version} gmon.out >> stats/analysis_${basename}.txt


cat stats/analysis_${basename}.txt

