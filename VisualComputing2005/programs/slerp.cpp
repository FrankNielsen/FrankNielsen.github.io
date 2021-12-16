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
// File: slerp.cpp
// 
// Description: Spherical linear interpolation demo program in OpenGL(R)
// ------------------------------------------------------------------------


#include "stdafx.h"

#include <windows.h>
#include <math.h>
#include <GL/gl.h>
#include <GL/glut.h>

using namespace std;

#define W 800
#define H 800

inline double drand() {return rand()/(double)RAND_MAX;}


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


	inline void Normalize()
	{
	double norm=Norm();
	u.x/=norm;u.y/=norm;u.z/=norm;
	}

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


void Slerp(Quaternion q1, Quaternion q2, Quaternion &qr , double lambda) 
{
	float dotproduct = q1.u.x * q2.u.x + q1.u.y * q2.u.y + q1.u.z * q2.u.z + q1.w * q2.w;
	float theta, st, sut, sout, coeff1, coeff2;

	// algorithm adapted from Shoemake's paper
 lambda=lambda/2.0;

	theta = (float) acos(dotproduct);
	if (theta<0.0) theta=-theta;
	
	st = (float) sin(theta);
	sut = (float) sin(lambda*theta);
	sout = (float) sin((1-lambda)*theta);
	coeff1 = sout/st;
	coeff2 = sut/st;

	qr.u.x = coeff1*q1.u.x + coeff2*q2.u.x;
	qr.u.y = coeff1*q1.u.y + coeff2*q2.u.y;
	qr.u.z = coeff1*q1.u.z + coeff2*q2.u.z;
	qr.w = coeff1*q1.w + coeff2*q2.w;

	qr.Normalize();
}


Point3D p,q,Rp;

double lambdaanim=0.0;


void MultiplyPointMatrix(float m[16], Point3D p, Point3D& rotp)
{
rotp.x=m[0]*p.x+m[1]*p.y+m[2]*p.z;
rotp.y=m[4]*p.x+m[5]*p.y+m[6]*p.z;
rotp.z=m[8]*p.x+m[9]*p.y+m[10]*p.z;
}



void display(void)
{
  GLfloat m[16];
  char buffer[256];
  double s=1.0;

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glColor3f(0.8,0.8,0.8);
  glutSolidSphere(0.99,32,32);

  glColor3f(1,1,0);
  glBegin(GL_LINES);
  glVertex3f(0,0,0);
  glVertex3f(0,2,0);

  glVertex3f(0,0,0);
  glVertex3f(2,0,0);

  glVertex3f(0,0,0);
  glVertex3f(0,0,2);
  glEnd();

  glColor3f(0,0,1);
  glPointSize(10);
  glBegin(GL_POINTS);
  glVertex3f(p.x,p.y,p.z);
  glEnd();

  glColor3f(1,0,1);
  glBegin(GL_POINTS);
  glVertex3f(q.x,q.y,q.z);
  glEnd();

Quaternion quatp,quatq, quatr;
quatp.u=p;quatp.w=0;
quatq.u=q;quatq.w=0;

glColor3f(0,1,0);
glPointSize(1.0);

glBegin(GL_LINE_STRIP);
for(double lambda=0;lambda<=1.01;lambda+=0.01)
{
	Slerp(quatp, quatq, quatr,lambda);
	quatr.ExportToMatrix(m);
	MultiplyPointMatrix(m,p,Rp);
	glVertex3f(s*Rp.x,s*Rp.y,s*Rp.z);
}
glEnd();

lambdaanim+=0.01; 
if (lambdaanim>1.0) lambdaanim=0.0;

Slerp(quatp, quatq, quatr,lambdaanim);
quatr.ExportToMatrix(m);
MultiplyPointMatrix(m,p,Rp);

glPointSize(5);
glColor3f(1,0,0);
glBegin(GL_POINTS);
glVertex3f(s*Rp.x,s*Rp.y,s*Rp.z);
glEnd();


glMatrixMode(GL_PROJECTION);
glPushMatrix();

  glLoadIdentity();
  glOrtho (0.0, W, 0.0, H, -1.0, 1.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glColor3f (0, 0, 0);

glRasterPos2f(50,30);
sprintf(buffer,"Spherical Linear Interpolation of Quaternions (L=%.3f)",lambdaanim);
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);

  glRasterPos2f(50,H-30);
sprintf(buffer,"Press any key to initialize another pair of points.");
   for(int i=0;buffer[i]!=0;i++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[i]);


  glMatrixMode(GL_PROJECTION);
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

inline void Spherical2Cartesian(double t,double p,double &X, double &Y, double &Z)
{
X=cos(p)*sin(t);
Y=sin(p);
Z=cos(p)*cos(t);	
}

void keyboard(unsigned char key, int x, int y)
{
  if (key=='q') exit(0);

// theta phi of point p
  Spherical2Cartesian(M_PI*drand()*2.0,-M_PI/2.0+M_PI*drand(),p.x,p.y,p.z);

  // theta, phi of point q
  Spherical2Cartesian(M_PI*drand()*2.0,-M_PI/2.0+M_PI*drand(),q.x,q.y,q.z);



  glutPostRedisplay();
}



int _tmain(int argc, _TCHAR* argv[])
{

  srand(1234);

  
	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE| GLUT_DEPTH); 
  glutInitWindowSize(W,H);
  glutCreateWindow("Quaternion SLERP");

  glutReshapeFunc(reshape);
  glutDisplayFunc(display);
  glutKeyboardFunc(keyboard);

  glClearColor(1.0, 1.0, 1.0, 0.0);
  glEnable(GL_DEPTH_TEST);

  glutIdleFunc(display);

  keyboard(0,0,0);
  glutMainLoop();
	return 0;
}

