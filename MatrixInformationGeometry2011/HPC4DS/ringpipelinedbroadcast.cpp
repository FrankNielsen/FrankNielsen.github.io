# include <mpi.h>
# include <cstdio>
# include <cstdlib>
using namespace std;

// we assume the message is decomposed into r integers

int main ( int argc , char * argv []) {
  int rank,size,r;
  
  MPI_Status status ;
  MPI_Init (& argc , & argv ) ;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank ) ;
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  MPI_Request request,request2;
  

  if (argc == 2)
    r = atoi(argv[1]);
  else{
    if (rank==0)
      printf("Please enter the number r of integers which you would like to broadcast");
    return 0;
  }
    
  
  if ( rank == 0) {
    printf("I am root and I am preparing values to send\n");
    int send_values[r];
    for(int i=0;i<r;i++){
      send_values[i] = rand() % 1001;
    }
    for (int i=0;i<r;i++){      
      MPI_Send(&(send_values[i]),1,MPI_INT,rank+1,0,MPI_COMM_WORLD);
    }
  }
  else{
    int receive_values[r];
    if (rank == size-1){
      printf("I am  the last process and I am waiting for value number 0\n");
      MPI_Irecv(&(receive_values[0]),1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&request);
      printf("I am the last process and I received my value number 0");
      for(int i=1;i<r;i++){
	MPI_Recv(&(receive_values[i]),1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&status);
	printf("I am the last process and I received my value number %d",i);
      }
      printf("I am the last process and I received all my values! Here they are\n");
      for(int i=0; i<size;i++){
	printf("%d ",receive_values[i]);
      }
      printf("\n");
    }
    else{
      printf("I am process %d and I am preparing to receive values\n",rank);
      MPI_Irecv(&(receive_values[0]),1,MPI_INT,rank-1,0,MPI_COMM_WORLD,&request);
      printf("I am process %d and I received my first value!\n",rank);
      for(int i=0;i<r-1;i++){
	printf("I am process %d and I am preparing to send my value number %d\n",rank,i);
	MPI_Send(&(receive_values[i]),1,MPI_INT,rank+1,0,MPI_COMM_WORLD);
	printf("I am process %d and I just sent my value number %d\n",rank,i);
	
	
	MPI_Recv(&(receive_values[i+1]),1,MPI_INT,rank+1,0,MPI_COMM_WORLD,&status);
	printf("I am process %d and I received my value number %d!\n",rank,i+1);
      }
      MPI_Send(&(receive_values[r-1]),1,MPI_INT,rank+1,0,MPI_COMM_WORLD);
    }
  }


  MPI_Finalize();
  return 0;
}