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
// File: ransac.cpp
// 
// Description: A purely combinatorial implementation of RANSAC
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <math.h>


using namespace std;


inline double drand()
{
return (double)rand()/(double)RAND_MAX;
}

int _tmain(int argc, _TCHAR* argv[])
{
double failure=0.05;
double alpha=0.5;
int i,n=1000;
int r1,r2;
double k,maxround;
bool *feature,success;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"\nCombinatorial implementation of RANSAC scheme:"<<endl;

srand(23);

feature=new bool[n];
for(i=0;i<n;i++) 
if (drand()>0.5) feature[i]=true; else feature[i]=false;


maxround=log(failure)/log(1-alpha*alpha);

std::cout<<"Simulation of RANSAC"<<endl;
std::cout<<"alpha="<<alpha<<" "<<" failure<"<<failure<<endl;
std::cout<<"Two pairs. #MaxRounds="<<ceil(maxround)<<endl;

cout<<"I will perform 20 rounds of RANSAC now..."<<endl;

for(int trial=0;trial<20;trial++)
{
k=0;success=false;



while(k<maxround)
{
r1=rand()%n;
r2=(rand()%(n-1)+r1)%n;

if ((feature[r1])&&(feature[r2])) {success=true;}
k++;
}

if (success) {std::cout<<"Found a pair of inliers!"<<endl;}
else {std::cout<<"Failed to find a pair of inliers (but probability of failure was:"<<failure<<"!"<<endl;}
}

delete [] feature;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);
	return 0;
}

