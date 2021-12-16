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
// File: discreteconvolution.cpp
// 
// Description: A simple program to perform a discrete convolution on images.
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;

void SaveImagePPM(unsigned char * data, int w, int h, char * file);
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h);

char filenameinput[]="convolution-input.ppm";
char filenameoutput[]="convolution-result.ppm";

class filter {public:
int d;
double **array;

filter(int dim)
{d=dim;
array=new double *[d];
for(int i=0;i<d;i++) array[i]=new double[d];
}

void normalize(double n)
{int i,j;

if (n==0.0){
for(i=0;i<d;i++)
for(j=0;j<d;j++)
	n+=array[i][j];
}

n=1.0/n;

for(i=0;i<d;i++)
for(j=0;j<d;j++)
	array[i][j]*=n;
}




Write()
{
int i,j;

for(i=0;i<d;i++)
{
	printf("\n");
	for(j=0;j<d;j++)
{
printf("%lf\t",array[i][j]);
}}
printf("\n");
}


};


void DiscreteConvolution(unsigned char * imgs, int w, int h, unsigned char * imgr, filter * F)
{
int i,j,k,l,band;
int s,index;
double accum;

s=(F->d-1)/2;

for(band=0;band<3;band++) //RGB
{
	// for all pixels
for(i=0;i<h;i++)
	for(j=0;j<w;j++)
	{
		accum=0.0; index=-1;
		// convolve
	for(k=-s;k<=s;k++)
		for(l=-s;l<=s;l++)
		{
		if ((i+k>=0)&&(i+k<h)&&(j+l>=0)&&(j+l<w))
		{
		index=3*((i+k)*w+j+l);
		accum += (F->array[k+s][l+s]*imgs[index+band]);
		}

		index=3*(i*w+j);
		
		// clamping
		if (accum<0) accum=0.0; 
		if (accum>255) accum=255.0;
		imgr[index+band]=(unsigned char)accum;
		
		}
	}
}
}

//
// discrete convolution test program
//
int _tmain(int argc, _TCHAR* argv[])
{
int w,h;
unsigned char *imgsource, * imgresult;
filter *kernel;



cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"Convolving an input image with a kernel."<<endl;


// Laplacian kernel
kernel=new filter(3);
kernel->array[0][0]=0;
kernel->array[0][1]=-1;
kernel->array[0][2]=0;

kernel->array[1][0]=-1;
kernel->array[1][1]=4;
kernel->array[1][2]=-1;

kernel->array[2][0]=0;
kernel->array[2][1]=-1;
kernel->array[2][2]=0;



// Identity kernel
/*
kernel=new filter(3);
kernel->array[0][0]=0;kernel->array[0][1]=0;kernel->array[0][2]=0;
kernel->array[1][0]=0;kernel->array[1][1]=1;kernel->array[1][2]=0;
kernel->array[2][0]=0;kernel->array[2][1]=0;kernel->array[2][2]=0;
*/


imgsource=LoadImagePPM(filenameinput,w,h);

imgresult=new unsigned char [3*w*h];
DiscreteConvolution(imgsource,w,h,imgresult, kernel);

SaveImagePPM(imgresult,w,h,filenameoutput);

delete [] imgresult;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);


	return 0;
}

// Save a PPM Image
void SaveImagePPM(unsigned char * data, int w, int h, char * file)
{
	ofstream OUT(file, ios::binary);
	if (OUT){
    OUT << "P6" << endl << w << ' ' << h << endl << 255 << endl;
	OUT.write((char *)data, 3*w*h);
	OUT.close();}
}

// Load a PPM Image that does not contain comments.
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h)
{
	 char dummy1=0, dummy2=0; int maxc;
	unsigned char * img;
	ifstream IN(ifile, ios::binary);

	IN.get(dummy1);IN.get(dummy2);
	if ((dummy1!='P')&&(dummy2!='6')) {cerr<<"Not P6 PPM file"<<endl; return NULL;}
 
    IN >> w >> h;
    IN >> maxc;
    IN.get(dummy1);
	
    img=new  unsigned char[3*w*h];
	IN.read((char *)img, 3*w*h); 
	IN.close();
	return img;
}