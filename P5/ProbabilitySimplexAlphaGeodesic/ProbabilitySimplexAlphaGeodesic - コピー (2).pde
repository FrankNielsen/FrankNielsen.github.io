// Frank.Nielsen@acm.org
// last updated June 2023

import processing.pdf.*;

int side = 800;
int ww = side;
int hh = side;
/*
double minx=0;
double maxx=1;
double miny=0;
double maxy=1;
*/

double minx=-0.05;
double maxx=1.05;
double miny=-0.05;
double maxy=1.05;


boolean toggleText=true;
boolean toggleAnimation=true;
boolean toggleRectify=false;
boolean toggleMidpoint=true;


int n;

double [][] V;
double [] p, q, vp,vq;

float ptsize=3;




// we sample from proposal normal distribution

int s=side;
double []  Ssample;


public static double CauchypStd(double x)
{
  return   1.0/(Math.PI*(1+x*x));
}

public static double CauchyDensity(double x, double gamma)
{
  return   (1.0/gamma)*CauchypStd(x/gamma);
}


public static double LaplacianDensity(double x, double m, double s)
{
  return   (1.0/(2.0*s))*Math.exp(-Math.abs(x-m)/s);
}

public static double GaussianDensity(double x, double m, double s)
{
  return 1.0/(Math.sqrt(2.0*Math.PI)*s)*Math.exp(-0.5*sqr((x-m)/s));
}

// a standard normal variate
public static double GaussianVariate1D()
{
  double u1=Math.random();
  double u2=Math.random();

  return Math.sqrt(-2.0*Math.log(u1))*Math.cos(2.0*Math.PI*u2);
}

//
// The three fixed probability distributions of a 2d mixture family
//
public   double p0(double x)
{
  return CauchyDensity(x, 1);
}

public   double p1(double x)
{
  return GaussianDensity(x, 1, 1);
}

public   double p2(double x)
{
  return LaplacianDensity(x, 2, 1);
}

// the proposal distribution
public   double q(double x)
{
  return  GaussianDensity(x, 0, 4);
}


//
// Randomized Bregman generator for a mixture family
//
public   double F(double [] theta)
{
  int j;
  double cumS=0;
  double m, theta2;

  //println();
  theta2=(1-(theta[0]+theta[1]));
  if (theta2<0 ) {
    println("error "+theta2);
    System.exit(1);
  }

  for (j=0; j<s; j++)
  {


    // mixture density
    m=  theta[0]*p1(Ssample[j]) + theta[1]*p2(Ssample[j]) + theta2*p0(Ssample[j]);

    //println("m="+m);

    cumS+= (m*Math.log(m)/q(Ssample[j]));
  }

  return (1.0/(double)s) * cumS;
}


// 2d inner product
public   double inner(double [] pt1, double [] pt2)
{
  return pt1[0]*pt2[0]+pt1[1]*pt2[1];
}

//
// MC gradient of negentropy
//
public   double [] gradF(double [] theta)
{
  int j;
  double [] grad=new double [2];
  double gradx=0, grady=0, m;
  double theta2=(1-(theta[0]+theta[1]));

  for (j=0; j<s; j++)
  {
    m= theta[0]*p1(Ssample[j])+ theta[1]*p2(Ssample[j])+ theta2*p0(Ssample[j]);

    gradx += (p1(Ssample[j])-p0(Ssample[j]))*(1+Math.log(m))/q(Ssample[j]);
    grady += (p2(Ssample[j])-p0(Ssample[j]))*(1+Math.log(m))/q(Ssample[j]);
  }

  grad[0]=gradx/(double)s;
  grad[1]=grady/(double)s;

  return grad;
}



void setup()
{
  size(800,800);
  initialize();
}


void MyLine(double x1, double y1, double x2, double y2)
{
  if (toggleRectify) MyLineRectify(x1, y1, x2, y2);
  else  MyLineNoRectify(x1, y1, x2, y2);
}


void MyPoint(double x, double y)
{

  if (toggleRectify) MyPointRectify(x, y);
  else MyPointNoRectify(x, y);
}


void MyLineRectify(double x1, double y1, double x2, double y2)
{
  int nbstep=10;
  double x, xx, y, yy;
  line(x2X(x1+0.5*y1), y2Y(y1*sqrt(3)/2.0), x2X(x2+0.5*y2), y2Y(y2*sqrt(3)/2.0)) ;
}

void MyLineNoRectify(double x1, double y1, double x2, double y2)
{
  int nbstep=10;
  double x, xx, y, yy;
  line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
}


void MyPointRectify(double x, double y)
{
  ellipse((float)x2X(x+0.5*y), (float)y2Y(y*sqrt(3)/2.0), ptsize, ptsize);
}

void MyPointNoRectify(double x, double y)
{
  ellipse((float)x2X(x), (float)y2Y(y), ptsize, ptsize);
}

double h(double alpha, double u)
{
  if (alpha==1.0) return Math.log(u);
  else return Math.pow(u, (1-alpha)/2.0);
}
double hinv(double alpha, double u)
{
  if (alpha==1.0) return Math.exp(u);
  else return Math.pow(u, 2.0/(1-alpha));
}

double hmean(double alpha, double x, double y, double t)
{
  return hinv(alpha, t*h(alpha, x)+(1-t)*h(alpha, y));
}

double [] geodesic(double alpha, double [] p, double [] q, double t)
{
  double [] res=new double[3];
  double tmp=0;
  res[0]=hmean(alpha, p[0], q[0], t);
  res[1]=hmean(alpha, p[1], q[1], t);
  res[2]=hmean(alpha, 1-p[0]-p[1], 1-q[0]-q[1], t);
  tmp=res[0]+res[1]+res[2];
  res[0]/=tmp;
  res[1]/=tmp;
  res[2]/=tmp;
  
  double[] res2=new double[2]; 
  res2[0]=res[0];res2[1]=res[1];
  
  return res2;
}

double [] midPoint(double alpha, double []p, double [] q)
{
  return geodesic(alpha, p, q, 0.5);
}

void drawGeodesic(double alpha, double []p, double [] q)
{

  double t;
  double tstep=0.005;
  
  for (t=0; t<1.0-tstep; t+=tstep)
  {
    double [] interp=geodesic(alpha, p, q, t);
     double [] interpt=geodesic(alpha, p, q, t+tstep);
    //MyPoint(interp[0], interp[1]);
    MyLine(interp[0], interp[1],interpt[0], interpt[1]);
  }
  
  double [] interp=geodesic(alpha, p, q, 0);
    MyPoint(interp[0], interp[1]);
    interp=geodesic(alpha, p, q, 1);
    MyPoint(interp[0], interp[1]);
    
}

void animate()
{
 double l=0.005;
 double [] np, nq;
 np=new double[2];nq=new double[2];
 
   np[0]=p[0]+l*vp[0];  
   np[1]=p[1]+l*vp[1];  
  
  nq[0]=q[0]+l*vq[0];  
  nq[1]=q[1]+l*vq[1];  
  
  double eps=0.05;
  
  if ((np[1]<eps)||(np[1]>1-eps)||(np[0]<eps)||(np[0]>1-eps)||(np[0]+np[1]>1-eps)||(np[0]+np[1]<eps)) {vp[0]=-vp[0];vp[1]=-vp[1];} else {p=np;}
  if ((nq[1]<eps)||(nq[1]>1-eps)||(nq[0]<eps)||(nq[0]>1-eps)||(nq[0]+nq[1]>1-eps)||(nq[0]+nq[1]<eps)) {vq[0]=-vq[0];vq[1]=-vq[1];} else{q=nq; }
  
 
}

void draw()
{
  int i, j, ii, jj;
double minalpha=-5; double maxalpha=5; double stepalpha=0.5;
double alpha;

  surface.setTitle("α-geodesics in the probability simplex");
  background(255, 255, 255);
  stroke(0);
  strokeWeight(3);

  MyLine(V[0][0], V[0][1], V[1][0], V[1][1]);
  MyLine(V[1][0], V[1][1], V[2][0], V[2][1]);
  MyLine(V[2][0], V[2][1], V[0][0], V[0][1]);


  stroke(255, 0, 255);
  MyPoint(p[0], p[1]);
  MyPoint(q[0], q[1]);
  
  strokeWeight(1);
  
  for(alpha=-1;alpha<=1;alpha+=1)
  {
    float intensity=(float)((alpha-minalpha)/(maxalpha-minalpha));
    stroke(255*(1-intensity),255*(1-intensity),255*(1-intensity));
  drawGeodesic(alpha, p, q);
  
  stroke(0);
 

  }
  
 strokeWeight(2);
  stroke(0, 0, 255);// blue m-geodesic
  drawGeodesic(-1, p, q);
  stroke(255, 0, 0); // red e-geodesic
  drawGeodesic(1, p, q);
  stroke(255, 0, 255); // magenta Fisher-Rao geodesic
 drawGeodesic(0, p, q);

stroke(0,0,0);
for(alpha=-1;alpha<=1;alpha+=1)
  {
     if (toggleMidpoint){
    double [] mid=midPoint(alpha,p,q);
   MyPoint(mid[0],mid[1]);
    // ellipse((float)x2X(mid[0]), (float)y2Y(mid[1]), 2*ptsize,2*ptsize);
}
  }





  noFill();

  if (toggleText)
  {
    String msg;
    if (toggleRectify) msg="Probability simplex/Categorical manifold"; else msg="Mixture parameter space";
    textSize(32);
    fill(0, 0, 0);
    stroke(0, 0, 0);
    text(msg, 100, 30);
  }
  
  if (toggleAnimation) {animate();}
}




void drawgood()
{
  int i, j, ii, jj;
double minalpha=-5; double maxalpha=5; double stepalpha=0.5;
double alpha;

  surface.setTitle("α-geodesics in the probability simplex");
  background(255, 255, 255);
  stroke(0);
  strokeWeight(3);

  MyLine(V[0][0], V[0][1], V[1][0], V[1][1]);
  MyLine(V[1][0], V[1][1], V[2][0], V[2][1]);
  MyLine(V[2][0], V[2][1], V[0][0], V[0][1]);


  stroke(255, 0, 255);
  MyPoint(p[0], p[1]);
  MyPoint(q[0], q[1]);
  
  strokeWeight(1);
  
  for(alpha=minalpha;alpha<=maxalpha;alpha+=stepalpha)
  {
    float intensity=(float)((alpha-minalpha)/(maxalpha-minalpha));
    stroke(255*(1-intensity),255*(1-intensity),255*(1-intensity));
  drawGeodesic(alpha, p, q);
  
  stroke(0);
 

  }
  
 strokeWeight(2);
  stroke(0, 0, 255);// blue m-geodesic
  drawGeodesic(-1, p, q);
  stroke(255, 0, 0); // red e-geodesic
  drawGeodesic(1, p, q);
  stroke(255, 0, 255); // magenta Fisher-Rao geodesic
 drawGeodesic(0, p, q);

stroke(0,0,0);
for(alpha=minalpha;alpha<=maxalpha;alpha+=stepalpha)
  {
     if (toggleMidpoint){
    double [] mid=midPoint(alpha,p,q);
   MyPoint(mid[0],mid[1]);
    // ellipse((float)x2X(mid[0]), (float)y2Y(mid[1]), 2*ptsize,2*ptsize);
}
  }





  noFill();

  if (toggleText)
  {
    String msg;
    if (toggleRectify) msg="Embedded probability simplex"; else msg="Mixture parameter space";
    textSize(32);
    fill(0, 0, 0);
    stroke(0, 0, 0);
    text(msg, 100, 30);
  }
  
  if (toggleAnimation) {animate();}
}
public static double mind(double x, double y)
{
  if (x<y) return x;
  else return y;
}

public static double sqr(double x) {
  return x;
}


void initialize()
{
  //double [][] V;
  V=new double [3][2];
  V[0][0]=0;
  V[0][1]=0;
  V[1][0]=1;
  V[1][1]=0;
  V[2][0]=0;
  V[2][1]=1;

  p=new double[2];
  p[0]=Math.random();
  p[1]=(1-p[0])*Math.random();
  q=new double[2];
  q[0]=Math.random();
  q[1]=(1-q[0])*Math.random();
  
  
    vp=new double[2];
  vp[0]=Math.random();
  vp[1]=(1-vp[0])*Math.random();
  vq=new double[2];
  vq[0]=Math.random();
  vq[1]=(1-vq[0])*Math.random();
  
}


void initializeDegenerate()
{
  //double [][] V;
  V=new double [3][2];
  V[0][0]=0;
  V[0][1]=0;
  V[1][0]=1;
  V[1][1]=0;
  V[2][0]=0;
  V[2][1]=1;

  p=new double[2];
  p[0]=Math.random();
  p[1]=(1-p[0])*Math.random();
  
  q=new double[2];
  double lambda=Math.random()/(p[0]+p[1]);
  q[0]=lambda*p[0];
  q[1]=lambda*p[1];
  
  
    vp=new double[2];
  vp[0]=Math.random();
  vp[1]=(1-vp[0])*Math.random();
  vq=new double[2];
  vq[0]=Math.random();
  vq[1]=(1-vq[0])*Math.random();
  
}


void keyPressed()
{if (key=='a'){toggleAnimation=!toggleAnimation;}

if (key=='m'){toggleMidpoint=!toggleMidpoint;}

if (key=='d') {initializeDegenerate();toggleAnimation=false;}
  if (key=='q') exit();
  if (key==' ') {
    initialize();
    draw();
  }

  if ((key=='p')||(key=='P')) savepdffile();
  if (key=='t') {
    toggleText=!toggleText;
    draw();
  }

  if (key=='r') {
    toggleRectify=!toggleRectify;
    draw();
  }
}


public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

public  float X2x(double X)
{
  return (float)(minx+(maxx-minx)*((X)/(float)side));
}



public  float y2Y(double y)
{
  return (float)(side- ((y-miny)*side/(maxy-miny)));
}

public  float Y2y(double Y)
{
  return (float)(miny+(maxy-miny)*((side-Y)/(float)side));
}



void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "Probability simplex-"+suffix+".pdf");


  draw();

  save("Probability simplex-"+suffix+".png");
  endRecord();
}



void strokefill(color cc)
{
  stroke(cc);
  fill(cc);
}
