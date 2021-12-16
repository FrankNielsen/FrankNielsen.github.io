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
// File: casting.cpp
// 
// Description: Convert Euclidean/projective points via C++ casting
// ------------------------------------------------------------------------

#include "stdafx.h"
using namespace std;

struct ProjectivePoint;
struct EuclideanPoint;

struct ProjectivePoint {
  double x,y,w;
  ProjectivePoint() {}
  ProjectivePoint(double a, double b, double c = 1.0) : x(a), y(b), w(c) {}
  explicit ProjectivePoint(EuclideanPoint const& p);
  ProjectivePoint& operator=(EuclideanPoint const& p);
};

struct EuclideanPoint{
  double x,y;
  EuclideanPoint() {}
  EuclideanPoint(double a, double b) : x(a), y(b)  {}
  explicit EuclideanPoint(ProjectivePoint const& p);
  EuclideanPoint& operator=(ProjectivePoint const& p);
};

ProjectivePoint&
ProjectivePoint::operator=(EuclideanPoint const& p) 
	{ x = p.x; y = p.y; w = 1.0; return *this; }
	
ProjectivePoint::ProjectivePoint(EuclideanPoint const& p) : x(p.x), y(p.y), w(1.0) 
	{}

EuclideanPoint&
EuclideanPoint::operator=(ProjectivePoint const& p) 
	{ x = p.x/p.w; y = p.y/p.w; return *this; }
	
EuclideanPoint::EuclideanPoint(ProjectivePoint const& p) : x(p.x/p.w), y(p.y/p.w) 
	{}


void PrintEuclideanPoint(EuclideanPoint e)
{
cout<<"["<<e.x<<","<<e.y<<"]"<<endl;
}


void PrintProjectivePoint(ProjectivePoint p)
{
cout<<"["<<p.x<<","<<p.y<<","<<p.w<<"]"<<endl;
}



int _tmain(int argc, _TCHAR* argv[])
{
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout <<"Casting projective/Euclidean points....\n";
EuclideanPoint P=EuclideanPoint(3,2);
ProjectivePoint Q,Q1(1,1,2);

Q=P;

cout << "Euclidean Point "; PrintEuclideanPoint(P);
cout << " is casted to Projective Point " ; PrintProjectivePoint(Q);
cout <<endl;

cout << "Projective Point "; PrintProjectivePoint(Q1);
cout << " is casted to Euclidean Point "; PrintEuclideanPoint((EuclideanPoint)Q1);
cout << endl;

cout<<"Press Return key"<<endl;
char line[100];
gets(line);

return 0;
}

