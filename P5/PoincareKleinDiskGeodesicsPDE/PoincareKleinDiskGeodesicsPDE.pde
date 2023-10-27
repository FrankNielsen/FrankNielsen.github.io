
/* (c) April 2021-refreshed Oct 2023 Frank Nielsen Frank.Nielsen@acm.org
 see
 Closed-form expression of geodesics in the Klein model of hyperbolic geometry
 or
 The hyperbolic Voronoi diagram in arbitrary dimension
 https://arxiv.org/abs/1210.8234
 
 press 'p' key for Poincaré mode
 press 'k' key for Klein mode
 
 press 'x' key for screenshots in png and pdf
 
 press 'q' key for exit
 */

import processing.pdf.*;

public enum DISK {
  POINCARE, KLEIN
}

DISK mode=DISK.KLEIN;

int winwidth=800, winheight=800;
int side=winheight;

double minx=-1, maxx=1;
double miny=-1, maxy=1;


int n=10;
Point2D [] parray, qarray;
double alpha=0;
double dalpha=0.01;
boolean animation=true;

void Initialize()
{
  int i;
  parray=new Point2D[n];
  qarray=new Point2D[n];
  for (i=0; i<n; i++) {
    parray[i]=new Point2D();
    parray[i].rand();
    qarray[i]=new Point2D();
    qarray[i].rand();
  }

  // reference distance
  double dist=KleinDistance(parray[0], qarray[0]);


  for (i=0; i<n; i++)
  {
    double ratio=dist/KleinDistance(parray[i], qarray[i]);
    qarray[i]=LERP(parray[i], qarray[i], KleinGeodesicC(parray[i], qarray[i], ratio));
    //println("dist:"+dist+" "+i+" "+KleinDistance(parray[i], qarray[i]));
  }
}

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


void drawLine(double a, double b, double c, double d)
{
  line(x2X(a), y2Y(b), x2X(c), y2Y(d));
}

void drawPoint(double a, double b)
{
  ellipse(x2X(a), y2Y(b), 5, 5);
}


public static double cosh(double x)
{
  return 0.5*(Math.exp(x)+Math.exp(-x));
}

public static double sqr(double x)
{
  return x*x;
}

public static double arccosh(double x)
{
  return Math.log(x+Math.sqrt(x*x-1.0));
}


public static double KleinDistance(Point2D p, Point2D q)
{
  double np2=p.sqrnorm();
  double nq2=q.sqrnorm();
  return arccosh( (1-(p.x*q.x+p.y*q.y))/Math.sqrt((1-np2)*(1-nq2)));
}

public static double max(double a, double b)
{
  if (a<b) return b;
  else return a;
}


public static Point2D LERP(Point2D p, Point2D q, double alpha)
{
  Point2D res=new Point2D();
  res.x=p.x+alpha*(q.x-p.x);
  res.y=p.y+alpha*(q.y-p.y);

  return res;
}


public static double KleinGeodesicC(Point2D p, Point2D q, double alpha)
{
  double a=1-p.sqrnorm();
  double b=p.inner(q.minus(p));
  double c=(q.minus(p)).sqrnorm();
  double d=cosh(alpha*KleinDistance(p, q));

  return (  a*d*Math.sqrt((a*c+b*b)*(d*d-1))  +a*b*(1-d*d)  )/(a*c*d*d+b*b);
}

void keyPressed()
{
  if (key=='q') {exit();}
    
  if (key==' ') {
    Initialize();
    draw();
  }
  
  
  if (key=='p') {
    mode=DISK.POINCARE;
    draw();
  }
  
    if (key=='k') {
    mode=DISK.KLEIN;
    draw();
  }


  if (key=='x') {
    savepdffile();
  }
}

void setup()
{
  Initialize();
  size(800, 800);
}

void draw()
{
  if (mode==DISK.KLEIN) drawKlein();
  if (mode==DISK.POINCARE) drawPoincare();
}

double inner(Point2D p1, Point2D p2)
{return p1.x*p2.x+p1.y*p2.y;}

// input are two points in klein disk
void drawPoincareGeodesic(Point2D k1, Point2D k2)
{
 int i, nbsteps=30;
 Point2D p1,p2;
 double alpha,beta;
 
 for(i=0;i<nbsteps;i++)
 {
 alpha=i/(double)nbsteps;
 beta=(i+1)/(double)nbsteps;
   
 p1=Klein2Poincare(LERP(k1,k2,alpha));
 p2=Klein2Poincare(LERP(k1,k2,beta));
 
 drawLine(p1.x,p1.y,p2.x,p2.y);
 }
 
}

public Point2D Klein2Poincare(Point2D p)
{
  Point2D result=new Point2D();

  double s=(1-Math.sqrt(1-inner(p, p)))/(inner(p, p));

  result.x=s*p.x;
  result.y=s*p.y;

  return result;
}

// Conformal disk model
void drawPoincare() {
  background(255, 255, 255);


  // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(3);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx, cy, side, side);

  int i;
  for (i=0; i<n; i++)
  {
 drawPoincareGeodesic(parray[i],qarray[i]);

    Point2D mm=LERP(parray[i], qarray[i], KleinGeodesicC(parray[i], qarray[i], alpha));
    
    Point2D m=Klein2Poincare(mm);

    stroke(255, 0, 0);
    drawPoint(m.x, m.y);
    stroke(0);
    
    // endpoints
    Point2D pp=Klein2Poincare(parray[i]);
    Point2D qq=Klein2Poincare(qarray[i]);
    
    drawPoint(pp.x, pp.y);
    drawPoint(qq.x, qq.y);
  }



  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  strokeWeight(1);
  // end draw disk

  stroke(0);fill(0);
  textSize(24);
  text("Poincaré disk", 40, 20);
  
  if (animation)
  {
    alpha+=dalpha;
    if (alpha>1) dalpha=-dalpha;
    if (alpha<0) dalpha=-dalpha;
  }
}
// end of Poincare


void drawKlein() {
  background(255, 255, 255);


  // draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(3);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx, cy, side, side);

  int i;
  for (i=0; i<n; i++)
  {
    drawLine(parray[i].x, parray[i].y, qarray[i].x, qarray[i].y);

    Point2D m=LERP(parray[i], qarray[i], KleinGeodesicC(parray[i], qarray[i], alpha));

    stroke(255, 0, 0);
    drawPoint(m.x, m.y);
    stroke(0);
    drawPoint(parray[i].x, parray[i].y);
    drawPoint(qarray[i].x, qarray[i].y);
  }



  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
  strokeWeight(1);
  
  stroke(0);fill(0);
  textSize(24);
  text("Klein disk", 40, 20);
  
  // end draw disk

  if (animation)
  {
    alpha+=dalpha;
    if (alpha>1) dalpha=-dalpha;
    if (alpha<0) dalpha=-dalpha;
  }
}


void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();


mode=DISK.KLEIN;
  beginRecord(PDF, "KleinGeodesics-"+suffix+".pdf");
  background(255);
  draw();

  save("KleinGeodesics-"+suffix+".png");
  endRecord();
  
  
  mode=DISK.POINCARE;
  beginRecord(PDF, "PoincareGeodesics-"+suffix+".pdf");
  background(255);
  draw();

  save("PoincareGeodesics-"+suffix+".png");
  endRecord();
}
