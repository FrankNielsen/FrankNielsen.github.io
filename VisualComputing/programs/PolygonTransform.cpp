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
// File: PolygonTransform.cpp
// 
// Description: 2D polygon transformations
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <GL/glut.h>  
#include <math.h>

using namespace std;


static GLfloat face[][2]={ {6,0}, {0,12}, {2,20}, {4,12}, {8,16}, {12,12}, {14,20}, {16,12}, {10,0}, {6,0}} ;
static GLfloat nose[][2]={{7,7}, {8,9}, {9,7}, {7,7}};
static GLfloat lefteye[][2]={{4,10}, {4,11}, {5,11}, {5,10}, {4,10}};
static GLfloat righteye[][2]={{11,10} ,{11,11}, {12,11}, {12,10}, {11,10}};
static GLfloat mouth[][2]={{6,5}, {7,4}, {9,4}, {10,5}};

#define INDEX(a,b) ((a)+(b)*4)
GLfloat M[16], MGL[16];

GLfloat minr,maxr;
GLfloat translateX=0.0,translateY=0.0;
GLfloat shear=1.0;
GLfloat angle=3.141592/4.0; // pi/4 approximatively -:)

void display(void)               
{int i,j;

	glClearColor(1,1,1,0);
    glClear(GL_COLOR_BUFFER_BIT);

	glMatrixMode(GL_MODELVIEW);

	// World Coordinate System
	glLoadIdentity();

	glColor3f(1,0,0);
	glBegin(GL_LINES);
	glVertex2f(minr,0);glVertex2f(maxr,0);
	glVertex2f(0,minr);glVertex2f(0,maxr);
	glEnd();

	glTranslatef(translateX,translateY,0.0);
	glMultMatrixf(M);
	//glLoadMatrixf(M);
	
	glColor3f(0,0,0);
	// Local Coordinate Systems
	glBegin(GL_LINE_STRIP);
	for(i=0;i<10;i++)
		{glVertex2f(face[i][0],face[i][1]);}
	glEnd();

	glBegin(GL_LINE_STRIP);
	for(i=0;i<5;i++)
		{glVertex2f(lefteye[i][0],lefteye[i][1]);}
	glEnd();

	glBegin(GL_LINE_STRIP);
	for(i=0;i<5;i++)
		{glVertex2f(righteye[i][0],righteye[i][1]);}
	glEnd();

	glBegin(GL_LINE_STRIP);
	for(i=0;i<4;i++)
		{glVertex2f(mouth[i][0],mouth[i][1]);}
	glEnd();

	glBegin(GL_LINE_STRIP);
	for(i=0;i<4;i++)
		{glVertex2f(nose[i][0],nose[i][1]);}
	glEnd();

	glGetFloatv(GL_MODELVIEW_MATRIX, MGL);

	 printf("Model Matrix OpenGL:\n");

	 for(i=0;i<4;i++)
		 {for(j=0;j<4;j++) 
			 printf("%f ",MGL[INDEX(i,j)]);
		 printf("\n");}

    
    glutSwapBuffers( );
}

void reshape(int w, int h) 
{
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrtho(minr,maxr,minr,maxr,-1,1);
}

void keypress(unsigned char key, int x, int y)
{
	int i,j;

	printf("Key %c\n",key);

	 switch (key)
	 {
	 case 'I': case 'i':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		break;

	case 'T': case 't':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,3)]=1.0;
		M[INDEX(1,3)]=2.0;
		break;

		case 'R': case 'r':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=cos(angle); M[INDEX(0,1)]=-sin(angle); 
		M[INDEX(1,0)]=sin(angle); M[INDEX(1,1)]=cos(angle);
		break;


	 case 'O': case 'o':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=M[INDEX(1,1)]=-1;
		break;

	 case  'Y': case 'y':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=-1;
		break;

	case  'X': case 'x':
		 for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(1,1)]=-1;
		break;

	case 'K':case 'k':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,1)]=shear;
		break;

	case 'L':case 'l':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(1,0)]=shear;
		break;

	 }

	 printf("Model Matrix:\n");
	 for(i=0;i<4;i++)
		 {for(j=0;j<4;j++) 
			 printf("%f ",M[INDEX(i,j)]);
		 printf("\n");}
 display();
}

void move(int key, int x, int y)
{
    float step = 0.1;

    switch (key) {
    case GLUT_KEY_UP:
        translateY += step;
        break;
    case GLUT_KEY_DOWN:
        translateY -= step;
        break;

    case GLUT_KEY_LEFT:
        translateX -= step;
        break;
    case GLUT_KEY_RIGHT:
        translateX += step;
        break;
    }
    glutPostRedisplay();
}


void main(void)
{int i,j;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;



    glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowPosition(0,0);  
    glutInitWindowSize(512, 512);
    glutCreateWindow("2D Transformations in OpenGL(R)");

	minr=-50; maxr=50;
	for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
 
    glutReshapeFunc(reshape);
    glutDisplayFunc(display);

    glutSpecialFunc(move);
	glutKeyboardFunc(keypress);
    
	glutMainLoop( );
}
