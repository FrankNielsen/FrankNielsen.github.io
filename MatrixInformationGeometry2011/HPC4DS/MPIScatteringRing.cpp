// filename: MPIScatteringRing.cpp
// Scattering on the oriented ring
# include <mpi.h>
# include <cstdio>
# include <cstdlib>
using namespace std;

int main ( int argc , char * argv []) {
  int rank , size ;
  MPI_Status status ;
  MPI_Init (& argc , & argv ) ;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank ) ;
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  MPI_Request request;
  
  if (rank == 0){
    int values[size-1];
    for(int i=0;i<size;i++){
      values[i]=i*i;
    }
    
    for (int i =1; i < size; i++){
      printf("process 0 is sending value %d to process %d intended for process %d\n",values[size-1-i],1,size-i);
      MPI_Isend(&values[size-1-i],1,MPI_INT,1,0,MPI_COMM_WORLD,&request);
    }
  }
  else{
    int my_received_val;
    int val_to_transfer;
    for (int i = rank; i < size-1; i++){
      MPI_Recv(&val_to_transfer,1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&status);
      printf("process %d received value %d for process %d which it now transfers to process %d\n",rank,val_to_transfer,size-1-i+rank,rank+1);
      MPI_Isend(&val_to_transfer,1,MPI_INT,rank+1,0,MPI_COMM_WORLD, &request);
    }
    MPI_Recv(&my_received_val,1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&status);
    printf("process %d received value %d from process %d\n",rank,my_received_val,rank-1);
  }
  MPI_Finalize();
  return  0;
}
