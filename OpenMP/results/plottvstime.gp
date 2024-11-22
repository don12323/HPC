# Set input file name
datafile = "threadsvstime.txt"

# Set plot parameters
set title "Number of Threads vs. Elapsed Time (loop)"
set xlabel "Number of Threads"
set ylabel "Elapsed Time (seconds)"
set grid
set key top left

set terminal png
set output "plotThread.png"

# Plot the data
plot datafile using 1:2 with linespoints title "Elapsed Time"

