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
// File: traits-geometrykernel.cpp
// 
// Description: Compute the convex hull of a 2D point set using Andrew's algorithm.
// The geometric kernel (arithmetic+predicate) is given to a traits class.
// ------------------------------------------------------------------------

// This code has been adapted from an original code of Lutz Kettner 

#include "stdafx.h"
#include <vector>
#include <queue>
#include <algorithm>
#include <windows.h>
#include <GL/gl.h>
#include <GL/glut.h>

#define W 800
#define H 800

// Notice: This code is not robust. See Chapter "Robustness"

using namespace std;


template <class NumberType> class Point2D {
public:
    NumberType x;
    NumberType y;

bool operator <  ( const Point2D<NumberType> & rhs)
{return (x<rhs.x);}

bool operator >  (const Point2D<NumberType> & rhs)
{return (x>rhs.x);}

bool operator ==  (const Point2D<NumberType> & rhs)
{return (x==rhs.x);}

 
};

template <class NumberType> struct ConvexHullTraits
{
    typedef Point2D<NumberType> Point;

    struct Leftturn {
        bool operator()( const Point& p, const Point& q, const Point& r)
		{
			if ((q.x-p.x) * (r.y-p.y) >(r.x-p.x) * (q.y-p.y)) return true;
			else return false;
        }
    };

    Leftturn leftturn() const { return Leftturn(); }
};


template <class BidirectionalIterator, class OutputIterator, class ConvexHullTraits>
OutputIterator 
ConvexHull( BidirectionalIterator first, BidirectionalIterator beyond,
             OutputIterator result, const ConvexHullTraits& traits) {
    typedef typename ConvexHullTraits::Point Point;
    vector<Point> hull;
    hull.push_back( *first); 
    hull.push_back( *first);

	// First compute the  lower convex hull 
    BidirectionalIterator i = first;
    for ( ++i; i != beyond; ++i) {
        while ( traits.leftturn()( hull.end()[-2], *i, hull.back()))
            hull.pop_back();
        hull.push_back( *i);
    }

    // Now compute the upper convex hull 
    i = beyond;
    for ( --i; i != first; ) {
        --i;
        while ( traits.leftturn()( hull.end()[-2], *i, hull.back()))
            hull.pop_back();
        hull.push_back( *i);
    }

    // Finally, get the full convex hull (intersection of lower and upper hulls)
    hull.pop_back();
    hull.front() = hull.back();
    hull.pop_back();
    return copy( hull.begin(), hull.end(), result);
}



#define N 150

Point2D<double> point;
priority_queue<Point2D<double> >  q;
vector<Point2D<double> > set,  result;
ConvexHullTraits<double> MyConvexHullPolicy;


inline double drand()
{
return 0.1+0.8*(rand()/(double)RAND_MAX);
}



void disp( void ) 
{
int i;

glClearColor(1,1,1,1);
glClear(GL_COLOR_BUFFER_BIT);



glColor3f(0,0,1);
glPointSize(2);
glBegin(GL_POINTS);
for(i=0;i<N;i++)
glVertex2f(set[i].x,set[i].y);
glEnd();


glColor3f(1,0,0);
glBegin(GL_LINE_LOOP);
for(i=0;i<result.size();i++)
glVertex2f(result[i].x,result[i].y);
glEnd();


glFlush();
}



void key(unsigned char key , int x , int y) 
{

	set.clear();
	result.clear();


for(int i=0;i<N;i++)
	{
	point.x=drand();
	point.y=drand();
	set.push_back(point);
	}

	sort(set.begin(),set.end());

ConvexHull(set.begin(), set.end(), back_inserter(result), MyConvexHullPolicy);
cout<<"Number of extreme points on the hull:"<<result.size()<<endl;

glutPostRedisplay(); 
}

int _tmain(int argc, _TCHAR* argv[])
{
	
	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;


	cout<<"Geometric traits class using STL."<<endl;

	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Convex Hull (Geometric Traits Class)| Push any key for another set");
	glutDisplayFunc(disp);

	srand(2005);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	
	glutKeyboardFunc(key);
	key(0,0,0);
	glutMainLoop();

	return 0;
}

