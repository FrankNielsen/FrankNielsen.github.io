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
// File: segmentintersection-primitive.cpp
// 
// Description: Define a predicate that report whether two line segments 
// intersect or not using Orient2D orientation predicates of triples of points.
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <windows.h>
#include <GL/gl.h>
#include <GL/glut.h>


using namespace std;

// Orientation predicate results:
#define CCW 1
#define ON 0
#define CW -1

#define W 800
#define H 800


// Random number from 0 to 1
inline double drand(){return rand()/(double)RAND_MAX;}

class Point2D{
public: double x,y;

		friend ostream &operator<<(ostream & o, const Point2D & p)
		{
			o<<"("<<p.x<<"."<<p.y<<")"; return o;
		}
};

// Orientation test: 2x2 determinant sign
#define ERR 1.0e-6

double vOrient2D( const Point2D& p, const Point2D& q, const Point2D& r)
  {
	  return ((q.x-p.x)*(r.y-p.y) - (r.x-p.x)*(q.y-p.y));
  }

int Orient2D( const Point2D& p, const Point2D& q, const Point2D& r)
  {
	  if ((q.x-p.x)*(r.y-p.y) > (r.x-p.x)*(q.y-p.y)+ERR) return CCW;
 	  if ((q.x-p.x)*(r.y-p.y) < (r.x-p.x)*(q.y-p.y)-ERR) return CW;

   return ON;
  }

class Segment2D{
public: Point2D a,b;

		Segment2D::RandomDraw()
		{
		a.x=drand();a.y=drand();
		b.x=drand();b.y=drand();

		// swap extremities
		if (a.x>b.x) swap(a,b);
		}

		friend ostream &operator<<(ostream & o, const Segment2D & s)
		{
		o<<"Segment ["<<s.a<<","<<s.b<<"]"; return o;
		}
		
		bool Intersect(Segment2D s)
		{

		if (Orient2D(a,b,s.a)==Orient2D(a,b,s.b)) return false;
		if (Orient2D(s.a,s.b,a)==Orient2D(s.a,s.b,b)) return false;
		return true;
		}

		// Assume a.x<s.a.x
		// Only two orientation predicate evaluations
		bool IntersectOptimize(Segment2D s)
		{
		// can be separated by a vertical line
		if (b.x<s.a.x) return false; 

		if (s.b.x<b.x)
		{
		if (Orient2D(a,b,s.a)!=Orient2D(a,b,s.b)) return true;
		else return false;
		}
		else
		{
		if (Orient2D(a,b,s.a)==Orient2D(s.a,s.b,b)) return true;
		else return false;
		}
		}


		double orient2D( const Point2D& p, const Point2D& q, const Point2D& r)
		{return ((q.x-p.x)*(r.y-p.y) - (r.x-p.x)*(q.y-p.y));}

		Point2D ReportPoint(Segment2D s)
		{Point2D result;double lambda;

		lambda=orient2D(a,s.a,s.b)/(orient2D(a,b,s.b)-orient2D(a,b,s.a));

		result.x=a.x+(b.x-a.x)*lambda;
		result.y=a.y+(b.y-a.y)*lambda;

		return result;
		}
};

Segment2D s1,s2;

void disp( void ) 
{
char buffer[256];
Point2D p;

glClearColor(1,1,1,1);
glClear(GL_COLOR_BUFFER_BIT);


if (s1.Intersect(s2)) 
{
	glColor3f(1,0,0); 
p=s1.ReportPoint(s2);
glPointSize(5.0);
glBegin(GL_POINTS);
glVertex2f(p.x,p.y);
glEnd();
cout<<p<<endl;
}
	else
	glColor3f(0,1,0);

glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, 1, 0.0, 1, -1.0, 1.0);
glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

	glBegin(GL_LINES); 
	glVertex2f(s1.a.x,s1.a.y);
	glVertex2f(s1.b.x,s1.b.y);
	glVertex2f(s2.a.x,s2.a.y);
	glVertex2f(s2.b.x,s2.b.y);
	glEnd();

  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f (0, 0, 0);

  // First segment label
  glRasterPos2f(W*s1.a.x,H*s1.a.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'a');
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, '1');

  glRasterPos2f(W*s1.b.x,H*s1.b.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'b');
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, '1');

   // Second segment label
   glRasterPos2f(W*s2.a.x,H*s2.a.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'a');
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, '2');

   glRasterPos2f(W*s2.b.x,H*s2.b.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'b');
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, '2');


   glRasterPos2f(50,30);
   sprintf(buffer,"Press any key for another point sequence sample.");
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

  glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();      

  glFlush();
}


void key(unsigned char key , int x , int y) 
{
s1.RandomDraw();
s2.RandomDraw();
if (s1.a.x>s2.a.x) swap(s1,s2);

cout<<s1<<endl;
cout<<s2<<endl;
glutPostRedisplay(); 
}

int main(int argc , char ** argv) 
{

	
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Line segment detection");
	glutDisplayFunc(disp);

	srand(2005);
	cout<<"Basic primitive for checking whether two segments intersect or not."<<endl;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	s1.RandomDraw();
	s2.RandomDraw();

	glutKeyboardFunc(key);
	glutMainLoop();
}

