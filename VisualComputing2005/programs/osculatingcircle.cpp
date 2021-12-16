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
// File: osculatingcircle.cpp
// 
// Description: Interactive demo of the osculating circle of a parametric curve
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <windows.h>
#include <math.h>
#include <GL/gl.h>
#include <GL/glut.h>

#define W 800
#define H 800

using namespace std;



typedef   double number;
class point {
public: 
number x,y;

inline number Distance(point q)
{return sqrt((q.x-x)*(q.x-x) + (q.y-y)*(q.y-y));}
};

void SolveDisc3(point p1, point p2, point p3, point & center, number &rad);



point center, pleft, p, pright;
double r,curv;


inline float f(number x)
{
return 5*pow((x-0.5),3.0)+0.5;
}



void disp( void ) 
{
char buffer[256];
int i;
float x;
double theta;

glClearColor(1,1,1,1);
glClear(GL_COLOR_BUFFER_BIT);

glPointSize(1.0);
glColor3f(0,0,0);
glBegin(GL_POINTS);

for(x=0;x<1.0;x+=0.001)
{
glVertex2f(x,f(x));
}
glEnd();


glPointSize(5.0);
glColor3f(1,0,0);
glBegin(GL_POINTS);
glVertex2f(p.x,p.y);
glColor3f(0,1,0);
glVertex2f(center.x,center.y);
glEnd();

glColor3f(0,0,1);

glBegin(GL_LINE_LOOP);
for(i=0;i<500;i++)
{
theta=2.0*3.14159265*i/500.0;
glVertex2f(center.x+r*cos(theta),center.y+r*sin(theta));
}
glEnd();



glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
glColor3f(0.5,0,0);

glRasterPos2f(50,10);
   sprintf(buffer,"Move the point on the curve using arrows (x=%.3f,y=%.3f).",p.x,p.y);
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

glRasterPos2f(50,H-30);
   sprintf(buffer,"Radius=%.3f Curvature=%.3f",r,curv);
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
double inc=0.01;

cout<<(int)key<<endl;

if ((key=='+')||(key==59)) p.x+=inc;
if ((key=='-')||(key==45)) p.x-=inc;

if (p.x>1.0) p.x=0;
if (p.x<0.0) p.x=1.0;

p.y=f(p.x);

pleft.x=p.x-inc;
pleft.y=f(pleft.x);
pright.x=p.x+inc;
pright.y=f(pright.x);

SolveDisc3(pleft,p,pright,center,r);
curv=1.0/r;



glutPostRedisplay(); 
}

void specialkey(int k,int x, int y)
{
   switch (k) {
   case GLUT_KEY_LEFT:
      key(45,0,0);
      break;
   case GLUT_KEY_RIGHT:
      key(59,0,0);
      break;
   case GLUT_KEY_UP:
      key(59,0,0);
      break;
   case GLUT_KEY_DOWN:
      key(45,0,0);
      break;
   }
}


int _tmain(int argc, _TCHAR* argv[])
{

	

	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;


	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Osculating Circle (Curvature) Demo.");
	glutDisplayFunc(disp);

	srand(2005);
	cout<<"Osculating circle."<<endl;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	

	p.x=0.5;
	p.y=f(p.x);
	key(59,0,0);

	glutKeyboardFunc(key);
	 glutSpecialFunc(specialkey);

	glutMainLoop();

	return 0;
}


// The unique circle passing through exactly three non-collinear points  p1, p2 ,p3
void SolveDisc3(point p1, point p2, point p3, point & center, number &rad)
{
number a = p2.x - p1.x;
number b = p2.y - p1.y;
number c = p3.x - p1.x;
number d = p3.y - p1.y;
number e = a*(p2.x + p1.x)*0.5 + b*(p2.y + p1.y)*0.5;
number f = (c*(p3.x + p1.x)*0.5) + (d*(p3.y + p1.y)*0.5);
number det = a*d - b*c;    

center.x = (d*e - b*f)/det;   
center.y = (-c*e + a*f)/det;

rad =p1.Distance(center);
}

