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
// File: warping.cpp
// 
// Description: forward and backward image warping
// ------------------------------------------------------------------------

#include "stdafx.h"

#include <fstream>
#include <math.h>

using namespace std;

void SaveImagePPM(unsigned char * data, int w, int h, char * file);
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h);

char filenameinput[]="imagewarping.ppm";
char filenameforward[]="forwardwarping.ppm";
char filenamebackward[]="backwardwarping.ppm";


class Matrix{
public: 
	double array[3][3];
};


void inline MatrixPoint(Matrix H,double x,double y, double &xm, double &ym)
{
double xx,yy,zz;

xx=H.array[0][0]*x+H.array[0][1]*y+H.array[0][2];
yy=H.array[1][0]*x+H.array[1][1]*y+H.array[1][2];
zz=H.array[2][0]*x+H.array[2][1]*y+H.array[2][2];

xm=xx/zz;ym=yy/zz;
}


void InverseMatrix(Matrix M, Matrix &Minv)
{
	
  double t4  = M.array[0][0] * M.array[1][1];
  double t6  = M.array[0][0] * M.array[1][2];
  double t8  = M.array[0][1] * M.array[1][0];
  double t10 = M.array[0][2] * M.array[1][0];
  double t12 = M.array[0][1] * M.array[2][0];
  double t14 = M.array[0][2] * M.array[2][0];
  double t17 = 1.0 / ( t4 * M.array[2][2] - t6  * M.array[2][1] - t8  * M.array[2][2] + 
		      t10 * M.array[2][1] + t12 * M.array[1][2] - t14 * M.array[1][1]);



  Minv.array[0][0] =  (M.array[1][1] * M.array[2][2] - M.array[1][2] * M.array[2][1]) * t17;
  Minv.array[0][1] = -(M.array[0][1] * M.array[2][2] - M.array[0][2] * M.array[2][1]) * t17;
  Minv.array[0][2] =  (M.array[0][1] * M.array[1][2] - M.array[0][2] * M.array[1][1]) * t17;
  Minv.array[1][0] = -(M.array[1][0] * M.array[2][2] - M.array[1][2] * M.array[2][0]) * t17;
  Minv.array[1][1] =  (M.array[0][0] * M.array[2][2] - t14) * t17;
  Minv.array[1][2] = -(t6 - t10) * t17;
  Minv.array[2][0] =  (M.array[1][0] * M.array[2][1] - M.array[1][1] * M.array[2][0]) * t17;
  Minv.array[2][1] = -(M.array[0][0] * M.array[2][1] - t12) * t17;
  Minv.array[2][2] =  (t4 - t8) * t17;

 
}


int _tmain(int argc, _TCHAR* argv[])
{
unsigned char * img, * imgd; 
int indexuv, indexxy;
int w,h;
int u,v,x,y;
double xreal,yreal,ureal,vreal;
Matrix T, Tinv;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"Forward/backward image mapping."<<endl;


T.array[0][0]=1.3; T.array[0][1]=0.0; T.array[0][2]=0.0;
T.array[1][0]=0.2; T.array[1][1]=0.9; T.array[1][2]=0.0;
T.array[2][0]=0.0; T.array[2][1]=0.0; T.array[2][2]=1.0;

InverseMatrix(T,Tinv);

img=LoadImagePPM(filenameinput,w,h);

imgd=new unsigned char [3*w*h];

memset(imgd,255,w*h*3); // background color

// Forward mapping from xy to uv
for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	MatrixPoint(T,x,y,ureal,vreal);
	// Roundings
	u=(int)ureal;v=(int)vreal;

	if ((u>=0)&&(u<w)&&(v>0)&&(v<h))
	{
	indexuv=3*(u+v*w); 
	indexxy=3*(y*w+x);

	imgd[indexuv]  =img[indexxy];
	imgd[indexuv+1]=img[indexxy+1];
	imgd[indexuv+2]=img[indexxy+2];
	}
}

SaveImagePPM(imgd,w,h,filenameforward);
memset(imgd,255,w*h*3); // background color

// Backward mapping from uv to xy
for(u=0;u<w;u++)
	for(v=0;v<h;v++)
	{
	MatrixPoint(Tinv,u,v,xreal,yreal);
	x=(int)xreal;y=(int)yreal;

	if ((x>=0)&&(x<w)&&(y>=0)&&(y<h))
	{
	indexuv=3*(u+v*w); 
	indexxy=3*(y*w+x);

	imgd[indexuv]=img[indexxy];
	imgd[indexuv+1]=img[indexxy+1];
	imgd[indexuv+2]=img[indexxy+2];
	}
}

SaveImagePPM(imgd,w,h,filenamebackward);

char line[256];
cout<<"Press Return key"<<endl;
gets(line);


delete [] imgd;

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