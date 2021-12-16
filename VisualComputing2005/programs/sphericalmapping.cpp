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
// File: sphericalmapping.cpp
// 
// Description: Map a Cartesian image to a theta phi spherical image
// (provide field of view)
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream.h>
#include <math.h>


#define max(a,b) ((a)>(b) ? (a) : (b))
#define min(a,b) ((a)>(b) ? (b) : (a))
#define max2(a,b) ((a)>(b) ? (a) : (b))
#define min2(a,b) ((a)>(b) ? (b) : (a))
#define max4(a,b,c,d) max2(max2(a,b),max2(c,d))
#define min4(a,b,c,d) min2(min2(a,b),min2(c,d))

#define M_PI 3.1415926

inline void Cartesian2Spherical(double X, double Y, double Z, double &theta, double &phi)
{
theta=atan2(X,Z);
phi=atan2(Y,sqrt(X*X+Z*Z));
}

void ImgSphere(unsigned char* img, unsigned char * res, int w, int h, double focal)
{

int i,j;
double theta, phi;
int x,y,cx,cy;
unsigned char r,g,b;
double theta1, phi1, theta2, phi2,theta3, phi3,theta4, phi4;
double mp,mt,Mt,Mp;
int index,indeximg;
double X,Y,P,T;

cx=w/2;
cy=h/2;

Cartesian2Spherical((double)(-cx),(double)(0.0),focal, theta1, phi1);
Cartesian2Spherical((double)(cx),(double)(0.0),focal,  theta2, phi2);
Cartesian2Spherical((double)(0.0),(double)(cy),focal, theta3, phi3);
Cartesian2Spherical((double)(0.0),(double)(-cy),focal, theta4, phi4);

mp=min4(phi1, phi2, phi3, phi4);
Mp=max4(phi1, phi2, phi3, phi4);
mt=min4(theta1,theta2,theta3,theta4);
Mt=max4(theta1,theta2,theta3,theta4);

cerr <<"Phi min:"<<mp*180.0/M_PI<<" max:"<<Mp*180.0/M_PI<<endl;
cerr <<"Theta min:"<<mt*180.0/M_PI<<" max:"<<Mt*180.0/M_PI<<endl;



for(i=0;i<h;i++){
  for(j=0;j<w;j++)  
    { 
	  index=3*(w*i+j);

      P=mp+((double)i/(double)h)*(Mp-mp);
      T=mt+((double)j/(double)w)*(Mt-mt);
      X=tan(T)*focal;
      Y=tan(P)*sqrt((X*X+(focal)*(focal)));
      x=cx+(int)X;
	  y=cy+(int)Y;

	  indeximg=3*(w*y+x);

      if ((0<=x)&&(x<w)&&(0<=y)&&(y<h)) 
		{	res[index++]=img[indeximg++];
			res[index++]=img[indeximg++];
			res[index++]=img[indeximg++];}
	  
	  else{
		  res[index++]=0;
		  res[index++]=0;
		  res[index++]=0;
	  }

      }
	}

}


unsigned char * LoadImagePPM(char *ifile,  int &w, int &h);
void SaveImagePPM(unsigned char * data, int w, int h, char * file);


int _tmain(int argc, _TCHAR* argv[])
{
	unsigned char * imgin, * imgout;
	int w,h;
	double focal,fov;


	
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

	
	cout <<"Spherical coordinates. Create a spherical image from a camera image."<<endl;


	imgin=LoadImagePPM("normal120deg.ppm",w,h);
	imgout=new unsigned char [3*w*h];

	fov=120.0*(180.0/M_PI);focal=w/(2.0*tan(fov/2.0));
	cout <<"focal length in pixels:"<<focal<<endl;

	ImgSphere(imgin, imgout, w,h,focal);
	SaveImagePPM(imgout, w,h, "sphericalimage.ppm");

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
