
/* (c) December 2023 Frank Nielsen Frank.Nielsen@acm.org
 Demo: Reflection about the geodesic passing through two given points in the Poincar\'e disk model of hyperbolic geometry
 */

import processing.pdf.*;

int winwidth=512, winheight=512;
int side=winheight;

double minx=-1, maxx=1;
double miny=-1, maxy=1;

//boolean toggleKlein=true;
//boolean togglePoincare=false;

boolean toggleKlein=false;
boolean togglePoincare=true;

int n=20;
Point2D [] parray, qarray;
Point2D [] pointP, pointK;

double alpha=0;
double dalpha=0.01;
boolean animation=true;

double a0, b0, r0;
Reflection reflec;

float ptsize=5;

// Convert Klein2Pointcare
Point2D K2P(Point2D k)
{
  double sqrr=k.x*k.x+k.y*k.y;
  double rescale=(1-Math.sqrt(1-sqrr))/sqrr;
  return new Point2D(rescale*k.x, rescale*k.y);
}


Point2D P2K(Point2D p)
{
  double rescale=2.0/(1+p.sqrnorm());

  return new Point2D(rescale*p.x, rescale*p.y);
}


void Initialize()
{
  int i;
  parray=new Point2D[n];
  qarray=new Point2D[n];

  pointP=new Point2D[n];
  pointK=new Point2D[n];
  double xx, yy, rr, theta;

  for (i=0; i<n; i++) {
    rr=Math.random();
    theta=Math.random()*Math.PI*2;

    pointK[i]=new Point2D(rr*Math.cos(theta), rr*Math.sin(theta));
    pointP[i]=K2P(pointK[i]);

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
    println("dist:"+dist+" "+i+" "+KleinDistance(parray[i], qarray[i]));
  }

  /*
 parray[0]=new Point2D(0.1,-0.3);
   parray[1]=new Point2D(-0.1,0.6);
   parray[2]=new Point2D(0.0,0.07542668890493671);
   */

  // pointP[0]=new Point2D(-0.2,-0.2);
  // pointP[1]=new Point2D(-0.7,0.2);
  //[a0=-1.449999972065928,b0=-1.24999996508241,r0=1.632482727883478]


  pointK[0]=P2K(pointP[0]);
  pointK[1]=P2K(pointP[1]);

  Point2D mid=LERP(pointK[0], pointK[1], 0.5);
  Point2D Pmid= K2P(mid);

  println("mid P:"+Pmid.x+" "+Pmid.y); //exit();

  //pointP[2]=Pmid;
  //pointK[2]=mid;



  a0=-1.449999972065928;
  b0=-1.24999996508241;
  r0=1.632482727883478;



  reflec=new Reflection(a0, b0, r0);


  reflec=new Reflection(pointP[0], pointP[1], Pmid);
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


void drawPoincareGeodesicEndpoint(Point2D p1, Point2D p2)
{
  Point2D k, kn, k1, k2, pmin, pmax;

  k1=P2K(p1);
  k2=P2K(p2);

  double tmin=0, tmax=1;

  double stept=0.001;



  for (double t=tmin; t<=tmax+stept; t+=stept)
  {
    k=LERP(k1, k2, t);
    kn=LERP(k1, k2, t+stept);
    drawLine(K2P(k), K2P(kn));
  }
}


void drawPoincareGeodesic(Point2D p1, Point2D p2)
{
  Point2D k1, k2, pmin, pmax;

  k1=P2K(p1);
  k2=P2K(p2);

  double tmin, tmax;
  double a, b, c, delta;

  a=(k1.minus(k2)).sqrnorm();
  b=2*k1.inner(k2.minus(k1));
  c=k1.sqrnorm()-1;
  delta=b*b-4*a*c;

  tmin=(-b-Math.sqrt(delta))/(2.0*a);
  tmax=(-b+Math.sqrt(delta))/(2.0*a);

  Point2D k, kn, kmin, kmax;
  kmin=k1.plus((k2.minus(k1)).times(tmin));
  kmax=k1.plus((k2.minus(k1)).times(tmax));

  pmin=K2P(kmin);
  pmax=K2P(kmax);

  double stept=0.001;

  k=LERP(k1, k2, tmin+stept);
  drawLine(K2P(kmin), K2P(k));

  k=LERP(k1, k2, tmax-stept);
  drawLine(K2P(kmax), K2P(k));

  for (double t=tmin; t<=tmax+stept; t+=stept)
  {
    k=LERP(k1, k2, t);
    kn=LERP(k1, k2, t+stept);
    drawLine(K2P(k), K2P(kn));
  }

  stroke(128, 128, 0);
  drawPoint(pmin);
  drawPoint(pmax);
}


void drawKleinGeodesicEndpoint(Point2D k1, Point2D k2)
{
  double tmin, tmax;
  double a, b, c, delta;

  a=(k1.minus(k2)).sqrnorm();
  b=2*k1.inner(k2.minus(k1));
  c=k1.sqrnorm()-1;
  delta=b*b-4*a*c;

  tmin=0;
  tmax=1;

  Point2D pmin, pmax;
  pmin=k1.plus((k2.minus(k1)).times(tmin));
  pmax=k1.plus((k2.minus(k1)).times(tmax));

  drawLine(pmin, pmax);
}


void drawKleinGeodesic(Point2D k1, Point2D k2)
{
  double tmin, tmax;
  double a, b, c, delta;

  a=(k1.minus(k2)).sqrnorm();
  b=2*k1.inner(k2.minus(k1));
  c=k1.sqrnorm()-1;
  delta=b*b-4*a*c;

  tmin=(-b-Math.sqrt(delta))/(2*a);
  tmax=(-b+Math.sqrt(delta))/(2*a);

  Point2D pmin, pmax;
  pmin=k1.plus((k2.minus(k1)).times(tmin));
  pmax=k1.plus((k2.minus(k1)).times(tmax));

  drawLine(pmin, pmax);
}

void drawLine(Point2D p1, Point2D p2)
{
  drawLine(p1.x, p1.y, p2.x, p2.y);
}


void drawLine(double a, double b, double c, double d)
{
  line(x2X(a), y2Y(b), x2X(c), y2Y(d));
}

void drawPoint(double a, double b)
{
  ellipse(x2X(a), y2Y(b), ptsize, ptsize);
}

void drawPoint(Point2D p)
{
  drawPoint(p.x, p.y);
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
  if (key==' ') {
    Initialize();
    draw();
  }

  if (key=='p') {
    togglePoincare=!togglePoincare;
  }
  if (key=='k') {
    toggleKlein=!toggleKlein;
  }


  if (key=='x') {
    savepdffile();
  }
  if (key=='q') {
    exit();
  }
}

void setup()
{
  Initialize();
  size(512, 512);
}

void draw() {
  background(255, 255, 255);
  stroke(0);
  noFill();
  strokeWeight(3);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx, cy, side, side);

  stroke(0, 255, 0);
  drawPoint(0, 0);
  stroke(0, 0, 0);
  strokeWeight(1);

  if (toggleKlein) drawKlein();
  if (togglePoincare) drawPoincare();
}

// Klein
void drawKlein() {
  int i;

   
  drawKleinGeodesic(pointK[0], pointK[1]);

  stroke(255, 0, 255);
  for (i=0; i<n; i++)
  {
    Point2D r=reflec.reflect(pointP[i]);
    Point2D kr=P2K(r);
    stroke(255, 0, 255);
        drawKleinGeodesicEndpoint(pointK[i], kr);
 stroke(0, 0, 255);
    drawPoint(kr);
    
     stroke(255, 0, 0);
  drawPoint(pointK[i]);

  }
}


// Poincare
void drawPoincare() {
  int i;

  // draw geodesic line on which to perform reflection
  drawPoincareGeodesic(pointP[0], pointP[1]);

 

  for (i=0; i<n; i++)
  {
    Point2D r=reflec.reflect(pointP[i]);
  
  stroke(255, 0, 255);
    drawPoincareGeodesicEndpoint(pointP[i], r);
    
      stroke(255, 0, 0);
     drawPoint(pointP[i]);
        stroke(0, 0, 255);
     drawPoint(r);
     
  }
}



void drawGood() {
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



  beginRecord(PDF, "PoincareReflectionGeodesic-"+suffix+".pdf");
  draw();
  endRecord();
  
  save("PoincareReflectionGeodesics-"+suffix+".png");

}
