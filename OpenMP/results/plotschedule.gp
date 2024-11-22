set terminal pngcairo enhanced font 'Verdana,12'
set output 'scheduling.png'

set title "Elapsed Time vs Chunk Size"
set xlabel "Chunk Size"
set ylabel "Elapsed Time (s)"
set key top left
set logscale x
plot "static.txt" using 1:2 with linespoints title "static", \
     "dynamic.txt" using 1:2 with linespoints title "dynamic", \
     "guided.txt" using 1:2 with linespoints title "guided"
    

