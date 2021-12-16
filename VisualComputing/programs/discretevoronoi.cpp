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
// File: DiscreteVoronoi.cpp
// 
// Description: Rasterize Voronoi Diagrams for various "distance" functions
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream.h>
#include <math.h>

void SaveImagePPM(unsigned char * data, int w, int h, char * file);


#define NB_GENERATOR 30
#define LINELENGTH 3

#define WIDTH 800
#define HEIGHT 800


class point
{
public: double x,y;

		inline double Distance(point q)
			{return sqrt((q.x-x)*(q.x-x) + (q.y-y)*(q.y-y));}
};

point generator[NB_GENERATOR];
unsigned char red[NB_GENERATOR], green[NB_GENERATOR], blue[NB_GENERATOR];

// Voronoi image
short voronoi[WIDTH][HEIGHT];


void VoronoiEuclidean()
{
int i,j,k,winner;
long double dist,distmin;
point pixel;

// for all pixels
for(i=0;i<HEIGHT;i++)
	for(j=0;j<WIDTH;j++)
	{
	pixel.x=j;pixel.y=i;

	distmin=1.0e30;

	for(k=0;k<NB_GENERATOR;k++)
	{
	dist=pixel.Distance(generator[k]);
		if (dist<distmin) {distmin=dist;winner=k;}
	}

	voronoi[i][j]=winner;
	}
}

int _tmain(int argc, _TCHAR* argv[])
{
int i,j,index;
unsigned char *raster;

srand(2005);


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout <<"Compute a Voronoi diagram image by sampling at regular positions."<<endl;
cout <<"Be patient!"<<endl;

raster=new unsigned char[3*WIDTH*HEIGHT];

for(i=0;i<NB_GENERATOR;i++) 
	{
		generator[i].x=LINELENGTH+rand()%(WIDTH-2*LINELENGTH);
		generator[i].y=LINELENGTH+rand()%(HEIGHT-2*LINELENGTH);
		red[i]=rand()%256;green[i]=rand()%256;blue[i]=rand()%256;
	}

VoronoiEuclidean();

for(i=0;i<HEIGHT-LINELENGTH;i++)
	for(j=0;j<WIDTH-LINELENGTH;j++)
	{
	index=3*(i*WIDTH+j);

	if ((voronoi[i][j]!=voronoi[i+LINELENGTH][j])||(voronoi[i][j]!=voronoi[i][j+LINELENGTH])) 
	{
		raster[index]=raster[index+1]=raster[index+2]=0;
	}
	else
	{
	raster[index]=red[voronoi[i][j]];
	raster[index+1]=green[voronoi[i][j]];
	raster[index+2]=blue[voronoi[i][j]];
	}
	}


	for(i=0;i<NB_GENERATOR;i++) 
	{
		
		for(int k=-LINELENGTH;k<=LINELENGTH;k++)
			for(int l=-LINELENGTH;l<=LINELENGTH;l++)
			{
			index=3*((generator[i].y+k)*WIDTH+generator[i].x+l);
			raster[index]=raster[index+1]=raster[index+2]=0;
			}
	}


	SaveImagePPM(raster,WIDTH,HEIGHT,"discretevoronoi.ppm");

	delete [] raster;

	cout<<"Completed!"<<endl;

	
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
