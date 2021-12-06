// Cleaned, Feb 2016
// Frank Nielsen, Frank.Nielsen@acm.org
// May 2013
// Updated February 2014
// note that some remapped center can be outside the unit disk.
//

// The structures are in a scene graph that is displayed and controlled
// using a hyperbolic rotation and hyperbolic translation

import processing.pdf.*;
import java.util.Random;
import java.util.*;
import java.io.*;
import java.io.*;
import java.nio.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;

boolean debug=true;
boolean modedash=true;

boolean animation=false;
//boolean animation=true;

boolean showTangent=false;
// boolean showTangent=true;

boolean showText=false;

int currentsel=0;


class Pline{
double cx; double cy;
double r;
double a1, a2; // angles for arc


}

class Line
{
double a, b, c; // ax+by+cx=0

Line(double aa, double bb, double cc)
{
a=aa;b=bb;c=cc;
}

public double y(double x)
{
return (-c-a*x)/b;
}

}





void drawLine(double a, double b, double c, double d)
{
line(x2X(a),y2Y(b),x2X(c),y2Y(d));
}

// draw a right angle
void drawRightAngle(double x1, double y1)
{
Line tl=new Line(x1,y1,-1);

// parallel line inside the circle
Line tl2=new Line(x1,y1,-1+0.2);

drawLine(-1,tl.y(-1),1,tl.y(1));
drawLine(-1,tl2.y(-1),1,tl2.y(1));
}


void drawTangentLine(double x1, double y1)
{
Line tl=new Line(x1,y1,-1);

drawLine(-1,tl.y(-1),1,tl.y(1));
} 

void myPrintln(String s)
{
 if (debug) println(s); 
}

// for 720p



//int winwidth=1280,winheight=720;
//int winwidth=1280/2,winheight=720/2; // good
int winwidth=900,winheight=650;

double aspectratio=winheight/winwidth;
int offsetY=20;
int side=winheight-2*offsetY, size=side;
int offsetX=(winwidth-winheight)/2; // center in the canvas
point Origin=new point(offsetX+side/2, offsetY+side/2);



/*
public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

// inverse
public  float X2x(double X)
{
  return (float)(minx+(maxx-minx)*(X/(float)side));
}

public  float Y2y(double Y)
{
  return (float)(miny+(maxy-miny)*((side-Y)/(float)side));
}


// flip or not flip
public  float y2Y(double y)
{
  return (float)(side-(y-miny)*side/(maxy-miny));
}
*/


public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx) + offsetX);
}

// inverse
public  float X2x(double X)
{
  return (float)(minx+(maxx-minx)*((X-offsetX)/(float)side));
}

public  float Y2y(double Y)
{
  return (float)(miny+(maxy-miny)*((side-Y+offsetY)/(float)side));
}

public  float y2Y(double y)
{
  return (float)(side-(y-miny)*side/(maxy-miny)+offsetY);
}







int nmax=500;
//int n=50;

//int n=20;
//int n=8;
//int n=256;
int n=25;

// for two points, Klein bisector equation
double ax2, ay2, c2;
//
point Inter1, Inter2;
// shrink a bit
point SInter1, SInter2;

double Ucx, Ucy, Urad;
double Pcx, Pcy, Prad;
float sizegen=2.0;
int pos=-1;


double Uminx, Umaxx;


boolean shiftMode=false;

//boolean modeColor=true;
boolean modeColor=false;
boolean showFullGeodesic=false;

double  maxzhyperboloid;

point kpstart, kpnow; // for moebius transformation
Complex transformation, cstart, cnow;

int modeKLEIN=1;
int modePOINCARE=2;
int modeUPPER=3;
int modePD=4;
int modeKLEINPOINCARE=5;
int modeKLEINEUCLIDEAN=6;
int modePROJHYPERBOLOID=7;

int mode=modeKLEIN; 

BB BBBall; 
BB BBUpper; 
BB BBEuclidean;
BB BBHyperboloid;
BB BBPD;



// Data-structures
// H is for projected hyperboloid
PowerDiagram diagram, diagramE, diagramH;
OpenList sites, sitesE, sitesH;
Random rand = new Random();
PolygonSimple rootPolygon, rootPolygonE, rootPolygonH;
PolygonSimple polygon, polygonE, polygonH;
Site site, siteE, siteH;


boolean [][] DelaunayEdge;


double epsilon=1.0e-7;

double point[][];//=new double[n][2];
double pointK[][];//=new double[n][2];
double center[][];//=new double[n][2];
double radius[];//=new double[n];

// Klein to Euclidean
point[] pointKE;
point[] pointKH;

color [] col;



public void savegenerator(String filename)
{
  int i, j;

  myPrintln("Saving the generators in file "+filename);
  try
  {
    BufferedWriter out = new BufferedWriter(new FileWriter(filename));

    out.write(n+"\r\n");

    for (i=0;i<n;i++)
    {
      out.write(point[i][0]+"\r\n");
      out.write(point[i][1]+"\r\n");
      //  myPrintln(" saving "+point[i][0]+" "+point[i][1]);
    }
    out.close();
  } 
  catch (IOException e)
  {
    myPrintln("Exception ");
  }
}




int rr, gg, bb;// colors for rendering the Voronoi

int wwc=3; // for showing the origin
boolean showOrigin=true;

// Poincare disk model to hemisphere model
// central projection from (0.0.-1)
point f1(point p)
{
  point result;
  double den=1.0+p.x*p.x+p.y*p.y;

  return new point(2*p.x/den, 2*p.y/den, (1.0-p.x*p.x-p.y*p.y)/den);
}


point f2(point p)
{
  point result; 

  return new point(p.x, p.y, 1.0);
}

// Klein to Hyperboloid
point f3(point p)
{
  point result; 
  double den=Math.sqrt(1.0-p.x*p.x-p.y*p.y);

  return new point(p.x/den, p.y/den, 1.0/den);
}


point f3inv(point p)
{
  point result; 

  return new point(p.x/p.z, p.y/p.z, 1);
}


// Hyperboloid to Euclidean on z=0, central projection from (0,0,2)
point f4(point p)
{
  point result; 
  double den=p.z-2;

  return new point(-2*p.x/den, -2*p.y/den, 0);
}


double sqr(double x) {
  return x*x;
}

// here p.z=0
point f4inv(point p)
{
  point result; 
  double lambda;
  lambda=-1.0/Math.sqrt(4-sqr(p.x+1)-sqr(p.y+1));
  return new point(lambda*(p.x+1), lambda*(p.y+1), -2*lambda);
}



public   Complex Poincare2Upper(Complex z)
{
  return (new Complex(z.im, -z.re-1)).divides(new Complex(z.re-1, z.im));
}

public point Poincare2Upper(point p)
{
  Complex c=new Complex(p.x, p.y);
  c=Poincare2Upper(c);
  return new point(c.re, c.im);
}

public point Upper2Klein(point p)
{
  return Poincare2Klein(Upper2Poincare(p));
}

// a modifier
public   Complex Upper2Poincare(Complex z)
{
  return (new Complex(z.re, z.im-1)).divides(new Complex(z.re, z.im+1));
}



public point Upper2Poincare(point p)
{
  Complex c=new Complex(p.x, p.y);
  c=Upper2Poincare(c);
  return new point(c.re, c.im);
}



// Hemisphere
public point Klein2Beltrami(point p)
{
  return new point(p.x, p.y, Math.sqrt(1.0-p.x*p.x-p.y*p.y));
}

// hyperboloid
public point Klein2Weierstrass(point p)
{
  double  den=Math.sqrt(1-p.x*p.x-p.y*p.y);

  return new point(p.x/den, p.y/den, 1.0/den);
}


public point Klein2Upper(point p)
{
  return Poincare2Upper(Klein2Poincare(p));
}


//int n=300;
//int n=1000;
//int n=32;

//int n=10;

// int n=300;
//
// int n=100;
//int n=50;


// Visualization options
boolean savePDF=false;
boolean drawPoincare=true;
boolean drawKlein=false;
boolean drawPowerDiagram=false;
boolean drawOrigin=false;
boolean drawBoundary=false;
boolean drawRegularTriangulation=false;
boolean blackmode=true;
boolean geop=true;
boolean geosvg=true;

float ww=3;// size of sites


void keyReleased() {
  if ((key == CODED)&&(keyCode  == SHIFT)) {
    shiftMode=false;
  }
}

//
// Handling keyboard events
//
void keyPressed() {  
  int modeKLEIN=1;
  int modePOINCARE=2;
  int modeUPPER=3;
  int modePD=4;
  int modeKLEINPOINCARE=5;


if (key=='l')
  {showTangent=!showTangent;}
    
  if (key=='y')
  {//degenerate elements
    int i;
    for (i=0;i<n;i++)
    {
      double nn=Math.sqrt(sqr(point[i][0])+sqr(point[i][1]));
      point[i][0]/=nn; 
      point[i][0]*=0.8;
      point[i][1]/=nn; 
      point[i][1]*=0.8;
    }
    createPDstructure();
  }



  if (key=='c') {
    modeColor=!modeColor;
  }

  if (key=='v') {
    checkCombinatorics();
  }

  if ((key == CODED)&&(keyCode  == SHIFT)) {
    shiftMode=true;
    kpstart=new point(-X2x(mouseX), -Y2y(mouseY));
    cstart=new Complex(kpstart.x, kpstart.y);
    kpnow=new point(-X2x(mouseX), -Y2y(mouseY));
    cnow=new Complex(kpnow.x, kpnow.y);

    transformation=Transformation(cstart, cnow);

    myPrintln("start hyperbolic moving...");
  }

  //myPrintln("key pressed "+key+" " +(int)key);

  if (key=='1') mode=modeKLEIN;
  if (key=='3') mode=modePOINCARE;
  if (key=='5') mode=modeUPPER;
  if (key=='2') mode=modePD;
  if (key=='4') mode=modeKLEINPOINCARE;
  if (key=='6') {
    mode=modeKLEINEUCLIDEAN;
  }


  if (key=='8') {
    mode=modePROJHYPERBOLOID;
  }


  if (key=='9') {
    if (n!=2) n=2; 
    else n=50;  
    createPDstructure();
  }


  if (key=='d') {
    deleteSite();
  }


  if (key=='e') {
    double sc=2; 
    double normp;

    normp=Math.sqrt(sqr(point[0][0])+sqr(point[0][1]));
    point[0][0]/=normp*sc; 
    point[0][1]/=normp*sc; 

    normp=Math.sqrt(sqr(point[1][0])+sqr(point[1][1]));
    point[1][0]/=normp*sc; 
    point[1][1]/=normp*sc; 

    createPDstructure();
  }


  if (key=='h') {
    drawRegularTriangulation=!drawRegularTriangulation;
  }

  if (key=='n') {
    initialize();
  }

  if (key==',') {
    ww/=2.0;
  }

float factorpd=1.1;

  if (key=='.') {
    if (mode==modePD) {
      myPrintln("zoom out PD"); 
      sidePD*=factorpd;
      createBBs();
       ww/=factorpd;;
    }
  }


  if (key=='\\') {
    if (mode==modePD) {
      myPrintln("zoom in PD"); 
      sidePD/=factorpd;;
      ww*=factorpd;
      createBBs();
    }
  }

  if (key=='g') {
    String filenamegen="generator-"+minute()+"-"+second()+".txt";
    myPrintln("Saved generators to "+filenamegen);
    savegenerator(filenamegen);
    myPrintln("done");
  }

  if (key=='o') {
    showOrigin=!showOrigin;
  }


  if ((key=='*')||(key==':')) {
    n*=2;
    initialize();
  }
  if (key=='/') {
    n/=2;
    initialize();
  }

  if (key=='q') {
    exit();
  }

  // save current
  if (key=='s') {
    savepdffile();
  }

  if (key=='z') {
    chooseColor();
  }



  if (key=='x') {
    //myPrintln(LinesKlein);
    String[] list = split(LinesKlein, '\n');
    saveStrings("klein-output.txt", list);
  }

  if (key=='a') {
    animation=!animation;
  }

  // should be in Poincare
  if (key=='t') {// isometry translation in poincare model
    myPrintln("Isometry translation");

    Complex z0=new Complex(-X2x(mouseX), -Y2y(mouseY));
    isometry(0, z0);
    createPDstructure();
  }
  
  
  if (key=='j') {// isometry translation in poincare model
    myPrintln("Isometry translation");

double [] PoincarePt=Klein2Poincare(point[currentsel]);

    Complex z0=new Complex(-PoincarePt[0],-PoincarePt[1]);
    isometry(0, z0);
    
    createPDstructure();
  
currentsel++;
if (currentsel>=n) currentsel=0;
}
  
  

  if (key=='r') {// isometry translation
    myPrintln("Isometry rotation");
  //  isometry(PI/4.0, new Complex(0, 0));
  isometry(PI/40, new Complex(0, 0));
    createPDstructure();
  }


  if (key=='f') {// double flocus transformation
    myPrintln("double focus transformation");
    doubleFocus();
    createPDstructure();
  }




  draw();
}


void doubleFocus()
{
  int i;
  Complex z;
  Complex a=new Complex(X2x(mouseX), Y2y(mouseY));

  for (i=0;i<n;i++)
  {
    // should convert to Poincare the point
    point pp=Klein2Poincare(new point(point[i][0], point[i][1])); 
    z=new Complex(pp.x, pp.y);


    // transform in poincare disk model
    z=z.dualFocus(a);
    // convert back to Klein for internal representation
    point kk=Poincare2Klein(new point(z.re, z.im));
    point[i][0]=kk.x; 
    point[i][1]=kk.y;
  }
}


// from Poincare 
void isometry(double angle, Complex z0)
{
  int i;
  Complex z;
  for (i=0;i<n;i++)
  {
    // should convert to Poincare the point
    point pp=Klein2Poincare(new point(point[i][0], point[i][1])); 
    z=new Complex(pp.x, pp.y);
    z=z.isometry(angle, z0);
    // convert back to Klein
    point kk=Poincare2Klein(new point(z.re, z.im));
    point[i][0]=kk.x; 
    point[i][1]=kk.y;
  }
}

// from Klein
void isometryKlein(Complex z0k)
{
  int i;
  Complex z;
  Complex z0;
  point pz0=Klein2Poincare(new point(z0k.re, z0k.im));
  z0 =new Complex(pz0.x, pz0.y);

  for (i=0;i<n;i++)
  {
    // should convert to Poincare the point
    point pp=Klein2Poincare(new point(point[i][0], point[i][1])); 
    z=new Complex(pp.x, pp.y);
    z=z.isometry(0, z0);
    // convert back to Klein
    point kk=Poincare2Klein(new point(z.re, z.im));
    point[i][0]=kk.x; 
    point[i][1]=kk.y;
  }
}



// Also save in png
void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
  //  save("HVD.current."+suffix+".png");
  myPrintln("Saving PNG/PDF with suffix "+suffix);  

  beginRecord(PDF, "HVD.current."+suffix+".pdf");
  background(255);
  draw();
  addSignature();
  //saveFrame("HVD.current."+suffix+".png");
  save("HVD.current."+suffix+".png");
  endRecord();

  rr=gg=bb=0;  
  beginRecord(PDF, "HVD.P."+suffix+".pdf");
  background(255);
  drawPoincare();
  addSignature();
  //saveFrame("HVD.P."+suffix+".png");
  save("HVD.P."+suffix+".png");
  endRecord();


  rr=gg=bb=0;  
  beginRecord(PDF, "HVD.HF."+suffix+".pdf");
  background(255);
  drawProjectedHyperboloid();
  addSignature();
  //saveFrame("HVD.P."+suffix+".png");
  save("HVD.HF."+suffix+".png");
  endRecord();


  rr=gg=bb=0;  
  beginRecord(PDF, "HVD.E."+suffix+".pdf");
  background(255);
  drawEuclidean();
  addSignature();
  //saveFrame("HVD.P."+suffix+".png");
  save("HVD.E."+suffix+".png");
  endRecord();



  beginRecord(PDF, "HVD.K."+suffix+".pdf");
  background(255);
  drawKlein();
  addSignature();
  //saveFrame("HVD.K."+suffix+".png");
  save("HVD.K."+suffix+".png");
  endRecord();

  beginRecord(PDF, "HVD.PD"+suffix+".pdf");
  background(255);
  drawLaguerre();
  addSignature();
  //saveFrame("HVD.PD"+suffix+".png");
  save("HVD.PD"+suffix+".png");
  endRecord();

  beginRecord(PDF, "HVD.U."+suffix+".pdf");
  background(255);
  drawUpper();
  addSignature();
  //saveFrame("HVD.U."+suffix+".png");
  save("HVD.U."+suffix+".png");
  endRecord();


  beginRecord(PDF, "HVD.KP."+suffix+".pdf");
  background(255);
  rr=gg=0;
  bb=255;
  drawKlein();
  rr=255;
  gg=bb=0;
  drawPoincare();
  addSignature();
  // saveFrame("HVD.KP."+suffix+".png");
  save("HVD.KP."+suffix+".png");
  endRecord();
}

void setup()
{
  
  // size(size, size,P2D);
  // size(size, size,OPENGL);
  //size(size, size);
 // size(winwidth,winheight);
 size(900,650);
  frame.setTitle("Visualizing hyperbolic Voronoi diagrams");
  frame.setLocation(0,0);
  
  initialize();
  // noLoop();
  if (savePDF) beginRecord(PDF, "PowerDiagram-HVD.pdf");
}

// double minx=-1, maxx=1;
// double miny=-1, maxy=1;
double bs=0.00;
double minx=-1-bs, maxx=1+bs;
double miny=-1-bs, maxy=1+bs;


/*
public  float Y2y(double Y)
 {
 return (float)(miny+(maxy-miny)*(Y/(float)side));
 }
 
 
 // flip or not flip
 public  float y2Y(double y)
 {
 return (float)((y-miny)*side/(maxy-miny));
 }
 */



public  float y2Yflip(double y)
{
  return (float)(side-(y-miny)*side/(maxy-miny));
}


// a point in the unit disk to a point on a disk of center width/2
public  float transform(double t)
{
  // double r=

  //return (float)((side/2)+r*(side/2)*Math.cos(theta));

  return(float)((side/2)*(1+2*t));
}

public  float[] transform(double x, double y)
{
  float[]result=new float[2];
  double r= Math.sqrt(x*x+y*y);
  double theta=Math.atan2(y, x);

  result[0]=(float)((side/2)+(side/2)*Math.cos(theta));
  result[1]=(float)((side/2)+(side/2)*Math.sin(theta));

  return result;
}

//
// point class
//
class point {
  public double x; 
  double y; 
  double z;
  point() {
    x=y=0;
    z=0;
  }
  point(double xx, double yy) {
    x=xx;
    y=yy;
  }
  point(double xx, double yy, double zz) {
    x=xx;
    y=yy;
    z=zz;
  }
  double Distance(point q) {
    return (x-q.x)*(x-q.x) + (y-q.y)*(y-q.y);
  }
  
  
  double distance(point q) {
    return Math.sqrt((x-q.x)*(x-q.x) + (y-q.y)*(y-q.y));
  }

// distance to origin
  double norm() {
    return Math.sqrt(x*x+y*y);
  }
  void unit() {
    double s=this.norm(); 
    x/=s; 
    y/=s;
  }

  void randomHyperboloid()
  {
    x=Math.random(); 
    y=Math.random();
    z=Math.sqrt(1+x*x+y*y);
  }

  void randomKlein()
  {
    double t=Math.random()*Math.PI*2;
    double r= Math.random();
    x=r*Math.cos(t);
    y=r*Math.sin(t);
    z=1;
  }

  void randomPoincare()
  {
    double t=Math.random()*Math.PI*2;
    double r= Math.random();
    x=r*Math.cos(t);
    y=r*Math.sin(t);
    z=1;
  }
} // end class point

double innerE(point p, point q)
{
  return p.x*q.x + p.y*q.y;
}

//
// Ball bisector equation in Poincare ball model: a generalized circle
//
GBall PBisector(point p, point q)
{
  double p2=innerE(p, p);
  double q2=innerE(q, q);
  double a, c;
  point b=new point(0, 0);

  a=(1/(1-p2))-(1/(1-q2));
  b.x=2*(q.x/(1-q2) - p.x/(1-p2));
  b.y=2*(q.y/(1-q2) - p.y/(1-p2));

  c=(p2/(1-p2))-(q2/(1-q2));

  /*
double den=p2-q2;
   double r;
   c=new point(0,0);
   c.x=(p.x*(1-q2)-q.x*(1-p2))/den;
   c.y=(p.y*(1-q2)-q.y*(1-p2))/den;
   
   r=Math.sqrt(sqr(c.x-p.x)+sqr(c.y-p.y));
   return new Ball(c,r); 
   */
  return new GBall(a, b, c);
}

// generalized ball: ball or line
class GBall {
  point center; 
  double r;
  boolean isLine;

  double a, c;
  point b;

  boolean orthogonal(GBall B2)
  {
    double delta=sqr(center.x-B2.center.x)+sqr(center.y-B2.center.y)-r*r-B2.r*B2.r;

    if (Math.abs(delta)<0.003) return true; 
    else return false;
  }


  // ok
  double y(double x)
  {
    return (-c-(b.x*x))/b.y;
  }
  // bisector equation
  // a<x,x>+<b,x>+c=0  (normalize assuming a^2+|\b\|^2+c^2=1
  GBall(double aa, point bb, double cc) {
    a=aa;  
    b=bb; 
    c=cc;

    if (a!=0)
    {// bisector is a sphere
      isLine=false;

      center=new point(-b.x/(2*a), -b.y/(2*a));

      double ccc=0.25*(b.x*b.x+b.y*b.y)/(a*a);

      // r=Math.sqrt(-(c/a)+innerE(center,center));
      r=Math.sqrt(ccc-(c/a));
    }
    else
    {// bisector is a line
      isLine=true;
    }
  }
}


class Ball {
  point center; 
  double rad;
  Ball() {
    center=new point();
  }

  public double hypot(double x, double y) {
    return Math.sqrt(x*x+y*y);
  }

  public point []  intersection(Ball B)
  {
    point [] res=null;
    double r=rad;
    boolean intersect;
    double dist=Math.sqrt(sqr(center.x-B.center.x)+sqr(center.y-B.center.y));
    if ((dist>=Math.abs(r-B.rad) )&& (dist<=r+B.rad))
    {// intersect
      res=new point[2];

      double x0=center.x;
      double y0=center.y;
      double r0=rad;
      double x1=B.center.x;
      double y1=B.center.y;
      double r1=B.rad;

      double a, dx, dy, d, h, rx, ry;
      double x2, y2;

      /* dx and dy are the vertical and horizontal distances between
       * the circle centers.
       */
      dx = x1 - x0;
      dy = y1 - y0;

      /* Determine the straight-line distance between the centers. */
      //d = sqrt((dy*dy) + (dx*dx));
      d = hypot(dx, dy); // Suggested by Keith Briggs

      /* Check for solvability. */
      if (d > (r0 + r1))
      {
        /* no solution. circles do not intersect. */
        return null;
      }
      if (d < Math.abs(r0 - r1))
      {
        /* no solution. one circle is contained in the other */
        return null;
      }

      /* 'point 2' is the point where the line through the circle
       * intersection points crosses the line between the circle
       * centers.  
       */

      /* Determine the distance from point 0 to point 2. */
      a = ((r0*r0) - (r1*r1) + (d*d)) / (2.0 * d) ;

      /* Determine the coordinates of point 2. */
      x2 = x0 + (dx * a/d);
      y2 = y0 + (dy * a/d);

      /* Determine the distance from point 2 to either of the
       * intersection points.
       */
      h = Math.sqrt((r0*r0) - (a*a));

      /* Now determine the offsets of the intersection points from
       * point 2.
       */
      rx = -dy * (h/d);
      ry = dx * (h/d);

      /* Determine the absolute intersection points. */

point psol1=new point(x2 + rx, y2 + ry);
point psol2=new point(x2 - rx, y2 - ry);

 
      res[0]=psol1;
      res[1]=psol2;


      return res;
    }
    else
      return res;
  }

  Ball(point c, double r) {
    center=c; 
    rad=r;
  }

  // if close to 0 perpendicular
  double perpendicular(Ball B2)
  {
    return sqr(B2.center.x-center.x)+sqr(B2.center.y-center.y)-(rad*rad + B2.rad*B2.rad);
  }
}

// Equation of the circle passing through 3 points 
Ball SolveDisk(point p1, point p2, point p3)
{
  Ball result=new Ball();

  double a = p2.x - p1.x;
  double b = p2.y - p1.y;
  double c = p3.x - p1.x;
  double d = p3.y - p1.y;
  double e = a*(p2.x + p1.x)*0.5 + b*(p2.y + p1.y)*0.5;
  double f = (c*(p3.x + p1.x)*0.5) + (d*(p3.y + p1.y)*0.5);
  double det = a*d - b*c;    

  result.center.x = (d*e - b*f)/det;   
  result.center.y = (-c*e + a*f)/det;

  result.rad =p1.Distance(result.center);

  return result;
}

double inner(point p, point q)
{
  return p.x*q.x+p.y*q.y;
}


double inner(double[]p, double[]q)
{
  return p[0]*q[0]+p[1]*q[1];
}

// remap a Klein point to a Poincare point

point Klein2Poincare(point p)
{
  point result=new point();

  double s=(1-Math.sqrt(1-inner(p, p)))/(inner(p, p));

  result.x=s*p.x;
  result.y=s*p.y;

  return result;
}


point Poincare2Klein(point p)
{
  point result=new point();

  double s=2.0/(1+p.x*p.x+p.y*p.y);

  result.x=s*p.x;
  result.y=s*p.y;

  return result;
}



double[] Klein2Poincare(double[] p)
{
  double[] result=new double[2];

  double s=(1-Math.sqrt(1-inner(p, p)))/(inner(p, p));

  result[0]=s*p[0];
  result[1]=s*p[1];

  return result;
}

point Klein2PoincareP(point p)
{
  double s=(1.0d-Math.sqrt(1.0d-inner(p, p)))/(inner(p, p));
  if (Double.isNaN(s)) {
    myPrintln("\t\t s NaN:"+p.x+" "+p.y);
    s=1;
  }
  return new point(s*p.x, s*p.y);
}

//
// geodesic in poincare ball = arc of circle  (circle intersection the limit circle)
//

void geodesicPoincareNotYet(point ip1, point ip2)
{
  point p1, p2, p3, qq;
  Ball B;



  p1=Klein2PoincareP(ip1);
  p2=Klein2PoincareP(ip2);
  // mid point on the geodesic
  p3=Klein2PoincareP(new point(0.5*(ip1.x+ip2.x), 0.5*(ip1.y+ip2.y)));

  p1=new point(x2X(p1.x), y2Y(p1.y));
  p2=new point(x2X(p2.x), y2Y(p2.y));
  p3=new point(x2X(p3.x), y2Y(p3.y));

  stroke(255, 0, 255);
  ellipse((float)p1.x, (float)p1.y, ww, ww);
  ellipse((float)p2.x, (float)p2.y, ww, ww);
  ellipse((float)p3.x, (float)p3.y, ww, ww);


  B=SolveDisk(p1, p2, p3);

  float begin, end;
  begin=(float)Math.atan2(p1.y-B.center.y, p1.x-B.center.x);
  end=(float)Math.atan2(p2.y-B.center.y, p2.x-B.center.x);

  double  rr=B.rad;
  myPrintln("Ball: radius "+rr+" "+begin+" "+end);
  noFill();

  stroke(255, 0, 0);

  ellipse((float)B.center.x, (float)B.center.y, (float)rr, (float)rr);
  arc((float)B.center.x, (float)B.center.y, (float)rr, (float)rr, begin, end);
  // draw arc
}

double Norm(point p)
{
  return Math.sqrt((p.x*p.x)+(p.y*p.y));
}

// Points are given in Klein model
void geoPoincare(point k1, point k3)
{
  point k2;
  point P1, P2, P3;
  double cx, cy, D, rad;
  float begina=0, enda=0;

  // midpoint
  double lambda;
  //lambda=0.1+0.8*Math.random();
  lambda=0.5;
  double s=0.99999;
  k1=new point(k1.x*s, k1.y*s);
  k3=new point(k3.x*s, k3.y*s);
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  P1=Klein2Poincare(k1);
  P2=Klein2Poincare(k2);
  P3=Klein2Poincare(k3);



  // points in Euclidean coordinates now
  P1.x=x2X(P1.x);
  P1.y=y2Y(P1.y);
  P2.x=x2X(P2.x);
  P2.y=y2Y(P2.y);
  P3.x=x2X(P3.x);
  P3.y=y2Y(P3.y);


  D  = (P1.x*(P2.y-P3.y) + P2.x*(P3.y-P1.y) + P3.x*(P1.y-P2.y));
  cx = (((P1.x*P1.x+P1.y*P1.y)*(P2.y-P3.y)+(P2.x*P2.x+P2.y*P2.y)*(P3.y-P1.y)+(P3.x*P3.x+P3.y*P3.y)*(P1.y-P2.y))/(2*D));
  cy = ((P1.x*P1.x+P1.y*P1.y)*(P3.x-P2.x)+(P2.x*P2.x+P2.y*P2.y)*(P1.x-P3.x)+(P3.x*P3.x+P3.y*P3.y)*(P2.x-P1.x))/(2*D);

  rad=Math.sqrt(((P1.x-cx)*(P1.x-cx) + (P1.y-cy)*(P1.y-cy)));


  Pcx=cx;
  Pcy=cy;
  Prad=rad;

  // arc between first point and third point
  begina=atan2((float)(P1.y-cy), (float)(P1.x-cx));
  enda=atan2((float)(P3.y-cy), (float)(P3.x-cx));



  if (enda<begina) {

    float tmp; 
    tmp=enda; 
    enda=begina; 
    begina=tmp;
  }

  //stroke(255,0,0);
  if (enda-begina>PI)
  {

    arc((float)cx, (float)cy, (float)(2*rad), (float)(2*rad), enda, begina+2*PI);
  }
  else {

    arc((float)cx, (float)cy, (float)(2*rad), (float)(2*rad), (float)begina, (float)enda);
  }
}

//
// Draw a Poincare geodesic: an arc of circle perpendicular to the bounding sphere
//
void geoPoincareBad(point k1, point k3)
{
  point k2;
  point P1, P2, P3;
  double cx, cy, D, rad;
  float begina=0, enda=0;

  // midpoint
  double lambda=0.1+0.8*Math.random();
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  P1=Klein2PoincareP(k1);
  P2=Klein2PoincareP(k2);
  P3=Klein2PoincareP(k3);


  P1.x=x2X(P1.x);
  P1.y=y2Y(P1.y);
  P2.x=x2X(P2.x);
  P2.y=y2Y(P2.y);
  P3.x=x2X(P3.x);
  P3.y=y2Y(P3.y);

  myPrintln("P1 "+P1.x+" "+P1.y);
  myPrintln("P2 "+P2.x+" "+P2.y);
  myPrintln("P3 "+P3.x+" "+P3.y);

  // equation of the circle
  D  = (P1.x*(P2.y-P3.y) + P2.x*(P3.y-P1.y) + P3.x*(P1.y-P2.y));

  myPrintln("D..."+D);

  cx = (((P1.x*P1.x+P1.y*P1.y)*(P2.y-P3.y)+(P2.x*P2.x+P2.y*P2.y)*(P3.y-P1.y)+(P3.x*P3.x+P3.y*P3.y)*(P1.y-P2.y))/(2*D));
  cy = ((P1.x*P1.x+P1.y*P1.y)*(P3.x-P2.x)+(P2.x*P2.x+P2.y*P2.y)*(P1.x-P3.x)+(P3.x*P3.x+P3.y*P3.y)*(P2.x-P1.x))/(2*D);

  rad=Math.sqrt(((P1.x-cx)*(P1.x-cx) + (P1.y-cy)*(P1.y-cy)));

  // arc between first point and third point
  begina=atan2((float)(P1.y-cy), (float)(P1.x-cx));
  enda=atan2((float)(P3.y-cy), (float)(P3.x-cx));
  if (enda<begina) {
    //myPrintln("need to swap");
    float tmp; 
    tmp=enda; 
    enda=begina; 
    begina=tmp;
  }

  //ellipse((float)(cx),(float)(cy),(float)(2*rad),(float)(2*rad));

  myPrintln("center "+cx+" "+cy+" r="+rad+" angle "+begina+" "+enda);

  arc((float)x2X(cx), (float)(cy), (float)(2*rad), (float)(2*rad), (float)begina, (float)enda);
  //  arc((float)x2X(cx),(float)y2Y(cy),(float)x2X(2*rad),(float)x2X(2*rad),(float)enda,(float)begina);
}

// Rasterize piecewisely
void geodesicPoincare(point p1, point p2)
{
  point   p3, pp3;
  Ball B;
  double lambda, dlambda=1.0/50.0;
  double lambdan;


  stroke(255, 0, 0);//fill(0,0,0);
  noFill();
  for (lambda=0;lambda<=1-dlambda;lambda+=dlambda)
  {
    p3=new point(p1.x+lambda*(p2.x-p1.x), p1.y+lambda*(p2.y-p1.y)); 
    //if (Norm(p3)<1-epsilon) p3=Klein2PoincareP(p3);
    p3=Klein2PoincareP(p3);

    pp3=new point(p1.x+(lambda+dlambda)*(p2.x-p1.x), p1.y+(lambda+dlambda)*(p2.y-p1.y));
    //if (Norm(pp3)<1-epsilon) pp3=Klein2PoincareP(pp3);
    pp3=Klein2PoincareP(pp3);

    //if (Double.isNaN(p3.x))
    // myPrintln("not a number "+lambda);
    //if (!Double.isNaN(p3.x)&&!Double.isNaN(pp3.x))

    line(x2X(p3.x), y2Y(p3.y), x2X(pp3.x), y2Y(pp3.y));
  }
  /*
 p3=Klein2PoincareP(new point(p1.x+(1-dlambda)*(p2.x-p1.x),  p1.y+(1-dlambda)*(p2.y-p1.y)));
   pp3=Klein2PoincareP(new point(p1.x+ (p2.x-p1.x),  p1.y+ (p2.y-p1.y)));
   line(x2X(p3.x),y2Y(p3.y),x2X(pp3.x),y2Y(pp3.y)); 
   */
}

double Norm(double x, double y) {
  return Math.sqrt(x*x+y*y);
}

//
// Main drawing procedure for the representation of the hyperbolic Voronoi diagrams
// conformal with arcs of circle
void drawPoincareBefore()
{
  int i, j, jj;
  float r;
  float[] dp1;
  float[] dp2;

  //stroke(0,0,0);
  noStroke();
  //  fill(255,0,255);
  if (!blackmode)  fill(255, 0, 0); 
  else fill(0, 0, 0);

  stroke(255, 0, 0); 
  fill(255, 0, 0);
  for ( i=0;i<n;i++) {   // Display Poincare sites
    if (modeColor)  strokefill(col[i]);
    ellipse((float)x2X(pointK[i][0]), (float)y2Y(pointK[i][1]), ww, ww);
  }   

  if (!blackmode)  fill(255, 0, 0); 
  else fill(0, 0, 0);

  // Poincare

  strokeWeight(1); 
  noFill();
  stroke(255, 0, 0);

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];//
    polygon=site.getPolygon();
    ArrayList<Site> neigh= site.neighbours;

    double eps=Float.MIN_VALUE;

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {
        jj=(j+1)%polygon.length;

        point p1, p2;

        p1=new point(polygon.x[j], polygon.y[j]);
        p2=new point(polygon.x[jj], polygon.y[jj]);

        /*
            if (IsBorder(p1)&&(IsBorder(p2)) {
         
         myPrintln("skip!");
         continue;
         
         }*/

        //     if ((p1.norm()>1+eps) && (p2.norm()>1+eps)) continue;

        //   if ((p1.norm()>1-eps)&& (p2.norm()>1-eps)) continue;


        /*
           if ((p1.norm()>1.0-eps) &&(p2.norm()>1.0-eps))
         continue;
         */

        //  p1=Klein2PoincareP(new point(polygon.x[j],polygon.y[j]) );
        //   p2=Klein2PoincareP(new point(polygon.x[jj],polygon.y[jj]));
        //  epsilon=1.0e-7;
        epsilon=0.01;
        //   if ((Norm(polygon.x[j],polygon.y[j])<1-epsilon) && (Norm(polygon.x[jj],polygon.y[jj])<1-epsilon))
        {     // THIS IS GOOD 

          // if (geop)   geodesicPoincare(p1,p2);
          //if (geosvg) 

          // if ((p1.norm()<1.0-eps) && (p2.norm()<1.0-eps))
          { 
            geoPoincare(p1, p2);
          }

          //  geodesicPoincareNotYet(p1,p2);
        }
      }
    }
  }
  /*
        if (drawBoundary){
   float f=0.98;
   stroke(128,128,128);
   noFill();
   strokeWeight(10);
   ellipse(side/2,side/2,f*side,f*side);
   strokeWeight(1);
   }
   
   stroke(128,128,128);noFill();
   float ff=0.98;
   strokeWeight(10);
   ellipse(side/2,side/2,ff*side,ff*side);
   strokeWeight(1);
   
   */

  stroke(128, 128, 128);
  noFill();
  float ff=1;
  ellipse(side/2, side/2, ff*side, ff*side);
}

//
// Draw the power diagram
//
void drawLaguerre()
{
  int i, j, jj;
  float r;
  float[] dp1;
  float[] dp2;
  // BLACK
  stroke(200, 200, 200); 
  noFill();
  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];

    if (site.weight>0)  r=(float)(Math.sqrt((float)site.weight)*side/2.0); // rescale 
    else
      r=(float)(Math.sqrt((float)-site.weight)*side/2.0); // rescale 
    // myPrintln("radius"+r);     
    ellipse((float)BBPD.x2X(site.x), (float)BBPD.y2Y(site.y), 2*r, 2*r);
  }


  stroke(0, 0, 0);
  fill(0, 0, 0); 
  // draw the centers of generator
  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    if (modeColor) strokefill(col[i]); 
    else  strokefill(0, 0, 0);
    ellipse((float)BBPD.x2X(site.x), (float)BBPD.y2Y(site.y), ww, ww);
  } 

  stroke(0, 0, 0);
  fill(0, 0, 0); 

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {
        jj=(j+1)%polygon.length;

        line( BBPD.x2X(polygon.x[j]), BBPD.y2Y(polygon.y[j]), BBPD.x2X(polygon.x[jj]), BBPD.y2Y(polygon.y[jj])   );
      }
    }
  }


// draw bounding circle
  float f=1;
  stroke(0);
  noFill();

  float diam=BBPD.x2X(1)-BBPD.x2X(-1);
  
  if (modedash) {   strokeWeight(2);
dashedCircle(BBPD.x2X(0), BBPD.y2Y(0),diam/2.0, 2, 1);}
  else{  strokeWeight(5);
  ellipse(BBPD.x2X(0), BBPD.y2Y(0), diam, diam);
  } 
  strokeWeight(1);
}

String LinesKlein="";


void checkCombinatorics()
{
  int i;
  int disagree=0;

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    siteE=sitesE.array[i];
    polygonE=siteE.getPolygon();

    if ((polygon!=null)&&(polygonE!=null)) {
      myPrintln(i+"\t"+polygon.length+" Euclidean:"+polygonE.length); 
      if (polygon.length!=polygonE.length)  disagree++;
    }
  }

  myPrintln("#cells in diagreements:"+disagree);
}

void MyLine(double x1, double y1, double x2, double y2)
{
  line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
  LinesKlein=LinesKlein+x1+"\n"+y1+"\n"+x2+"\n"+y2+"\n";
}


//
// Draw the Voronoi diagram in the hyperbolic Klein-Beltrami model    
//
void drawKlein()
{
  int i, j, jj;
  float r;
  float[] dp1;
  float[] dp2;
  int discardededge=0;
  int clippededge=0;
  int fulledge=0;

  LinesKlein="";

  stroke(rr, gg, bb);

  // DrawKlein


  double normj, normjj;
  double eps=0;
  point p, q, u, inter, inter1, inter2;

   stroke(255,0,0);// BLUE

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {// next vertex of the polygon
        jj=(j+1)%polygon.length;
        // Draw only the Voronoi diagram and not the clipping boundary  k-gons
        normj=Norm(polygon.x[j], polygon.y[j]);
        normjj=Norm(polygon.x[jj], polygon.y[jj]);

        /*
   if ( (normj>1+eps)&&(normjj>1+eps)) 
         {
         discardededge++;
         continue;}
         */
        if ( (normj>1+eps)&&(normjj>1+eps)) 
        {
          discardededge++;
          continue;
          /*
     if (false){
           p=new point(polygon.x[j],polygon.y[j]); 
           q=new point(polygon.x[jj],polygon.y[jj]);
           u=new point(q.x-p.x,q.y-p.y);
           double aa,bb,cc,delta, ll1,ll2;
           aa=(u.x*u.x)+(u.y*u.y);
           bb=2*(p.x*u.x+p.y*u.y);
           cc=p.x*p.x+p.y*p.y-1.0;
           delta=(bb*bb)-(4.0*aa*cc);
           
           if (delta<0){ //discardededge++;
           //
           }
           else{// ckip
           ll1=(-bb+Math.sqrt(delta))/(2.0*aa);
           ll2=(-bb-Math.sqrt(delta))/(2.0*aa);
           inter1=new point(p.x+ll1*u.x,p.y+ll1*u.y);
           inter2=new point(p.x+ll2*u.x,p.y+ll2*u.y);
           line( x2X(inter1.x), y2Y(inter1.y) ,  x2X(inter2.x),  y2Y(inter2.y)   );
           }
           }
           */
        }



        if ( ((normj>1)&&(normjj<1)) || ((normjj>1)&&(normj<1))  ) 
        {
          clippededge++;
          // intersection of an edge with a circle: solve a quadratic equation

          if (normj<normjj)
          {
            p=new point(polygon.x[j], polygon.y[j]); 
            q=new point(polygon.x[jj], polygon.y[jj]);
          }
          else
          { 
            q=new point(polygon.x[j], polygon.y[j]); 
            p=new point(polygon.x[jj], polygon.y[jj]);
          }
          // p is inside ball q is outside
          // direction vector
          u=new point(q.x-p.x, q.y-p.y);
          double aa, bb, cc, delta, ll;
          aa=(u.x*u.x)+(u.y*u.y);
          bb=2*(p.x*u.x+p.y*u.y);
          cc=p.x*p.x+p.y*p.y-1;
          delta=bb*bb-4.0*aa*cc;
          ll=(-bb+Math.sqrt(delta))/(2.0*aa);
          inter=new point(p.x+ll*u.x, p.y+ll*u.y);
          // line from p to inter
          //double check=Norm(inter.x,inter.y);
          //System.out.myPrintln("check:"+check);

          //ok  line( x2X(p.x), y2Y(p.y), x2X(inter.x), y2Y(inter.y)   );

          MyLine(p.x, p.y, inter.x, inter.y   );
        } // end clip


        // should implement clip line
        // circle of radius side/2 centered at midscreen
        //  clipline( x2X(polygon.x[j]), y2Y(polygon.y[j]) ,  x2X(polygon.x[jj]),  y2Y(polygon.y[jj])   )


        if ( (Norm(polygon.x[j], polygon.y[j])<1)&&(Norm(polygon.x[jj], polygon.y[jj])<1))
        {   
          fulledge++;
          // ok    line( x2X(polygon.x[j]), y2Y(polygon.y[j]), x2X(polygon.x[jj]), y2Y(polygon.y[jj])   );
          MyLine( polygon.x[j], polygon.y[j], polygon.x[jj], polygon.y[jj]   );
        }
      }
    }
  }

  stroke(rr, gg, bb);
  fill(0, 0, 255);

  int nbedges=fulledge+clippededge;

  LinesKlein=nbedges+"\n"+LinesKlein;


  // draw the centers of generators
  strokeWeight(2);
  for ( i=0;i<n;i++) {   
    if (modeColor) {
      fill(col[i]);
      stroke(col[i]);
    }
    ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ww, ww);

    LinesKlein=point[i][0]+"\n"+point[i][1]+"\n"+LinesKlein;
  }

  // highlight selection
  if (pos!=-1) {
    stroke(255, 0, 0);
    ellipse((float)x2X(point[pos][0]), (float)y2Y(point[pos][1]), ww, ww);
  }
  //


  LinesKlein=n+"\n"+LinesKlein;

float thick=5;
  
  // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(thick);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  // end draw disk
  
  //println("Draw Delaunay");
  
  strokefill(0,0,255);
  
  for(i=0;i<n;i++)
      for(j=0;j<n;j++)
      {
       if (DelaunayEdge[i][j]) 
       {MyLine(  (point[i][0]), 
       (point[i][1]),  (point[j][0]), point[j][1] );
       
       
     //  println(i+" "+j+" Del "+ x2X(point[i][0])+" "+y2Y(point[i][1])+" "+x2X(point[j][0])+" "+y2Y(point[j][1]));
       }
      }
      
}


void strokefill(color cc)
{  
  stroke(cc);
  fill(cc);
}

void strokefill(int r, int g, int b)
{
  stroke(r, g, b);
  fill(r, g, b);
}

//
// Draw Poincare Voronoi diagram in the unit disk
//
void drawPoincare()
{
  int i, j, jj;
  float r;
  float[] dp1;
  float[] dp2;
  int discardededge=0;
  int clippededge=0;
  int fulledge=0;
  double normj, normjj;
  double eps=0;
  point p, q, inter;
  point inter1, inter2;

 // stroke(rr, gg, bb);
 stroke(255,0,0);
  noFill();

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {
        jj=(j+1)%polygon.length;
        // Draw only the Voronoi diagram and not the clipping boundary  k-gons
        normj=Norm(polygon.x[j], polygon.y[j]);
        normjj=Norm(polygon.x[jj], polygon.y[jj]);

        // Both extremities can be outside de disk yet the line intersect the ball
        if ( (normj>1)&&(normjj>1)) 
        {
          discardededge++;
          continue;
          /*
    p=new point(polygon.x[j],polygon.y[j]); 
           q=new point(polygon.x[jj],polygon.y[jj]);
           point u=new point(q.x-p.x,q.y-p.y);
           double aa,bb,cc,delta, ll1,ll2;
           aa=(u.x*u.x)+(u.y*u.y);
           bb=2*(p.x*u.x+p.y*u.y);
           cc=p.x*p.x+p.y*p.y-1;
           delta=bb*bb-4.0*aa*cc;
           
           if (delta<0){ discardededge++;
           continue;
           }
           else{
           ll1=(-bb+Math.sqrt(delta))/(2.0*aa);
           ll2=(-bb-Math.sqrt(delta))/(2.0*aa);
           inter1=new point(p.x+ll1*u.x,p.y+ll1*u.y);
           inter2=new point(p.x+ll2*u.x,p.y+ll2*u.y);
           geoPoincare( new point(inter1.x, inter1.y) ,  new point(inter2.x,  inter2.y)   );
           }
           */
        }

        if ( ((normj>1-eps)&&(normjj<1+eps)) || ((normjj>1-eps)&&(normj<1+eps))  ) 
        {
          clippededge++;
          // intersection of an edge with a circle: solve a quadratic equation



          if (normj<normjj)
          {
            p=new point(polygon.x[j], polygon.y[j]); 
            q=new point(polygon.x[jj], polygon.y[jj]);
          }
          else
          { 
            q=new point(polygon.x[j], polygon.y[j]); 
            p=new point(polygon.x[jj], polygon.y[jj]);
          }
          // p is inside ball q is outside
          // direction vector
          point u=new point(q.x-p.x, q.y-p.y);
          double aa, bb, cc, delta, ll;
          aa=(u.x*u.x)+(u.y*u.y);
          bb=2*(p.x*u.x+p.y*u.y);
          cc=p.x*p.x+p.y*p.y-1;
          delta=bb*bb-4.0*aa*cc;
          ll=(-bb+Math.sqrt(delta))/(2.0*aa);
          inter=new point(p.x+ll*u.x, p.y+ll*u.y);
          // line from p to inter
          //double check=Norm(inter.x,inter.y);
          //System.out.myPrintln("check:"+check);

          geoPoincare( new point(p.x, p.y), new point(inter.x, inter.y)   );
        } // end clip


        if ( (Norm(polygon.x[j], polygon.y[j])<1+eps)&&(Norm(polygon.x[jj], polygon.y[jj])<1+eps))
        {   
          fulledge++;
          geoPoincare( new point(polygon.x[j], (polygon.y[j])), new point(polygon.x[jj], polygon.y[jj])   );
        }
      }
    }
  }

  //stroke(255,0,0);
  //fill(255,0,0);
  strokefill(rr, gg, bb);
  strokeWeight(sizegen);
  // draw the centers of generator
  for ( i=0;i<n;i++) {   
    point P=Klein2Poincare(new point(point[i][0], point[i][1]));
    if (modeColor) strokefill(col[i]); 
    else  strokefill(rr, gg, bb);
    ellipse((float)x2X(P.x), (float)y2Y(P.y), ww, ww);
  }

   float thick=5;
  
  // draw disk with center cross
    float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  
  
  stroke(0);
  noFill();
  strokeWeight(thick);

if (modedash) {  strokeWeight(2);
dashedCircle(cx,cy, side/2.0,2,1);
} else{
  
  ellipse(cx,cy, side,side);
}
  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  // end draw disk
  
  
   stroke(0,0,255);
  noFill();
  for(i=0;i<n;i++)
      for(j=0;j<n;j++)
      {
       if (DelaunayEdge[i][j]) 
       { 
       
       
       geoPoincare( new point(point[i][0], (point[i][1])), new point(point[j][0], point[j][1])   );
       
       
     //  println(i+" "+j+" Del "+ x2X(point[i][0])+" "+y2Y(point[i][1])+" "+x2X(point[j][0])+" "+y2Y(point[j][1]));
       }
      }
}


//
// Draw the Voronoi diagram on the upper space model
//
void drawUpper()
{
  int i, j, jj;
  float r;
  float[] dp1;
  float[] dp2;
  int discardededge=0;
  int clippededge=0;
  int fulledge=0;
  double normj, normjj;

  //stroke(rr, gg, bb); 
  stroke(255,0,0);
  noFill();

  for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {
        jj=(j+1)%polygon.length;
        // Draw only the Voronoi diagram and not the clipping boundary  k-gons
        normj=Norm(polygon.x[j], polygon.y[j]);
        normjj=Norm(polygon.x[jj], polygon.y[jj]);

        if ( (normj>1)&&(normjj>1)) 
        {
          discardededge++;
          continue;
        }

        if ( ((normj>1)&&(normjj<1)) || ((normjj>1)&&(normj<1))  ) 
        {
          clippededge++;
          // intersection of an edge with a circle: solve a quadratic equation
          point p, q, inter;
          if (normj<normjj)
          {
            p=new point(polygon.x[j], polygon.y[j]); 
            q=new point(polygon.x[jj], polygon.y[jj]);
          }
          else
          { 
            q=new point(polygon.x[j], polygon.y[j]); 
            p=new point(polygon.x[jj], polygon.y[jj]);
          }
          // p is inside ball q is outside
          // direction vector
          point u=new point(q.x-p.x, q.y-p.y);
          double aa, bb, cc, delta, ll;
          aa=(u.x*u.x)+(u.y*u.y);
          bb=2*(p.x*u.x+p.y*u.y);
          cc=p.x*p.x+p.y*p.y-1;
          delta=bb*bb-4.0*aa*cc;
          ll=(-bb+Math.sqrt(delta))/(2.0*aa);
          inter=new point(p.x+ll*u.x, p.y+ll*u.y);
          // line from p to inter
          //double check=Norm(inter.x,inter.y);
          //System.out.myPrintln("check:"+check);

          geoUpper( new point(p.x, p.y), new point(inter.x, inter.y)   );
        } // end clip


        if ( (Norm(polygon.x[j], polygon.y[j])<1)&&(Norm(polygon.x[jj], polygon.y[jj])<1))
        {   
          fulledge++;
          geoUpper( new point(polygon.x[j], (polygon.y[j])), new point(polygon.x[jj], polygon.y[jj])   );
        }
      }
    }
  }

  strokefill(rr, gg, bb);

  // draw the centers of generator
  for ( i=0;i<n;i++) {   
    point P=Klein2Upper(new point(point[i][0], point[i][1]));
    if (modeColor) strokefill(col[i]); 
    else  strokefill(rr, gg, bb);
    ellipse((float)BBUpper.x2X(P.x), (float)BBUpper.y2Y(P.y), ww, ww);
  }


  if (showOrigin)
  {
    strokeWeight(1);
    float midx, midy;
    point mid=Poincare2Upper(new point(0, 0)); // mid=(0,1)
    myPrintln("\t"+mid.x+" "+mid.y);
    midx=(float)BBUpper.x2X(mid.x);
    midy=(float)BBUpper.y2Y(mid.y);
    myPrintln("\t in pixels:"+midx+" "+midy);

    stroke(0, 0, 0);
    line(midx-2*wwc, midy, midx+2*wwc, midy);
    line(midx, midy-2*wwc, midx, midy+2*wwc);
    stroke(rr, gg, bb);
  }

strokeWeight(5);
line(BBUpper.x2X(-50),BBUpper.y2Y(0),BBUpper.x2X(50),BBUpper.y2Y(0));
strokeWeight(1);
  myPrintln("Statistics: Discarded edge:"+discardededge+" clipped edge:"+clippededge+" full edge:"+fulledge );

   stroke(0,0,255);
  noFill();
  for(i=0;i<n;i++)
      for(j=0;j<n;j++)
      {
       if (DelaunayEdge[i][j]) 
       { 
       
       
       geoUpper( new point(point[i][0], (point[i][1])), new point(point[j][0], point[j][1])   );
       
       
     //  println(i+" "+j+" Del "+ x2X(point[i][0])+" "+y2Y(point[i][1])+" "+x2X(point[j][0])+" "+y2Y(point[j][1]));
       }
      }



}

//
// Compute bounding box for upper halfplane
//
void ComputeUpper2BB()
{
  int i;
  double minx, maxx, maxy;
  point P;
  double deltax, deltay, delta;
  double dx;

  P=Klein2Upper(new point(point[0][0], point[0][1]));

  minx=xminUpper(new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1]));
  maxx=xmaxUpper(new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1]));


  maxy=P.y;

  for ( i=1;i<n;i++) {   
    P=Klein2Upper(new point(point[i][0], point[i][1]));
    if (P.y>maxy) maxy=P.y;
  } 

  dx=0.1*(maxx-minx);
  minx-=dx; 
  maxx+=dx;
  maxy+=dx;

  deltax=maxx-minx;
  deltay=maxy;

  if (deltax>deltay) delta=deltax; 
  else delta=deltay;

  BBUpper=new BB(minx, minx+delta, 0, delta, side, side, 0, 0);
}


void ComputeUpperBB()
{
  int i;
  double minx, maxx, maxy;
  point P;
  double deltax, deltay, delta;
  double dx;



  P=Klein2Upper(new point(point[0][0], point[0][1]));

  minx=maxx=P.x;


  maxy=P.y;

  for ( i=1;i<n;i++) {   
    P=Klein2Upper(new point(point[i][0], point[i][1]));
    if (P.x<minx) minx=P.x;
    if (P.x>maxx) maxx=P.x;
    if (P.y>maxy) maxy=P.y;
  } 

  dx=0.1*(maxx-minx);
  minx-=dx; 
  maxx+=dx;
  maxy+=dx;

  deltax=maxx-minx;
  deltay=maxy;

  if (deltax>deltay) delta=deltax; 
  else delta=deltay;

  BBUpper=new BB(minx, minx+delta, 0, delta, side, side, 0, 0);
}




// Draw Klein diagram in Euclidean...from another equivalent diagram
void drawEuclidean()
{
  int i, j, jj; 
  
  if (siteE==null) return;

  stroke(0, 0, 0);
  fill(0, 0, 0);

  for ( i=0;i<sitesE.size;i++) {
    siteE=sitesE.array[i];
    polygonE=siteE.getPolygon();

    if (polygonE!=null) {
      for (j=0;j<polygonE.length;j++)
      {
        jj=(j+1)%polygonE.length;

        point pp=new point(polygonE.x[j], polygonE.y[j]);
        point qq=new point(polygonE.x[jj], polygonE.y[jj]);

        line(BBEuclidean.x2X(pp.x), BBEuclidean.y2Y(pp.y), BBEuclidean.x2X(qq.x), BBEuclidean.y2Y(qq.y)     );
      }
    }
  }


  // draw sites 
  for ( i=0;i<n;i++) {  
    if (modeColor) {
      stroke(col[i]);
      fill(col[i]);
    } 
    ellipse((float)BBEuclidean.x2X(pointKE[i].x), (float)BBEuclidean.y2Y(pointKE[i].y), ww, ww);
  }
}


//
// on the plane z=1
//
void drawProjectedHyperboloid()
{
  if (sitesH==null) return;
  int i, j, jj; 

  stroke(0, 0, 0);
  fill(0, 0, 0);

  for ( i=0;i<sitesH.size;i++) {
    siteH=sitesH.array[i];
    polygonH=siteH.getPolygon();

    /*
    if (modeColor) {
     stroke(col[i]);
     fill(col[i]);
     } 
     */

    if (polygonH!=null) {
      /*
       beginShape();
       for (j=0;j<polygonH.length;j++)
       {
       jj=(j+1)%polygonH.length;
       
       point pp=new point(polygonH.x[j], polygonH.y[j]);
       point qq=new point(polygonH.x[jj], polygonH.y[jj]);
       vertex(BBHyperboloid.x2X(pp.x), BBHyperboloid.y2Y(pp.y));
       //   line(BBHyperboloid.x2X(pp.x), BBHyperboloid.y2Y(pp.y), BBHyperboloid.x2X(qq.x), BBHyperboloid.y2Y(qq.y)     );
       }
       endShape();
       */


      for (j=0;j<polygonH.length;j++)
      {
        jj=(j+1)%polygonH.length;

        point pp=new point(polygonH.x[j], polygonH.y[j]);
        point qq=new point(polygonH.x[jj], polygonH.y[jj]);
        line(BBHyperboloid.x2X(pp.x), BBHyperboloid.y2Y(pp.y), BBHyperboloid.x2X(qq.x), BBHyperboloid.y2Y(qq.y)     );
      }
    }
  }


  // draw sites 
  for ( i=0;i<n;i++) {  
    if (modeColor) {
      stroke(col[i]);
      fill(col[i]);
    } 
    ellipse((float)BBHyperboloid.x2X(pointKH[i].x), (float)BBHyperboloid.y2Y(pointKH[i].y), ww, ww);
  }
}


//
// Main drawing procedure
//



void drawKleinPoincare()
{
  rr=0;
  gg=0;
  bb=255;  
  drawKlein();
  rr=255;
  gg=0;
  bb=0;
  drawPoincare();
}

void drawBall()
{
  if (drawKlein) {
    rr=0;
    gg=0;
    bb=255;
    drawKlein();
  }
  if (drawPoincare) {
    rr=255;
    gg=0;
    bb=0;
    drawPoincare();
  }
}


//
// Add watermark
//
void addSignature()
{
  textSize(1);
  //stroke(128, 128, 128);
  //fill(0, 0, 0);
  strokefill(254, 254, 254);
  text("(C) 2009-2014 Frank Nielsen. All rights reserved.", 2, size-2);
}

//
// While dragging show the current position
//
void  drawTransformedKlein()
{
  int i;
  point pk, pp;
  Complex zz, z;

  for ( i=0;i<n;i++) {  
    pp=Klein2Poincare(new point(point[i][0], point[i][1]));
    z=new Complex(pp.x, pp.y); 

    zz= (z.plus(transformation)).divides( ((transformation.conjugate()).times(z)).plus(1) );

    pp=Poincare2Klein(new point(zz.re, zz.im));

    stroke(255, 0, 0);
    ellipse((float)x2X(pp.x), (float)y2Y(pp.y), 2*ww, 2*ww);
  }
}

void MyEllipse(double x, double y, double r)
{
  ellipse((float)x, (float)y, (float)(2*r), (float)(2*r));
}

//
// Drawing procedure on the upper plane
//
double Min(double a, double b) {
  if (a<b) return a; 
  else return b;
}
double Max(double a, double b) {
  if (a>b) return a; 
  else return b;
}

// draw a dashed circle
void dashedCircle(float cx, float cy, float radius, int dashWidth, int dashSpacing) {
  
  println("dashed circle:"+cx+" "+cy+" "+radius);
  
    int steps = 200;
    int dashPeriod = dashWidth + dashSpacing;
    boolean lastDashed = false;
    for(int i = 0; i < steps; i++) {
      boolean curDashed = (i % dashPeriod) < dashWidth;
      if(curDashed && !lastDashed) {
        beginShape();
      }
      if(!curDashed && lastDashed) {
        endShape();
      }
      if(curDashed) {
        float theta = map(i, 0, steps, 0, TWO_PI);
        vertex(cx+cos(theta) * radius, cy+sin(theta) * radius);
      }
      lastDashed = curDashed;
    }
    if(lastDashed) {
      endShape();
    }
}

//
// Draw bisector in the upper plane
//
void draw2Upper()
{
  background(255,255,255);
  double uminx, uminy, umaxx, umaxy;
  float thick=5;
  double x1, X1, x2, X2;
  double xx, XX, yy, YY;
  point P1=Klein2Upper(new point(point[0][0], point[0][1]));
  point P2=Klein2Upper(new point(point[1][0], point[1][1]));
  
  uminy=0;
  umaxy=Max(P1.y, P2.y);
  


  fullCircleUpper(new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1]));
  x1=Uminx;
  X1=Umaxx;
  fullCircleUpper( Inter1, Inter2  );
  x2=Uminx;
  X2=Umaxx;

  YY=Max(P1.y, P2.y);
  xx=Min(x1, x2);
  XX=Max(X1, X2);
  
println(xx+" "+XX+" Y:"+YY);

/*

  double deltaX=XX-xx;
  double deltaY=YY;
  double delta=Max(deltaX, deltaY);
  double xstart=xx;
*/

  BBUpper=new  BB(xx, XX, 0, YY, winwidth, winheight, 0, 0);
  
  

  strokeWeight(thick);
  // geodesic
  stroke(0, 0, 255);
  noFill();
  geoUpper( new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1])   );
  Ball B1=new Ball(new point(Ucx, Ucy), Urad);

  /*
 if (showFullGeodesic){
   strokeWeight(1);noFill();
   // ellipse((Ucx,Ucy,2*Urad,2*Urad);
   MyEllipse(Ucx,Ucy,Urad);
   }
   */

  // bisector

  strokefill(255, 0, 0);
  strokeWeight(thick);
  noFill();
  geoUpper( Inter1, Inter2  );
  Ball B2=new Ball(new point(Ucx, Ucy), Urad);

  /*
  if (showFullGeodesic){
   strokeWeight(1);noFill();
   // ellipse((Ucx,Ucy,2*Urad,2*Urad);
   MyEllipse(Ucx,Ucy,Urad);}
   */


  //line(x2X(p1.x),y2Y(p1.y),x2X(p2.x),y2Y(p2.y));

  // generator  
  strokefill(0, 0, 0); 
  ellipse((float)BBUpper.x2X(P1.x), (float)BBUpper.y2Y(P1.y), thick, thick);
  ellipse((float)BBUpper.x2X(P2.x), (float)BBUpper.y2Y(P2.y), thick, thick);

/*
  point [] interp=B1.intersection(B2);
  strokefill(0, 255, 0);
  ellipse((float)interp[0].x, (float)interp[0].y, 5, 5);
  ellipse((float)interp[1].x, (float)interp[1].y, 5, 5);
*/
  textSize(30);
  strokefill(128);
  text("Poincare upper plane", 2, 30);
}

//
// Draw geodesic and bisector in the Poincare models
//
void draw2Poincare()
{
float thick=5.0;

   // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(thick);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  // end draw disk
  
  if (showTangent){
strokefill(0,255,205);
/*drawTangentLine(Inter1.x,Inter1.y);
drawTangentLine(Inter2.x,Inter2.y);
*/
drawRightAngle(Inter1.x,Inter1.y);
}


  
  Ball BBB = new Ball(new point(side/2, side/2), side/2);

 
  strokeWeight(thick);

  // geodesic
  stroke(0, 0, 255);
  noFill();
  geoPoincare( new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1])   );

  Ball B1=new Ball(new point(Pcx, Pcy), Prad );
  myPrintln(B1.center.x+" "+B1.center.y+" "+B1.rad);
  myPrintln("perpendicular B1:"+B1.perpendicular(BBB));
  // bisector



  strokefill(255, 0, 0);
  noFill();
  geoPoincare( Inter1, Inter2  );
  //  point P1=Klein2Poincare(new point(point[0][0], point[0][1]));
  //point P2=Klein2Poincare(new point(point[1][0], point[1][1]));
  ellipse(x2X(Inter1.x),y2Y(Inter1.y),thick,thick);
  ellipse(x2X(Inter2.x),y2Y(Inter2.y),thick,thick);

  Ball B2=new Ball(new point(Pcx, Pcy), Prad );
  myPrintln(B2.center.x+" "+B2.center.y+" "+B2.rad);
  myPrintln("perpendicular B2:"+B2.perpendicular(BBB));

//intersection point
  point [] interp=B1.intersection(B2);
  strokefill(0, 255, 0);
  
 if (interp[0].distance(Origin)<interp[1].distance(Origin)) 
  ellipse((float)interp[0].x, (float)interp[0].y, 5, 5);
else  ellipse((float)interp[1].x, (float)interp[1].y, 5, 5);


  myPrintln("perpendicular bisector/geodesic:"+B1.perpendicular(B2));

  // generator  
  strokefill(0, 0, 0);
  point P1=Klein2Poincare(new point(point[0][0], point[0][1]));
  point P2=Klein2Poincare(new point(point[1][0], point[1][1]));
  ellipse(x2X(P1.x), y2Y(P1.y), thick, thick);
  ellipse(x2X(P2.x), y2Y(P2.y), thick, thick);




  /*
// Draw bisector from equation
   stroke(255,0,0);
   GBall BP=PBisector(P1,P2);
   //myPrintln("bisector "+BP.center.x+" "+BP.center.y+" rad="+BP.rad);
   if (!BP.isLine){
   float rrr=x2X(2*BP.r);
   myPrintln(BP.center.x+" "+BP.center.y+" rad="+BP.r);
   ellipse(x2X(BP.center.x),y2Y(BP.center.y),rrr,rrr );
   //ellipse((float)BP.center.x,(float)BP.center.y,rrr,rrr );
   }
   else
   {// draw a line
   line(x2X(-1),y2Y(BP.y(-1)),x2X(1),y2Y(BP.y(1)));
   stroke(128,128,128);
   float diam=x2X(2*0.5);
   ellipse(x2X(0),y2Y(0),diam,diam);
   }
   */

if (showText){
  textSize(30);
  strokefill(128);
  text("Poincare disk", 2, 30);}
}

// Overlay of the two bisectors
void draw2KleinPoincare()
{
  float thick=5.0;

   // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(thick);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  // end draw disk
  
  
  
  Ball BBB = new Ball(new point(side/2, side/2), side/2);

 
  strokeWeight(thick);

  // geodesic
  stroke(0, 0, 255);
  noFill();
  geoPoincare( new point(point[0][0], point[0][1]), new point(point[1][0], point[1][1])   );

  Ball B1=new Ball(new point(Pcx, Pcy), Prad );
 
  // bisector



  strokefill(255, 0, 0);
  noFill();
  geoPoincare( Inter1, Inter2  );
  //  point P1=Klein2Poincare(new point(point[0][0], point[0][1]));
  //point P2=Klein2Poincare(new point(point[1][0], point[1][1]));
  ellipse(x2X(Inter1.x),y2Y(Inter1.y),thick,thick);
  ellipse(x2X(Inter2.x),y2Y(Inter2.y),thick,thick);

  Ball B2=new Ball(new point(Pcx, Pcy), Prad );
 

//intersection point
  point [] interp=B1.intersection(B2);
  strokefill(0, 255, 0);
  ellipse((float)interp[0].x, (float)interp[0].y, 5, 5);
//  ellipse((float)interp[1].x, (float)interp[1].y, 5, 5);

 
  // generator  
  strokefill(0, 0, 0);
  point P1=Klein2Poincare(new point(point[0][0], point[0][1]));
  point P2=Klein2Poincare(new point(point[1][0], point[1][1]));
  ellipse(x2X(P1.x), y2Y(P1.y), thick, thick);
  ellipse(x2X(P2.x), y2Y(P2.y), thick, thick);

// klein
strokeWeight(thick);
  
  // geodesic
  strokefill(205, 205, 255);
  line(x2X(point[0][0]), y2Y(point[0][1]), x2X(point[1][0]), y2Y(point[1][1]));
  



  // bisector
  strokefill(255, 205, 205);
  line(x2X(Inter1.x), y2Y(Inter1.y), x2X(Inter2.x), y2Y(Inter2.y));
  ellipse(x2X(Inter1.x), y2Y(Inter1.y), thick, thick);
  ellipse(x2X(Inter2.x), y2Y(Inter2.y), thick, thick);
  

  // intersection point
  strokefill(205, 255, 205);
  point interpp=lineIntersect(x2X(point[0][0]), y2Y(point[0][1]), x2X(point[1][0]), y2Y(point[1][1]), x2X(Inter1.x), y2Y(Inter1.y), x2X(Inter2.x), y2Y(Inter2.y));
  ellipse((float)interpp.x, (float)interpp.y, 5.0, 5.0);

  // generator  
  strokefill(0, 0, 0);
  ellipse(x2X(point[0][0]), y2Y(point[0][1]), thick, thick);
  ellipse(x2X(point[1][0]), y2Y(point[1][1]), thick, thick);





  textSize(30);
   strokefill(128);
   text("Klein & Poincare", 2, 30);  
   
}


public point lineIntersect(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) 
{
  double denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);
  if (denom == 0.0) { // Lines are parallel.
    return null;
  }
  double ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3))/denom;
  double ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3))/denom;
  if (ua >= 0.0f && ua <= 1.0f && ub >= 0.0f && ub <= 1.0f) {
    // Get the intersection point.
    return new point( (x1 + ua*(x2 - x1)), (y1 + ua*(y2 - y1)));
  }

  return null;
}

//
// Draw the geodesic/bisecter in Klein disk
//
void draw2Klein()
{
  float thick=5;
  
  // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(thick);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  // end draw disk
  
  strokeWeight(thick);
  /*
  if (showTangent){
strokefill(0,255,205);
drawTangentLine(Inter1.x,Inter1.y);
drawTangentLine(Inter2.x,Inter2.y);
}
*/

  
  // geodesic
  strokefill(0, 0, 255);
  line(x2X(point[0][0]), y2Y(point[0][1]), x2X(point[1][0]), y2Y(point[1][1]));
  



  // bisector
  strokefill(255, 0, 0);
  line(x2X(Inter1.x), y2Y(Inter1.y), x2X(Inter2.x), y2Y(Inter2.y));
  ellipse(x2X(Inter1.x), y2Y(Inter1.y), thick, thick);
  ellipse(x2X(Inter2.x), y2Y(Inter2.y), thick, thick);
  


  // intersection point
  strokefill(0, 255, 0);
  point  interp=lineIntersect(x2X(point[0][0]), y2Y(point[0][1]), x2X(point[1][0]), y2Y(point[1][1]), x2X(Inter1.x), y2Y(Inter1.y), x2X(Inter2.x), y2Y(Inter2.y));
  ellipse((float)interp.x, (float)interp.y, 5.0, 5.0);

  // generator  
  strokefill(0, 0, 0);
  ellipse(x2X(point[0][0]), y2Y(point[0][1]), thick, thick);
  ellipse(x2X(point[1][0]), y2Y(point[1][1]), thick, thick);



/*
  textSize(30);
  strokefill(128);
  text("Klein disk", 2, 30);
  */
}

// Draw for two points
void draw2()
{
  background(255, 255, 255);

  if (mode==modeKLEIN) {
    draw2Klein();
  }


  if (mode==modePOINCARE) {
    draw2Poincare();
  }

  if (mode==modeUPPER) {
    draw2Upper();
  }

  if (mode==modeKLEINPOINCARE) {
    draw2KleinPoincare();
  }


  if (animation) {
    animate();
  }
}

//
// Rendering in the window
//
void draw()
{
  if (n==2) {
    draw2();
  }
  else
  {

    background(255, 255, 255);

    if (mode==modeKLEIN) {
      rr=gg=bb=0;
      drawKlein();

      if (shiftMode)
      {
        stroke(128, 255, 128);  
        drawTransformedKlein();
      }
    }


    if (mode==modePOINCARE) {
      rr=gg=bb=0;
      drawPoincare();
    }
    if (mode==modeKLEINPOINCARE) {
      drawKleinPoincare();
    }
    if (mode==modeUPPER) {
      rr=gg=bb=0;
      stroke(rr, gg, bb);
      drawUpper();
    }
    if (mode==modePD) {
      rr=gg=bb=0;
      drawLaguerre();
    } 


    if (mode==modeKLEINEUCLIDEAN) {
      rr=gg=bb=0;
      drawEuclidean();
    } 

    if (mode==modePROJHYPERBOLOID) {
      rr=gg=bb=0;
      drawProjectedHyperboloid();
    } 


    if (animation) {
      animate();
    }

    if (savePDF) endRecord();
  }
}

//
// update the point positions
//
void animate()
{
  int i;
  float nrm;
  float thresh=0.98;

  for (i=0;i<n;i++)
  {
    nrm=sqrt((float)( point[i][0]*point[i][0]+ point[i][1]*point[i][1]));

    point[i][0]=point[i][0]+anim[i][0];
    point[i][1]=point[i][1]+anim[i][1];

    if (nrm>thresh) {
      point[i][0]/=(nrm/thresh); 
      point[i][1]/=(nrm/thresh); 
      // bounce
      anim[i][0]=-anim[i][0]; 
      anim[i][1]=-anim[i][1];

      point[i][0]=point[i][0]+anim[i][0];
      point[i][1]=point[i][1]+anim[i][1];
    }
  }

  createPDstructure();
}


public static double normSqr(double [] x)
{
  return x[0]*x[0]+x[1]*x[1];
}




double xminUpper(point k1, point k3)
{
  point k2;
  point U1, U2, U3;
  double cx, cy, D, rad;

  double lambda;
  lambda=0.5;
  double s=0.99999;
  k1=new point(k1.x*s, k1.y*s);
  k3=new point(k3.x*s, k3.y*s);
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  U1=Klein2Upper(k1);
  U2=Klein2Upper(k2);
  U3=Klein2Upper(k3);


  // points in Euclidean coordinates now
  U1.x=BBUpper.x2X(U1.x);
  U1.y=BBUpper.y2Y(U1.y);
  U2.x=BBUpper.x2X(U2.x);
  U2.y=BBUpper.y2Y(U2.y);
  U3.x=BBUpper.x2X(U3.x);
  U3.y=BBUpper.y2Y(U3.y);

  D  = (U1.x*(U2.y-U3.y) + U2.x*(U3.y-U1.y) + U3.x*(U1.y-U2.y));
  cx = (((U1.x*U1.x+U1.y*U1.y)*(U2.y-U3.y)+(U2.x*U2.x+U2.y*U2.y)*(U3.y-U1.y)+(U3.x*U3.x+U3.y*U3.y)*(U1.y-U2.y))/(2*D));
  cy = ((U1.x*U1.x+U1.y*U1.y)*(U3.x-U2.x)+(U2.x*U2.x+U2.y*U2.y)*(U1.x-U3.x)+(U3.x*U3.x+U3.y*U3.y)*(U2.x-U1.x))/(2*D);
  rad=Math.sqrt(((U1.x-cx)*(U1.x-cx) + (U1.y-cy)*(U1.y-cy)));

  return cx-rad;
}


double xmaxUpper(point k1, point k3)
{
  point k2;
  point U1, U2, U3;
  double cx, cy, D, rad;

  double lambda;
  lambda=0.5;
  double s=0.99999;
  k1=new point(k1.x*s, k1.y*s);
  k3=new point(k3.x*s, k3.y*s);
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  U1=Klein2Upper(k1);
  U2=Klein2Upper(k2);
  U3=Klein2Upper(k3);


  // points in Euclidean coordinates now
  U1.x=BBUpper.x2X(U1.x);
  U1.y=BBUpper.y2Y(U1.y);
  U2.x=BBUpper.x2X(U2.x);
  U2.y=BBUpper.y2Y(U2.y);
  U3.x=BBUpper.x2X(U3.x);
  U3.y=BBUpper.y2Y(U3.y);

  D  = (U1.x*(U2.y-U3.y) + U2.x*(U3.y-U1.y) + U3.x*(U1.y-U2.y));
  cx = (((U1.x*U1.x+U1.y*U1.y)*(U2.y-U3.y)+(U2.x*U2.x+U2.y*U2.y)*(U3.y-U1.y)+(U3.x*U3.x+U3.y*U3.y)*(U1.y-U2.y))/(2*D));
  cy = ((U1.x*U1.x+U1.y*U1.y)*(U3.x-U2.x)+(U2.x*U2.x+U2.y*U2.y)*(U1.x-U3.x)+(U3.x*U3.x+U3.y*U3.y)*(U2.x-U1.x))/(2*D);
  rad=Math.sqrt(((U1.x-cx)*(U1.x-cx) + (U1.y-cy)*(U1.y-cy)));

  return cx+rad;
}


void fullCircleUpper(point k1, point k3)
{
  point k2;

  point U1, U2, U3;
  double cx, cy, D, rad;
  float begina=0, enda=0;

  // midpoint
  double lambda;
  lambda=0.5;
  double s=0.99999;
  k1=new point(k1.x*s, k1.y*s);
  k3=new point(k3.x*s, k3.y*s);
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  U1=Klein2Upper(k1);
  U2=Klein2Upper(k2);
  U3=Klein2Upper(k3);

  D  = (U1.x*(U2.y-U3.y) + U2.x*(U3.y-U1.y) + U3.x*(U1.y-U2.y));
  cx = (((U1.x*U1.x+U1.y*U1.y)*(U2.y-U3.y)+(U2.x*U2.x+U2.y*U2.y)*(U3.y-U1.y)+(U3.x*U3.x+U3.y*U3.y)*(U1.y-U2.y))/(2*D));
  cy = ((U1.x*U1.x+U1.y*U1.y)*(U3.x-U2.x)+(U2.x*U2.x+U2.y*U2.y)*(U1.x-U3.x)+(U3.x*U3.x+U3.y*U3.y)*(U2.x-U1.x))/(2*D);
  rad=Math.sqrt(((U1.x-cx)*(U1.x-cx) + (U1.y-cy)*(U1.y-cy)));

  Uminx=cx-rad; 
  Umaxx=cx+rad;
}

// geodesics are half circles perpendicular to the H0 plane
void geoUpper(point k1, point k3)
{
  point k2;
  ;
  point U1, U2, U3;
  double cx, cy, D, rad;
  float begina=0, enda=0;

  // midpoint
  double lambda;
  lambda=0.5;
  double s=0.99999;
  k1=new point(k1.x*s, k1.y*s);
  k3=new point(k3.x*s, k3.y*s);
  k2=new point(lambda*k1.x+(1-lambda)*k3.x, lambda*k1.y+ (1-lambda)*k3.y) ;

  U1=Klein2Upper(k1);
  U2=Klein2Upper(k2);
  U3=Klein2Upper(k3);


  // points in Euclidean coordinates now
  U1.x=BBUpper.x2X(U1.x);
  U1.y=BBUpper.y2Y(U1.y);
  U2.x=BBUpper.x2X(U2.x);
  U2.y=BBUpper.y2Y(U2.y);
  U3.x=BBUpper.x2X(U3.x);
  U3.y=BBUpper.y2Y(U3.y);

  D  = (U1.x*(U2.y-U3.y) + U2.x*(U3.y-U1.y) + U3.x*(U1.y-U2.y));
  cx = (((U1.x*U1.x+U1.y*U1.y)*(U2.y-U3.y)+(U2.x*U2.x+U2.y*U2.y)*(U3.y-U1.y)+(U3.x*U3.x+U3.y*U3.y)*(U1.y-U2.y))/(2*D));
  cy = ((U1.x*U1.x+U1.y*U1.y)*(U3.x-U2.x)+(U2.x*U2.x+U2.y*U2.y)*(U1.x-U3.x)+(U3.x*U3.x+U3.y*U3.y)*(U2.x-U1.x))/(2*D);
  rad=Math.sqrt(((U1.x-cx)*(U1.x-cx) + (U1.y-cy)*(U1.y-cy)));

  Ucx=cx;
  Ucy=cy;
  Urad=rad;

  // arc between first point and third point
  begina=atan2((float)(U1.y-cy), (float)(U1.x-cx));
  enda=atan2((float)(U3.y-cy), (float)(U3.x-cx));
  if (enda<begina) {
    //myPrintln("need to swap");
    float tmp; 
    tmp=enda; 
    enda=begina; 
    begina=tmp;
  }


  noFill();

  if (enda-begina>PI)
  {
    arc((float)cx, (float)cy, (float)(2*rad), (float)(2*rad), enda, begina+2*PI);
  }
  else {
    arc((float)cx, (float)cy, (float)(2*rad), (float)(2*rad), (float)begina, (float)enda);
  }
}


//

// f4 circ f3
point Klein2EuclideanAlmostGood(point p)
{
  return f4(f3(p));
}

// frank
point Klein2ProjectedHyperboloid(point p)
{
  point hyp=Klein2Hyperboloid(p);
  return new point(hyp.x/hyp.z, hyp.y/hyp.z);
}

point Klein2Euclidean(point p)
{
  point hyp=Klein2Hyperboloid(p);
  double den=maxzhyperboloid-hyp.z;
  return new point(maxzhyperboloid*hyp.x/(den), maxzhyperboloid*hyp.y/den);
}



//
// Initialization
//
double [][] anim;
double scanim=0.001;

void chooseColor()
{
  int i; 
  col=new color[nmax];
  for (i=0;i<nmax;i++)
  {
    col[i]=color(random(255), random(255), random(255));
  }
}


void initialize()
{
  int i; 
  float r=side/2, xx, yy;
  double rr, aa;

  chooseColor();

  anim=new double[nmax][2];
  point=new double[nmax][2];
  pointK=new double[nmax][2];
  center=new double[nmax][2];
  radius=new double[nmax];
  pointKE=new point[nmax];
  pointKH=new point[nmax];

DelaunayEdge=new boolean[nmax][nmax];


  // set animation velocity vectors
  for (i=0;i<nmax;i++)
  {
    rr=Math.random();
    aa=Math.random();
    xx=(float)(rr*Math.cos(2.0*Math.PI*aa));
    yy=(float)(rr*Math.sin(2.0*Math.PI*aa));

    anim[i][0]=xx*scanim;
    anim[i][1]=yy*scanim;
  }

  // create a root polygon which limits the voronoi diagram.
  //  here it is just a rectangle.

  rootPolygon = new PolygonSimple();
  // clip to unit disk for Klein
  int k=2*n;
  for (i=0;i<k;i++)
  {
    xx=(float)(Math.cos(2.0*Math.PI*i/(double)k));
    yy=(float)(Math.sin(2.0*Math.PI*i/(double)k));
    rootPolygon.add(10*xx, 10*yy);
  }

  // clipping box for the Euclidean Voronoi diagram
  rootPolygonE = new PolygonSimple();
  double bigN=100000;
  rootPolygonE.add(-bigN, -bigN);
  rootPolygonE.add(-bigN, bigN);
  rootPolygonE.add(bigN, bigN);
  rootPolygonE.add(bigN, -bigN);


  rootPolygonH = new PolygonSimple();
  bigN=100000;
  rootPolygonH.add(-bigN, -bigN);
  rootPolygonH.add(-bigN, bigN);
  rootPolygonH.add(bigN, bigN);
  rootPolygonH.add(bigN, -bigN);

  // bounding box
  /*
double large=10000000;
   rootPolygon.add(large,large);
   rootPolygon.add(large,-large);
   rootPolygon.add(large,large);
   rootPolygon.add(-large,large);     
   */
  maxzhyperboloid=0;
  myPrintln("initialize for "+n+" points");

  //diagram = new PowerDiagram();
  //  sites = new OpenList();

  double maxr=0.9;
  double theta;
  // create  points (sites) and set random positions in the rectangle defined above.
  for (  i = 0; i < n; i++) {
    // point in a unit circle
    // double rr=rand.nextDouble();
   
   
   rr=maxr*rand.nextDouble();
    theta=2.0*Math.PI*rand.nextDouble();


/*
if (i==0) {rr=0.0; theta=0;}
else{
   rr=0.99;
    theta=2.0*Math.PI*(i-1)/(double)(n-1);
}
*/
    // uniform in klein disk
    // in unit disk
    point[i][0]=rr*Math.cos(theta);
    point[i][1]=rr*Math.sin(theta);
    
   // if ((n==2)&&(!animation)) {point[1][0]=-point[0][0]; point[1][1]=- point[0][1]; }

    /* 
     // uniform in poincare
     point pp=Poincare2Klein(new point(point[i][0],point[i][1]));
     point[i][0]=pp.x;
     point[i][1]=pp.y;
     */
    point ph=Klein2Hyperboloid(new point(point[i][0], point[i][1]));
    maxzhyperboloid=mymax(maxzhyperboloid, ph.z);


    pointK[i]=Klein2Poincare(point[i]);

    point kleinp=new point(point[i][0], point[i][1], 1);

    // central projection...
    pointKE[i]=Klein2Euclidean(kleinp);

    pointKH[i]=Klein2ProjectedHyperboloid(kleinp);

    myPrintln(i+" "+point[i][0]+" "+point[i][1]);

    double den=2.0*Math.sqrt(1.0-normSqr(point[i]));
    //  myPrintln("\t"+den);

    //  center[i][0]=point[i][0]/den;
    //  center[i][1]=point[i][1]/den;
    //  radius[i]= (normSqr(point[i])/(den*den))-(2.0/den);
    //  myPrintln("radius weight:"+radius[i]);
  }

  createPDstructure();
  
  

  myPrintln("max z hyperboloid:"+ maxzhyperboloid);
  
  UpdateDelaunay();
  
  
}


void UpdateDelaunay()
  {
  DelaunayEdge=new boolean [nmax][nmax];
  int i,j;
  
for ( i=0;i<nmax;i++)
for ( j=0;j<nmax;j++)
DelaunayEdge[i][j]=false;

Site site;
for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    PolygonSimple polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      { 
        
        if (Norm(polygon.x[j], polygon.y[j])<1)
        {
           int res[] = indexVoronoiGenerators(polygon.x[j], polygon.y[j]);
             
             
             println(res.length+" !!!!");
             
           if (res.length==3){
           DelaunayEdge[res[0]][res[1]]=true;
           DelaunayEdge[res[1]][res[2]]=true;
           DelaunayEdge[res[0]][res[2]]=true;}
            
           if (res.length==2){
              DelaunayEdge[res[0]][res[1]]=true;
           }
           
        }
      }}}


}

double DistanceKlein(double [] p,double [] q)
{
return  (1.0-(p[0]*q[0]+p[1]*q[1]))/Math.sqrt( (1-(p[0]*p[0]+p[1]*p[1])) * (1-(q[0]*q[0]+q[1]*q[1])) )  ;
}

int [] indexVoronoiGenerators(double x, double y)
{
  double eps=1.0e-5;
  int [] res=new int[3];
  double mindistance=Double.MAX_VALUE;
  double []  p=new double [2]; p[0]=x; p[1]=y;    
  int i;
  
  for(i=0;i<n;i++)
  {
  if (DistanceKlein(p,point[i])<mindistance) {mindistance=DistanceKlein(p,point[i]);}
  }
  
  int j=0;
  for(i=0;i<n;i++)
  {
  if (Math.abs(DistanceKlein(p,point[i])-mindistance)<eps  )  res[j++]=i;
  if (j>=3) break;
  }
  
  //if (j==2) println("2!!!!!"); else println("3!!!!!"); 
  int [] res2=new int[j];
  for(i=0;i<j;i++) res2[i]=res[i];
  
  return res2;
}

public double mymax(double a, double b)
{
  if (a>b) return a; 
  else return b;
}

public point Klein2Hyperboloid(point p)
{
  double  den=Math.sqrt(1-p.x*p.x-p.y*p.y);
  return new point(p.x/den, p.y/den, 1.0/den);
}     

//
// Create the Euclidean Voronoi structure, frank method
//
void createHstructure()
{
  diagramH = new PowerDiagram();
  sitesH = new OpenList();  
  int i;
  diagramH = new PowerDiagram();
  sitesH = new OpenList();

  for (i=0;i<n;i++)
  {
    point pe=Klein2ProjectedHyperboloid(new point(point[i][0], point[i][1]));
    double pe2=pe.x*pe.x+pe.y*pe.y;

    siteH = new Site(pe.x, pe.y);
    siteH.setWeight(0.25*pe2-Math.sqrt(1+pe2));  
    sitesH.add(siteH);
  }

  diagramH.setSites(sitesH);
  diagramH.setClipPoly(rootPolygonH);
  diagramH.computeDiagram();
}



// 2013 fast method paper
void createEstructure()
{
  diagramE = new PowerDiagram();
  sitesE = new OpenList();  
  int i;
  diagramE = new PowerDiagram();
  sitesE = new OpenList();

  for (i=0;i<n;i++)
  {
    point pe=Klein2Euclidean(new point(point[i][0], point[i][1]));

    siteE = new Site(pe.x, pe.y );
    siteE.setWeight(0);  
    sitesE.add(siteE);
  }

  diagramE.setSites(sitesE);
  diagramE.setClipPoly(rootPolygonE);
  diagramE.computeDiagram();
}


//
// Create the power diagram structure
//

double sideK=1, sideP=1, sideU=2, sidePD=1, sideH=2, sideE=20;

void createBBs()
{
  BBBall=new BB(-sideK, sideK, -sideK, sideK, side, side, 0, 0);
  BBEuclidean=new BB(-sideE, sideE, -sideE, sideE, side, side, 0, 0);
  BBHyperboloid=new BB(-sideH, sideH, -sideH, sideH, side, side, 0, 0);
  BBPD=new BB(-sidePD, sidePD, -sidePD, sidePD, side, side, offsetX, -offsetY);
}


void createPDstructure()
{
  diagram = new PowerDiagram();
  sites = new OpenList();  
  int i;
  double den;



  createBBs();

  if (n==2) {
    double mminx=-10; 
    double deltab=-mminx;
    // BBUpper=new BB(mminx, mminx+deltab, 0, deltab, side, side, 0, 0);
    ComputeUpperBB();
    // Klein bisector for two points
    double tp=Math.sqrt(1.0-point[0][0]*point[0][0]-point[0][1]*point[0][1]);
    double tq=Math.sqrt(1.0-point[1][0]*point[1][0]-point[1][1]*point[1][1]);

    ax2=tp*point[1][0]-tq*point[0][0];
    ay2=tp*point[1][1]-tq*point[0][1];
    c2=tq-tp;

    point p1=new point(0, -c2/ay2);
    point p2=new point(1, (-c2-ax2)/ay2);

    point u=new point(1, -ax2/ay2)   ;  
    point p=new point(0, -c2/ay2);
    double aa, bb, cc, delta, ll1, ll2;
    aa=(u.x*u.x)+(u.y*u.y);
    bb=2*(p.x*u.x+p.y*u.y);
    cc=p.x*p.x+p.y*p.y-1;
    delta=bb*bb-4.0*aa*cc;
    ll1=(-bb+Math.sqrt(delta))/(2.0*aa);
    ll2=(-bb-Math.sqrt(delta))/(2.0*aa);
    Inter1=new point(p.x+ll1*u.x, p.y+ll1*u.y);
    Inter2=new point(p.x+ll2*u.x, p.y+ll2*u.y);
    double s=0.999999;
    SInter1=new point(s*Inter1.x, s*Inter1.y);
    SInter2=new point(s*Inter2.x, s*Inter2.y);
  }
  else {

    diagram = new PowerDiagram();
    sites = new OpenList();

    for (i=0;i<n;i++)
    {
      den=2.0*Math.sqrt(1.0-normSqr(point[i]));
      center[i][0]=point[i][0]/den;
      center[i][1]=point[i][1]/den;
      radius[i]= (normSqr(point[i])/(den*den))-(2.0/den);

      if (Double.isNaN(radius[i])) {
        myPrintln("not a number !"+den);
        exit();
      }

      site = new Site(center[i][0], center[i][1] );
      site.setWeight(radius[i]);  

      sites.add(site);
    }



    diagram.setSites(sites);
    diagram.setClipPoly(rootPolygon);
    diagram.computeDiagram();   

    if (!animation) ComputeUpperBB();


    for (i=0;i<n;i++)
    {
      point kleinp=new point(point[i][0], point[i][1], 1);

      // central projection...
      pointKE[i]=Klein2Euclidean(kleinp);
    }

/*
    createEstructure();
    createHstructure();
  */

}

UpdateDelaunay();
}


int NN(point now)
{
  int i, res=0;
  double mdist, dist;

  mdist=Double.MAX_VALUE;

  for (i=0;i<n;i++)
  {
    dist=now.Distance(new point(pointK[i][0], pointK[i][1]));
    if (dist<mdist) {
      mdist=dist;
      res=i;
    }
  }


  return res;
}


int NN()
{
  int i, res=0;
  double mdist, dist;
  point now=new point(X2x(mouseX), Y2y(mouseY));
  mdist=Double.MAX_VALUE;

  for (i=0;i<n;i++)
  {
    dist=now.Distance(new point(pointK[i][0], pointK[i][1]));
    if (dist<mdist) {
      mdist=dist;
      res=i;
    }
  }


  return res;
}

void addSite(double xx, double yy)
{

  point[n][0]=xx;
  point[n][1]=yy;
  pointK[n]=Klein2Poincare(point[n]);
  double den=2.0*Math.sqrt(1.0-normSqr(point[n]));
  //  myPrintln("\t"+den);

  center[n][0]=point[n][0]/den;
  center[n][1]=point[n][1]/den;
  radius[n]= (normSqr(point[n])/(den*den))-(2.0/den);
  myPrintln("radius weight:"+radius[n]);

  site = new Site(center[n][0], center[n][1] );
  site.setWeight(radius[n]);  //rand.nextInt(5000)

  sites.add(site);  
  n++;
}


void moveSite(int pos, double xx, double yy)
{

  point[pos][0]=xx;
  point[pos][1]=yy;
  pointK[pos]=Klein2Poincare(point[pos]);
  double den=2.0*Math.sqrt(1.0-normSqr(point[pos]));
  //  myPrintln("\t"+den);

  center[pos][0]=point[pos][0]/den;
  center[pos][1]=point[pos][1]/den;
  radius[pos]= (normSqr(point[pos])/(den*den))-(2.0/den);
  myPrintln("radius weight:"+radius[pos]);

  site = new Site(center[pos][0], center[pos][1] );
  site.setWeight(radius[pos]);  //rand.nextInt(5000)

  // sites.add(site);  
  sites.array[pos]=site;
}


//
// Adding/moving points interactively, or browsing the disk
//
Complex Transformation(Complex cstart, Complex cnow)
{
  Complex den=cstart.times(cnow.conjugate()).plus(1);
  return cstart.times(cnow).divides(den);
}

void mouseDragged()
{

  if (shiftMode) 
  {
    if (mode==modeKLEIN) {
      myPrintln("dragging, updating isometry");
      //kpnow=new point(-X2x(mouseX),-Y2y(mouseY));
      kpnow=new point(X2x(mouseX), Y2y(mouseY));
      cnow=new Complex(kpnow.x, kpnow.y);

      Complex den=cstart.times(cnow.conjugate()).plus(1);
      transformation=Transformation(cstart, cnow);
      //Composition

      // isometryKlein(new Complex(kpstart.x,kpstart.y));
      // isometryKlein(new Complex(kpnow.x,kpnow.y));
      // createPDstructure();
    }
  }



  if ( (mouseButton == RIGHT)) {
    double xx, yy;
    xx=X2x(mouseX);
    yy=Y2y(mouseY);

    if (mode==modeKLEIN) {
      // compute closest  point
      int index=NN(); 
      pos=index;
      myPrintln("NN index "+index);

      moveSite(index, xx, yy);
      createPDstructure();
    }

    if (mode==modePOINCARE)
    {
      myPrintln("RIGHT POINCARE x="+xx+" y="+yy);
      point pk=Poincare2Klein(new point(xx, yy));
      int index=NN(pk); 
      pos=index;
      myPrintln("NN index "+index);

      moveSite(index, xx, yy);
      createPDstructure();
    }

    if (mode==modeUPPER)
    {
      xx=BBUpper.X2x(mouseX);
      yy=BBUpper.Y2y(mouseY);
      myPrintln("RIGHT UPPER  x="+xx+" y="+yy);
      point pk=Upper2Klein(new point(xx, yy));
      int index=NN(pk); 
      pos=index;
      myPrintln("NN index "+index);

      moveSite(index, xx, yy);
      createPDstructure();
    }
  }
}

//
// remove a site
//
void deleteSite()
{
  int index=NN(); 
  pos=index;

  myPrintln(mouseX+" "+mouseY);
  myPrintln("delete NN index "+index);

  point[pos][0]=point[n][0];
  point[pos][1]=point[n][1];
  n--;
  myPrintln("point set size:"+n);

  createPDstructure();
}

void mousePressed() {
  double xx, yy;
  xx=X2x(mouseX);
  yy=Y2y(mouseY);

  if (shiftMode) {
    if (mode==modeKLEIN) {
      myPrintln("initialize kpstart");
      kpstart=new point(-x2X(mouseX), -y2Y(mouseY));
      cstart=new Complex(kpstart.x, kpstart.y);
    }
  }
  else {

    if (keyPressed   && (key == CODED) &&  (key==SHIFT) && mousePressed && (mouseButton == LEFT) ) {
      myPrintln("removing generator");
      return;
    }


    if (mousePressed && (mouseButton == LEFT)) {
      pos=-1;

      if (mode==modeKLEIN) {
        myPrintln("LEFT KLEIN x="+xx+" y="+yy);
        addSite(xx, yy);
        createPDstructure();
      }

      if (mode==modePOINCARE)
      {
        myPrintln("LEFT POINCARE x="+xx+" y="+yy);
        point pk=Poincare2Klein(new point(xx, yy));
        addSite(pk.x, pk.y);
        createPDstructure();
      }

      if (mode==modeUPPER)
      {
        xx=BBUpper.X2x(mouseX);
        yy=BBUpper.Y2y(mouseY);
        myPrintln("LEFT UPPER  x="+xx+" y="+yy);
        point pk=Upper2Klein(new point(xx, yy));
        addSite(pk.x, pk.y);
        createPDstructure();
      }
    }
  }
  /* else if (mousePressed && (mouseButton == RIGHT)) {
   // compute closest  point
   int index=NN(); 
   pos=index;
   myPrintln("NN index "+index);
   
   moveSite(index, xx, yy);
   createPDstructure();
   }*/
}

//
// Compte the power diagrams
//
void computebeforePD()
{
  diagram.setSites(sites);
  diagram.setClipPoly(rootPolygon);
  diagram.computeDiagram();   

  ComputeUpperBB();
  BBBall=new BB(-1, 1, -1, 1, side, side, 0, 0);
  BBEuclidean=new BB(-10, 10, -10, 10, side, side, 0, 0);
}
