// filename: MPIMonteCarloPi.cpp
int main(int argc, char *argv[]) {
  MPI_Init(&argc, &argv);
  #define INT_MAX_ 1000000000
    int myid, size, inside=0, outside=0, points=10000;
  double  x, y, Pi_comp, Pi_real=3.141592653589793238462643;
	
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
	
  if (myid == 0) {
    for (int i=1; i<size; i++) /* send  to  slaves */
      MPI_Send(&points, 1, MPI_INT, i, i, MPI_COMM_WORLD);
  } else 
    MPI_Recv(&points, 1, MPI_INT, 0, i, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
  rands=new double[2*points]; 
	
  for (int i=0; i<2*points; i++ ) {
    rands[i]=random(); 
    if (rands[i]<=INT_MAX_) 
      i++
    }
		
    for (int i=0; i<points; i++ ) {
      x=rands[2*i]/INT_MAX_;
      y
        =rands[2*i+1]/INT_MAX_;
      if ((x*x+y*y)<1) inside++ /* point  inside unit circle*/
    }
		
  delete[] rands;
	
  if (myid == 0) {
    for (int i=1; i<size; i++) {
      int temp; 
      MPI_Recv(&temp, 1, MPI_INT, i, i, MPI_COMM_WORLD, MPI_STATUS_IGNORE); 
      inside+=temp;
    } /* master sums all  */
  } else 
    MPI_Send(&inside, 1, MPI_INT, 0, i, MPI_COMM_WORLD); /* send inside to master */
  if (myid == 0) {
    Pi_comp = 4 * (double) inside / (double)(size*points);
    cout << "Value obtained: " << Pi_comp << endl << "Pi:" << Pi_real << endl;
  }
	
  MPI_Finalize(); 
	
  return 0;
}