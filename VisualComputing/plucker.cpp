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
// File: plucker.cpp
// 
// Description: Manipulating Plucker coordinates for line/point incidence,
// line/line intersection tests, etc. 
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream.h>
#include <math.h>


//using namespace std;

// Inhomogeneous coordinates
class Point3D{public: double x,y,z;

Point3D()
{x=y=z=0.0;}

Point3D(double xx, double yy, double zz)
{x=xx;y=yy;z=zz;}

friend ostream & operator << (ostream & os, const Point3D p)
{
	os<<"["<<p.x<<","<<p.y<<","<<p.z<<"]";
return os;
}
};

class Plucker{
public: double c[6];


Plucker::Plucker(Point3D p1, Point3D p2)
{
c[0]=p2.x-p1.x;
c[1]=p2.y-p1.y;
c[2]=p2.z-p1.z;
c[3]=p1.y*p2.z-p1.z*p2.y;
c[4]=p2.x*p1.z-p1.x*p2.z;
c[5]=p1.x*p2.y-p2.x*p1.y;
}




friend ostream & operator << (ostream & os, const Plucker l)
{
	os<<"Plucker Line:["<< l.c[0] <<"," << l.c[1] <<","<<l.c[2]<<","<<l.c[3]<<","<<l.c[4]<<","<<l.c[5]<<"]";
return os;
}


}; // Homogeneous coordinates

double PluckerDotProduct(Plucker l1, Plucker l2)
{
double s=0;

for(int i=0;i<6;i++)
	s+=l1.c[i]*l2.c[(3+i)%6];

return s;
}


// The same primitive rewritten differently
double PluckerLineIntersect(Plucker l1, Plucker l2)
{
double s;

s=l1.c[0]*l2.c[3]+l2.c[0]*l1.c[3] +\
l1.c[1]*l2.c[4]+l2.c[1]*l1.c[4]+\
l1.c[2]*l2.c[5]+l2.c[2]*l1.c[5];

return s;
}


double PluckerPointOnLine(Plucker l, Point3D p)
{
double rx, ry, rz, rw;

rx=l.c[3]*p.x+l.c[4]*p.y+l.c[5]*p.z;
ry=-l.c[2]*p.y+l.c[1]*p.z+l.c[3];
rz=-l.c[2]*p.x+l.c[0]*p.z-l.c[4];
rw=-l.c[1]*p.x+l.c[0]*p.y+l.c[5];

//cout<<rx<<" "<<ry<< " "<<rz<<" "<<rw<<" "<<endl;
return fabs(rx)+fabs(ry)+fabs(rz)+fabs(rw);
}


inline double drand() {return rand()/(double)RAND_MAX;}

int _tmain(int argc, _TCHAR* argv[])
{
srand(2555);

Point3D p(drand(),drand(),drand()), q(drand(),drand(),drand()),r, s(drand(),drand(),drand());
double lambda=0.2;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;



r.x=p.x*lambda+(1-lambda)*q.x;
r.y=p.y*lambda+(1-lambda)*q.y;
r.z=p.z*lambda+(1-lambda)*q.z;



// If you replace r by this code, it is highly likely not to intersect anymore 
//r=Point3D(drand(),drand(),drand());


Plucker l1(p,q), l2(r,s);

cout<<"Plucker coordinates demo.\n\n"<<endl;


cout<<"Build the line passing through point P="<<p<<" and Q="<<q<<endl;
cout<<"Plucker coordinates of the line: L1="<<l1<<endl;

cout<<"\n\nBuild the line passing through point R="<<r<<" and S="<<s<<endl;
cout<<"Plucker coordinates of the line:"<<l2<<endl;

cout<<"Those lines should be contained in a same plane."<<endl;
cout<<"The dot product of the corresponding Plucker vectors are:"<<PluckerDotProduct(l1,l2)<<endl;
cout<<"It should be exactly zero if there were no numerical imprecisions"<<endl;


cout<<"\n\nLines L1 and L2 should intersect:"<<PluckerLineIntersect(l1,l2)<<endl;
cout<<"It should be exactly zero if there were no numerical imprecisions"<<endl;


cout<<"\n\nCheck that point R is on line L1:"<<PluckerPointOnLine(l1,r)<<endl;
cout<<"It should be exactly zero if there were no numerical imprecisions"<<endl;


cout<<"\n\nPress Return to exit."<<endl;
char line[256];
gets(line);

	return 0;
}

