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
// File: matchsegments.cpp
// 
// Description: Compute the scaled rigid transformation in 2D that match a
// pair of segments
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <math.h>

using namespace std;

#define M_PI        3.14159265358979323846 

inline double drand()
{
return rand()/(double)RAND_MAX;
}

typedef double transformation[3][3];

class point2d{public: 
  double x,y,w; // homogeneous coordinates 

  point2d::point2d()
  {x=drand();y=drand();w=1.0;}

  point2d::point2d(double xx, double yy, double ww)
  {x=xx;y=yy;w=ww;}

  point2d Transformation(transformation t)
  {double xp,yp,wp;

  xp=t[0][0]*x+t[0][1]*y+t[0][2]*w;
  yp=t[1][0]*x+t[1][1]*y+t[1][2]*w;
  wp=t[2][0]*x+t[2][1]*y+t[2][2]*w;

  return point2d(xp/wp,yp/wp,1);
  }

 friend ostream& operator << (ostream & os,  point2d p)
  {
	os << "["<<p.x<<","<<p.y<<" "<<"|"<<p.w<<"]";
	return os;
  } 

};




//
// Compute a transformtion
// 
void BaseTransformation(point2d p1,point2d p2,point2d q1,point2d q2,transformation& t)
{
double theta,theta1,theta2,zoom;

zoom=sqrt(((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y))/((q2.x-q1.x)*(q2.x-q1.x)+(q2.y-q1.y)*(q2.y-q1.y)));


theta1=atan(fabs((p2.y-p1.y)/(p2.x-p1.x)));
theta2=atan(fabs((q2.y-q1.y)/(q2.x-q1.x)));
if ((p2.x<p1.x)&&(p2.y<p1.y)) theta1=M_PI+theta1;
if ((p2.x<p1.x)&&(p2.y>=p1.y)) theta1=M_PI-theta1;
if ((p2.x>=p1.x)&&(p2.y<p1.y)) theta1=2.0*M_PI-theta1;
if ((q2.x<q1.x)&&(q2.y<q1.y)) theta2=M_PI+theta2;
if ((q2.x<q1.x)&&(q2.y>=q1.y)) theta2=M_PI-theta2;
if ((q2.x>=q1.x)&&(q2.y<q1.y)) theta2=2.0*M_PI-theta2;
theta=theta2-theta1;
t[0][2]=-p1.x*cos(theta)+p1.y*sin(theta)+q1.x*zoom;
t[1][2]=-p1.x*sin(theta)-p1.y*cos(theta)+q1.y*zoom;
t[0][0]=cos(theta);t[0][1]=-sin(theta);
t[1][0]=sin(theta);t[1][1]=cos(theta);
t[2][0]=t[2][1]=0.0;t[2][2]=zoom;
}



int _tmain(int argc, _TCHAR* argv[])
{
int i,j;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

srand(1234);

point2d p1,p2,q1,q2;
transformation sr;



BaseTransformation(p1,p2,q1,q2,sr);

cout<<"Scaled rigid transformation:"<<endl;
for(i=0;i<3;i++)
{
	for(j=0;j<3;j++)
		cout<<sr[i][j]<<" ";
	cout<<endl;
}

cout<<"\n\nChecking..."<<endl;
cout<<"P1 "<<p1<<" should match to Q1 "<<q1<<" :"<<p1.Transformation(sr)<<endl;

cout<<"P2 "<<p2<<" should match to Q2 "<<q2<<" :"<<p2.Transformation(sr)<<endl;



char line[256];
cout<<"Press Return key"<<endl;
gets(line);
	return 0;
}

