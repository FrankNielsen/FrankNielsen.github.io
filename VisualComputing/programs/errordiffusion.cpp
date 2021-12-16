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
// File: errordiffusion.cpp
// 
// Description: Halftoning and dithering (error diffusion of Floyd-Steinberg)
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;

void SaveImagePPM(unsigned char * data, int w, int h, char * file);
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h);

char filenameinput[]="lena.ppm";
char filenamethreshold[]="binary-threshold.ppm";
char filenamerandomthreshold[]="binary-randomthreshold.ppm";
char filenameerrordiffusion[]="binary-diffusion.ppm";
char filenamedither[]="tone-dither.ppm";



int _tmain(int argc, _TCHAR* argv[])
{
unsigned char * img, * imgd; 
int x,y,index;
int w,h;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Halftoning and dithering demos."<<endl;


img=LoadImagePPM(filenameinput,w,h);

imgd=new unsigned char [3*w*h];


// Constant threshold
for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	index=3*(x+y*w);

	if (img[index]>127)
	{
	imgd[index]  =255;
	imgd[index+1]=255;
	imgd[index+2]=255;
	}
	else
	{
	imgd[index]  =0;
	imgd[index+1]=0;
	imgd[index+2]=0;

	}
}

SaveImagePPM(imgd,w,h,filenamethreshold);

srand(2004);

// Constant threshold
for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	index=3*(x+y*w);

	if (img[index]> (rand()%127))
	{
	imgd[index]  =255;
	imgd[index+1]=255;
	imgd[index+2]=255;
	}
	else
	{
	imgd[index]  =0;
	imgd[index+1]=0;
	imgd[index+2]=0;

	}
}

	SaveImagePPM(imgd,w,h,filenamerandomthreshold);

// Error diffusion
unsigned char error;
float delta;

for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	index=3*(x+y*w);

	if (img[index]> (rand()%127))
	{
	imgd[index]  =255;
	imgd[index+1]=255;
	imgd[index+2]=255;
	error=255-img[index];
	}
	else
	{
	imgd[index]  =0;
	imgd[index+1]=0;
	imgd[index+2]=0;
	error=-img[index];
	}
	if ((y<h-1)&&(x<w-1)&&(x>0))
	{
	// Now diffuse the error
	delta=img[index+1]+error*7.0/16.0;
	if (delta<0) img[index+1]=0;
	if (delta>255) img[index+1]=255; else img[index+1]=(unsigned char)delta;

	index=3*(x-1+(y+1)+w);
	delta=img[index]+error*3.0/16.0;
	if (delta<0) img[index]=0;
	if (delta>255) img[index]=255; else img[index]=(unsigned char)delta;

	index=3*(x+(y+1)+w);
	delta=img[index]+error*5.0/16.0;
	if (delta<0) img[index]=0;
	if (delta>255) img[index]=255; else img[index]=(unsigned char)delta;


	}
}

SaveImagePPM(imgd,w,h,filenameerrordiffusion);

unsigned char dithercell[2][2]={{48,144}, {192, 96}};

// Dithering
//
for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	index=3*(x+y*w);

	if (img[index]> dithercell[y%2][x%2])
	{
	imgd[index]  =255;
	imgd[index+1]=255;
	imgd[index+2]=255;
	}
	else
	{
	imgd[index]  =0;
	imgd[index+1]=0;
	imgd[index+2]=0;

	}
}

	SaveImagePPM(imgd,w,h,filenamedither);

delete [] img;


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