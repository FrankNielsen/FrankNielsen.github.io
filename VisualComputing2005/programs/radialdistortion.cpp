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
// File: radialdistortion.cpp
// 
// Description: A simple interactive interface for visualizing the radial
// distortion effects. Use only one coefficient: kappa1 (Tsai model)
// ------------------------------------------------------------------------

#include "stdafx.h"

#include <windows.h>
#include <math.h>
#include <GL/gl.h>
#include <GL/glut.h>

#define M_PI 3.14159265

using namespace std;

#define W 800
#define H 800

double kappa1=0.0, aspecty=1.0;

double dkappa1=0.0001;
double daspecty=0.1;




void DrawCircle(double x, double y, double r)
{
int k;
double xd, yd, rd, angle;
double xi, yi, ri;

glBegin(GL_LINE_LOOP);

for(k=0;k<100;k++)
{
angle=2.0*M_PI*k/100.0;

// from distorted to ideal
xd=x+r*cos(angle);
yd=y+r*sin(angle);
rd=r;


ri=rd*(1+kappa1*rd*rd);

xi=x+ri*cos(angle);
yi=y+ri*sin(angle);


glVertex2f(xi,yi);

}
glEnd();

}

void display(void)
{
char buffer[256];
int i,j;

glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glColor3f (0, 0, 0);

  glBegin(GL_LINES);
  for(i=0;i<H;i+=50)
  {
	glVertex2f(0,i);
	glVertex2f(W,i);
  }

  for(i=0;i<W;i+=50)
  {
	glVertex2f(i,0);
	glVertex2f(i,H);
  }
	  glEnd();

	  glColor3f(0,0,1);
	  for(int k=0;k<W;k+=5)
		  DrawCircle(W/2,H/2,k);


	  glColor3f (0, 0, 0);
 glRasterPos2f(50,30);
   sprintf(buffer,"Radial distortions. kappa1=%e",kappa1);
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);


   glRasterPos2f(50,H-30);
   sprintf(buffer,"Press  '<'/'>' for kappa1");
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);


 

 glFlush();
 glutSwapBuffers();

}


void keyboard(unsigned char key, int x, int y)
{
  if (key=='q') exit(0);

  // aspect y
  if (key==43) {aspecty+=daspecty;}

  if (key==45) {aspecty-=daspecty;}

  // kappa
  if (key==62) {kappa1+=dkappa1;}

  if (key==60) {kappa1-=dkappa1;}

  glutPostRedisplay();
}


int _tmain(int argc, _TCHAR* argv[])
{
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE); 
  glutInitWindowSize(W,H);
  glutCreateWindow("Radial distortions");

  glutDisplayFunc(display);
  glutKeyboardFunc(keyboard);

   glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glClearColor(1.0, 1.0, 1.0, 0.0);
  glutMainLoop();
  return 0;
}

