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
// File: segmentintersection-projective.cpp
// 
// Description: Compute the potential intersection point of two line segments using
// the cross-product: cross-product for  defining supporting lines and cross-product 
// of the line vectors for determining the intersection projective point.
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <windows.h>
#include <math.h>
#include <GL/gl.h>
#include <GL/glut.h>

using namespace std;

#define W 800
#define H 800

// Duality
#define Line2D Point2D

inline double drand() {return rand()/(double)RAND_MAX;}

class Point2D{public:
double x,y,w;

Point2D::Point2D(double xx, double yy)
{
x=xx;
y=yy;
w=1.0;
}

Point2D::Point2D()
{x=y=0.0; w=1.0;}


// Dehomogenization (perspective division)
void Normalize()
{
	if (w!=0) {x/=w; y/=w; w=1.0;}
}


void Rand()
{
x=drand();y=drand();w=1.0;
}


friend ostream & operator << (ostream & os, const Point2D p)
{
	os<<"["<<p.x<<","<<p.y<<","<<p.w<<"]";
return os;
}

};



Point2D intersection;
Point2D p,q,r,s,u1,u2;
Line2D l1, l2;

bool intersect;



Point2D CrossProduct(Point2D p1, Point2D p2)
{
Point2D result;

result.x=p1.y*p2.w-p1.w*p2.y;
result.y=p1.w*p2.x-p1.x*p2.w;
result.w=p1.x*p2.y-p1.y*p2.x;

return result;
}


void disp( void ) 
{
char buffer[256];
double lambda=2.0*W;

glClearColor(1,1,1,1);
glClear(GL_COLOR_BUFFER_BIT);

glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, 1, 0.0, 1, -1.0, 1.0);
glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f(0,1,0);
	glBegin(GL_LINES); 
	glVertex2f(p.x-lambda*u1.x,p.y-lambda*u1.y);
	glVertex2f(p.x+lambda*u1.x,p.y+lambda*u1.y);

	glVertex2f(r.x-lambda*u2.x,r.y-lambda*u2.y);
	glVertex2f(r.x+lambda*u2.x,r.y+lambda*u2.y);

	glEnd();

	glColor3f(0,0,0);
	glBegin(GL_LINES); 
	glVertex2f(p.x,p.y);
	glVertex2f(q.x,q.y);
	glEnd();

	glBegin(GL_LINES); 
	glVertex2f(r.x,r.y);
	glVertex2f(s.x,s.y);
	glEnd();


	glPointSize(5.0);
	glColor3f(1,0,0);
	glBegin(GL_POINTS);
	glVertex2f(intersection.x,intersection.y);
	glEnd();
	glPointSize(1.0);

  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f (0, 0, 0);

  glRasterPos2f(50,30);
   sprintf(buffer,"Press any key for another point sequence sample.");
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

   glRasterPos2f(50,H-50);
   sprintf(buffer,"Line segments %s", (intersect  ? "intersect": "do not intersect"));
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
	double norm;

	// 1st segment
p.Rand();
q.Rand();
if (p.x>q.x) swap(p,q);

	// 2nd segment
r.Rand();
s.Rand();
if (r.x>s.x) swap(r,s);


// Directional vectors
u1.x=q.x-p.x;
u1.y=q.y-p.y;
norm=sqrt(u1.x*u1.x + u1.y*u1.y);
u1.x/=norm;u1.y/=norm;
u1.w=1.0;

u2.x=s.x-r.x;
u2.y=s.y-r.y;
norm=sqrt(u2.x*u2.x+u2.y*u2.y);
u2.x/=norm;u2.y/=norm;
u2.w=1.0;

//cout<<u1<<u2<<endl;


l1=CrossProduct(p,q);
l2=CrossProduct(r,s);

// intersection point is the cross-product of the line coefficients (duality)
intersection=CrossProduct(l1,l2);
intersection.Normalize(); // to get back Euclidean point

cout<<"P="<<p<<"\nQ="<<q<<"\nR="<<r<<"\nS="<<s<<endl;

cout<<"Intersection point of lines:"<<intersection.x<<" "<<intersection.y<<endl;


if ((intersection.x>=p.x)&&(intersection.x<=q.x)&&(intersection.x>=r.x)&&(intersection.x<=s.x)) intersect=true; else intersect=false;

if (intersect) cout<<"Line segments intersect."<<endl;
else
cout <<"Line segments do not intersect."<<endl;

glutPostRedisplay(); 
}

int _tmain(int argc, _TCHAR* argv[])
{


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"Line segment intersection using projective geometry."<<endl;

	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Line intersection (using projective geometry - cross-product)");
	glutDisplayFunc(disp);

	srand(2005);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	

	glutKeyboardFunc(key);

	key(' ',0,0);
	glutMainLoop();

	return 0;
}

