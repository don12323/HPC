#timing
set terminal png
set output 'timing_graph.png'
set title "Game of Life Timing Data"
set xlabel "Grid Size (n = m)"
set ylabel "Time (ms)"
set logscale x

set logscale y
set key outside

plot 'gpu_data.txt' using 1:3 with linespoints title 'GPU', \
     'gpu_data.txt' using 1:4 with linespoints title 'Kernel',\
     'cpu_data.txt' using 1:3 with linespoints title 'Serial'

#speed up
set output 'speedup.png'
set title "Speed up S=T_{s}/T_{p}"
set xlabel "Grid Size (n = m)"
set ylabel "S"
set logscale y
set logscale x 
plot 'cpu_data.txt' using 1:($3/$4) with linespoints title 'S'

#kernel time
set output 'kernel.png'
set title "Percentage spent on kernel execution"
set xlabel "Grid Size (n = m)"
set ylabel "t_{k} (%)"
set logscale x
plot 'gpu_data.txt' using 1:($4/$3*100) with linespoints title 't_{k}'























