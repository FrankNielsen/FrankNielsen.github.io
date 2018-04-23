// filename: MPIHelloWorld.cpp
# include <iostream>
using namespace std;
# include "mpi.h"
int main ( int argc, char *argv[] )
{
  int id, p, name_len;
  char processor_name[MPI_MAX_PROCESSOR_NAME];
//  Initialize MPI.
  MPI::Init ( argc, argv );
//  Get the number of processes.
  p = MPI::COMM_WORLD.Get_size ( );
//  Get the individual process ID.
  id = MPI::COMM_WORLD.Get_rank ( );
  MPI_Get_processor_name(processor_name, &name_len);
  // Print off a hello world message
 cout << "  Processor " << processor_name<<"  ID="<<id << " Welcome to MPI!'\n";
//  Terminate MPI.
  MPI::Finalize ( );
return 0;
}
