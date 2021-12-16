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
// File: heron.cpp
// 
// Description: Simple templated linked list class
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <math.h>

#include <iostream>
using namespace std;


// This example can be calculated robustly using the CORE library
// see http://www.cs.nyu.edu/exact/core/heron/

int _tmain(int argc, _TCHAR* argv[])
{

float a,b,c,heron,s;
double A,B,C, HERON, S;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;



a=10000; b=5000.000001; c=15000;
s=a+b+c;s/=2.0;
heron=s*(s-a)*(s-b)*(s-c);
heron=sqrt(heron);


A=10000; B=5000.000001; C=15000;
S=A+B+C;S/=2.0;
HERON=S*(S-A)*(S-B)*(S-C);
HERON=sqrt(HERON);

cout.precision(10);
cout <<"Heron's formula for computing the area of a triangle:"<<endl;
cout <<"Calculated area using single-precision floating-point numbers:"<<heron<<endl;
cout <<"Calculated area using double-precision floating-point numbers:"<<HERON<<endl;
 

char line[256];
cout<<"Press Return key"<<endl;
gets(line);

	return 0;
}

