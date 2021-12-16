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
// File: BlendHomography.cpp
// 
// Description: Match two perspective images by an homography (simple blending)
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>
#include <math.h>

using namespace std;


class Point{
public:
	double x,y,z;

	Point(){x=y=z=0.0;}
	Point (double xx,double yy, double zz) {x=xx;y=yy;z=zz;}

//
// Cross product of two vectors. 
// Returns a vector perpendicular to the plane spanned by the two vectors
//
inline void Point::CrossProduct(Point v1,Point v2) 
{ 
		x=v1.y*v2.z-v1.z*v2.y;
        y=v1.z*v2.x-v1.x*v2.z;
        z=v1.x*v2.y-v1.y*v2.x;
}

inline void   Point::ScalarMultiply(Point v,double l)
{
x=l*v.x;
y=l*v.y;
z=l*v.z;
}


};
   
	

inline double DotProduct(Point v1, Point v2)
{
double res;

res=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;
return res;
}




class Matrix{
public: 
	double array[3][3];
};


void MatrixMultiply(Matrix m1,Matrix m2, Matrix &result)
{
int i,j,k;
double res;


for(i = 0; i < 3; i++)
 for(j = 0; j < 3; j++){
      res = 0.0; 
      for(k = 0; k < 3; k++) 
	res += (m1.array[i][k] * m2.array[k][j]);
      result.array[i][j] = res;
    }

}


//
// Compute the homography by decomposing to the unit square
// We can compute the inverse of a matrix as InvM=AdjunctM/detM. This implies mostly
// multiplications. Also since it is a projective transformation we can discard the 
// computation of det M
//
int ComputeHomography4Points(Point l[4], Point r[4], Matrix &H)
{
int i,j;
Point cp[6],col[3],lig[3],pv[3];
double det[6];
Matrix H1inv,H2,tmp;

cp[0].CrossProduct(r[2],r[3]);
cp[1].CrossProduct(r[0],r[3]);
cp[2].CrossProduct(r[2],r[0]);

cp[3].CrossProduct(l[2],l[3]);
cp[4].CrossProduct(l[0],l[3]);
cp[5].CrossProduct(l[2],l[0]);


det[0]=DotProduct(r[0],cp[0]);
det[1]=DotProduct(r[1],cp[1]);
det[2]=DotProduct(r[1],cp[2]);
det[3]=DotProduct(l[0],cp[3]);
det[4]=DotProduct(l[1],cp[4]);
det[5]=DotProduct(l[1],cp[5]);

col[0].ScalarMultiply(r[1],det[0]);
col[1].ScalarMultiply(r[2],det[1]);
col[2].ScalarMultiply(r[3],det[2]);
  
pv[0].CrossProduct(l[2], l[3]);
pv[1].CrossProduct(l[3], l[1]);
pv[2].CrossProduct(l[1], l[2]);

if ((det[0]!=0.0)&&(det[1]!=0.0)&&(det[2]!=0.0)\
	&&(det[3]!=0.0)&&(det[4]!=0.0)&&(det[5]!=0.0))
  {
	// Non-degenerate case
      lig[0].ScalarMultiply(pv[0],1.0/det[3]);
      lig[1].ScalarMultiply(pv[1],1.0/det[4]);
      lig[2].ScalarMultiply(pv[2],1.0/det[5]);


	  H1inv.array[0][0]=lig[0].x;
	  H1inv.array[0][1]=lig[0].y;
      H1inv.array[0][2]=lig[0].z;

	  H1inv.array[1][0]=lig[1].x;
	  H1inv.array[1][1]=lig[1].y;
      H1inv.array[1][2]=lig[1].z;

	  H1inv.array[2][0]=lig[2].x;
	  H1inv.array[2][1]=lig[2].y;
      H1inv.array[2][2]=lig[2].z;

	  H2.array[0][0]=col[0].x;
	  H2.array[1][0]=col[0].y;
	  H2.array[2][0]=col[0].z;

	  H2.array[0][1]=col[1].x;
	  H2.array[1][1]=col[1].y;
	  H2.array[2][1]=col[1].z;

	  H2.array[0][2]=col[2].x;
	  H2.array[1][2]=col[2].y;
	  H2.array[2][2]=col[2].z;

   
      MatrixMultiply(H2,H1inv,tmp);

      // Normalize...
      
      for(i=0;i<3;i++)
		{
		for(j=0;j<3;j++)
			H.array[i][j]=(tmp.array[i][j]/tmp.array[2][2]);
		}
	  return 1;
    }
else 
  { 
    // Degenerate case: return Id matrix.
    for(i=0;i<3;i++)
		{
		for(j=0;j<3;j++) H.array[i][j]=((i==j)? 1.0 : 0.0);
		}
	return 0;
	}  
} 


void inline MatrixPoint(Matrix H,double x,double y,int &xi, int &yi)
{
double xx,yy,zz;

xx=H.array[0][0]*x+H.array[0][1]*y+H.array[0][2];
yy=H.array[1][0]*x+H.array[1][1]*y+H.array[1][2];
zz=H.array[2][0]*x+H.array[2][1]*y+H.array[2][2];


xi=(int)(xx/zz+0.5);
yi=(int)(yy/zz+0.5);
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

int _tmain(int argc, _TCHAR* argv[])
{
char filename1[]="bookcovers1.ppm";
char filename2[]="bookcovers2.ppm";
char filenameo[256];

int w,h,wo,ho, i,j;
unsigned char *img1, *img2, *imgo;
int ixorg, iyorg, index,indexo;
Point l[4], r[4];
Matrix H;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;



cout << "Blend two pictures by homography"<<endl;
cout << "Frank Nielsen"<<endl;

img1=LoadImagePPM(filename1,w,h);
img2=LoadImagePPM(filename2,w,h);
imgo=new unsigned char [3*w*h];
memset(imgo,255,3*w*h);


l[0]=Point(831,281,1.0); 
l[1]=Point(948,423,1.0);
l[2]=Point(788, 505,1.0); 
l[3]=Point(874, 641,1.0); 

r[0]=Point(811,173,1);
r[1]=Point(985,251,1);
r[2]=Point(763,371,1);
r[3]=Point(904,443,1);

ComputeHomography4Points(r,l,H);

// Should implement a better interpolator. Here we use nearest neighbor
for(i=0;i<h;i++)
for(j=0;j<w;j++)
{
MatrixPoint(H,j,i,ixorg,iyorg);

index=3*(iyorg*w+ixorg); 
indexo=3*(i*w+j);

if ((iyorg>0)&&(iyorg<h)&&(ixorg>0)&&(ixorg<w))
{
imgo[indexo]=0.5*(img1[index]+img2[indexo]);
imgo[indexo+1]=0.5*(img1[index+1]+img2[indexo+1]);
imgo[indexo+2]=0.5*(img1[index+2]+img2[indexo+2]);
}
else

{
imgo[indexo]=(img2[indexo]);
imgo[indexo+1]=(img2[indexo+1]);
imgo[indexo+2]=(img2[indexo+2]);
}

}

for(i=0;i<3;i++){

for(j=0;j<3;j++)
{
cout <<H.array[i][j]<<" ";
}
cout <<endl;
}


sprintf(filenameo,"blendhomography.ppm");
SaveImagePPM(imgo,w,h,filenameo);


char line[256];
cout<<"Press Return key"<<endl;
gets(line);


delete [] img1; delete [] img2;
delete [] imgo;

	return 0;
}

