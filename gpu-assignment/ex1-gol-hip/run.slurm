#!/bin/bash --login
#SBATCH --account=courses0100-gpu
#SBATCH --reservation=CurtinHPCcourse
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --partition=gpu
#SBATCH --time=00:05:00
#SBATCH --export=NONE
#SBATCH --output=my_gol.out


module load rocm/5.2.3

make clean
make

n=1000
m=10000

srun ./bin/game_of_life_hip ${n} ${m} 100
