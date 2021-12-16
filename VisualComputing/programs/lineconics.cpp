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
// File: lineconics.cpp
// 
// Description: Rasterize conics, line conis and dual conics
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;

void SaveImagePPM(unsigned char * data, int w, int h, char * file);

class Vector3D{
public: double x,y,w;


		Vector3D::Vector3D()
		{x=y=0; w=1.0;}

		Vector3D::Vector3D(double px, double py, double pw)
		{
		x=px;
		y=py;
		w=pw;
		}

		inline PerspectiveDivision()
		{
			if (w!=0) {x/=w; y/=w; w=1.0;}
		}
};

class Vector6D{
public: double a,b,c,d,e,f;

		Vector6D::Vector6D(double pa, double pb, double pc, double pd,  double pe, double pf)
		{
		a=pa;
		b=pb;
		c=pc;
		d=pd;
		e=pe;
		f=pf;
		}
};


Vector6D conic(1,0.8,2,-0.5,-0.3,-0.5);

typedef double matrix3x3[3][3];

void InverseMatrix(matrix3x3 m,matrix3x3& minv)
{
  double t4  = m[0][0] * m[1][1];
  double t6  = m[0][0] * m[1][2];
  double t8  = m[0][1] * m[1][0];
  double t10 = m[0][2] * m[1][0];
  double t12 = m[0][1] * m[2][0];
  double t14 = m[0][2] * m[2][0];
  double t17 = 1.0 / ( t4 * m[2][2] - t6  * m[2][1] - t8  * m[2][2] + 
		      t10 * m[2][1] + t12 * m[1][2] - t14 * m[1][1]);

  minv[0][0] =  (m[1][1] * m[2][2] - m[1][2] * m[2][1]) * t17;
  minv[0][1] = -(m[0][1] * m[2][2] - m[0][2] * m[2][1]) * t17;
  minv[0][2] =  (m[0][1] * m[1][2] - m[0][2] * m[1][1]) * t17;
  minv[1][0] = -(m[1][0] * m[2][2] - m[1][2] * m[2][0]) * t17;
  minv[1][1] =  (m[0][0] * m[2][2] - t14) * t17;
  minv[1][2] = -(t6 - t10) * t17;
  minv[2][0] =  (m[1][0] * m[2][1] - m[1][1] * m[2][0]) * t17;
  minv[2][1] = -(m[0][0] * m[2][1] - t12) * t17;
  minv[2][2] =  (t4 - t8) * t17;
}


void ConicToMatrix(Vector6D C,matrix3x3 &m)
{
m[0][0]=C.a;m[0][1]=0.5*C.b;m[0][2]=0.5*C.d;
m[1][0]=0.5*C.b;m[1][1]=C.c;m[1][2]=0.5*C.e;
m[2][0]=0.5*C.d;m[2][1]=0.5*C.e;m[2][2]=C.f;
}


void MatrixToConic(matrix3x3 m, Vector6D& C)
{
C.a=m[0][0];
C.b=2*m[0][1];
C.c=m[1][1];
C.d=2*m[0][2];
C.e=2*m[1][2];
C.f=m[2][2];
}

#define W 1024	
#define H 1024

double thick=4.0/(double)W;

double minx=-1.0;
double maxx=1.3;

double miny=-1.0;
double maxy=1.3;


inline double ToX(double x)
{
return minx+(maxx-minx)*x/(double)W;
}


inline double  ToY(double y)
{
return miny+(maxy-miny)*y/(double)H;
}

inline double Circle(Vector3D p)
{
return p.x*p.x+p.y*p.y-0.5*0.5;
}

inline double ConicFunction(Vector6D C, Vector3D p)
{double res;

res= C.a*p.x*p.x+C.b*p.x*p.y+C.c*p.y*p.y+C.d*p.x*p.w+C.e*p.y*p.w+C.f*p.w*p.w;

return res;
}

// dot product
inline double LineFunction(Vector3D l, Vector3D p)
{
return l.x*p.x+l.y*p.y+l.w*p.w;
}

char filename[256]="draw.ppm";
unsigned char * img;


// Draw a line
void DrawLine(Vector3D l, double th)
{
int i,j,index;

for(i=0;i<H;i++)
	for(j=0;j<W;j++)
	{
	Vector3D point(ToX(j),ToY(i),1);
	index=3*(i*W+j);


	if (fabs(LineFunction(l,point))<th) 
		{	
			img[index]=img[index+1]=img[index+2]=0;
		}
	}
}

int _tmain(int argc, _TCHAR* argv[])
{
int i,j,index;
Vector3D p;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


img=new unsigned char [3*W*H];

for(i=0;i<H;i++)
	for(j=0;j<W;j++)
	{
		index=3*(i*W+j);img[index]=img[index+1]=img[index+2]=255;
	}


	static first=false;
	matrix3x3 m,minv;

	
	//inverse conic

	ConicToMatrix(conic, m);
	InverseMatrix(m,minv);
	MatrixToConic(minv,conic);

	cout<<"Conics coefficients:"<<endl;
	cout<<conic.a<<" "<<conic.b<<" "<<conic.c<<" "<<conic.d<<" "<<conic.e<<" "<<conic.f<<endl;

minx=3*minx;maxx=3*maxx;miny=3*miny;maxy=3*maxy;
thick=3*thick;


cout<<"Be patient this takes a while..."<<endl;

for(i=0;i<H;i++)
{
	if ((i%100)==0) {cout<<100.0*i/(double)H<<"% done..."<<endl;}
	for(j=0;j<W;j++)
	{
	Vector3D point(ToX(j),ToY(i),1);
	index=3*(i*W+j);

	
	
if (fabs(ConicFunction(conic,point))<3*thick) 
		{
			// Point on the conic
			img[index]=img[index+1]=img[index+2]=0;

			point.PerspectiveDivision();

		// p=Cx
		p.x=conic.a*point.x+0.5*conic.b*point.y+0.5*conic.d*point.w;
		p.y=0.5*conic.b*point.x+conic.c*point.y+0.5*conic.e*point.w;
		p.w=0.5*conic.d*point.x+0.5*conic.e*point.y+conic.f*point.w;

		//if (!first){first=true;
		if (rand()%50==0)
			DrawLine(p, thick/2.0);
		//}		
		}
		
	}
	}

SaveImagePPM(img,W,H,filename);


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
