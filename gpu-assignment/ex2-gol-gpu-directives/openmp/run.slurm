#!/bin/bash --login
#--reservation=CurtinHPCcourse
#SBATCH --account=courses0100-gpu
#SBATCH --tasks=1
#SBATCH --partition=gpu
#SBATCH --gpus-per-node=8
#SBATCH --time=00:05:00
#SBATCH --export=NONE
#SBATCH --output=my_gol.out

module load rocm/5.2.3
module load craype-accel-amd-gfx90a

#compile
srun --export=all -u -n 1 make clean
srun --export=all -u -n 1 make

serial=01_gol_cpu_serial
gpu=02_gol_gpu_openmp

n=10
m=10

#run program
srun --export=all -u -n 1 ./bin/${gpu} ${n} ${m} 100



