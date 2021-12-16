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
// File: Fibonacci.cpp
// 
// Description: Compute the first elements of Fibonacci series 
// with or without pointer arithmetic
// ------------------------------------------------------------------------

#include "stdafx.h"
#define N 10

using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{
// Compute the first N elements of Fibonacci series 
int Fibonacci[N], *F, i; 

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Compute the Fibonacci numbers.\n"<<endl;

Fibonacci[0]=0;
Fibonacci[1]=1;

for(i=2;i<N;i++) 
	{Fibonacci[i]=Fibonacci[i-2]+Fibonacci[i-1];}

cout<<"Without pointer arithmetic:"<<endl;
for(i=0;i<N;++i)
	cout <<"F("<<i<<")="<<Fibonacci[i]<<endl;


cout<<"With pointer arithmetic:"<<endl;

F=Fibonacci; // or equivalently F=&Fibonacci[0];
(*F)=0;F++;
(*F)=1;F++;

for(i=2;i<N;i++) 
	{
	(*F)=(*(F-2))+(*(F-1));
	F++;
	}

F=Fibonacci;
for(i=0;i<N;++i,F++)
	cout <<"F("<<i<<")="<<(*F)<<endl;


cout<<"Press Return key"<<endl;
char line[100];
gets(line);

	return 0;
}

