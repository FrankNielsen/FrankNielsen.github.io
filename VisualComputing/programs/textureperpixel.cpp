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
// File: textureperpixel.cpp 
// 
// Description: Texture Synthesis per Pixel (Wei & Levoy Algorithm)
// ------------------------------------------------------------------------


#include "stdafx.h"

#include <list>
#include <vector>
#include <fstream>
using namespace std ;

// Require the ANN library
// download and install it from
// http://www.cs.umd.edu/~mount/ANN/

#include "ann.h"
#pragma comment (lib,"ann.lib")

template <class COORD_TYPE=double,class INDEX_TYPE=unsigned int> class CAnnTree_Simple {
public:
	CAnnTree_Simple():pAnnTree(0),dim(-1){}
	~CAnnTree_Simple(){Clear();}

	void Setup(int dim){ Clear(); this->dim = dim ; }

	void AddElement(COORD_TYPE* Elem,INDEX_TYPE Index){
		double* elm = new double[dim] ;
		for( int i=0;i<dim;i++ ) elm[i] = (double)Elem[i] ;
		Elements_tmp.push_back(elm) ;
		data.push_back(Index) ;
	}

	void ConstructSearchStructure(){
		int	n_pts = Elements_tmp.size() ;	
		ANNpointArray data_pts = annAllocPts(n_pts, dim);		
		PAtoDestroy.push_back(data_pts) ;
		list<double*>::iterator fit = Elements_tmp.begin() ;
		for( int i=0;i<n_pts;i++,fit++ ){
			ANNpoint p = data_pts[i] ;
			memcpy(p,*fit,sizeof(double)*dim) ;
			delete[] *fit ;
		}

		Elements_tmp.clear() ;
		
		if( pAnnTree )  delete pAnnTree ;
		pAnnTree = new ANNkd_tree(data_pts,n_pts,dim) ;
	}

	INDEX_TYPE FindMostSimilar( COORD_TYPE* Query,double error_bound = 0.001 ) throw(std::exception)
	{
		ANNpoint query_pt = annAllocPt(dim);
		for( int i=0;i<dim;i++ ) query_pt[i] = Query[i] ;
		
		if( data.empty() ) return 0 ;
		ANNidx nn_idx ;
		ANNdist dist ;
		
		// search nearest neighbor
		pAnnTree->annkSearch(			// search
			query_pt,			// query point
			1,				// number of near neighbors
			&nn_idx,				// nearest neighbors (returned)
			&dist,				// distance (returned)
			error_bound);				// error bound
		
		annDeallocPt(query_pt) ;
		
		if( nn_idx < 0 || nn_idx >= data.size() )
			throw std::exception("Couldn't find similar point.") ;

		return data[nn_idx] ;
	}

	void Clear(){
		dim = -1 ; data.clear() ;
		for(list<double*>::iterator fit=Elements_tmp.begin();fit != Elements_tmp.end();fit++ ) delete[] *fit ;
		Elements_tmp.clear() ;
		if( pAnnTree ) delete pAnnTree ; pAnnTree = 0 ;
		for(list<ANNpointArray>::iterator it = PAtoDestroy.begin() ;
		it != PAtoDestroy.end() ; it++ ){
			annDeallocPts(*it) ;
		}
		PAtoDestroy.clear() ;
	}

	int GetItemNum(){ return data.size() ; }
	int GetDim(){return dim;}
protected:
	int dim ;
	vector<INDEX_TYPE> data ;
	list<double*> Elements_tmp ;
	list<ANNpointArray> PAtoDestroy ;
	ANNkd_tree* pAnnTree ;
} ;

class CPoint {
public :
	CPoint(int x=0,int y=0){ this->x = x ; this->y = y ; }
	int x,y ;
} ;

#define GETPIXELQUICK(img,x,y) &img->raster[((y)*img->width+(x))*3]

#define GETPIXELLOOP(img,x,y) GETPIXELQUICK(img,(x+img->width)%img->width,(y+img->height)%img->height)

class Image{
public: 
	int width, height;
	unsigned char * raster;
	

	void SaveImagePPM(char * file)
{
	ofstream OUT(file, ios::binary );
	if (OUT){
    OUT << "P6" << endl << width << ' ' << height << endl << 255 << endl;
	OUT.write((char *)raster, 3*width*height);
	OUT.close();}
}

// Load a PPM Image that does not contain comments.

Image(int w, int h)
{
width=w;height=h;
raster=new unsigned char [3*width*height];
}

Image(char *ifile)
{
	 char dummy1=0, dummy2=0; int maxc;
	unsigned char * img;
	ifstream IN(ifile, ios::binary);

	IN.get(dummy1);IN.get(dummy2);
	if ((dummy1!='P')&&(dummy2!='6')) {cerr<<"Not P6 PPM file"<<endl; }
 
    IN >> width >> height;
    IN >> maxc;
    IN.get(dummy1);
	
    raster=new  unsigned char[3*width*height];
	IN.read((char *)raster, 3*width*height); 
	IN.close();
}

};



void TextureSynthesis(Image* imgSrc, Image* imgDest, const int nsize_2)
{
	
	const int nsize = nsize_2*2 + 1 ;

	CAnnTree_Simple<unsigned char,CPoint> SearchTree ;
	{
		// Build search tree.
		
		SearchTree.Setup( 3 * (nsize*nsize_2+nsize_2) ) ;
		
		unsigned char* buf = new unsigned char[SearchTree.GetDim()] ;

		for( int iy = nsize_2 ; iy < imgSrc->height ; ++iy ){
			for( int ix = nsize_2 ; ix < imgSrc->width - nsize_2 ; ++ix ){
				unsigned char* bp = buf ;

				for( int diy=-nsize_2 ; diy<0 ; ++diy )
					for( int dix=-nsize_2 ; dix<=nsize_2 ; ++dix,bp+=3 ){
					memcpy( bp,GETPIXELQUICK(imgSrc, ix+dix,iy+diy ),3 ) ;
				}

				int diy=0 ;
				for( int dix=-nsize_2 ; dix<0 ; ++dix,bp+=3 ){
					memcpy( bp,GETPIXELQUICK(imgSrc, ix+dix,iy+diy ),3 ) ;
				}

				SearchTree.AddElement( buf,CPoint(ix,iy) ) ;
			}
		}
		
		delete[] buf ;
		SearchTree.ConstructSearchStructure() ;
	}

	// Fill main L-Shape
	{
		unsigned char* buf = new unsigned char[SearchTree.GetDim()] ;
		
		for( int iy=0;iy<imgDest->height;++iy ) 
			for( int ix=0;ix<imgDest->width;++ix )
			{
			unsigned char* tgt_pxl = GETPIXELQUICK(imgDest,ix,iy) ;
			unsigned char* bp = buf ;
			
			for( int diy=-nsize_2 ; diy<0 ; ++diy )
				for( int dix=-nsize_2 ; dix<=nsize_2 ; ++dix,bp+=3 )
					memcpy( bp,GETPIXELLOOP(imgDest, ix+dix,iy+diy ),3 ) ;
		
			int diy=0 ;
			for( int dix=-nsize_2 ; dix<0 ; ++dix,bp+=3 )
				memcpy( bp,GETPIXELLOOP(imgDest, ix+dix,iy+diy ),3 );
		

			CPoint& bestMatchLocation = SearchTree.FindMostSimilar( buf ) ;
			memcpy( tgt_pxl,GETPIXELQUICK(imgSrc, bestMatchLocation.x,bestMatchLocation.y ) , 3 ) ;
		}

		delete[] buf ;
	}
}

#include <ctime> 

int _tmain(int argc, _TCHAR* argv[])
{
Image *imgsource, *imgtarget;
int wo,ho;

imgsource=new Image("texturesynthesis-input.ppm");

wo=2*imgsource->width;
ho=2*imgsource->height;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"I am creating 4 times larger texture now... Wait a bit please."<<endl;

imgtarget=new Image(wo,ho);

srand(2005);

for(int i=0;i<3*wo*ho;i++) imgtarget->raster[i]=(unsigned char)(rand()%256);

TextureSynthesis(imgsource,imgtarget,2);
imgtarget->SaveImagePPM("texturesynthesis-output.ppm");



char line[256];
cout<<"Press Return key"<<endl;
gets(line);

return 0;
}

