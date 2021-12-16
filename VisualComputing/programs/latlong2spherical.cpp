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
// File: latlong2spherical.cpp
// 
// Description: Environment map conversion procedure using generic functions
// transform xy to theta phi and transform theta phi to xy
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <math.h>
#include <fstream>

using namespace std;

#ifndef M_PI
#define M_PI        3.14159265358979323846  
#endif

#ifndef M_PI_2
#define M_PI_2      1.57079632679489661923  
#endif

inline bool InRangeABX(double a,double b,double x)
{
	if (x<a) return false;
	if (x>b) return false;
	return true;
}


class  Raymap{
public:
int width,height;

Raymap(int w, int h)
{width=w;height=h;}

~Raymap();

virtual int transformXY2TP(double x,double y,double &t, double &p)
{return 0;}

virtual int transformTP2XY(double t,double p,double &x, double &y)
{return 0;}

};

// Equirectangular format
class RaymapLatLong : public Raymap
{
public:
RaymapLatLong(int w,int h): Raymap(w,h) {};

int transformXY2TP(double x,double y,double &t, double &p);
int transformTP2XY(double t,double p,double &x, double &y);
};


int RaymapLatLong::transformXY2TP(double x,double y,double &t, double &p)
{
t=(-M_PI+2.0*M_PI*x/width); // [-PI,PI[
p=(-M_PI / 2.0 + M_PI*y/height); // [-PI/2,PI/2[
return 1;
}

int RaymapLatLong::transformTP2XY(double t,double p,double &x, double &y)
{
while (t<-M_PI) t+=(M_PI*2.0);
while (t>=M_PI) t-=(2.0*M_PI);

if (p>=M_PI_2) return transformTP2XY(t-M_PI,M_PI-p,x,y);
if (p<-M_PI_2) return transformTP2XY(t-M_PI,-(M_PI+p),x,y);

x=width*((t+M_PI)/(2.0*M_PI));//[0,width[
y=height*((p+M_PI/2.0)/M_PI);// [0,height[	
return 1;
}

// Cubic format
class RaymapSphericalBall: public Raymap
{
public:
RaymapSphericalBall(int w,int h): Raymap(w,h) {};

int transformXY2TP(double x,double y,double &t, double &p);
int transformTP2XY(double t,double p,double &x, double &y);
};


int  RaymapSphericalBall::transformXY2TP(double px,double py,double &theta, double &phi)
{
double x = (2.0/(double)width) * double(px) - 1.0 + 0.5/(double)width;
double y = (2.0/(double)height) * double(py) - 1.0 + 0.5/(double)height;
double zsq = 1.0 - x*x - y*y;

      if (zsq<0.0) {
	theta=phi=0.0;
	return 0;
      } else {
	double z = sqrt(zsq);
    double doten,X,Y,Z;

	doten=-z;

	    X=-2.0*doten*x;	
			Y=-2.0*doten*y;
		Z=-1.0-2.0*doten*z;
	
		theta=atan2(X,Z);
		phi=atan2(Y,sqrt(X*X+Z*Z));
	  return 1;
	  }
}

// Not yet implemented
int  RaymapSphericalBall::transformTP2XY(double t,double p,double &x, double &y)
{return -1;}

// Image file I/O
void SaveImagePPM(unsigned char * data, int w, int h, char * file);
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h);

//
// Convert environment maps (nearest neighbor interpolation)
//
void ConvertEnvironmentMap(int ws, int hs, Raymap *raymaps, unsigned char *imgs, int wt, int ht, Raymap *raymapt, unsigned char *imgt)
{
int i,j;
double t,p;
double xs,ys;
int XS,YS;
unsigned char *pixels, *pixelt;

for(i=0;i<ht;i++) 
{	for(j=0;j<wt;j++)
	{	pixelt=&imgt[3*(i*wt+j)];
		if (raymapt->transformXY2TP(j,i,t,p))
		{
			if (raymaps->transformTP2XY(t,p,xs,ys))
			{
			XS=(int)floor(xs);YS=(int)floor(ys);

			if (InRangeABX(0,ws-1,XS) && InRangeABX(0,hs-1,YS)) 
				{
				pixels=&imgs[3*(XS+YS*ws)]; // Nearest neighbor
				*(pixelt++)=*(pixels++);
				*(pixelt++)=*(pixels++);
				*(pixelt++)=*(pixels++);
				}	
			}
		}
		else {*(pixelt++)=255;*(pixelt++)=255;*(pixelt++)=255;} 
	}
}
}



int _tmain(int argc, _TCHAR* argv[])
{
Raymap * latlong, * spherical;
int ws,hs;
int wt=512, ht=512;
unsigned char * imgsource, *imgtarget;

char filenamesource[]="latlong.ppm";
char filenametarget[]="spherical.ppm";

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout <<"Convert Latitude-Longitude to Spherical Map."<<endl;

imgsource=LoadImagePPM(filenamesource,ws,hs);
imgtarget=new unsigned char [3*wt*ht];

latlong=new RaymapLatLong(ws,hs);
spherical=new RaymapSphericalBall(wt,ht);

ConvertEnvironmentMap(ws, hs,latlong, imgsource , wt, ht, spherical, imgtarget);

SaveImagePPM(imgtarget,wt,ht,filenametarget);

delete [] imgsource;
delete [] imgtarget;


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
