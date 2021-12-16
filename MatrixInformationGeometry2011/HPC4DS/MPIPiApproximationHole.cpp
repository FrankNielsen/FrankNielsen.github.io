// filename: MPIPiApproximationHole.cpp
#include <math.h>
#include "mpi.h"
#include <iostream>
using namespace std;
 
int main(int argc, char *argv[]){
    int n, rank, size, i;
    double PI  = 3.141592653589793238462643;
    double mypi, pi, h, sum, x;
 
    MPI::Init(argc, argv);
    size = MPI::COMM_WORLD.Get_size();
    rank = MPI::COMM_WORLD.Get_rank();
 
    while (1) {
        if (rank == 0) {
            cout << "Enter n (or an integer < 1 to exit) :" << endl;
            cin >> n;
        }
 
        MPI::COMM_WORLD.Bcast(...);
        if (n<1) {
            break;
        } else {
            h = 1.0 / (double) n;
            sum = 0.0;
            for (i = rank + 1; i <= n; i += size) {
                x = h * ((double)i - 0.5);
                sum += (4.0 / (1.0 + x*x));
            }
            mypi = h * sum;
 
            MPI::COMM_WORLD.Reduce(...);
            if (rank == 0){
                cout << "pi is approximated by " << pi
                     << ", the error is " << fabs(pi - PI) << endl;
            }
        }
    }
    MPI::Finalize();
    return 0;
}
