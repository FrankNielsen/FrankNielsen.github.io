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
// File: spheremap.cpp
// 
// Description: Reflection mapping in OpenGL(R) using a sphere map texture image
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <windows.h>

#include <fstream>
#include <GL/gl.h>
#include <GL/glut.h>
#include <math.h>

using namespace std;

float angle=0.0;

// Load a PPM Image that does not contain comments.

unsigned char * LoadImagePPM(char *ifile,  int &w, int &h)
{
	char dummy1=0, dummy2=0; int maxc;
	unsigned char * img;
	ifstream fileinput(ifile, ios::binary);

	fileinput.get(dummy1);
	fileinput.get(dummy2);
	if ((dummy1!='P')&&(dummy2!='6')) {cerr<<"Not P6 PPM file"<<endl; return NULL;}
 
    fileinput >> w >> h;
    fileinput >> maxc;
    fileinput.get(dummy1);
	
    img=new  unsigned char[3*w*h];
	fileinput.read((char *)img, 3*w*h); 
	fileinput.close();
	return img;
}

#define M_PI        3.14159265358979323846

SetupTexturewithMipmap(char* filename, GLuint id);

static GLfloat lightposition[] = {-10.0, 10.0, 10.0, 0.0};
static GLfloat lightambient[] = {0.3, 0.3, 0.3, 1.0};
static GLfloat lightspecular[] = {0.8, 0.6, 0.8, 1.0};
static GLfloat lightdiffuse[] = {1.0, 1.0, 1.0, 1.0};
static GLfloat materialdiffuse[] = {1.0, 0.7, 1.0, 0.0};

GLuint texid[1];

void reshape(GLsizei w, GLsizei h)
{
  glViewport(0, 0, w, h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(54.0, (GLfloat)(w/h), 2, 100);
}



void Init()
{
  glClearColor(1,1,1, 0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(54.0, 1.0, 2.0, 100.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glLightfv(GL_LIGHT0, GL_POSITION, lightposition);
  glLightfv(GL_LIGHT0, GL_AMBIENT, lightambient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, lightdiffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR, lightspecular);
  glEnable(GL_LIGHT0);
  glEnable(GL_LIGHTING);
  glEnable(GL_NORMALIZE);
  glEnable(GL_DEPTH_TEST);
  glGenTextures(1, texid);
  
  SetupTexturewithMipmap("mirrorball512.ppm", texid[0]);

  glBindTexture(GL_TEXTURE_2D, texid[0]);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
  glEnable(GL_TEXTURE_2D);
}

void RenderScene()
{
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);

  angle+=1.0;if (angle>360) angle-=360;

  glRotatef(angle,1,0,1);
  glutSolidTeapot(1.0);
  
  glDisable(GL_TEXTURE_GEN_T);
  glDisable(GL_TEXTURE_GEN_S);
}

void display()
{
  glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(0.0, 0.0, -4.0);
  glPushMatrix();
 
  glMaterialfv(GL_FRONT, GL_DIFFUSE, materialdiffuse);
  glBindTexture(GL_TEXTURE_2D, texid[0]);
  RenderScene();
  glPopMatrix();
  glutSwapBuffers();
}



void idle()
{
glutPostRedisplay();
}

void keyboard(unsigned char c, int x, int y)
{
  static int move=1;
  switch(c){
  case 'q':
    exit(0);
  case ' ':
    move=move?0:1;
    if(move == 1) glutIdleFunc(NULL);
    else glutIdleFunc(idle);
    break;
  default:
    break;
  }
}




int _tmain(int argc, _TCHAR* argv[])
{
 
 
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
 
  glutInitWindowPosition(0,0);
  glutInitWindowSize(1024,1024);

  glutCreateWindow("Reflection mapping using a sphere map");

  Init();
 
  glutDisplayFunc(display);
  glutIdleFunc(idle);
  glutReshapeFunc(reshape);
  glutKeyboardFunc(keyboard);
  glutMainLoop();
 
  return 0;
}



int SetupTexturewithMipmap(char* filename, GLuint id)
{ 
 int size; 
  GLubyte* data; 
 
  data=LoadImagePPM(filename,size,size);
  cout<<"Texture size:"<<size<<endl;
  glBindTexture(GL_TEXTURE_2D, id); 
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1); 
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB, size, size,  GL_RGB, GL_UNSIGNED_BYTE, data);
  
 return 1;
} 


