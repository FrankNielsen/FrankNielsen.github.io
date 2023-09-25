//
// (c) Nov. 2021 Frank.Nielsen@acm.org
// Hilbert
//
// Use xnview to convert ppm to png
// https://www.xnview.com/en/
//
// https://arxiv.org/pdf/2203.11434.pdf

import java.io.*;
import java.util.*;

class Point
{
  double x, y, z;

  Point(double xx, double yy) {
    this.x=xx;
    this.y=yy;
  }
  Point() {
    x=y=0.0;
  }

  void rand() {
    x=Math.random();
    y=Math.random();
  }
}

//
// Main class for drawing the rasterized Voronoi diagram
//
class VoronoiHilbertSimplexB
{
  static PPM img;
  static int w=512, h=w;

  static int type=0;

  static double side=5;

  static double minx=0;
  static double maxx=1;



  static double miny=0;
  static double maxy=1;


  static double max(double a, double b) {
    if (a>b) return a;
    else return b;
  }

  static double max(double a, double b, double c) {
    return max(max(a, b), c);
  }


  static double min(double a, double b) {
    if (a<b) return a;
    else return b;
  }

  static double min(double a, double b, double c) {
    return min(min(a, b), c);
  }


  final static   int n=16;
  //final static   int n=32;

  static Point [] set =new Point[n];
  static Point [] vel =new Point[n];

  static Point [] normset=new Point[n];

  //static int nbloop=100;
  static int nbloop=1;

  static int[] R=new int[n];
  static int[] G=new int[n];
  static int[] B=new int[n];

  // Bounding Boxes
  static BB MomentCoord, SimplexCoord, varNormCoord;


  public static double AitchisonDistance(Point p, Point q)
  {
    double res=0.0;


    double gp=geometricMean(p);
    double gq=geometricMean(q);

    res=sqr(Math.log(p.x/gp)-Math.log(q.x/gq))+sqr(Math.log(p.y/gp)-Math.log(q.y/gq))+sqr(Math.log(p.z/gp)-Math.log(q.z/gq));


    return Math.sqrt(res);
  }

  public static double xToX(int x)
  {
    return (minx+(maxx-minx)*x/(double)w);
  }

  public static int Xtox(double X)
  {
    return   (int)(((X-minx)/(maxx-minx))*(w-1));
  }

  public static int Ytoy(double Y)
  {
    return   (int)(((Y-miny)/(maxy-miny))*(h-1));
  }


  public static double yToY(int y)
  {
    return (miny+(maxy-miny)*y/(double)h);
  }

  public static double sqr(double x) {
    return x*x;
  }


  public static double varNormDistance(Point p, Point q)
  {

    double M;
    double m;


    M=max(p.x-q.x, max(p.y-q.y, p.z-q.z));
    m=min(p.x-q.x, min(p.y-q.y, p.z-q.z));


    return M-m;
  }




  public static double varNormDistLog(double [] p, double [] q)
  {
    int i, d=p.length;
    double M=0;
    double m=Double.POSITIVE_INFINITY;

    for (i=0; i<d; i++)
    {
      M=max(M, Math.log(p[i])-Math.log(q[i]));
      m=min(m, Math.log(p[i])-Math.log(q[i]));
    }

    return M-m;
  }



  public static double varNormDistLog(Point p, Point q)
  {

    double M, m;

    M=max(Math.log(p.x)-Math.log(q.x), max(Math.log(p.y)-Math.log(q.y), Math.log(p.z)-Math.log(q.z)));
    m=min(Math.log(p.x)-Math.log(q.x), min(Math.log(p.y)-Math.log(q.y), Math.log(p.z)-Math.log(q.z)));



    return M-m;
  }


  public static double geometricMean(double [] p)
  {
    double res=0.0;
    int i, d=p.length;

    for (i=0; i<d; i++) res+=Math.log(p[i]);

    return Math.exp( (1.0/(double)d)*res );
  }


  public static double geometricMean(Point p)
  {
    double res=0.0;


    res=Math.log(p.x)+Math.log(p.y)+Math.log(p.z);

    return Math.exp( (1.0/(double)3)*res );
  }

  public static double [] LogRep(double [] p)
  {
    double gp=geometricMean(p);
    int i, d=p.length;
    double [] res=new double[d];
    for (i=0; i<d; i++)
    {
      res[i]=Math.log(p[i]/gp);
    }
    return res;
  }


  public static Point LogRep(Point p)
  {
    double gp=geometricMean(p);
    Point res=new Point();
    //double tmp=p.x+p.y+p.z;

    //System.out.println("unit:"+tmp);

    res.x=Math.log(p.x/gp);
    res.y=Math.log(p.y/gp);
    res.z=Math.log(p.z/gp);

    //tmp=res.x+res.y+res.z;
    //System.out.println("zero:"+tmp);

    return res;
  }

  //
  public static double Dist(Point p, Point q)
  {
    if (type==0) return HilbertDistance(p, q);
    else return varNormDistance(LogRep(p), LogRep(q));
  }


  // KL in the proba simplex
  public static double KL(Point p, Point q)
  {
    return p.x*Math.log(p.x/q.x)+  p.y*Math.log(p.y/q.y)+ (1-p.x-p.y)*Math.log((1-p.x-p.y)/(1-q.x-q.y));
  }

  public static double HilbertDistance(Point p, Point q)
  {
    return Math.log( max( p.x/q.x, p.y/q.y, p.z/q.z)/ min(p.x/q.x, p.y/q.y, p.z/q.z) );
  }


  static int nbf=0; //nbframe

  public static PPM flipVertical(PPM img)
  {
    int i, j;
    PPM imgflip=new PPM(img.width, img.height);

    for (i=0; i<img.width; i++)
      for (j=0; j<img.height; j++)
      {
        int jj=img.height-1-j;
        imgflip.r[jj][i]=img.r[j][i];
        imgflip.g[jj][i]=img.g[j][i];
        imgflip.b[jj][i]=img.b[j][i];
      }


    return imgflip;
  }


  public static PPM DiscreteVarNormVorDiag()
  {
    int i, j, k, ii, jj;
    Point P=new Point();
    double X, Y, min;
    int winner;
    double s;
    int[][] Winner;
    Winner=new int[w][h];

    PPM img=new PPM(w, h);

    // all white
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
      }



    // for all image pixels
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        // a point on the W2 hexagonal plane
        P.x=varNormCoord.X2x(i);
        P.y=varNormCoord.Y2y(j);
        P.z=-P.x-P.y;  //sum should be zero

        min=Double.MAX_VALUE;
        winner=-1;



        // for all sites
        for (k=0; k<n; k++)
        { // generator is on left-hand-side
          if (varNormDistance(normset[k], P)<min)
          {
            min=varNormDistance(normset[k], P);
            winner=k;
            //  System.out.println("new min distance "+min);
          }
        }


        //System.out.println(winner);
        Winner[i][j]=winner;
        //  img.r[i][j]=R[winner];img.g[i][j]=G[winner]; img.b[i][j]=B[winner];
      }



    for (i=1; i<w-1; i++)
      for (j=1; j<h-1; j++)
      {

        if (Winner[i][j]==-1) continue;

        /* P.x=varNormCoord.x2X(i);
         P.y=varNormCoord.y2Y(j);
         P.z=-(P.x+P.y);
         */

        /*
        if (P.x+P.y>1) {
         img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
         } else
         */

        {


          if ( (Winner[i][j]!=Winner[i-1][j])||
            (Winner[i][j]!=Winner[i+1][j])||
            (Winner[i][j]!=Winner[i][j-1])||
            (Winner[i][j]!=Winner[i][j+1])
            )
          {
            //  jj=h-1-j; // flip
            jj=j;
            img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=0; //black Voronoi border
          } else
          {
            // jj=h-1-j; // flip
            jj=j;

            //  img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=255;
            winner=Winner[i][j];

            img.r[jj][i]=R[winner];
            img.g[jj][i]=G[winner];
            img.b[jj][i]=B[winner];
          }
        }
      }


    // Write sites
    for (k=0; k<n; k++)
    {
      i=(int)varNormCoord.x2X(normset[k].x);
      j=(int)varNormCoord.y2Y(normset[k].y);


      int ss=5;

      for (ii=-ss; ii<=ss; ii++)
        for (jj=-ss; jj<=ss; jj++)
        {
          if ((i+ii>0)&&(jj+j>0)&&(ii+i<w)&&(jj+j<h))
          {
            //int nj=h-1-j;
            int nj=j;
            img.r[nj+jj][i+ii]=img.g[nj+jj][i+ii]=img.b[nj+jj][i+ii]=0;
          }
        }
    }

    return img;
  }


  public static PPM DiscreteVorDiag()
  {
    int i, j, k, ii, jj;
    Point P=new Point();
    double X, Y, min;
    int winner;
    double s;
    int[][] Winner;
    Winner=new int[w][h];

    PPM img=new PPM(w, h);

    // all white
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
      }



    // for all image pixels
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        P.x=xToX(i);
        P.y=yToY(j);
        P.z=1-(P.x+P.y);

        min=Double.MAX_VALUE;
        winner=-1;



        {


          // for all sites
          for (k=0; k<n; k++)
          { // generator is on left-hand-side
            if (HilbertDistance(set[k], P)<min)
            {
              min=HilbertDistance(set[k], P);
              winner=k;
              //  System.out.println("new min distance "+min);
            }
          }
        }

        //System.out.println(winner);
        Winner[i][j]=winner;
        //  img.r[i][j]=R[winner];img.g[i][j]=G[winner]; img.b[i][j]=B[winner];
      }



    for (i=1; i<w-1; i++)
      for (j=1; j<h-1; j++)
      {

        if (Winner[i][j]==-1) continue;

        P.x=xToX(i);
        P.y=yToY(j);



        /*
        if (P.x+P.y>1) {
         img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
         } else
         */

        {


          if ( (Winner[i][j]!=Winner[i-1][j])||
            (Winner[i][j]!=Winner[i+1][j])||
            (Winner[i][j]!=Winner[i][j-1])||
            (Winner[i][j]!=Winner[i][j+1])
            )
          {
            //  jj=h-1-j; // flip
            jj=j;
            img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=0; //black Vor border
          } else
          {
            // jj=h-1-j; // flip
            jj=j;

            //  img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=255;
            winner=Winner[i][j];

            img.r[jj][i]=R[winner];
            img.g[jj][i]=G[winner];
            img.b[jj][i]=B[winner];
          }
        }
      }


    // Write sites
    for (k=0; k<n; k++)
    {
      i=Xtox(set[k].x);
      j=Ytoy(set[k].y);


      int ss=5;

      for (ii=-ss; ii<=ss; ii++)
        for (jj=-ss; jj<=ss; jj++)
        {
          if ((i+ii>0)&&(jj+j>0)&&(ii+i<w)&&(jj+j<h))
          {
            //int nj=h-1-j;
            int nj=j;
            img.r[nj+jj][i+ii]=img.g[nj+jj][i+ii]=img.b[nj+jj][i+ii]=0;
          }
        }
    }

    return img;
  }



  public static PPM DiscreteVorDiagAitchison()
  {
    int i, j, k, ii, jj;
    Point P=new Point();
    double X, Y, min;
    int winner;
    double s;
    int[][] Winner;
    Winner=new int[w][h];

    PPM img=new PPM(w, h);

    // all white
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
      }



    // for all image pixels
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        P.x=xToX(i);
        P.y=yToY(j);
        P.z=1-(P.x+P.y);

        min=Double.MAX_VALUE;
        winner=-1;



        {


          // for all sites
          for (k=0; k<n; k++)
          { // generator is on left-hand-side
            if (AitchisonDistance(set[k], P)<min)
            {
              min=AitchisonDistance(set[k], P);
              winner=k;
              //  System.out.println("new min distance "+min);
            }
          }
        }

        //System.out.println(winner);
        Winner[i][j]=winner;
        //  img.r[i][j]=R[winner];img.g[i][j]=G[winner]; img.b[i][j]=B[winner];
      }



    for (i=1; i<w-1; i++)
      for (j=1; j<h-1; j++)
      {

        if (Winner[i][j]==-1) continue;

        P.x=xToX(i);
        P.y=yToY(j);



        /*
        if (P.x+P.y>1) {
         img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
         } else
         */

        {


          if ( (Winner[i][j]!=Winner[i-1][j])||
            (Winner[i][j]!=Winner[i+1][j])||
            (Winner[i][j]!=Winner[i][j-1])||
            (Winner[i][j]!=Winner[i][j+1])
            )
          {
            //  jj=h-1-j; // flip
            jj=j;
            img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=0; //black Vor border
          } else
          {
            // jj=h-1-j; // flip
            jj=j;

            //  img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=255;
            winner=Winner[i][j];

            img.r[jj][i]=R[winner];
            img.g[jj][i]=G[winner];
            img.b[jj][i]=B[winner];
          }
        }
      }


    // Write sites
    for (k=0; k<n; k++)
    {
      i=Xtox(set[k].x);
      j=Ytoy(set[k].y);


      int ss=5;

      for (ii=-ss; ii<=ss; ii++)
        for (jj=-ss; jj<=ss; jj++)
        {
          if ((i+ii>0)&&(jj+j>0)&&(ii+i<w)&&(jj+j<h))
          {
            //int nj=h-1-j;
            int nj=j;
            img.r[nj+jj][i+ii]=img.g[nj+jj][i+ii]=img.b[nj+jj][i+ii]=0;
          }
        }
    }

    return img;
  }

  public static PPM Juxtapose(PPM img1, PPM img2)
  {
    PPM img=new PPM(img1.width+img2.width, h);
    int i, j;

    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img1.r[j][i];
        img.g[j][i]=img1.g[j][i];
        img.b[j][i]=img1.b[j][i];

        img.r[j][i+w]=img2.r[j][i];
        img.g[j][i+w]=img2.g[j][i];
        img.b[j][i+w]=img2.b[j][i];
      }


    return img;
  }

  // from moment to simplex
  public static PPM ConvertSimplexForward(PPM img)
  {
    PPM res=new PPM(w, h);
    int i, j;
    double x, y;
    double eta1, eta2, eta3;
    int X, Y;

    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        res.r[j][i]=
          res.g[j][i]=
          res.b[j][i]=255;
      }

    // for all pixels in the simplex image
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        eta1=MomentCoord.X2x(i);
        eta2=MomentCoord.Y2y(j);
        eta3=1-eta1-eta2;

        // in lambda
        x=1-eta1-eta2/2.0;
        //x=0.5*eta2+eta3;
        y=(Math.sqrt(3.0)/2.0)*eta2;

        // in pixels
        X=(int)SimplexCoord.x2X(x);
        Y=(int)SimplexCoord.y2Y(y);

        if ((X>=0)&&(X<w-1)&&(Y>=0)&&(Y<h-1))
        {
          res.r[Y][X]=img.r[h-1-j][i];
          res.g[Y][X]=img.g[h-1-j][i];
          res.b[Y][X]=img.b[h-1-j][i];
          /*
   res.r[j][i]=img.r[Y][X];
           res.g[j][i]=img.g[Y][X];
           res.b[j][i]=img.b[Y][X];
           */
        }
      }

    return res;
  }



  public static PPM ConvertSimplex(PPM img)
  {
    PPM res=new PPM(w, h);
    int i, j;
    double x, y;
    double eta1, eta2, eta3;
    int ii, jj;

    // for all pixels in the simplex image
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        x=SimplexCoord.X2x(i);
        y=SimplexCoord.Y2y(j);

        // lambda
        eta2=(2.0/Math.sqrt(3.0))*y;
        eta3=x-eta2/2.0;
        eta1=1-eta2-eta3;

        ii=(int)MomentCoord.x2X(eta1);
        jj=(int)MomentCoord.y2Y(eta2);

        //
        //  if ((eta1>=0)&&(eta1<1)&&(eta2>=0)&&(eta2<eta1))
        if ((ii>=0)&&(ii<w-1)&&(jj>=0)&&(jj<h-1))
        {
          res.r[i][j]=img.r[ii][jj];
          res.g[i][j]=img.g[ii][jj];
          res.b[i][j]=img.b[ii][jj];
        }
      }

    return res;
  }


  // push moment coord to simplex coord
  public static PPM DiscreteVorDiagSimplex()
  {
    int i, j, k, ii, jj;
    Point P=new Point();
    double X, Y, min;
    int winner;
    double s;
    int[][] Winner;
    Winner=new int[w][h];

    PPM img=new PPM(w, h);

    System.out.println(SimplexCoord.info());

    // all white
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
      }



    // for all image pixels
    for (i=0; i<w; i++)
      for (j=0; j<h; j++)
      {
        P.x=xToX(i);
        P.y=yToY(j);

        /*
         eta1=P.x;
         eta2=P.y;
         eta3=1.0-eta1-eta2;
         
         s1=0.5*eta2+eta3;
         s2=0.5*Math.sqrt(3.0)*eta2;
         */

        //  i=(int)SimplexCoord.x2X(s1);
        //  j=(int)SimplexCoord.y2Y(s2);


        min=Double.MAX_VALUE;
        winner=-1;



        {


          // for all sites
          for (k=0; k<n; k++)
          { // generator is on left-hand-side
            if (Dist(set[k], P)<min)
            {
              min=Dist(set[k], P);
              winner=k;
              //  System.out.println("new min distance "+min);
            }
          }
        }

        //System.out.println(winner);
        Winner[i][j]=winner;
        //  img.r[i][j]=R[winner];img.g[i][j]=G[winner]; img.b[i][j]=B[winner];
      }



    for (i=1; i<w-1; i++)
      for (j=1; j<h-1; j++)
      {

        if (Winner[i][j]==-1) continue;

        P.x=xToX(i);
        P.y=yToY(j);



        /*
        if (P.x+P.y>1) {
         img.r[j][i]=img.g[j][i]=img.b[j][i]=255;
         } else
         */

        {


          if ( (Winner[i][j]!=Winner[i-1][j])||
            (Winner[i][j]!=Winner[i+1][j])||
            (Winner[i][j]!=Winner[i][j-1])||
            (Winner[i][j]!=Winner[i][j+1])
            )
          {
            //  jj=h-1-j; // flip
            jj=j;
            img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=0; //black Vor border
          } else
          {
            // jj=h-1-j; // flip
            jj=j;

            //  img.r[jj][i]=img.g[jj][i]=img.b[jj][i]=255;
            winner=Winner[i][j];

            img.r[jj][i]=R[winner];
            img.g[jj][i]=G[winner];
            img.b[jj][i]=B[winner];
          }
        }
      }


    double eta1, eta2, eta3;
    double s1, s2;

    // Write sites
    for (k=0; k<n; k++)
    {
      // i=Xtox(set[k].x);
      // j=Ytoy(set[k].y);

      eta1=set[k].x;
      eta2=set[k].y;
      eta3=1.0-eta1-eta2;

      s1=0.5*eta2+eta3;
      s2=0.5*Math.sqrt(3.0)*eta2;

      i=(int)SimplexCoord.x2X(s1);
      j=(int)SimplexCoord.y2Y(s2);

      System.out.println("k:"+k+"\t s1="+s1+"\t s2="+s2+"\t i:"+i+"\t j:"+j);



      int ss=5;

      for (ii=-ss; ii<=ss; ii++)
        for (jj=-ss; jj<=ss; jj++)
        {
          if ((i+ii>0)&&(jj+j>0)&&(ii+i<w)&&(jj+j<h))
          {
            //int nj=h-1-j;
            int nj=j;
            img.r[nj+jj][i+ii]=img.g[nj+jj][i+ii]=img.b[nj+jj][i+ii]=0;
          }
        }
    }

    return img;
  }


  public static void updatePoints()
  {
    double xx, yy;

    for (int i=0; i<n; i++)
    {
      xx=set[i].x+vel[i].x;
      yy=set[i].y+vel[i].y;
      if ((xx+yy>1)||(xx<0)||(yy<0)) {
        vel[i].x=-vel[i].x;
        vel[i].y=-vel[i].y;
      } else {
        set[i].x=xx;
        set[i].y=yy;
        set[i].z=1-(set[i].x+set[i].y);

        /*  double term=(1.0/3.0)*(Math.log(set[i].x)+Math.log(set[i].y)+Math.log(set[i].z));
         normset[i].x=Math.log(set[i].x)-term;
         normset[i].y=Math.log(set[i].y)-term;
         normset[i].z=Math.log(set[i].z)-term;
         */
        normset[i]=LogRep(set[i]);
      }
    }
  }

  public static void main(String [] a)
  {
    System.out.println("Hilbert/Aitchison simplex Voronoi diagrams and total variation VD");
    int i, j;

    MomentCoord=new BB(0, 1, 0, 1, w, h, 0, 0);
    SimplexCoord=new BB(0, 1, 0, 1, w, h, 0, 0);

    varNormCoord=new BB(-2.5, 2.5, -2.5, 2.5, w, h, 0, 0);


    for (i=0; i<n; i++)
    {
      // Draw at random colors
      R[i]=(int)(255*Math.random());
      G[i]=(int)(255*Math.random());
      B[i]=(int)(255*Math.random());

      set[i]=new Point();
      vel[i]=new Point();


      set[i].x=Math.random();
      set[i].y=(1.0-set[i].x)*Math.random();
      set[i].z=1-(set[i].x+set[i].y);

      vel[i].x=Math.random()*0.01;
      vel[i].y=Math.random()*0.01;

      // normset[i]=new Point();
      normset[i]=LogRep(set[i]);
      /*
    double term=(1.0/3.0)*(Math.log(set[i].x)+Math.log(set[i].y)+Math.log(set[i].z));
       normset[i].x=Math.log(set[i].x)-term;
       normset[i].y=Math.log(set[i].y)-term;
       normset[i].z=Math.log(set[i].z)-term;
       */

      // double sum=normset[i].x+normset[i].y+normset[i].z;
      // System.out.println(i+" norm point sum: "+sum);
    }

    type=0;

    /*
double dH=HilbertDistance(set[0],set[1]);
     double dVN1=varNormDistance(normset[0],normset[1]);
     double dVN2=varNormDistance(LogRep(set[0]),LogRep(set[1]));
     double dVN3=varNormDistLog(set[0],set[1]);
     System.out.println("Check isometry:  Hilbert"+dH+" "+dVN1+" "+dVN2+" "+dVN3);
     
     //System.exit(0);
     
     */
    PPM img0, img1, img, imgvn, imgai;


    for (nbf=0; nbf<nbloop; nbf++)
    {
      /*
      type=0;
       img=ConvertSimplexForward(DiscreteVorDiag());
       
       type=1;
       imgvn=DiscreteVarNormVorDiag();
       
       img=JuxtaposeOffset(img,20,imgvn);
       */


      img=ConvertSimplexForward(DiscreteVorDiag());
      imgai=ConvertSimplexForward(DiscreteVorDiagAitchison());
      imgvn=DiscreteVarNormVorDiag();

      img=JuxtaposeOffset(JuxtaposeOffset(imgai, 20, img), 20, imgvn);


      String snb = String.format("%03d", nbf);

      img.write("AitchisonHilbertTotalVariationVoronoi-"+snb+".ppm");



      updatePoints();
    }


    System.out.println("Completed Hilbert Voronoi diagrams!");
  }


  public static PPM JuxtaposeOffset(PPM img1, int offset, PPM img2)
  {
    PPM img=new PPM(img1.width+img2.width+offset, h);
    int i, j;

    // blank image background
    for (i=0; i<img1.width+img2.width+offset; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=   img.g[j][i]=   img.b[j][i]=255;
      }

    for (i=0; i<img1.width; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i]=img1.r[j][i];
        img.g[j][i]=img1.g[j][i];
        img.b[j][i]=img1.b[j][i];
      }

    for (i=0; i<img2.width; i++)
      for (j=0; j<h; j++)
      {
        img.r[j][i+img1.width+offset]=img2.r[j][i];
        img.g[j][i+img1.width+offset]=img2.g[j][i];
        img.b[j][i+img1.width+offset]=img2.b[j][i];
      }


    return img;
  }
}




class PPM
{
  public int [][] r; // Red channel
  public int [][] g; // Green channel
  public int [][] b; // Blue channel
  public int depth, width, height;

  public PPM()
  {
    depth=255;
    width = height = 0;
  }

  public PPM(int Width, int Height)
  {
    depth = 255;
    width = Width;
    height = Height;
    r = new int[height][width];
    g = new int[height][width];
    b = new int[height][width];
  }

  public void read(String fileName)
  {
    String line;
    StringTokenizer st;
    int i;

    try {
      DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream(fileName)));
      in.readLine();
      do {
        line = in.readLine();
      } while (line.charAt(0) == '#');

      st = new StringTokenizer(line);
      width = Integer.parseInt(st.nextToken());
      height = Integer.parseInt(st.nextToken());
      r = new int[height][width];
      g = new int[height][width];
      b = new int[height][width];
      line = in.readLine();
      st = new StringTokenizer(line);
      depth = Integer.parseInt(st.nextToken());

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          r[y][x] = in.readUnsignedByte();
          g[y][x] = in.readUnsignedByte();
          b[y][x] = in.readUnsignedByte();
        }
      }
      in.close();
    }
    catch(IOException e) {
    }
  }

  public void write(String filename)
  {
    String line;
    StringTokenizer st;
    int i;
    try {
      DataOutputStream out =new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename)));
      out.writeBytes("P6\n");
      out.writeBytes("# INF555 Ecole Polytechnique\n");
      out.writeBytes(width+" "+height+"\n255\n");

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          out.writeByte((byte)r[y][x]);
          out.writeByte((byte)g[y][x]);
          out.writeByte((byte)b[y][x]);
        }
      }
      out.close();
    }
    catch(IOException e) {
    }
  }
}
// End of simple PPM library




// Bounding box
class BB
{
  double minx, maxx;
  double miny, maxy;
  int w, h;
  int tx, ty;

  // by default tx, ty=0;
  BB(double mx, double Mx, double my, double My, int ww, int hh, int ttx, int tty)
  {
    minx=mx;
    maxx=Mx;
    miny=my;
    maxy=My;
    w=ww;
    h=hh;
    tx=ttx;
    ty=tty;
  }

  BB(double mx, double Mx, double my, double My, int ww, int hh)
  {
    minx=mx;
    maxx=Mx;
    miny=my;
    maxy=My;
    w=ww;
    h=hh;
    tx=ty=0;
  }




  public String info()
  {
    return "Bounding box:"+minx+" "+maxy+" "+miny+" "+maxy+" | width pixels "+w+" height pixels "+h;
  }

  public  float x2X(double x)
  {
    return (float)(tx+((x-minx)*w/(maxx-minx)));
  }


  public  float y2Y(double y)
  {
    return (float)(h-(ty+((y-miny)*h/(maxy-miny))));
  }


  public  float Y2y(double Y)
  {
    return (float)(miny+(maxy-miny)*((h-Y)/(float)h));
  }


  public  float X2x(double X)
  {
    return (float)(minx+(maxx-minx)*(X/(float)w));
  }
}
