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
// File: logpolartransform.cpp
// 
// Description: Compute the log polar transformation of a source image
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>
#include <math.h>
using namespace std;

#define max2(a,b) ((a)>(b) ? (a) : (b))
#define min2(a,b) ((a)>(b) ? (b) : (a))
#define max4(a,b,c,d) max2(max2(a,b),max2(c,d))
#define min4(a,b,c,d) min2(min2(a,b),min2(c,d))


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


// XY <-> Log-Theta conversions

inline double rp(int x,int y,int px,int py)
{
return log( sqrt( ((double)((px-x)*(px-x)+(py-y)*(py-y))) ) );
}


inline double theta(int x,int y,int px,int py)
{
return atan2((double)(py-y),(double)(px-x));
}

inline int x(double r,double t,int px)
{
return (int)floor((double)(px+exp(r)*cos(t)));
}

inline int y(double r,double t,int py)
{
return (int)floor((double)(py+exp(r)*sin(t)));
}


#define M_PI 3.14159265

int _tmain(int argc, _TCHAR* argv[])
{
char* inputfile, *outputfile;
unsigned char * imagein, *imageout;
int w,h,index,indexs;

int px,py,i,j;
int pixelx,pixely;
int op=1;

double rxy,rxY,rXy,rXY,rmin,rmax,r;
double tmin,tmax,t;

char filenamein[]="cambridge512.ppm";



cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


 cout<<">Log-polar image converter utility program."<<endl;

    imagein=LoadImagePPM(filenamein,w,h);
	
 px=w/2.0;
 py=h/2.0;
 tmin=-1.0*M_PI;
 tmax=1.0*M_PI; 
 rmax=rmin=0.0;

    imageout=new unsigned char [3*w*h];
  

  // Polar transform. Compute bounding box for parameters
  // and then proceed by the inverse mapping


if (rmax==0.0)
    {
rxy=rp(0,py,px,py);
rXy=rp(w-1,py,px,py);
rxY=rp(px,h-1,px,py);
rXY=rp(px,0,px,py);
rmax=max4(rxy,rXy,rxY,rXY);
    }


// inverse mapping
for(i=0;i<h;i++)
for(j=0;j<w;j++)
  {

    if ((i==0)&&(j==0)) continue; // singularity

t=tmin+(tmax-tmin)*j/(double)(w);
r=rmin+(rmax-rmin)*i/(double)(h);

pixelx=x(r,t,px);
pixely=y(r,t,py);

index=3*(j+w*i);
indexs=3*(pixelx+pixely*w);

if ((pixelx>=0)&&(pixelx<w)&&(pixely>=0)&&(pixely<h)) 
{
imageout[index]=imagein[indexs];
imageout[index+1]=imagein[indexs+1];
imageout[index+2]=imagein[indexs+2];
}
else 
{imageout[index]=0; //Black
imageout[index+1]=0;
imageout[index+2]=0;
}

  }

SaveImagePPM(imageout,w,h,"logpolar.ppm");

delete [] imagein;
delete [] imageout;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);

	return 0;
}

