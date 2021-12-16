// filename: MPIVolumeUnionSpheres.cpp
// Parallel implementation of the approximation of the volume of a set of spheres
#include <limits>
#include <math.h>
#include <iostream>
#include <stdlib.h>
#include <time.h>
#include "mpi.h"

#define n 8*2
#define d 3
#define e 8*1000

double get_rand(double min, double max) {
	double x = rand() / (double)RAND_MAX;
	
}

double distance2(double p0[d], double p1[d]) {
	double x = 0;
	for (int i = 0; i < d; i++) {
		double diff = p0[i] - p1[i];
		x += diff * diff;
	}
	return x;
}

int main(int argc, char** argv) {
	srand(0); 
	MPI_Init(&argc, &argv);

	int n_proc, rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &n_proc);


	double radius0[n];
	double C0[n][d];
    // Generate data
	if (rank == 0) {
		for (int i = 0; i < n; i++) {
			radius0[i] = get_rand(1, 5);
			for (int j = 0; j < d; j++) C0[i][j] = get_rand(-20, 20);
		}

	}

	// Send data to processes
	double radius[n];
	double C[n][d];
	int begin = n / n_proc*rank;
	int loc_n = n / n_proc;
	MPI_Scatter(radius0, loc_n, MPI_DOUBLE, &(radius[begin]), loc_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Scatter(C0, 3 * loc_n, MPI_DOUBLE, &(C[begin][0]), 3 * loc_n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	double bb[d][2];

	// Compute the bounding box
	for (int i = 0; i < d; i++) {
		bb[i][0] = std::numeric_limits<double>::infinity();
		bb[i][1] = -std::numeric_limits<double>::infinity();

		for (int j = begin; j < begin + loc_n; j++) {
			bb[i][0] = fmin(bb[i][0], C[j][i] - radius[j]);
			bb[i][1] = fmax(bb[i][1], C[j][i] + radius[j]);
		}

		MPI_Reduce(rank ? &(bb[i][0]) : MPI_IN_PLACE, &(bb[i][0]), 1, MPI_DOUBLE, MPI_MIN, 0, MPI_COMM_WORLD);
		MPI_Reduce(rank ? &(bb[i][1]) : MPI_IN_PLACE, &(bb[i][1]), 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
	}

	// Compute the volume of the bounding box

	double volBB = 1;
	for (int i = 0; i < d; i++) volBB *= bb[i][1] - bb[i][0];
	// Draw variates and perform rejection sampling
	double samples[e][3];
	if (rank == 0) {

		for (int i = 0; i < e; i++) {
			for (int j = 0; j < d; j++) samples[i][j] = get_rand(bb[j][0], bb[j][1]);
		}
	}
	MPI_Bcast(samples, 3 * e, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	// Testing variates

	bool hit[e];
	for (int i = 0; i < e; i++) hit[i] = false;
	for (int i = 0; i < e; i++) {
		for (int j = begin; j < begin + loc_n; j++) {
			if (distance2(samples[i], C[j]) < radius[j] * radius[j]) hit[i] = true;
		}
	}

	// Gather results and count the accepted variates

	bool hit0[e];
	for (int i = 0; i < e; i++) hit0[i] = false;

	MPI_Reduce(hit, hit0, e, MPI_C_BOOL, MPI_LOR, 0, MPI_COMM_WORLD);

	if (rank == 0) {
		int ePrime = 0;
		for (int i = 0; i < e; i++) {
			if (hit0[i]) ePrime++;
		}
		double vol = volBB * (double)ePrime / double(e);
		std::cout << vol << std::endl;
		std::cout << ePrime << std::endl;
	}

	MPI_Finalize();
	return 0;
}
