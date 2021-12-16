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
// File: rotation-by-quaternion.cpp
// 
// Description: A simple implementation that shows how to use quaternion
// to perform rotations around some axis
// ------------------------------------------------------------------------


#include "stdafx.h"

#include <windows.h>
#include <math.h>
#include <GL/gl.h>
#include <GL/glut.h>

using namespace std;

#define W 800
#define H 800


#define M_PI 3.14159265
#define toRad(x) ((x)*(M_PI/180.0))

class Point3D
{
public:
	double x,y,z;
};

class Quaternion{
public:
	double w;
	Point3D u;

	inline void Multiply(const Quaternion q)
		{
			Quaternion tmp;
			tmp.u.x = ((w * q.u.x) + (u.x * q.w) + (u.y * q.u.z) - (u.z * q.u.y));
			tmp.u.y = ((w * q.u.y) - (u.x * q.u.z) + (u.y * q.w) + (u.z * q.u.x));
			tmp.u.z = ((w * q.u.z) + (u.x * q.u.y) - (u.y * q.u.x) + (u.z * q.w));
			tmp.w = ((w * q.w) - (u.x * q.u.x) - (u.y * q.u.y) - (u.z * q.u.z));
			*this = tmp;
		}

	inline double Norm()
	{return sqrt(u.x*u.x+u.y*u.y+u.z*u.z+w*w);}

	inline void Conjugate()
	{
	u.x=-u.x;
	u.y=-u.y;
	u.z=-u.z;
	}

	inline void Inverse()
	{
	double norm=Norm();
	Conjugate();
	u.x/=norm;
	u.y/=norm;
	u.z/=norm;
	w/=norm;
	}


	void ExportToMatrix(float matrix[16]) 
{
	float wx, wy, wz, xx, yy, yz, xy, xz, zz;
	
	// adapted from Shoemake
	xx = u.x * u.x;
	xy = u.x * u.y;
	xz = u.x * u.z;
	yy = u.y * u.y;
	zz = u.z * u.z;
	yz = u.y * u.z;

	wx = w * u.x;
	wy = w * u.y;
	wz = w * u.z;

	matrix[0] = 1.0f - 2.0f*(yy + zz);
	matrix[4] = 2.0f*(xy - wz);
	matrix[8] = 2.0f*(xz + wy);
	matrix[12] = 0.0;
 
	matrix[1] = 2.0f*(xy + wz);
	matrix[5] = 1.0f - 2.0f*(xx + zz);
	matrix[9] = 2.0f*(yz - wx);
	matrix[13] = 0.0;

	matrix[2] = 2.0f*(xz - wy);
	matrix[6] = 2.0f*(yz + wx);
	matrix[10] = 1.0f - 2.0f*(xx + yy);
	matrix[14] = 0.0;

	matrix[3] = 0;
	matrix[7] = 0;
	matrix[11] = 0;
	matrix[15] = 1;
}
	
};

Quaternion RotateAboutAxis(Point3D pt, double angle, Point3D axis)
	{
	Quaternion q,p, qinv;

	q.w=cos(0.5*angle);
	q.u.x=sin(0.5*angle)*axis.x;
	q.u.y=sin(0.5*angle)*axis.y;
	q.u.z=sin(0.5*angle)*axis.z;

	p.w=0;
	p.u=pt;

	qinv=q;
	qinv.Inverse();

	q.Multiply(p);
	q.Multiply(qinv);

	return q;
	}





Point3D p;
Point3D axis;
double angle=20;



void display(void)
{
  int i;
  GLfloat m[16];
  char buffer[256];

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glColor3f(0.8,0.8,0.8);
  glutSolidSphere(0.99,32,32);

  angle+=1.0;
  if (angle>360.0) angle-=360.0;


  glColor3f(1,1,0);
  glBegin(GL_LINES);
  glVertex3f(0,0,0);
  glVertex3f(0,2,0);

  glVertex3f(0,0,0);
  glVertex3f(2,0,0);

  glVertex3f(0,0,0);
  glVertex3f(0,0,2);
  glEnd();


  glColor3f(0,1,0);
  glBegin(GL_LINES);
  glVertex3f(0,0,0);
  glVertex3f(2*axis.x,2*axis.y,2*axis.z);
  glEnd();

  glColor3f(0,0,1);
  glPointSize(5);
  glBegin(GL_POINTS);
  glVertex3f(p.x,p.y,p.z);
  glEnd();

glColor3f(1,0,1);
glPointSize(1.0);
for(i=0;i<1000;i++)
{
	glLoadIdentity();
	Quaternion rp=RotateAboutAxis(p, 2.0*i*M_PI/1000.0,  axis);
	rp.ExportToMatrix(m);
	glMultMatrixf(m);
	glBegin(GL_POINTS);
	glVertex3f(p.x,p.y,p.z);
	glEnd();
}

glLoadIdentity();

  Quaternion rp=RotateAboutAxis(p, toRad(angle),  axis);
  rp.ExportToMatrix(m);
  glMultMatrixf(m);

  glColor3f(1,0,0);
  glPointSize(5);
  glBegin(GL_POINTS);
  glVertex3f(p.x,p.y,p.z);
  glEnd();
  

glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glColor3f (0, 0, 0);

glRasterPos2f(50,30);
   sprintf(buffer,"Blue point P is rotating to red point Q about the green axis, angle=%3.1f.",angle);
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

  glMatrixMode(GL_PROJECTION);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();      



 glFlush();
 glutSwapBuffers();
}


void reshape(int w, int h)
{
  GLfloat aspect = (GLfloat) w / (GLfloat) h;
  glViewport(0, 0, w, h);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  if (w <= h)
    glOrtho(-1.25, 1.25, -1.25 * aspect, 1.25 * aspect, -2.0, 2.0);
  else
    glOrtho(-1.25 * aspect, 1.25 * aspect, -1.25, 1.25, -2.0, 2.0);
  glutPostRedisplay();
}


void keyboard(unsigned char key, int x, int y)
{
  if (key=='q') exit(0);

  angle+=1.0;

  glutPostRedisplay();
}

inline void Spherical2Cartesian(double t,double p,double &X, double &Y, double &Z)
{
X=cos(p)*sin(t);
Y=sin(p);
Z=cos(p)*cos(t);	
}

int _tmain(int argc, _TCHAR* argv[])
{


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE| GLUT_DEPTH); 
  glutInitWindowSize(W,H);
  glutCreateWindow("Quaternion (for rotations)");

  glutReshapeFunc(reshape);
  glutDisplayFunc(display);
  glutKeyboardFunc(keyboard);

  glClearColor(1.0, 1.0, 1.0, 0.0);
  glEnable(GL_DEPTH_TEST);

  
  // theta phi of point p
  Spherical2Cartesian(toRad(10),toRad(25),p.x,p.y,p.z);

  // theta, phi
  Spherical2Cartesian(toRad(20),toRad(45),axis.x,axis.y,axis.z);

 
  glutIdleFunc(display);

  glutMainLoop();
	return 0;
}

