set terminal pngcairo enhanced font 'Verdana,12'
set output 'chunk_vs_time_plot_loop.png'

set title "nxn Grid size vs Elapsed Time (task)"
set xlabel "n"
set ylabel "Elapsed Time (seconds)"
set key 

plot 'chunkvstime_1_task.txt' using 1:2 with linespoints title '1 Thread', \
     'chunkvstime_2_task.txt' using 1:2 with linespoints title '2 Threads', \
     'chunkvstime_4_task.txt' using 1:2 with linespoints title '4 Threads', \
     'chunkvstime_8_task.txt' using 1:2 with linespoints title '8 Threads', \
     'chunkvstime_16_task.txt' using 1:2 with linespoints title '16 Threads'

