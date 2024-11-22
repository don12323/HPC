# Set input file name
datafile = "gridvstime2.txt"

# Set plot parameters
set title "Grid Size vs. Elapsed Time (task)"
set xlabel "Grid Size"
set ylabel "Elapsed Time (seconds)"
set grid
set key top left

set terminal png
set output "taskgvstime.png"

# Plot the data
plot datafile using 1:2 with linespoints title "Elapsed Time"

