// filename: MPIMatrixVectorMultiplication.cpp
#include <mpi.h>

int main(int argc, char *argv[]) {
  int A[4][4], b[4], c[4], line[4], temp[4], local_value, myid;
  MPI_Init(&argc, &argv); 
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	
  if (myid == 0) {/* initialization */
    for (int i=0; i<4; i++) {
      b[i] = 4 ? i; 
      for (int j=0; j<4; j++) 
        A[i][j] = i + j;
    }
    line[0]=A[0][0]; 
    line[1]=A[0][1];
    line[2]=A[0][2]; 
    line[3]=A[0][3];
  }
	
  if (myid == 0) {
    for (int i=1; i<4; i++) {// slaves perform multiplications
      temp[0]=A[i][0];
      temp[1] = A[i][1];
      temp[2] = A[i][2];
      temp[3] = A[i][3]; 
      MPI_Send( temp, 4, MPI_INT, i, i, MPI_COMM_WORLD);
      MPI_Send( b, 4, MPI_INT, i, i, MPI_COMM_WORLD);
    }
  } else {
    MPI_Recv( line, 4, MPI_INT, 0, myid, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    MPI_Recv( b, 4, MPI_INT, 0, myid, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  } 
  {// master node
    c[myid] = line[0] * b[0] + line[1] * b[1] + line [2] * b[2] + line[3] * b[3];
    if (myid != 0) {
      MPI_Send(&c[myid], 1, MPI_INT, 0, myid, MPI_COMM_WORLD);
    } else {
      for (int i=1; i<4; i++) {
        MPI_Recv( &c[i], 1, MPI_INT, i, i, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
      }
    }
    MPI_Finalize();  
    return 0;
  }
  