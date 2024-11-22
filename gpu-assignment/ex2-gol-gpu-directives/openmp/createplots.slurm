#!/bin/bash --login
#SBATCH --reservation=CurtinHPCcourse
#SBATCH --account=courses0100-gpu
#SBATCH --tasks=1
#SBATCH --partition=gpu
#SBATCH --gpus-per-node=8
#SBATCH --time=00:10:00
#SBATCH --export=NONE
#SBATCH --output=my_gol.out

module load rocm/5.2.3
module load craype-accel-amd-gfx90a

#compile
srun --export=all -u -n 1 make clean
srun --export=all -u -n 1 make

sizes=(10 100 1000 10000 20000)
output_file="plots/gpu_data.txt"
echo "n m Finished_GOL_Time(s)" > $output_file

for size in "${sizes[@]}"; do
	n=$size
	m=$size

	#run program
	srun --export=all -u -n 1 ./bin/02_gol_gpu_openmp ${n} ${m} 100 > temp_output.txt

	total=$(grep "Elapsed time" temp_output.txt | tail -1 | awk '{print $3}')
	echo "${n} ${m} ${total}" >> $output_file
done
rm temp_output.txt


