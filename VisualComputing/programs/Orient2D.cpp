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
// File: Orient2D.cpp
// 
// Description: 2D Orientation predicate demo with visualization in OpenGL
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <windows.h>
#include <GL/gl.h>
#include <GL/glut.h>

using namespace std;

#define W 800
#define H 800

#define CW 1
#define CCW -1
#define ON 0

int sign;

inline float drand(){return rand()/(double)RAND_MAX;}

class Point2D{
public: double x,y;

		Point2D::Reset()
		{x=drand();y=drand();}

		Point2D::Point2D()
		{Reset();}
};

// Orientation test: 2x2 determinant sign
// This is not the best bound but enough for this screen demo.
#define ERR 1.0e-6

int Orient2D( const Point2D& p, const Point2D& q, const Point2D& r)
  {
	  if ((q.x-p.x)*(r.y-p.y) > (r.x-p.x)*(q.y-p.y)+ERR) return CCW;
 	  if ((q.x-p.x)*(r.y-p.y) < (r.x-p.x)*(q.y-p.y)-ERR) return CW;

   return ON;
  }


  Point2D p,q,r;
  

void disp( void ) 
{
	char buffer[256];

glClearColor(1,1,1,1);
glClear(GL_COLOR_BUFFER_BIT);


if (sign==ON) {glColor3f(1,0,0);sprintf(buffer,"Degenerate case: collinearity");}
if (sign==CW) {glColor3f(0,1,0);sprintf(buffer,"Clockwise order of P,Q,R");}
if (sign==CCW) {glColor3f(0,0,1);sprintf(buffer,"Counterclockwise order of P,Q,R");}

if (sign!=ON){
glBegin(GL_TRIANGLES);
glVertex2f(p.x,p.y);
glVertex2f(q.x,q.y);
glVertex2f(r.x,r.y);
glEnd();}
else
{
glBegin(GL_LINE_LOOP);
glVertex2f(p.x,p.y);
glVertex2f(q.x,q.y);
glVertex2f(r.x,r.y);
glEnd();
}


glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f (0, 0, 0);

  glRasterPos2f(W*p.x,H*p.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'P');

   glRasterPos2f(W*q.x,H*q.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'Q');

   glRasterPos2f(W*r.x,H*r.y);
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, 'R');


   glRasterPos2f(50,H-50);
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

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

p.Reset();
q.Reset();
if (drand()<0.5) 
	{double lambda=drand();
	r.x=lambda*p.x+(1.0-lambda)*q.x;
	r.y=lambda*p.y+(1.0-lambda)*q.y;
	}
else
r.Reset();

sign=Orient2D(p,q,r);
glutPostRedisplay(); 
}

int _tmain(int argc, _TCHAR* argv[])
{

	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Orientation test demo: Predicate Orient2D.");
	glutDisplayFunc(disp);
	srand(2005);

	
	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;


	cout<<"Visualize the orientation tests Orient2D."<<endl;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	glutKeyboardFunc(key);
	sign=Orient2D(p,q,r);
	glutMainLoop();

	return 0;
}

