# include <mpi.h>
# include <cstdio>
# include <cstdlib>
using namespace std;

int next()
{
  int rank,size;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank );
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  return ((rank + 1) % size);
}

int previous()
{
int rank,size;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank );
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  return ((size + rank - 1) % size);  
}

int main ( int argc , char * argv []) {
  int rank , value , size ;
  if (argc == 2)
    value = atoi(argv[1]);
  else
    value = rand % 1001;
  MPI_Status status ;
  MPI_Init (& argc , & argv ) ;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank ) ;
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  if ( rank == 0) {
    /* Master Node sends out the value */
    MPI_Send ( &value , 1 , MPI_INT , next() , 0 , MPI_COMM_WORLD) ;
  }
  else {
    /* Slave Nodes block on receive then send on the value */
    MPI_Recv ( &value , 1 , MPI_INT , previous() , 0 , MPI_COMM_WORLD , &status ) ;
    if ( rank < size - 1) {
      MPI_Send ( &value , 1 , MPI_INT , next() , 0 , MPI_COMM_WORLD ) ;
    }
    printf ( "process %d received %d \n" , rank , value ) ;
  }
  MPI_Finalize();
  return 0;
}