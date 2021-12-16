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
// File: isometricprojection.cppm
// 
// Description: Choosing the view direction to get an isometric projection of cube(s)
// --------------

#include "stdafx.h"

#include <stdio.h>
#include <stdlib.h>
#include <glut.h>
#include <math.h>

using namespace std;

#define M_PI 3.14159265

double theta = 45.0, phi=45.0;
double pos=4.0;

void display(void) {
 float xeye,yeye,zeye;

  glClearColor(1,1,1,1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity();
 gluPerspective(54,1.0,1.0,50.0);

 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity();
 
  xeye = pos * cos(phi*M_PI/180.0) * cos(theta*M_PI/180.0);
  yeye = pos * cos(phi*M_PI/180.0) * sin(theta*M_PI/180.0);
  zeye = pos * sin(phi*M_PI/180.0);
  
  gluLookAt(xeye,yeye,zeye,   
            0.0,0.0,0.0,   
            0.0,0.0,1.0);   
  

// Draw principal axes
 glColor3f(0.5,0.5,0.5);
 glLineWidth(5.0);
 glBegin(GL_LINES);
  glVertex3f(0.0,0.0,0.0);
  glVertex3f(3,0.0,0.0);
  glVertex3f(0.0,0.0,0.0);
  glVertex3f(0.0,3,0.0);
  glVertex3f(0.0,0.0,0.0);
  glVertex3f(0.0,0.0,3);
 glEnd();

 // DrawCube

glColor3f(0,0,0);
glLineWidth(2.0);
glutWireCube(1.0);


glPushMatrix();
glTranslatef(0,-1,0);
glColor3f(0,0,1);
glutWireCube(1.0);
glPopMatrix();

glPushMatrix();
glTranslatef(-1,0,0);
glColor3f(1,0,0);
glutWireCube(1.0);
glPopMatrix();

glPushMatrix();
glTranslatef(0,0,-1);
glColor3f(0,1,0);
glutWireCube(1.0);
glPopMatrix();

 glFlush();
 glutSwapBuffers();
}


void keyboard(unsigned char key,int x,int y) 
{
 glutPostRedisplay();
 }

int _tmain(int argc, _TCHAR* argv[])
{

	
	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;


	glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(1024, 1024);
    glutCreateWindow("Isometric Projection");
    glutDisplayFunc(display);
    glutKeyboardFunc(keyboard);
	glEnable(GL_DEPTH_TEST); 
    glutMainLoop();
	return 0;
}

