#include "common.h"
#include <hip/hip_runtime.h>
#define NTHREADS 1024
//#define INCLUDE_CPU_VERSION
//#include "game_of_life.c"

#define HIP_CHECK_ERROR(X)({\
    if((X) != hipSuccess){\
        fprintf(stderr, "HIP error (%s:%d): %s\n", __FILE__, __LINE__, hipGetErrorString((X)));\
        exit(1);\
    }\
})

#define MALLOC_CHECK_ERROR(X)({\
    if ((X) == 0){\
        fprintf(stderr, "Malloc error (%s:%d).\n", __FILE__, __LINE__);\
        exit(1);\
    }\
})

__global__ void gpu_game_of_life_step(int *current_grid, int *next_grid, int n, int m){
    int neighbours;
    int n_i[8], n_j[8];
    unsigned int idx_in = blockDim.x * blockIdx.x + threadIdx.x;
    if (idx_in < n*m){
	    unsigned int i = idx_in / m;
	    unsigned int j = idx_in % m;
	    
            // count the number of neighbours, clockwise around the current cell.
            neighbours = 0;
            n_i[0] = i - 1; n_j[0] = j - 1;
            n_i[1] = i - 1; n_j[1] = j;
            n_i[2] = i - 1; n_j[2] = j + 1;
            n_i[3] = i;     n_j[3] = j + 1;
            n_i[4] = i + 1; n_j[4] = j + 1;
            n_i[5] = i + 1; n_j[5] = j;
            n_i[6] = i + 1; n_j[6] = j - 1;
            n_i[7] = i;     n_j[7] = j - 1;

            if(n_i[0] >= 0 && n_j[0] >= 0 && current_grid[n_i[0] * m + n_j[0]] == ALIVE) neighbours++;
            if(n_i[1] >= 0 && current_grid[n_i[1] * m + n_j[1]] == ALIVE) neighbours++;
            if(n_i[2] >= 0 && n_j[2] < m && current_grid[n_i[2] * m + n_j[2]] == ALIVE) neighbours++;
            if(n_j[3] < m && current_grid[n_i[3] * m + n_j[3]] == ALIVE) neighbours++;
            if(n_i[4] < n && n_j[4] < m && current_grid[n_i[4] * m + n_j[4]] == ALIVE) neighbours++;
            if(n_i[5] < n && current_grid[n_i[5] * m + n_j[5]] == ALIVE) neighbours++;
            if(n_i[6] < n && n_j[6] >= 0 && current_grid[n_i[6] * m + n_j[6]] == ALIVE) neighbours++;
            if(n_j[7] >= 0 && current_grid[n_i[7] * m + n_j[7]] == ALIVE) neighbours++;

            if(current_grid[i*m + j] == ALIVE && (neighbours == 2 || neighbours == 3)){
                next_grid[i*m + j] = ALIVE;
            } else if(current_grid[i*m + j] == DEAD && neighbours == 3){
                next_grid[i*m + j] = ALIVE;
            }else{
                next_grid[i*m + j] = DEAD;
            }
        }
    
}


/*
Implements the game of life on a grid of size `n` times `m`, starting from the `initial_state` configuration.

If `nsteps` is positive, returns the last state reached.
*/
int* gpu_game_of_life(const int *initial_state, int n, int m, int nsteps){
    int *grid = (int *) malloc(sizeof(int) * n * m);
   // int *updated_grid = (int *) malloc(sizeof(int) * n * m);
    
    //allocate memory in gpu
    int* dev_grid, *dev_updated_grid;
    HIP_CHECK_ERROR(hipMalloc(&dev_grid, sizeof(int) * n * m));
    HIP_CHECK_ERROR(hipMalloc(&dev_updated_grid, sizeof(int) * n * m));

    if(!grid){ //!updated_grid){
        printf("Error while allocating memory.\n");
        exit(1);
    }
    int current_step = 0;
    int *tmp = NULL;
    memcpy(grid, initial_state, sizeof(int) * n * m);
    
    //copy initial state grid to device
    HIP_CHECK_ERROR(hipMemcpy(dev_grid,grid, sizeof(int) * n * m, hipMemcpyHostToDevice));
    //calculate nblocks
    unsigned int nBlocks = (n*m + NTHREADS -1) / NTHREADS;

    float total=0;
    while(current_step != nsteps){
        current_step++;
        // Uncomment the following line if you want to print the state at every step
        //visualise(VISUAL_ASCII, current_step, grid, n, m);
	hipEvent_t start, stop;
	HIP_CHECK_ERROR(hipEventCreate(&start));
	HIP_CHECK_ERROR(hipEventCreate(&stop));
	HIP_CHECK_ERROR(hipEventRecord(start));
	//run gpu kernal
        gpu_game_of_life_step<<<nBlocks, NTHREADS>>>(dev_grid, dev_updated_grid, n, m);

	HIP_CHECK_ERROR(hipGetLastError());
	HIP_CHECK_ERROR(hipEventRecord(stop));
	HIP_CHECK_ERROR(hipDeviceSynchronize());
        
	float elapsed;
	HIP_CHECK_ERROR(hipEventElapsedTime(&elapsed, start, stop));	
	printf("'game_of_life' kernel execution time (ms): %.4f\n", elapsed);

	total += elapsed;
	//copy from device to host
	
//	HIP_CHECK_ERROR(hipMemcpy(updated_grid, dev_updated_grid, sizeof(int) * n * m, hipMemcpyDeviceToHost));
//	HIP_CHECK_ERROR(hipDeviceSynchronize());
	
	
	
	// swap current and updated grid
  //      tmp = grid;
    //    grid = updated_grid;
      //  updated_grid = tmp;

	// swap device pointers
	tmp = dev_grid;
	dev_grid = dev_updated_grid;
	dev_updated_grid = tmp;


	HIP_CHECK_ERROR(hipEventDestroy(start));
	HIP_CHECK_ERROR(hipEventDestroy(stop));
    }
    
    HIP_CHECK_ERROR(hipMemcpy(grid, dev_updated_grid, sizeof(int) * n * m, hipMemcpyDeviceToHost));
    HIP_CHECK_ERROR(hipDeviceSynchronize());

   //visualise(VISUAL_ASCII, current_step, grid, n, m);
    
    printf("Total Kernal time (ms): %.4f\n", total);
    HIP_CHECK_ERROR(hipFree(dev_updated_grid));
    HIP_CHECK_ERROR(hipFree(dev_grid));
    //free(updated_grid);
    return grid;
}










#ifndef INCLUDE_CPU_VERSION // do not define the main function if this file is included somewhere else.
int main(int argc, char **argv)
{
    struct Options *opt = (struct Options *) malloc(sizeof(struct Options));
    getinput(argc, argv, opt);
    int n = opt->n, m = opt->m, nsteps = opt->nsteps;
    int *initial_state = (int *) malloc(sizeof(int) * n * m);
    if(!initial_state){
        printf("Error while allocating memory.\n");
        return -1;
    }
    generate_IC(opt->iictype, initial_state, n, m);
    struct timeval start;
    start = init_time();
    int *final_state = gpu_game_of_life(initial_state, n, m, nsteps);
    float elapsed = get_elapsed_time(start);
    printf("Finnished GOL in %f ms\n", elapsed);
    free(final_state);
    free(initial_state);
    free(opt);
    return 0;
}
#endif
