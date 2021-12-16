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
// File: ShamosHoey.cpp
// 
// Description: Detect whether a set of line segments intersect or not
// Implement in a STL fashion a simple but optimal algorithm 
// to detect whether there exists an intersection point among a set of n segments in O(n log n) time
//
// Michael I. Shamos and Dan Hoey. 
// "Geometric intersection problems" (FOCS 1976)
// In 17th Annual Symposium on Foundations of Computer Science
// pages 208-215, Houston, Texas, 25-27 October 1976. IEEE. 
// ------------------------------------------------------------------------

#include "stdafx.h"


#include <vector>
#include <algorithm>
#include <windows.h>
#include <GL/gl.h>
#include <GL/glut.h>

#define W 900
#define H 900

using namespace std;

enum type {LEFT, RIGHT};

class point {
public:
double x,y;
int n;
type endpoint;


// Lexicographic order on the x-coordinate
bool operator <  ( const point & rhs)
{return (x<rhs.x);}

bool operator >  (const point & rhs)
{return (x>rhs.x);}
};

class segment {
public:
point A,B;
};

class Yline {
public:
static double x;

double a,b; // equation of nonvertical line y=ax+b
int n;

void setX(double xx) {x=xx;}

bool operator <  ( const Yline &  rhs)
{
//	cout <<"\t\tGeneric dictionary (inferior): "<<x<<endl;
	return (a*x+b<rhs.a*x+rhs.b);
}

bool operator >  ( const Yline &  rhs)
{
//	cout <<"\t\tGeneric dictionary (inferior): "<<x<<endl;
	return (a*x+b>rhs.a*x+rhs.b);
}

bool operator ==  ( const Yline &  rhs)
{
//	cout <<"\t\tGeneric dictionary (inferior): "<<x<<endl;
	return (a*x+b == rhs.a*x+rhs.b);}

};


double Yline::x;

bool intersection=false;

// Orientation test: 2x2 determinant sign
#define ERR 1.0e-6
#define CCW 1
#define ON 0
#define CW -1



int Orient2D( const point& p, const point& q, const point& r)
  {
	  if ((q.x-p.x)*(r.y-p.y) > (r.x-p.x)*(q.y-p.y)+ERR) return CCW;
 	  if ((q.x-p.x)*(r.y-p.y) < (r.x-p.x)*(q.y-p.y)-ERR) return CW;

   return ON;
  }


  bool SegmentIntersect(segment s1, segment s2)
		{

		if (Orient2D(s1.A,s1.B,s2.A)==Orient2D(s1.A,s1.B,s2.B)) return false;
		if (Orient2D(s2.A,s2.B,s1.A)==Orient2D(s2.A,s2.B,s1.B)) return false;
		intersection=true;
		return true;
		}

// Return a random number in [0,1]
inline double randd()
	{
		return (double)rand()/(double)RAND_MAX;
	}


// Line equation + segment number
void SegmentToYevent(segment S, int nn, Yline& eventp)
{
	eventp.n=nn;
	eventp.a=(S.B.y-S.A.y)/(S.B.x-S.A.x); //slope
	eventp.b=S.A.y-eventp.a*S.A.x; // y=ax+b
}

int Intersect()
{
cout << "Some pair of segments intersect"<<endl;
return 1;
}

//--------- Global variables for animation purposes

int n=10;
int ibelow, iabove, ime;
point P1,P2;
vector<point> T;
vector<point>::iterator event;
vector<Yline> Yorder;
vector<Yline>::iterator pos, below, above;
Yline yevent;
segment *seg;
double ycoord;
int inter1,inter2;
static nbstep=0;

void disp()
{
int i;
char buffer[256];
vector<Yline>::iterator yo;

glClearColor(1,1,1,0);
glClear(GL_COLOR_BUFFER_BIT);


glColor3f(0,0,1);
glPointSize(2);

// Draw the line segments
glBegin(GL_LINES);
for(i=0;i<n;i++)
	{
	glVertex2f(seg[i].A.x,seg[i].A.y);
	glVertex2f(seg[i].B.x,seg[i].B.y);
	}
glEnd();

glColor3f(0,0,0);
for(i=0;i<n;i++)
	{
	glRasterPos2f((seg[i].A.x+seg[i].B.x)/2.0,(seg[i].A.y+seg[i].B.y)/2.0);
	sprintf(buffer,"%3d",i);
   for(int ii=0;buffer[ii]!=0;ii++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[ii]);
	}

	

// Draw the line segment endpoints
glColor3f(0,1,0);
glPointSize(4);
glBegin(GL_POINTS);
for(i=0;i<n;i++)
	{
	glVertex2f(seg[i].A.x,seg[i].A.y);
	glVertex2f(seg[i].B.x,seg[i].B.y);
	}
glEnd();

if ((*event).x<=1.0)
{

glColor3f(1,0,0);
//cout<<"X-coord sweep line:"<<(*event).x<<endl;

//Draw the sweep line and the above/below line query
glBegin(GL_LINES);
glVertex2f((*event).x,0);
glVertex2f((*event).x,1);

glVertex2f(0,(*event).y);
glVertex2f(1,(*event).y);
glEnd();

// Draw the segment traces on the sweep line

glPointSize(15.0);
glColor3f(0,0,0);
glBegin(GL_POINTS);


cout<<"Order on the sweep line:";

for(yo=Yorder.begin();yo!=Yorder.end();yo++)
{

ycoord=(*yo).a*(*event).x+(*yo).b;
	glVertex2f((*event).x,ycoord);
	cout<<(*yo).n<<" ";

}
cout<<endl;
glEnd();


glLineWidth(3);
glColor3f(0.3,0.3,0.3);
if (iabove>-1)
{
glBegin(GL_LINES);
	glVertex2f(seg[iabove].A.x,seg[iabove].A.y);
	glVertex2f(seg[iabove].B.x,seg[iabove].B.y);
glEnd();
}

if (ibelow>-1)
{
glBegin(GL_LINES);
	glVertex2f(seg[ibelow].A.x,seg[ibelow].A.y);
	glVertex2f(seg[ibelow].B.x,seg[ibelow].B.y);
glEnd();
}
glLineWidth(1);

if (ime>-1)
{
glColor3f(0,1,0);
glBegin(GL_LINES);
	glVertex2f(seg[ime].A.x,seg[ime].A.y);
	glVertex2f(seg[ime].B.x,seg[ime].B.y);
glEnd();
}


if (intersection)
{
glColor3f(1,0,0);
glRasterPos2f(0.1,0.9);
sprintf(buffer,"Detected a pair of intersecting line segments! Press 'r' for another set");
for(int ii=0;buffer[ii]!=0;ii++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[ii]);

glColor3f(1,0,0);
glLineWidth(5);
glBegin(GL_LINES);
	glVertex2f(seg[inter1].A.x,seg[inter1].A.y);
	glVertex2f(seg[inter1].B.x,seg[inter1].B.y);
glVertex2f(seg[inter2].A.x,seg[inter2].A.y);
	glVertex2f(seg[inter2].B.x,seg[inter2].B.y);
	glEnd();
	glLineWidth(1);

}

if (nbstep>=2*n)
	{

glColor3f(1,0,0);
glRasterPos2f(0.01,0.9);
sprintf(buffer,"I have not detected any pair of intersecting segments ! Press 'r' for another set");
for(int ii=0;buffer[ii]!=0;ii++)
   glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, buffer[ii]);

	}

}



glFlush();
glutSwapBuffers();
}

void HandleEvent();
void InitializeSegments();


void key(unsigned char key , int x , int y) 
{

if (key=='r')
{
intersection=false;
nbstep=0;
InitializeSegments();
disp();
}
else{
	if (!intersection){
	nbstep++;


	if (nbstep<2*n)
	{
	event++;
	cout << "Number of segments crossing the Y sweep line:" << (unsigned int)Yorder.size() << endl;
	HandleEvent();
	}
	}
	
	// Refresh the animation
	disp();
}
}


void SeekBelowAbove()
{
iabove=ibelow=-1;

	for(int i=0;i<Yorder.size();i++)
	{
	if (Yorder[i]<yevent) 
		{
			if (ibelow==-1) ibelow=i;
				else if (Yorder[i]>Yorder[ibelow]) ibelow=i;
		}

	if (Yorder[i]>yevent) 
		{
		if (iabove==-1) iabove=i;
		else if (Yorder[i]<Yorder[iabove]) iabove=i;
		}
		
	}

	if (iabove!=-1) iabove=Yorder[iabove].n;
	if (ibelow!=-1) ibelow=Yorder[ibelow].n;

	cout<<"Above:"<<iabove<<" Below;"<<ibelow<<endl;
		}


//
// Handle a combinatorial event here
//
void HandleEvent()
{
ime=(*event).n;

SegmentToYevent(seg[(*event).n],(*event).n, yevent);

// we set the sweep line here for the generic dictionary
yevent.setX((*event).x); 


switch((*event).endpoint)
{
// segment (*event).n is combinatorial event

case LEFT: // Left endpoint
	
	cout<<"Insert segment number "<<ime<<endl;
	
	if (Yorder.size()>0)
	{
	below=Yorder.begin();
	while( (below!=Yorder.end()) && ((*below)<yevent) ) below++;

	Yorder.insert(below,yevent);
	}
	else Yorder.insert(Yorder.begin(),yevent);

	SeekBelowAbove();

	if (ibelow!=-1) 
		if (SegmentIntersect(seg[ime],seg[ibelow])) 
		{cout<<"segments "<<ime<<" and "<<ibelow<<" intersect."<<endl;
		inter1=ime; inter2=ibelow;}

	if (iabove!=-1)
		if (SegmentIntersect(seg[ime],seg[iabove]))
		{cout<<"segments "<<ime<<" and "<<iabove<<" intersect."<<endl;
	inter1=ime;inter2=iabove;}
	break;


case RIGHT: // Right endpoint
	
	cout<<"Remove segment number "<<ime<<endl;
	below=Yorder.begin();

	while((*below)<yevent) below++;
	Yorder.erase(below);

	SeekBelowAbove();

	if ((ibelow!=-1)&&(iabove!=-1)) 
		if (SegmentIntersect(seg[iabove],seg[ibelow]))
		{cout<<"segments "<<iabove<<" and "<<ibelow<<" intersect."<<endl;
	inter1=iabove;inter2=ibelow;}
	
	
	break;
}

}

// Main program interface

void InitializeSegments()
{int i;
double length=0.30;


cout<<"Create randomly "<<n<<" line segments."<<endl;

T.clear();

	for(i=0;i<n;i++)
	{
redraw:
	P1.x=randd();P1.y=randd();P1.n=i;
	P2.x=randd();P2.y=randd();P2.n=i;
	
	if ((P1.x-P2.x)*(P1.x-P2.x)+(P1.y-P2.y)*(P1.y-P2.y)>length*length) goto redraw;
	
	if (P1.x<P2.x) {P1.endpoint=LEFT; P2.endpoint=RIGHT; seg[i].A=P1; seg[i].B=P2;}
	if (P1.x>P2.x) {P1.endpoint=RIGHT; P2.endpoint=LEFT; seg[i].A=P2; seg[i].B=P1;}

	T.push_back(P1);
	T.push_back(P2);
	}	
	
cout<<"Sort the x-coordinates of segment endpoints."<<endl;
sort(T.begin(),T.end());
Yorder.clear();

iabove=ibelow=-1;

event=T.begin();
HandleEvent();
}


int _tmain(int argc, _TCHAR* argv[])
{
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"Press 'r' key to draw another line segment set."<<endl;

srand(2005);
 
seg=new segment[n];


InitializeSegments();

	glutInit(&argc , argv);
	glutInitWindowPosition(50,50);
	glutInitWindowSize(W,H);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGBA);

	glutCreateWindow("Line segment intersection detection algorithm (Sweep line algorithm).");
	glutDisplayFunc(disp);

	srand(2005);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0,1,0,1,-1,1);
	glMatrixMode(GL_MODELVIEW);
	
	glutKeyboardFunc(key);
	glutMainLoop();

cout<<"Press Return key"<<endl;
char line[100];
gets(line);

return 0;
}

