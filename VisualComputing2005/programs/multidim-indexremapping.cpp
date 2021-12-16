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
// File: multidim-indexremapping.cpp
// 
// Description: Conversions between 1D and dD array indices of arrays.
// ------------------------------------------------------------------------

#include "stdafx.h"

using namespace std;

// Array dimensions

const int d1=12, d2=21, d3=8, d4=30;
int D1,D2,D3,D4;

int marray[d4][d3][d2][d1];

void Error();

void FillArray()
{
int i1, i2, i3, i4;

for(i4=0;i4<d4;i4++)
	for(i3=0;i3<d3;i3++)
	for(i2=0;i2<d2;i2++)
	for(i1=0;i1<d1;i1++)
		marray[i4][i3][i2][i1]=rand();
}

int _tmain(int argc, _TCHAR* argv[])
{
int *larray=(int*)&marray[0][0][0][0];
int k,k1,k2,k3,k4,n,el1,el2;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Index remapping demo for arrays.\n\n"<<endl;

srand(2005);

FillArray();

D1=1;
D2=d1*D1;
D3=d2*D2;
D4=d3*D3;
n=d4*D4;

cout<<"Number of elements:"<<n<<endl;

for(int nbtest=0;nbtest<100;nbtest++)
{
k1=rand()%d1;
k2=rand()%d2;
k3=rand()%d3;
k4=rand()%d4;

cout<<"Multidimensional index to linear index mapping:"<<endl;

cout<<"\tMulti-dimensional array["<<k4<<"]"<<"["<<k3<<"]["<<k2<<"]["<<k1<<"]="<<marray[k4][k3][k2][k1]<<endl;
k=k4*D4+k3*D3+k2*D2+k1*D1;
cout<<"\tLinear array["<<k<<"]="<<larray[k]<<endl;

el1=marray[k4][k3][k2][k1];
el2=larray[k];
if (el1!=el2) {Error();break;}

cout<<"\nLinear index to multidimensional index mapping:"<<endl;
k=rand()%n;
cout<<"\tLinear array["<<k<<"]="<<larray[k]<<endl;
el2=larray[k];

k4=k/D4;
k=k-k4*D4; 


k3=k/D3;
k=k-k3*D3;


k2=k/D2;
k=k-k2*D2;


k1=k;
cout<<"\tMulti-dimensional array["<<k4<<"]"<<"["<<k3<<"]["<<k2<<"]["<<k1<<"]="<<marray[k4][k3][k2][k1]<<endl;
cout<<"-------------------------------------------\n\n\n";

el1=marray[k4][k3][k2][k1];


if (el1!=el2) {Error();break;}
}

char line[256];
cout<<"Press Return key"<<endl;
gets(line);

return 0;
}

void Error()
{
cout<<"Should not happen. There is an error here!"<<endl;
}