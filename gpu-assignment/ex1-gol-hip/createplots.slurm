#!/bin/bash --login
#SBATCH --account=courses0100-gpu
#SBATCH --reservation=CurtinHPCcourse
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:8
#SBATCH --partition=gpu
#SBATCH --time=00:05:00
#SBATCH --export=NONE
#SBATCH --output=my_gol.out


module load rocm/5.2.3

make clean
make
sizes=(10 100 1000 10000)
output_file="plots/gpu_data.txt"
echo "n m Finished_GOL_Time(ms) Kernel_Time(ms)" > $output_file

for size in "${sizes[@]}"; do
	n=$size
	m=$size

	#run program
	srun ./bin/game_of_life_hip ${n} ${m} 100 > temp_output.txt

	total=$(grep "Finnished GOL in" temp_output.txt | awk '{print $4}')
	kernel=$(grep "Total Kernal time (ms)" temp_output.txt | awk '{print $5}')
	echo "${n} ${m} ${total} ${kernel}" >> $output_file
done
rm temp_output.txt


