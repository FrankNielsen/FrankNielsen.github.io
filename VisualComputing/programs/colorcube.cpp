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
// File: colorcube.cpp
// 
// Description: Rendering the RGB color cube in OpenGL(R)
// ------------------------------------------------------------------------

#include "stdafx.h"

#include "glut.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

typedef GLfloat Point3D[3];
typedef GLfloat color[4];

void display(void);
void cube(void);
void reshape(int,int);
void keyboard(unsigned char,int,int);

float angle=0.0;


void display( void )
{
   
	angle+=1.0;
	if (angle>360) angle-=360;

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glPushMatrix();
	glRotatef(angle,1,0,1);
	cube();
	glPopMatrix();
	glutSwapBuffers();
 }

void reshape(int w,int h)
{
	glViewport(0,0,(GLsizei)w,(GLsizei)h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(54,1.0,1.0,50.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt( 2.5,  2.5, 2.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
}

void cube(void)
{
    Point3D vertices[8]={{-1.0, -1.0, -1.0},
                        {-1.0, -1.0,  1.0},
                        {-1.0,  1.0, -1.0},
                        {-1.0,  1.0,  1.0},
                        { 1.0, -1.0, -1.0},
                        { 1.0, -1.0,  1.0},
                        { 1.0,  1.0, -1.0},
                        { 1.0,  1.0,  1.0} };

	Point3D colors[8] = {{0.,0.,0.},
						{0.,0.,1.},
						{0.,1.,0.},
						{0.,1.,1.},
						{1.,0.,0.},
						{1.,0.,1.},
						{1.,1.,0.},
						{1.,1.,1.} };

	// A cube is 6 quads defined by 8 vertices
    glBegin(GL_QUADS);
	
      glColor3fv(colors[1]);
      glVertex3fv(vertices[1]);
      glColor3fv(colors[5]);
      glVertex3fv(vertices[5]);
      glColor3fv(colors[7]);
      glVertex3fv(vertices[7]);
      glColor3fv(colors[3]);
      glVertex3fv(vertices[3]);
	
      glColor3fv(colors[7]);
      glVertex3fv(vertices[7]);
      glColor3fv(colors[6]);
      glVertex3fv(vertices[6]);
      glColor3fv(colors[2]);
      glVertex3fv(vertices[2]);
      glColor3fv(colors[3]);
      glVertex3fv(vertices[3]);
	
      glColor3fv(colors[2]);
      glVertex3fv(vertices[2]);
      glColor3fv(colors[6]);
      glVertex3fv(vertices[6]);
      glColor3fv(colors[4]);
      glVertex3fv(vertices[4]);
      glColor3fv(colors[0]);
      glVertex3fv(vertices[0]);
	
      glColor3fv(colors[5]);
      glVertex3fv(vertices[5]);
      glColor3fv(colors[4]);
      glVertex3fv(vertices[4]);
      glColor3fv(colors[6]);
      glVertex3fv(vertices[6]);
      glColor3fv(colors[7]);
      glVertex3fv(vertices[7]);
	
      glColor3fv(colors[4]);
      glVertex3fv(vertices[4]);
      glColor3fv(colors[5]);
      glVertex3fv(vertices[5]);
      glColor3fv(colors[1]);
      glVertex3fv(vertices[1]);
      glColor3fv(colors[0]);
      glVertex3fv(vertices[0]);
	
      glColor3fv(colors[0]);
      glVertex3fv(vertices[0]);
      glColor3fv(colors[1]);
      glVertex3fv(vertices[1]);
      glColor3fv(colors[3]);
      glVertex3fv(vertices[3]);
      glColor3fv(colors[2]);
      glVertex3fv(vertices[2]);
    glEnd();
 }

void keyboard(unsigned char key, int x, int y)
{
	glutPostRedisplay();
}

void idle()
{
glutPostRedisplay();	
}

void main(int argc, char** argv)
{
	glutInit(&argc,argv);
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(1024,1024);
	glutInitWindowPosition(70,70);
	glutCreateWindow("RGB Cube Color Space");
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	glutKeyboardFunc(keyboard);
	glutIdleFunc(idle);

	glClearColor( 1,1,1, 0.0 );
	glEnable(GL_DEPTH_TEST); 
	glShadeModel(GL_SMOOTH);

	glutMainLoop();
}
