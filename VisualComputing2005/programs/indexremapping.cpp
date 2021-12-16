/ ------------------------------------------------------------------------
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
// File: indexremapping.cpp
// 
// Description:  Conversion between 1D and 2D indices of arrays
// ------------------------------------------------------------------------


#include "stdafx.h"
#define w 23
#define h 71

using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{
int marray[w][h];
int *array;
int i,j,e;
int x,y;
int nbtest=5;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"2D index remapping technique in C++.\n\n"<<endl;

for(i=0;i<h;i++)
	for(j=0;j<w;j++)
		marray[j][i]=rand();

array=(int*)marray;

for(i=0;i<nbtest;i++)
{
e=rand()%(w*h);

x=e/h;
y=(e-x*h);

cout<<"I decompose 1D index number "<<e<<" into the 2D index pair:("<<x<<","<<y<<")."<<endl;
cout<<"Compare 2D marray["<<x<<"]["<<y<<"]="<<marray[x][y]<<" with 1D array["<<e<<"]="<<array[e]<<endl;
cout<<endl;
if (marray[x][y]!=array[e]) cout<<"Error!"<<endl;
}

char line[256];
cout<<"Press Return key"<<endl;
gets(line);
return 0;
}

