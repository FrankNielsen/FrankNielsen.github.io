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
// File: zoneplate.cpp
// 
// Description: create a zone plate image
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;

void SaveImagePPM(unsigned char * data, int w, int h, char * file);


int _tmain(int argc, _TCHAR* argv[])
{
unsigned char * img;
int x,y,index;
int w,h;



cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"Create a zone plate image."<<endl;

w=h=512;
img=new unsigned char [3*w*h];

for(x=0;x<w;x++)
	for(y=0;y<h;y++)
	{
	index=3*(y*w+x);

	if ( ((x*x+y*y)%2)==1)
	{
	img[index]=img[index+1]=img[index+2]=255;
	}
	else
	{
	img[index]=img[index+1]=img[index+2]=0;
	}
}


SaveImagePPM(img,w,h,"zoneplate.ppm");
delete [] img;

char line[256];
cout<<"Press Return key"<<endl;
gets(line);

	return 0;
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