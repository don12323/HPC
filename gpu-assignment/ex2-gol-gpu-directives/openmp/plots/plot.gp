#timing
set terminal png
set output 'timing_graph.png'
set title "Game of Life Timing Data(OpenMP)"
set xlabel "Grid Size (n = m)"
set ylabel "Time (s)"
set logscale x

set logscale y
set key outside

plot 'gpu_data.txt' using 1:3 with linespoints title 'GPU', \
     'cpu_data.txt' using 1:3 with linespoints title 'Serial'

#speed up
set output 'speedup.png'
set title "Speed up S=T_{s}/T_{p}"
set xlabel "Grid Size (n = m)"
set ylabel "S"
#unset logscale y
set logscale x 
plot 'cpu_data.txt' using 1:($3/$4) with linespoints title 'S'

