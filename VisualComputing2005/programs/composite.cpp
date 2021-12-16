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
// File: composite.cpp
// 
// Description: Simple image compositing demo
// ------------------------------------------------------------------------


#include "stdafx.h"
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


int _tmain(int argc, _TCHAR* argv[])
{
	char filebackground[]="background.ppm";
	 char fileforeground[]="furrydog.ppm";
 char filematte[]="furrydog-matte.ppm";
	unsigned  char *imgout, * imgmatte, * imgback;
	int w,h;
	int i,j,index;
	double alpha;

	imgout=LoadImagePPM(fileforeground,w,h);
	imgmatte=LoadImagePPM(filematte,w,h);
	imgback=LoadImagePPM(filebackground,w,h);

	
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"Image compositing using alpha channel."<<endl;

	for(i=0;i<h;i++)
		for(j=0;j<w;j++)
		{
index=3*(i*w+j);
alpha=imgmatte[index]/255.0;

imgout[index]=(unsigned char)((1-alpha)*imgback[index]+alpha*imgout[index]);
imgout[index+1]=(unsigned char)((1-alpha)*imgback[index+1]+alpha*imgout[index+1]);
imgout[index+2]=(unsigned char)((1-alpha)*imgback[index+2]+alpha*imgout[index+2]);

		}

SaveImagePPM(imgout,w,h,"composite.ppm");

delete [] imgout;
delete [] imgmatte;
delete [] imgback;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);
	return 0;
}

