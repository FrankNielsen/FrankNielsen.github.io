# include <mpi.h>
# include <cstdio>
# include <cstdlib>
using namespace std;

// we only do an all_to_all "broadcast", i.e each process sends one unique message to all other processes,
// as opposed to an all_to_all "scatter".
int main ( int argc , char * argv []) {
  int rank , size ;
  MPI_Status status ;
  MPI_Init (& argc , & argv ) ;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank ) ;
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  MPI_Request request;
  
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  int name_len;
  MPI_Get_processor_name(processor_name, &name_len);
  
  srand(2*rank);
  // initialize value
  int send_value = rand() % 1001;;
  printf("I am process %d on host %s and my value is %d\n",rank,processor_name,send_value);
  int received_values[size];
  received_values[rank] = send_value; //optional, to distinguish this cell as useless
  for(int i=0; i<size; i++){
    MPI_Send(&(received_values[(size+rank-i)%size]),1,MPI_INT,(rank+1)%size,0,MPI_COMM_WORLD);
    // printf("process %d sent value %d to process %d\n",rank,received_values[(size+rank-i)%size],(rank+1) % size);
    MPI_Irecv(&(received_values[(size+rank-i-1)%size]),1,MPI_INT,(size+rank-1)%size,0,MPI_COMM_WORLD,&request);
    
    // the two following lines are equivalent here
    // MPI_Wait(&request,&status);
    MPI_Barrier(MPI_COMM_WORLD);

    // printf("process %d received value %d from process %d\n",rank,received_values[(size+rank-i-1)%size],(size+rank-1)%size);
  }
  
  // optional: each node prints their values, allows to quickly check that all went well
  for(int i=0; i< size; i++){
    printf("%d ",received_values[i]);
  }
  printf("\n");
  
  MPI_Finalize();
  
  return 0;
}