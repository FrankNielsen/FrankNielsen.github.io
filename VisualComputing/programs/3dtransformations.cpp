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
// File: 3dtransformations.cpp
// 
// Description: Common 3D transformations: rotations, shears, translations...
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <GL/glut.h>
#include "bunny.h"

int width=512,height=512;
GLfloat cx,cy,cz;

#define INITIALIZE(M) for(int ii=0;ii<4;ii++) for(int jj=0;jj<4;jj++) M[4*ii+jj]=((ii==jj) ? 1.0 : 0.0);

void gravity()
{
int i;
cx=cy=cz=0.0;

for(i=0;i<NUM_POINTS;i++)
{
	cx+=bunny[3*i];
	cy+=bunny[3*i+1];
	cz+=bunny[3*i+2];
}

cx/=(float)NUM_POINTS;
cy/=(float)NUM_POINTS;
cz/=(float)NUM_POINTS;
}


void disp();
void keyb(unsigned char key, int x, int y);
void reshape(int x, int y);
void init();
GLfloat spin=0;
bool rotate=0;

#define INDEX(a,b) ((a)+(b)*4)
GLfloat M[16], MGL[16];

int main(int argc, char **argv){
  glutInit(&argc, argv);
  spin=0;
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
   glutInitWindowPosition(0,0);  
    glutInitWindowSize(width,height);
  glutCreateWindow("3D Transformations on the decimated Stanford Bunny");
  init();
  glutDisplayFunc(disp);
  glutKeyboardFunc(keyb);
  glutReshapeFunc(reshape);
  glutMainLoop();

  return 0;
}

void init(){
  glClearColor(0.0,0.0,0.0,0.0);
   glShadeModel(GL_FLAT);
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glVertexPointer(3,GL_FLOAT,0,bunny);
  glNormalPointer(GL_FLOAT,0,normals);
  glEnable(GL_NORMALIZE);


  glHint (GL_LINE_SMOOTH_HINT, GL_NICEST);	
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
		glEnable (GL_LINE_SMOOTH);	

  INITIALIZE(M);

  gravity();
  printf("%f %f %f\n",cx,cy,cz);
}


void DrawAxis(GLfloat maxu=1.0)
{
GLfloat b=10.0;

glDisable(GL_LIGHTING);


glLineWidth(3.0f);
glColor3f(1.0,0.0,0.0);
glBegin(GL_LINES);
glVertex3f(0.0,0.0,0.0);
glVertex3f(maxu,0.0,0.0);
glEnd();


glColor3f(0.0,1.0,0.0);
glBegin(GL_LINES);
glVertex3f(0.0,0.0,0.0);
glVertex3f(0.0,maxu,0.0);
glEnd();


glColor3f(0.0,0.0,1.0);
glBegin(GL_LINES);
glVertex3f(0.0,0.0,0.0);
glVertex3f(0.0,0.0,maxu);
glEnd();

glEnable(GL_LIGHTING);
}

void disp(void)
{


  static GLfloat position1 [] = {0.0,7,6,1.0};
   static GLfloat position2 [] = {0.0,-0.15,-0.1,1.0};
  static GLfloat color [] = {0.8,0.8,0.8,1.0};

  glClearColor(1.0,1.0,1.0,0.0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

 glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  gluLookAt(-0.3,0.25,0.5,0,0.11,0,0,1,0);

  glPushMatrix();
  glTranslatef(position1[0],position1[1],position1[2]); 
  glLightfv(GL_LIGHT0,GL_POSITION,position1);
glPopMatrix();


glPushMatrix();
glPushMatrix();

glMultMatrixf(M);

glColor3f(0.5,0.5,0.5);
if (rotate) {spin+=1.0;if (spin>360) spin-=360;}

glRotatef(spin,0.0,1.0,0.0);

  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,color);
  glDrawElements(GL_TRIANGLES,3*NUM_TRIANGLES,GL_UNSIGNED_INT,triangles);
  
  glPushMatrix(); glTranslatef(cx,cy,cz); DrawAxis(0.15); glPopMatrix();


 glPopMatrix();

  DrawAxis();

  glPopMatrix();

  // Swap the buffers && redraw
  glutSwapBuffers();
  glutPostRedisplay();
}

#include <math.h>
GLfloat angle=3.14159265/4.0;

void keyb(unsigned char key, int x, int y)
{
int i,j; float shear=1.0;

switch(key)
{

case ' ':
    rotate=!rotate;
  break;
  
 case 'I': case 'i':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		break;

	case 'T': case 't':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,3)]=cx;
		M[INDEX(1,3)]=cy;
		M[INDEX(2,3)]=cz;
		break;

		case 'E': case 'e':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=cos(angle); M[INDEX(0,1)]=-sin(angle); 
		M[INDEX(1,0)]=sin(angle); M[INDEX(1,1)]=cos(angle);
		break;
		
		case 'R': case 'r':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(1,1)]=cos(angle); M[INDEX(1,2)]=-sin(angle); 
		M[INDEX(2,1)]=sin(angle); M[INDEX(2,2)]=cos(angle);
		break;

		case 'W': case 'w':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=cos(angle); M[INDEX(0,2)]=-sin(angle); 
		M[INDEX(2,0)]=sin(angle); M[INDEX(2,2)]=cos(angle);
		break;

		case 'S': case 's':
		INITIALIZE(M);
		M[INDEX(0,0)]=1.5;M[INDEX(1,1)]=0.5;M[INDEX(2,2)]=0.25;
			break;



	 case 'O': case 'o':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=M[INDEX(1,1)]=-1; //M[INDEX(2,2)]-1;
		break;

	 case  'Y': case 'y':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(0,0)]=-1;
		break;

	case  'X': case 'x':
		 for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(1,1)]=-1;
		break;

	case 'Z':case 'z':
		
		 for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(2,2)]=-1;

	case 'H': case 'h':
for(i=0;i<4;i++) for(j=0;j<4;j++) M[INDEX(i,j)]=rand()/RAND_MAX;
M[INDEX(0,3)]=M[INDEX(1,3)]=M[INDEX(2,3)]=0.0;
M[INDEX(3,3)]=1.0;

		break;
		


		// SHEARS


		// shear zy
		case 'J':case 'j':
		for(i=0;i<4;i++) for(j=0;j<4;j++) M[4*i+j]=((i==j) ? 1.0 : 0.0);
		M[INDEX(2,1)]=shear;
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

}

void reshape(int x, int y){
  glViewport(0,0,x,y);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(50,x/(y*1.0),0.001,1000.0);  
  
  
}
