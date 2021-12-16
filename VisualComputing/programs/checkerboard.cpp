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
// File: checkerboard.cpp
// 
// Description: Create and save a checkerboard texture
// Map the texture onto a 3D quad in OpenGL(R)
// ------------------------------------------------------------------------


#include "stdafx.h"
#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;

#include <GL/glut.h>
#include <GL/glu.h>
#include <stdlib.h>
#include <stdio.h>

/*	Create checkerboard texture	*/
#define	checkImageWidth 64
#define	checkImageHeight 64
static GLubyte checkImage[checkImageHeight][checkImageWidth][4];

#ifdef GL_VERSION_1_1
static GLuint texName;
#endif

void makeCheckImage(void)
{
   int i, j, c;
    
   for (i = 0; i < checkImageHeight; i++) {
      for (j = 0; j < checkImageWidth; j++) {
         c = ((((i&0x8)==0)^((j&0x8))==0))*255;
         checkImage[i][j][0] = (GLubyte) c;
         checkImage[i][j][1] = (GLubyte) c;
         checkImage[i][j][2] = (GLubyte) c;
         checkImage[i][j][3] = (GLubyte) 255;
      }
   }
}

void init(void)
{    
   glClearColor (0.5, 0.5, 0.5, 0.0);
   glShadeModel(GL_FLAT);
   glEnable(GL_DEPTH_TEST);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);	


   makeCheckImage();
   glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

#ifdef GL_VERSION_1_1
   glGenTextures(1, &texName);
   glBindTexture(GL_TEXTURE_2D, texName);
#endif

   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
#ifdef GL_VERSION_1_1
   glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, checkImageWidth, checkImageHeight, 
                0, GL_RGBA, GL_UNSIGNED_BYTE, checkImage);
#else
   glTexImage2D(GL_TEXTURE_2D, 0, 4, checkImageWidth, checkImageHeight, 
                0, GL_RGBA, GL_UNSIGNED_BYTE, checkImage);
#endif
}

const GLfloat maxi=10000;
void display(void)
{
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   glEnable(GL_TEXTURE_2D);
   glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
#ifdef GL_VERSION_1_1
   glBindTexture(GL_TEXTURE_2D, texName);
#endif

   glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0); glVertex3f(-maxi, -maxi, 0.0);
   glTexCoord2f(0.0, 1.0); glVertex3f(maxi, -maxi, 0.0);
   glTexCoord2f(1.0, 1.0); glVertex3f(maxi, maxi, 0.0);
   glTexCoord2f(1.0, 0.0); glVertex3f(maxi, -maxi, 0.0);

   
   glEnd();
   glFlush();
   glDisable(GL_TEXTURE_2D);
}

void reshape(int w, int h)
{
   glViewport(0, 0, (GLsizei) w, (GLsizei) h);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(80.0, (GLfloat) w/(GLfloat) h, 1.0, 10.0*maxi);
   gluLookAt(0,0,3000, maxi/2,-maxi,0,0,0,1);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
  
}

void keyboard (unsigned char key, int x, int y)
{
   switch (key) {
      case 's':
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
         glutPostRedisplay();
         break;
      case 'S':
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
         glutPostRedisplay();
         break;
      case 't':
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
         glutPostRedisplay();
         break;
      case 'T':
         glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
         glutPostRedisplay();
         break;
      case 27:
         exit(0);
         break;
      default:
         break;
   }
}

// Save a PPM Image
void SaveImagePPM(unsigned char * data, int w, int h, char * file)
{
	ofstream OUT(file, ios::binary);
	if (OUT){
    OUT << "P6" << endl << w << ' ' << h << endl << 255 << endl;
	OUT.write((char *)data, 3*w*h);
	OUT.close();}
}

// Load a PPM Image that does not contain comments.
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h)
{
	 char dummy1=0, dummy2=0; int maxc;
	unsigned char * img;
	ifstream IN(ifile, ios::binary);

	IN.get(dummy1);IN.get(dummy2);
	if ((dummy1!='P')&&(dummy2!='6')) {cerr<<"Not P6 PPM file"<<endl; return NULL;}
 
    IN >> w >> h;
    IN >> maxc;
    IN.get(dummy1);
	
    img=new  unsigned char[3*w*h];
	IN.read((char *)img, 3*w*h); 
	IN.close();
	return img;
}

void CreateCheckerBoard()
{
unsigned char *img;
int w=512, h=512, i,j,I,J,index;
int step=64;

img=new unsigned char[3*w*h];

for(i=0;i<h;i++)
for(j=0;j<w;j++)
{
index=3*(i*w+j);
I=i/step; J=j/step;

if (((I+J)%2)==0)
{
	img[index]=img[index+1]=img[index+2]=255;
}
else
{
img[index]=img[index+1]=img[index+2]=0;
}

}

SaveImagePPM(img,w,h,"checkerboard.ppm");
delete [] img;
}



int main(int argc, char** argv)
{

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


   CreateCheckerBoard();
   glutInit(&argc, argv);
   glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
   glutInitWindowSize(512,512);
   glutInitWindowPosition(0,0);
   glutCreateWindow("Checkerboard");
   init();
   glutDisplayFunc(display);
   glutReshapeFunc(reshape);
   glutKeyboardFunc(keyboard);
   glutMainLoop();
   return 0; 
}



