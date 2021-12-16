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
// File: MiniBall.cpp
// 
// Description: Randomized Recursive Incremental Construction of the Smallest
// Enclosing Ball of a Set of 2D Points.
// ------------------------------------------------------------------------


// Miniball: this is a pedagogical implementation. 
// For efficient implementation, rather update the enclosing balls and consider square radii

#include "stdafx.h"
#include <math.h>

using namespace std;

typedef  long double number;

class point {
public: 
number x,y;

inline number Distance(point q)
{return sqrt((q.x-x)*(q.x-x) + (q.y-y)*(q.y-y));}
};

class disc{
public: 
point circumcenter;
number radius;
};

inline double drand(){return (double) rand () / RAND_MAX ;}

inline SwapPoint(point& a, point& b)
{point tmp; tmp=a; a=b; b=tmp;}

// The unique circle passing through exactly three non-collinear points  p1, p2 ,p3
void SolveDisc3(point p1, point p2, point p3, point & center, number &rad)
{
number a = p2.x - p1.x;
number b = p2.y - p1.y;
number c = p3.x - p1.x;
number d = p3.y - p1.y;
number e = a*(p2.x + p1.x)*0.5 + b*(p2.y + p1.y)*0.5;
number f = (c*(p3.x + p1.x)*0.5) + (d*(p3.y + p1.y)*0.5);
number det = a*d - b*c;    

center.x = (d*e - b*f)/det;   
center.y = (-c*e + a*f)/det;

rad =p1.Distance(center);
}

// The smallest circle passing through two points
void SolveDisc2(point p1, point p2, point & center, number &rad)
{
center.x = 0.5*(p1.x+p2.x);   
center.y = 0.5*(p1.y+p2.y);

rad =p1.Distance(center);
}



void MiniDisc(point* set, int n, point* basis, int b, point& center, number& rad)
{
point cl; number rl;
int k;

// Terminal cases
if (b==3)  SolveDisc3(basis[0], basis[1], basis[2], cl, rl);

if ((n==1)&&(b==0)) {rl=0.0; cl=set[0];}
if ((n==2)&&(b==0))  SolveDisc2(set[0],set[1], cl, rl); 
if ((n==0)&&(b==2))  SolveDisc2(basis[0],basis[1], cl, rl); 
if ((n==1)&&(b==1))  SolveDisc2(basis[0], set[0], cl, rl); 

// General case
if ((b<3)&&(n+b>2))
	{
	// Randomization: choosing a pivot
	k=rand()%n; // between 0 and n-1
	if (k!=0) SwapPoint(set[0],set[k]);

	MiniDisc(&set[1],n-1,basis,b,cl,rl);

	if (cl.Distance(set[0])>rl)
		{
		// Then set[0] necessarily belongs to the basis.
			basis[b++]=set[0];
			MiniDisc(&set[1],n-1,basis,b,cl,rl);
		}	
	}
	center=cl;rad=rl;
}


// Example
int _tmain(int argc, _TCHAR* argv[])
{
point *set, * basis, center;
int i, b=0;
number rad;
int N=10000;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Compute the smallest enclosing ball of a 2D point set."<<endl;

center.x=center.y=0;rad=0;
set=new point[N];
basis=new point[3];

for(i=0;i<N;i++) {set[i].x=drand();set[i].y=drand(); 
				}


cout <<"Randomized optimization: MiniDisc"<<endl;
MiniDisc(set,N,basis,b, center, rad);

cout <<"Center ("<<center.x<<","<<center.y<<") rad="<<rad<<endl;

delete [] set;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);

	return 0;
}

