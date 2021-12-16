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
// File: spheresubdivision.cpp
// 
// Description: subdivision refinement of the icosahedron for approximating
// the unit sphere
// ------------------------------------------------------------------------

#include "stdafx.h"


#include <stdlib.h>
#include <math.h>
#include <GL/glut.h>


using namespace std;


// coordinates of one of the icosahedron vertex
#define X 0.525731112119133696
#define Z 0.850650808352039932

// icosahedron  vertices
static GLfloat icosahedronvertex[12][3] = {
  {-X, 0.0, Z}, {X, 0.0, Z}, {-X, 0.0, -Z}, {X, 0.0, -Z},
  {0.0, Z, X}, {0.0, Z, -X}, {0.0, -Z, X}, {0.0, -Z, -X},
  {Z, X, 0.0}, {-Z, X, 0.0}, {Z, -X, 0.0}, {-Z, -X, 0.0}
};

// icosehedron faces
static int icosahedrontriangle[20][3] = {
  {1,4,0}, {4,9,0}, {4,5,9}, {8,5,4}, {1,8,4},
  {1,10,8}, {10,3,8}, {8,3,5}, {3,2,5}, {3,7,2},
  {3,10,7}, {10,6,7}, {6,11,7}, {6,0,11}, {6,1,0},
  {10,1,6}, {11,0,9}, {2,11,9}, {5,2,9}, {11,2,7}
};

GLfloat angle=0.0;

int subdiv = 0;	
bool animation=true;

// Vertices should belong to the unit sphere.
// so we perform normalization
void Normalize(GLfloat v[3])
{
  GLfloat d = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
  if (d!=0.0)
  {
	  v[0]/=d; 
	  v[1]/=d; 
	  v[2]/=d;
  }
}




// Recursively subdivide the sphere
void OneToFourTriangle(GLfloat v1[3], GLfloat v2[3], GLfloat v3[3], int depth)
{
  GLfloat v12[3], v23[3], v31[3];
  int i;

  if (depth == 0) {
		Normalize(v1);
		Normalize(v2);
		Normalize(v3);

		glColor3f(0.5,0.5,0.5);
		glBegin(GL_TRIANGLES);
		glVertex3fv(v1);
		glVertex3fv(v2);
		glVertex3fv(v3);
		glEnd();

		glColor3f(0,0,0);
		glLineWidth(3);
		glBegin(GL_LINE_LOOP);
		glVertex3fv(v1);
		glVertex3fv(v2);
		glVertex3fv(v3);
		glEnd();
  }
  else
  {
  // midpoint
  for (i = 0; i < 3; i++) 
  {
    v12[i] = (v1[i]+v2[i])/2.0;
    v23[i] = (v2[i]+v3[i])/2.0;
    v31[i] = (v3[i]+v1[i])/2.0;
  }
  

  // lift midpoints on the sphere
  Normalize(v12);
  Normalize(v23);
  Normalize(v31);

  // subdivide new one-to-four triangles 
  OneToFourTriangle(v1, v12, v31, depth-1);
  OneToFourTriangle(v2, v23, v12, depth-1);
  OneToFourTriangle(v3, v31, v23, depth-1);
  OneToFourTriangle(v12, v23, v31, depth-1);
  }
}

void display(void)
{
  int i;

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  gluLookAt(0.5, 0.5, -1.5,
            0.0, 0.0, 0.0,  
	        0.0, 1.0, 0.0); 

 
if (animation) angle+=0.3;
if (angle>360) angle-=360.0;

glPushMatrix();
glRotatef(angle,1,0,1);

  // subdivide each face of the triangle
  for (i = 0; i < 20; i++)
  {
    OneToFourTriangle(&icosahedronvertex[icosahedrontriangle[i][0]][0],
              &icosahedronvertex[icosahedrontriangle[i][1]][0],
	          &icosahedronvertex[icosahedrontriangle[i][2]][0],
	          subdiv);
  }

  glPopMatrix();

  glFlush();
  glutSwapBuffers();
}

void reshape(int w, int h)
{
  glViewport(0, 0, w, h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-1.25, 1.25, -1.25 , 1.25 , -2.0, 2.0);
  glMatrixMode(GL_MODELVIEW);
  glutPostRedisplay();
}



void keyboard(unsigned char key, int x, int y)
{
  if (key=='q') exit(0);

   if (key==' ') 
   {
	animation=!animation;
   }

  if (key=='+') subdiv++;
  if (key=='-') 
	{
	  subdiv--;
	  if (subdiv<0) subdiv = 0;
	}

  glutPostRedisplay();
}


void idle()
{
if (animation) subdiv=(int)(angle/70);

 glutPostRedisplay();
}

int main(int argc, char **argv)
{
 
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Recursive subdivision of the icosahedron for approximating the sphere."<<endl;
cout<<"' ' SPACE: toggle on/off animation."<<endl;
cout<<"+/- increase/decrease subdivision level."<<endl;

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH | GLUT_DOUBLE); 
  glutInitWindowSize(1024,1024);
  glutCreateWindow("Icosahedron subdivision for approximating the sphere");

  glutReshapeFunc(reshape);
  glutDisplayFunc(display);
  glutKeyboardFunc(keyboard);
  glutIdleFunc(idle);

  glClearColor(1.0, 1.0, 1.0, 0.0);	
  glEnable(GL_DEPTH_TEST);

  glutMainLoop();
  return(0);
}

