// filename: MPIFactorialReduce.cpp
#include <stdio.h>
#include "mpi.h"

int main(int argc, char *argv[]) {
  int i,me, nprocs;
  int number, globalFact=-1, localFact;

  MPI_Init(&argc,&argv);
	
  MPI_Comm_size(MPI_COMM_WORLD,&nprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&me);
	
	number=me+1;
	MPI_Reduce(&number,&globalFact,1,MPI_INT,MPI_PROD,0,MPI_COMM_WORLD);
	if (me==0) printf("Computing the factorial in MPI: %d processus = %d\n",nprocs,globalFact);
	
	localFact=1; for(i=0;i<nprocs;i++) {localFact*=(i+1);}
	if (me==0) printf("Versus local factorial: %d\n",localFact);
 
MPI_Finalize();
}
