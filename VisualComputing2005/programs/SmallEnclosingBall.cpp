// ------------------------------------------------------------------------
// This program is complementary material for the book:
//
// Frank Nielsen
//
// Visual Computing: Geometry, Graphics, and Vision
//
// ISBN: 1-58450-427-7
//
// Charles River Media, Inc.
//
//
// All programs are available at http://www.charlesriver.com/visualcomputing/
//
// You may use this program for ACADEMIC and PERSONAL purposes ONLY. 
//
//
// The use of this program in a commercial product requires EXPLICITLY
// written permission from the author. The author is NOT responsible or 
// liable for damage or loss that may be caused by the use of this program. 
//
// Copyright (c) 2005. Frank Nielsen. All rights reserved.
// ------------------------------------------------------------------------
 
// ------------------------------------------------------------------------
// File: SmallEnclosingBall.cpp
// 
// Description: Approximate the smallest enclosing ball of a high-dimensional
// point set using Badoui and Clarkson's algorithm.
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <math.h>

// dimension
const int d=100;

using namespace std;


inline double drand()
{
return (double)rand()/(double)RAND_MAX;
}

// d-dimensional point set
class PointdD{
public:
	double coord[d];

	double Distance(PointdD p)
	{
		double result=0.0;
		for(int i=0;i<d;i++)
				result+= ((coord[i]-p.coord[i])*(coord[i]-p.coord[i]));
		return sqrt(result);
	}

	void InitializeRandom()
	{
		for(int i=0;i<d;i++) 
				coord[i]=drand();
	}

	// initialize vertex of a cube
	void InitializeCube()
	{
	int setd=rand()%d;
	for(int i=0;i<d;i++) 
				coord[i]=0;
	coord[setd]=1.0;
	}

	void PrintPoint()
	{
	cout<<"[";
	for(int i=0;i<d;i++)  cout<<coord[i]<<" ";
	cout<<"]"<<endl;
	}
};

// Paper is available here:
// http://cm.bell-labs.com/who/clarkson/coresets1.html
void  BadoiuClarsonIteration(PointdD *setcore,  int core, PointdD &center, double &radius, int nbiter)
{
int i,iter,winner;
double distmax,dist;

// choose any point of the set as the initial circumcenter
center=setcore[0];

for(iter=0;iter<nbiter;iter++)
{
	winner=0;
	distmax=center.Distance(setcore[0]);

	// Maximum distance point
	for(i=1;i<core;i++)
		{
		dist=center.Distance(setcore[i]);
		if (dist>distmax) {winner=i;distmax=dist;}
	}
	radius=distmax;
	// Update
	for(i=0;i<d;i++)
	{
	center.coord[i]+=(1.0/(iter+1.0))*(setcore[winner].coord[i]-center.coord[i]);
	}

} // for
}


int _tmain(int argc, _TCHAR* argv[])
{
PointdD *set, center;
int i,n,nb;
double epsilon=0.01,radius;



cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


srand(2005);
   
	n=2*d;

	set=new PointdD[n];

	for(i=0;i<n;i++)
	{
	set[i].InitializeRandom();
	//set[i].InitializeCube();
	}

	cout<<"Implementation of Badoiu-Clarkson algorithm for computing"<<endl;
	cout<<"a small enclosing ball in large dimensions."<<endl;
	cout<<endl;
	cout<<"Create a set of "<<n<<" points in dimension "<<d<<endl;

	nb=(int)ceil(1.0/(epsilon*epsilon));
	cout<<"Epsilon="<<epsilon<<" Nb of iterations:"<<nb<<endl;

	cout<<"Be patient..."<<endl;
	BadoiuClarsonIteration(set,n,center,radius,nb);


	cout<<"The radius r of the ball is:"<<radius<<endl;
	cout<<"r is guaranteed to be less than "<<1+epsilon<<"r*, where r* is the optimal radius"<<endl;
	cout<<"Circumcenter:";
	center.PrintPoint();

	delete [] set;

	
cout<<"Press Return key"<<endl;
char line[256];
gets(line);

	return 0;
}

