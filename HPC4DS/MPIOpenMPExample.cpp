// filename: MPIOpenMPExample.cpp
#include <mpi.h>
#include <omp.h>
#include <stdio.h>
int main (int nargs, char** args)
{
int rank, nprocs, thread_id, nthreads;
int name_len;
char processor_name[MPI_MAX_PROCESSOR_NAME];
	
MPI_Init (&nargs, &args);
MPI_Comm_size (MPI_COMM_WORLD, &nprocs);
MPI_Comm_rank (MPI_COMM_WORLD, &rank);
MPI_Get_processor_name(processor_name, &name_len);

#pragma omp parallel private(thread_id, nthreads)
{
thread_id = omp_get_thread_num ();
nthreads = omp_get_num_threads ();
printf("Thread number %d (on %d) for the MPI process number %d (on %d) [%s]\n",
thread_id, nthreads, rank, nprocs,processor_name);
}
MPI_Finalize ();
return 0;
}