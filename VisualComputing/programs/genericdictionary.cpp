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
// File: genericdictionary.cpp
// 
// Description: sample program that shows the use of a templated dictionary
// ------------------------------------------------------------------------

#include "stdafx.h"

using namespace std;

class point {
public:
double x,y;
};

class segment {
public:
point A,B;
};


class Yline {
public:
static double x;

double a,b; // equation of nonvertical line y=ax+b


// Overloading
bool operator <  ( const Yline &  rhs)
{
	cout <<"\n\t\tGeneric dictionary (inferior): "<<x<<endl;
	cout <<"\t\t"<<a*x+b<<"<"<<rhs.a*x+b<<"?"<<endl;

	return (a*x+b<rhs.a*x+rhs.b);}

};

double Yline::x;

// Line equation + segment number
void SegmentToYevent(segment S,  Yline& eventp)
{
	eventp.a=(S.B.y-S.A.y)/(S.B.x-S.A.x); //slope
	eventp.b=S.A.y-eventp.a*S.A.x; // y=ax+b
}

int _tmain(int argc, _TCHAR* argv[])
{
segment seg1, seg2;
Yline lseg1, lseg2;
	
	srand(2005);

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


seg1.A.x=0;seg1.A.y=0;
seg1.B.x=1.0;seg1.B.y=1.0;

seg2.A.x=0;seg2.A.y=1;
seg2.B.x=1.0;seg2.B.y=0.0;

SegmentToYevent(seg1,lseg1);
SegmentToYevent(seg2,lseg2);

cout<<"I created two line segments (diagonals of the unit square)."<<endl;
cout<<"The associated line equations are:"<<endl;
cout<<"lseg1: y="<<lseg1.a<<"x+"<<lseg1.b<<"=0."<<endl;
cout<<"lseg2: y="<<lseg2.a<<"x+"<<lseg2.b<<"=0."<<endl;

Yline::x=0.25;

if (lseg1<lseg2) cout<<"segment 1 is below segment 2";
				else
				cout<<"segment 1 is above segment 2";

Yline::x=0.75;

if (lseg1<lseg2) cout<<"segment 1 is below segment 2";
				else
				 cout<<"segment 1 is above segment 2";



cout<<"\n\nPress Return key"<<endl;
char line[100];
gets(line);

	return 0;
}

