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
// File: openglviewport.cpp
// 
// Description: Show how to use the viewport to render on a same device several views
// --------------
#include "stdafx.h"
#include "glut.h"

using namespace std;


int width, height;

void init()
{

 glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
 glColor3f(0, 0, 0);
 glClearDepth(1);

 glMatrixMode(GL_PROJECTION);
 glLoadIdentity();

 glOrtho(-2, 2, -2, 2, -2, 2);

 glMatrixMode(GL_MODELVIEW);
 glLoadIdentity();
}

void reshape (int w, int h)
{
	width = w;
	height = h;
}

void drawScene()
{
 glColor3f(.95, .95, .95);

 glPushMatrix();
 glTranslatef(0, -1, 0);

 glBegin(GL_QUADS);
	glVertex3f(2, 0, 2);
	glVertex3f(2, 0, -2);
	glVertex3f(-2, 0, -2);
	glVertex3f(-2, 0, 2);
 glEnd();

 glPopMatrix();

 glColor3f(0.3,0.3,0.3);

 glRotatef(10,1.0,0.0, 0.0);
 glPushMatrix();
 glutWireTeapot(1);
 glPopMatrix();
}

void display()
{
 glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

 //bottom left: perspective
 glViewport(0, 0, width/2, height/2);

 glMatrixMode(GL_PROJECTION);
 glPushMatrix();
 glLoadIdentity();
 gluPerspective(45, 1, 1, 10000);
 glMatrixMode(GL_MODELVIEW);
 glPushMatrix();
 gluLookAt(5, 5, 5, 0, 0, 0, 0, 1, 0);
 drawScene();
 glPopMatrix();
 glMatrixMode(GL_PROJECTION);
 glPopMatrix();

 

 //bottom right: orthographic
 glViewport(width/2, 0, width/2, height/2);	
 glPushMatrix();
 gluLookAt(0, 0, 1,   0, 0, 0,   0, 1, 0); // z-axis down
 drawScene();
 glPopMatrix();

 //top left
 glViewport(0, height/2,width/2, height/2); 
 glPushMatrix();
 gluLookAt(0, 1, 0,   0, 0, 0,   0, 0, 1);  //y-axis down
 drawScene();
 glPopMatrix();

  //top right
 glViewport(width/2, height/2, width/2, height/2);
 glPushMatrix();
 gluLookAt(1, 0, 0,   0, 0, 0,  0, 1, 0); // x-axis down	
 drawScene();
 glPopMatrix();

 
 glFlush();
 glutSwapBuffers();
}



int _tmain(int argc, _TCHAR* argv[])
{
width = 750;height = width;



cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;



 glutInitDisplayMode(GLUT_SINGLE | 	GLUT_RGBA | GLUT_DEPTH);
 glutInitWindowSize(width, height);
 glutCreateWindow ("Several viewports mapped on a single screen");
 init();
 glutDisplayFunc(display);
 glutReshapeFunc(reshape);
 glutMainLoop();
 return 0;

}

