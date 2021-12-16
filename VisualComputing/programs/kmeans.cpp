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
// File: kmeans.cpp
// 
// Description: LLoyd iterative optimization clustering procedure
// At each step the sum of the squared differences decrease
// ------------------------------------------------------------------------

#include "stdafx.h"
#include "windows.h"
#include <GL/gl.h>
#include <GL/glut.h>
#include <math.h>

using namespace std;

#define square(x) ((x)*(x))

struct point2d
{
public: double x,y;
		int cluster; // membership
};


struct color{public: float r,g,b;};



int k;
point2d * centroid;
point2d * circumcenter;
color* clustercolor;


point2d * set;
int n;
int *nb, *nbc;


void init()
{int i;


n=500;
set=new point2d[n];

k=10;
centroid=new point2d[k];
clustercolor=new color[k];
nb=new int[k];
nbc=new int[k];


// Uniform distribution
for(i=0;i<n;i++)
{
set[i].x=(float)rand()/(float)RAND_MAX;
set[i].y=(float)rand()/(float)RAND_MAX;
set[i].cluster=0;
}


// E. Forgy initialization's rule
for(i=0;i<k;i++)
{
centroid[i]=set[rand()%n];
clustercolor[i].r=(float)rand()/(float)RAND_MAX;
clustercolor[i].g=(float)rand()/(float)RAND_MAX;
clustercolor[i].b=(float)rand()/(float)RAND_MAX;
}

}


// Hard membership
void KMeansAssign()
{
int i,j,winner;
double dist,distmin;

for(i=0;i<n;i++)
{
distmin=1.0e8;
	for(j=0;j<k;j++)
	{
	dist=sqrt(square(set[i].x-centroid[j].x)+square(set[i].y-centroid[j].y));
	if (dist<distmin) {distmin=dist; winner=j;}
	}
set[i].cluster=winner;
}

}

// KMeansAssign()
void KMeansCluster()
{
int i,j,cl;

for(j=0;j<k;j++)
	{
	nb[j]=0;
	centroid[j].x=centroid[j].y=0;
	}

for(i=0;i<n;i++)
	{
	cl=set[i].cluster;
	centroid[cl].x+=set[i].x;
	centroid[cl].y+=set[i].y;
	nb[cl]++;
	}

	nbc[0]=0;
for(j=0;j<k;j++)
	{
		if (j>0) {nbc[j]=nbc[j-1]+nb[j];}
	if (nb[j]>0) {centroid[j].x/=nb[j];centroid[j].y/=nb[j];}
	cout <<"Class "<<j<<" "<<nb[j]<<" "<<centroid[j].x<<" "<<centroid[j].y<<" ["<<nbc[j]<<"]"<<endl;
	nb[j]=0;
	}

}




void disp( void ) {
	glClearColor(1 , 1 , 1 , 0);
	glClear(GL_COLOR_BUFFER_BIT);
	glPointSize(2.0f);


	glBegin(GL_POINTS);
	
for(int i=0;i<n;i++)
{
	int cl=set[i].cluster;
	glColor3f(clustercolor[cl].r,clustercolor[cl].g,clustercolor[cl].b);
	glVertex2f(set[i].x,set[i].y);
}
glEnd();

// Centroids
glPointSize(5.0f);
glBegin(GL_POINTS);
for(int i=0;i<k;i++)
{
	glColor3f(clustercolor[i].r,clustercolor[i].g,clustercolor[i].b);
	glVertex2f(centroid[i].x,centroid[i].y);
}
glEnd();

	glFlush();
	glutSwapBuffers();


}


void key(unsigned char key , int x , int y) {
	printf("Key = %c\n" , key);

	if (key==' ')
	{
	// One Lloyd iteration
	KMeansAssign();
	KMeansCluster();
	disp();
	}
}



int _tmain(int argc, _TCHAR* argv[])
{

	
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"K-means clustering."<<endl;
cout<<"Press any key to perform one more iteration."<<endl;

	glutInit(&argc , argv);
	glutInitWindowPosition(100 , 100);
	glutInitWindowSize(800, 800);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);

	glutCreateWindow("k-Means clustering. ");
	glutDisplayFunc(disp);
	glutKeyboardFunc(key);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0 , 1 , 0 , 1 , -1 , 1);
	glMatrixMode(GL_MODELVIEW);
	init();
	KMeansAssign();

	glutMainLoop();

	return 0;
}

