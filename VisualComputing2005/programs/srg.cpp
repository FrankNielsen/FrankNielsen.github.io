/ ------------------------------------------------------------------------
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
// File: srg.cpp
// 
// Description: Statistical region growing segmentation using the union-find data structure
// -----------

// Region growing based on statistical concentration inequalities 
//
// Basic skeleton of the implementation of CVPR 2003 and TPAMI 2004

// Richard Nock and Frank Nielsen, "Statistical Region Merging", 
//     IEEE Transactions on Pattern Analysis and Machine Intelligence, 2004.
//
// Frank Nielsen and Richard Nock, "On Region Merging: the Statistical Soundness of Fast Sorting, with Applications", 
//     IEEE Computer Vision and Pattern Recognition 2003.

// 1. Read PPM Image
// 2. Sort by increasing order all pairs of adjacents pixels in 4-connectivity using max channel difference
// 3. Do region growing using the statistical predicate
// 4. Merge small regions (those having size less than 0.1% of image size)
// 5. Draw white borders of regions
// 6. Save PPM Image

#define _WINDOWS

#include "stdafx.h"
#include <fstream.h>
#include <iostream.h>


// Union-Find Data Structure
// See Tarjan, R. E. "Efficiency of a Good But Not Linear Set Union Algorithm," Journal of the ACM (JACM), 22(2), 215-225,  1975 

class ggvUnionFind{
public:
	int  *rank; 
	int *parent; 

ggvUnionFind(int n)
{int k;

parent=new int[n]; rank=new int[n];
for (k = 0; k < n; k++)
      {parent[k]   = k;rank[k] = 0;     }
}

~ggvUnionFind()
{delete [] rank; delete [] parent;}

 // Find procedures
int ggvUnionFind::Find(int k)
{
	while (parent[k]!=k ) k=parent[k];
    return k;}

// Assume x and y being roots
int ggvUnionFind::UnionRoot(int x, int y)
{  
	if ( x == y ) return -1;

      if (rank[x] > rank[y])  
      {parent[y]=x; return x;}
      else                       
      { parent[x]=y;if (rank[x]==rank[y]) rank[y]++;return y;}
}
};

// Portable pixelmap I/O
//

// P6        
// width height
// max
// rgb (in binary)

void SaveImagePPM(unsigned char * data, int w, int h, char * file)
{
	//ifstream IN(file, ios::in);

	//if (IN) {cerr<<"File "<<file<<" already exists. Cannot save PPM image."<<endl; IN.close();return;}

	ofstream OUT(file, ios::binary | ios::noreplace);
	if (OUT){
    OUT << "P6" << endl << w << ' ' << h << endl << 255 << endl;
	OUT.write((char *)data, 3*w*h);
	OUT.close();}
}

// Load a PPM Image that does not contain comments.
unsigned char * LoadImagePPM(char *ifile,  int &w, int &h)
{
	unsigned char dummy1=0, dummy2=0; int maxc;
	unsigned char * img;
	ifstream IN(ifile, ios::binary);

	IN.get(dummy1);IN.get(dummy2);
	if ((dummy1!='P')&&(dummy2!='6')) {cerr<<"Not P6 PPM file"<<endl; return NULL;}
 
    IN >> w >> h;
    IN >> maxc;
    IN.get(dummy1);
	
    img=new  unsigned char[3*w*h];
	IN.read(img, 3*w*h); 
	IN.close();
	return img;
}


#include <math.h>

#define max3(a,b,c) max(max((a),(b)),(c))
#define max(A,B) ((A>B) ? (A):(B))
#define min(A,B) ((A<B) ? (A):(B))


// Region Growing Class
class ggvRm
{
public:
int w,h,n;
unsigned char *raster;

double Q; // it is usually an integer representing the number of independent statistical variables
double g; // number of levels in a color channel
double logdelta;

// Auxilliary buffers for union-find operations
int *N;
float *Ravg, *Gavg, *Bavg;
int *C; // the class number

// Output image
int wo, ho;
unsigned char *rastero;

// number of pixels that define a "small region" to be collapsed
int smallregion;
int borderthickness;

ggvUnionFind *UF;

inline bool MergePredicate(int reg1, int reg2);
inline void ggvRm::MergeRegions(int C1, int C2);

ggvRm::ggvRm(int width, int height, unsigned char *ras);
ggvRm::~ggvRm();

int Segment();

void ggvRm::OutputSegmentation();
void ggvRm::MergeSmallRegion();
void DrawBorder();
};


ggvRm::ggvRm(int width, int height, unsigned char *ras)
{
int i,j,index;

n =width*height;
w=wo=width;
h=ho=height;

N=new int[n];
C=new int[n];
Ravg=new float[n];
Gavg=new float[n];
Bavg=new float[n];

UF=new ggvUnionFind(n);// Disjoint sets with exactly n pixels

raster=ras;
rastero=new unsigned char [wo*ho*3];
//
// Initialize to each pixel a leaf region in a union-find data structure

index=0;
for(i=0;i<h;i++)
	for(j=0;j<w;j++)
		{
		N[index]=1;
		C[index]=index; 
		Ravg[index]=(float)raster[3*index];
		Gavg[index]=(float)raster[3*index+1];
		Bavg[index]=(float)raster[3*index+2];
		index++;
		}

Q=32.0; g=256.0; logdelta = 2.0*log(6.0*n);
smallregion=(int)(0.001*n); // small regions are less than 0.1% of image pixels
borderthickness=3; // border thickness of regions
}

// Destructor
ggvRm::~ggvRm()
{delete UF; delete [] raster; delete [] rastero;}

inline bool ggvRm::MergePredicate(int reg1, int reg2)
{
double dR, dG, dB;
double logreg1, logreg2;
double dev1, dev2, dev;

dR=(Ravg[reg1]-Ravg[reg2]); dR*=dR;
dG=(Gavg[reg1]-Gavg[reg2]); dG*=dG;
dB=(Bavg[reg1]-Bavg[reg2]); dB*=dB;
logreg1 = min(g,N[reg1])*log(1.0+N[reg1]);
logreg2 = min(g,N[reg2])*log(1.0+N[reg2]);
dev1=((g*g)/(2.0*Q*N[reg1]))*(logreg1 + logdelta);
dev2=((g*g)/(2.0*Q*N[reg2]))*(logreg2 + logdelta);
dev=dev1+dev2;
return ( (dR<dev) && (dG<dev) && (dB<dev) );
}

// A pair of pixels
class ggvRmpair{
public:
int r1,r2;
unsigned char diff;

// overload operators
bool operator <  ( const ggvRmpair & rhs) {return (diff<rhs.diff);}
bool operator >  (const ggvRmpair & rhs) {return (diff>rhs.diff);}
};

// Sorting with buckets
void BucketSort(ggvRmpair * &a, int n)
{
int i;
int nbe[256], cnbe[256];
ggvRmpair *b;

b=new ggvRmpair[n];
for(i=0;i<256;i++) nbe[i]=0;
// class all elements according to their family
for(i=0;i<n;i++) nbe[a[i].diff]++;
// cumulative histogram
cnbe[0]=0;
for(i=1;i<256;i++) cnbe[i]=cnbe[i-1]+nbe[i-1]; // index of first element of category i

// allocation
for(i=0;i<n;i++) {b[cnbe[a[i].diff]++]=a[i];}
delete [] a;
a = b;
}

void ggvRm::OutputSegmentation()
{
int i,j, index, indexb;

index=0;
for(i=0;i<h;i++) // for each row
	for(j=0;j<w;j++) // for each column
	{
	indexb=UF->Find(index); // Get the index root
	// average color choice
	rastero[3*index]   =(unsigned char)Ravg[indexb];
	rastero[3*index+1] = (unsigned char)Gavg[indexb];
    rastero[3*index+2] =(unsigned char)Bavg[indexb];
	index++;
	}
}


// Merge small regions
void ggvRm::MergeSmallRegion()
{
int i,j, C1,C2, index;

index=0;

for(i=0;i<h;i++) // for each row
	for(j=1;j<w;j++) // for each column
	{ 
	index=i*w+j;
	C1=UF->Find(index);
	C2=UF->Find(index-1);
	if (C2!=C1) {if ((N[C2]<smallregion)||(N[C1]<smallregion)) MergeRegions(C1,C2);}	
}
}

// Draw white borders delimiting perceptual regions
void ggvRm::DrawBorder()
{
int i, j, k, l, C1,C2, reg,index;

for(i=1;i<h;i++) // for each row
	for(j=1;j<w;j++) // for each column
	{ 
	index=i*w+j;

	C1=UF->Find(index);
	C2=UF->Find(index-1-w);
	if (C2!=C1)
	{
	for(k=-borderthickness;k<=borderthickness;k++)
		for(l=-borderthickness;l<=borderthickness;l++)
		{
		index=(i+k)*w+(j+l);
		if ((index>=0)&&(index<w*h)) {
		rastero[3*index]=255;
		rastero[3*index+1]=255;
		rastero[3*index+2]=255;}
		}
	}
	}
}

// This is the core statistical region growing segmentation algorithm
inline void ggvRm::MergeRegions(int C1, int C2)
{
int reg,nreg;
float ravg,gavg,bavg;

			reg=UF->UnionRoot(C1,C2);
			nreg=N[C1]+N[C2]; 
			ravg=(N[C1]*Ravg[C1]+N[C2]*Ravg[C2])/nreg;
			gavg=(N[C1]*Gavg[C1]+N[C2]*Gavg[C2])/nreg;
			bavg=(N[C1]*Bavg[C1]+N[C2]*Bavg[C2])/nreg;
			
			N[reg]=nreg;
			Ravg[reg]=ravg;
			Gavg[reg]=gavg;
			Bavg[reg]=bavg;
}

// Region-growing segmentation framework
int ggvRm::Segment()
{
int i,j,index;
int reg1,reg2;
ggvRmpair * order;
int npair;
int cpair=0;
int C1,C2;


// Consider C4-connectivity here
npair=2*(w-1)*(h-1)+(h-1)+(w-1);
order=new ggvRmpair[npair];
	
for(i=0;i<h-1;i++)
{
	for(j=0;j<w-1;j++)
	{
	index=i*w+j;

	// C4  left
	order[cpair].r1=index;
	order[cpair].r2=index+1;
	order[cpair].diff=max3(\
		abs(raster[3*index]-raster[3*(index+1)]),\
		abs(raster[3*index+1]-raster[3*(index+1)+1]),\
		abs(raster[3*index+2]-raster[3*(index+1)+2])\
		);
	cpair++;

	// C4 below
	order[cpair].r1=index;
	order[cpair].r2=index+w;
	order[cpair].diff=max3(\
		abs(raster[3*index]-raster[3*(index+w)]),\
		abs(raster[3*index+1]-raster[3*(index+w)+1]),\
		abs(raster[3*index+2]-raster[3*(index+w)+2])\
		);
	cpair++;
	}
}

for(i=0;i<h-1;i++)
{
index=i*w+w-1;
order[cpair].r1=index;
	order[cpair].r2=index+w;
	order[cpair].diff=max3(\
		abs(raster[3*index]-raster[3*(index+w)]),\
		abs(raster[3*index+1]-raster[3*(index+w)+1]),\
		abs(raster[3*index+2]-raster[3*(index+w)+2])\
		);
	cpair++;
}

for(j=0;j<w-1;j++)
	{
	index=(h-1)*w+j;

	order[cpair].r1=index;
	order[cpair].r2=index+1;
	order[cpair].diff=max3(\
		abs(raster[3*index]-raster[3*(index+1)]),\
		abs(raster[3*index+1]-raster[3*(index+1)+1]),\
		abs(raster[3*index+2]-raster[3*(index+1)+2])\
		);
	cpair++;
	}

BucketSort(order,npair);

// Main algorithm is here!!!
for(i=0;i<npair;i++)
{
	reg1=order[i].r1; C1=UF->Find(reg1);
	reg2=order[i].r2; C2=UF->Find(reg2);
	if ((C1!=C2)&&(MergePredicate(C1,C2))) MergeRegions(C1,C2);			
}

delete [] order;
return 1;
}


// Main program
#include <iostream.h>

int main(int argc, char* argv[])
{
	int w, h; unsigned char *imgppm;
	char filenamein[256], filenameout[256];
	ggvRm * seg;

	
	cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
	cout<<"Demo program\n\n"<<endl;

	cout <<"Statistical Region Growing.\n"<<endl;
	if (argc==1) {cout<<argv[0]<<" srg-source.ppm [srg-output.ppm]\n(Only for PPM Images without comments. Eg., convert bmp->ppm with XnView.)"<<endl;return -1;}
	if (argc>=2) sprintf(filenamein,argv[1]); else sprintf(filenamein,"srg-source.ppm");
	if (argc>=3) sprintf(filenameout,argv[2]); else sprintf(filenameout,"srg-output.ppm");
	
	imgppm=LoadImagePPM(filenamein, w, h);
	seg=new ggvRm(w,h,imgppm);
	seg->Segment();
	seg->MergeSmallRegion(); // optional
	seg->OutputSegmentation(); // optional: write in the rastero buffer
	seg->DrawBorder(); // optional
	SaveImagePPM(seg->rastero,w,h,filenameout);


cout<<"Press Return key"<<endl;
char line[100];
gets(line);


return 1;
}

