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
// File: areafloodfill.cpp
// 
// Description: Compute the first elements of Fibonacci series 
// with or without pointer arithmetic
// ------------------------------------------------------------------------

#include "stdafx.h"

#include <iostream>
#include <fstream>
using namespace std;

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

class pixel{public: int x, int y;
pixel(int xcoord=0, int ycoord=0) {x=xcoord; y=ycoord;}
};

class color{public: unsigned char red, green, blue;};


// Queue (FIFO) implemented using a circular buffer

#define MAXSTACK 40000

class queue
{
public:

pixel pos[MAXSTACK];
int head, tail, count;


queue()
{
head=0;
tail=-1;
count=0;
}

inline void enQueue(pixel p)
{
if (count==MAXSTACK-1) cerr<<"Enqueue impossible"<<endl;
if (tail++==MAXSTACK) tail=0;

pos[tail]=p;
++count;
}

inline void deQueue()
{
	if (count!=0)
	{
	if (++head==MAXSTACK) head=0;
	count--;
	} else cerr<<"Dequeue impossible"<<endl;
}

inline void headQueue(pixel &p)
{
if (count>0) p=pos[head];
	else cerr<<"Head impossible"<<endl;
}


};



int FillRegionQueue(unsigned char *wr, int w, int h, pixel p, color background, color foreground)
{
int pos;
queue Q;

pos=p.y*w+p.x;

if ((wr[3*pos]==background.red) && (wr[3*pos+1 ]==background.green) && (wr[3*pos+2 ]==background.blue) )
{
wr[3*pos]=foreground.red;
wr[3*pos+1]=foreground.green;
wr[3*pos+2]=foreground.blue;

Q.enQueue(p);
}


while(Q.count>0)
{
Q.headQueue(p);

if (p.x>0) 
	{
	pos=p.y*w+(p.x-1);
	
	if ((wr[3*pos]==background.red) && (wr[3*pos+1 ]==background.green) && (wr[3*pos+2 ]==background.blue) )
	{
	wr[3*pos]=foreground.red;
	wr[3*pos+1]=foreground.green;
	wr[3*pos+2]=foreground.blue;

	Q.enQueue(pixel(p.x-1,p.y));
	}
	}

	
if (p.x<w-1) 
	{
	pos=p.y*w+(p.x+1);
	
	if ((wr[3*pos]==background.red) && (wr[3*pos+1 ]==background.green) && (wr[3*pos+2 ]==background.blue) )
	{
	wr[3*pos]=foreground.red;
	wr[3*pos+1]=foreground.green;
	wr[3*pos+2]=foreground.blue;
	
	Q.enQueue(pixel(p.x+1,p.y));
	}
	}

if (p.y>0) 
	{
	pos=(p.y-1)*w+p.x;
	
	if ((wr[3*pos]==background.red) && (wr[3*pos+1 ]==background.green) && (wr[3*pos+2 ]==background.blue) )
	{
	wr[3*pos]=foreground.red;
	wr[3*pos+1]=foreground.green;
	wr[3*pos+2]=foreground.blue;
	
	Q.enQueue(pixel(p.x,p.y-1));
	}
	}

if (p.y<h-1)
	{
	pos=(p.y+1)*w+p.x;
	
	if ((wr[3*pos]==background.red) && (wr[3*pos+1 ]==background.green) && (wr[3*pos+2 ]==background.blue) )
	{
	wr[3*pos]=foreground.red;
	wr[3*pos+1]=foreground.green;
	wr[3*pos+2]=foreground.blue;
	
	Q.enQueue(pixel(p.x,p.y+1));
	}
	}

	Q.deQueue();

} // while Queue is not empty


return 1;

}

int _tmain(int argc, _TCHAR* argv[])
{
pixel pixelseed(270,147);
char filename[]="fillex.ppm";
color front,back;
unsigned char * img;
int w,h;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Area Flood Filling Demo Using a Queue\n"<<endl;
cout<<"Loading image "<<filename<<endl;

back.red=back.green=back.blue=255;
front.red=255;front.green=front.blue=0;

img=LoadImagePPM(filename,w,h);
FillRegionQueue(img,w,h,pixelseed,back,front);
SaveImagePPM(img,w,h,"floodfill-result.ppm");

cout<<"Press Return key"<<endl;
char line[256];
gets(line);

return 0;
}

