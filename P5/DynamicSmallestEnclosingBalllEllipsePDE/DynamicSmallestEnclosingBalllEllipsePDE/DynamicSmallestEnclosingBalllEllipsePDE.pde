// Frank.Nielsen@acm.org
// 12 May 2020

// Farthest point to an ellipse can be compute as the farthest point to a disk after affine transformation 
// from Cholesky decom L D L^T

// https://twitter.com/gabrielpeyre/status/1230733890970624000

import processing.pdf.*;

double aniso=0.35;

int nbiterations=3000;

class IdPoint  
{
  double x, y, id;
  IdPoint(double X, double Y, int ID)
  {
    x=X;
    y=Y; 
    id=ID;
  }

  IdPoint(double X, double Y)
  {
    x=X;
    y=Y;
  }
}

//int n=32;
int n=16;

//boolean anim=true;
boolean anim=false;

int nb=300;

Point [] c;
double [] a;
double [] b;
double [] theta;

Point [] speed;
double [] speedr;
double [] thetaspeed;

int W=512;
int H=512;


double minr=10;
double maxr=60;
double offset=180;
double maxx=W-offset;
double maxy=H-offset;
double minx=offset;
double miny=offset;

double [] circumcenter=new double [2];
double radius=0;
int iter=0;

Point [][] ptset;

public  double sqr(double x) {
  return x*x;
}

public  double Distance(double [] p, Point q)
{
  double res=0.0;


  res = sqr(p[0]-q.x)+sqr(p[1]-q.y);

  return Math.sqrt(res);
}

public void BCIteration(int nb)
{
  int i;
  for (i=0; i<nb; i++) OneBCIteration();
}

int winneri, winnerj;
//
// Badoiu Clarkson iterations
//
public  void OneBCIteration()
{
  int i, j;
  double dist=0.0;
   winneri=-1;
   winnerj=-1;

  // farthest point
  for (i=0; i<n; i++)
  {
    for (j=0; j<nb; j++)
    {
      if (Distance(circumcenter, ptset[i][j])>dist)
      {
        winneri=i;
        winnerj=j;
        dist=Distance(circumcenter, ptset[i][j]);
      }
    }
  }


  double alpha=(1.0/(double)(iter+1));

  circumcenter[0]=(1-alpha)*circumcenter[0]+alpha*(ptset[winneri][winnerj].x);
  circumcenter[1]=(1-alpha)*circumcenter[1]+alpha*(ptset[winneri][winnerj].y);


  // update radius
  radius=0.0;
  for (i=0; i<n; i++) {
    for (j=0; j<nb; j++)
      if (Distance(circumcenter, ptset[i][j])>radius)
      {
        radius=Distance(circumcenter, ptset[i][j]);
      }
  }


  iter++;
}


Point [] addEllipse(Point c, double a, double b, double theta, int nb, int ID)
{
  Point [] res=new Point[nb];
  int i;

  for (i=0; i<nb; i++)
  {
    double angle=2.0*Math.PI*i/(double) nb;

    res[i]=new  Point(c.x+a*Math.cos(angle)*Math.cos(theta)-b*Math.sin(angle)*Math.sin(theta), 
      c.y+b*Math.sin(angle)*Math.cos(theta)+a*Math.cos(angle)*Math.sin(theta), ID);
  }

  return res;
}

void Initialize()
{
  int i;

  c=new Point[n];
  a=new double [n];
  b=new double [n];
  theta=new double [n];
  speedr=new double [n];
  thetaspeed=new double[n];
  speed=new Point[n];


  ptset=new Point[n][nb];

  for (i=0; i<n; i++)
  { 
    c[i]=new Point(W/3+W/3*Math.random(), H/3+H/3*Math.random(), i);
    a[i]=aniso*(0.5*minr+Math.random()*(maxr-minr));
    b[i]=0.5*minr+Math.random()*(maxr-minr);

    if (Math.random()<0.5) {
      a[i]=b[i];
    }

    theta[i]=Math.random()*2.0*Math.PI;

    speed[i]=new Point(Math.random(), Math.random());
    speedr[i]=Math.random();
    thetaspeed[i]=0.03*Math.random();

/*
    if (i==0) {
      a[0]=0.05*(maxr-minr);
      b[0]=3*(maxr-minr);
      speedr[i]=0.05;
    }
*/

    ptset[i]=addEllipse(c[i], a[i], b[i], theta[i], nb, i);
  }

  radius=0;
  circumcenter[0]=ptset[0][0].x;
  circumcenter[1]=ptset[0][0].y;
  iter=0;

  //OneBCIteration();
  BCIteration(nbiterations);
}

void setup()
{
  int i;
  size(512, 512);
  Initialize();
}


void keyPressed() {
  if (key=='.') { 
    n*=2;
    Initialize();
    redraw();
  }
  if (key==',') { 
    n/=2;
    Initialize();
    redraw();
  }


  if (key=='p') {
    exportPDF();
  }

  if (key=='a') {
    anim=!anim;
  }

  if (key=='i') {
    OneBCIteration();
  }

  if (key==' ') {
    Initialize();
  }

  if (key=='q') {
    exit();
  }
}

void exportPDF()
{
  beginRecord(PDF, "SEBEllipese"+millis()+".pdf"); 
  draw();
  endRecord();
}

// Dynamic maintenance
void animate()
{
  int i;

  for (i=0; i<n; i++)
  { 
    c[i]=new Point(c[i].x+speed[i].x, c[i].y+speed[i].y);
    a[i]=a[i]+aniso*(speedr[i]);
    b[i]=b[i]+speedr[i];

    theta[i]=theta[i]+thetaspeed[i];

    if (theta[i]>2.0*Math.PI) theta[i]-=2.0*Math.PI;

    if (a[i]>maxr) speedr[i]=-speedr[i];
    if (b[i]<minr) speedr[i]=-speedr[i];
    if (c[i].x>maxx) speed[i]=new Point(-speed[i].x, speed[i].y);
    if (c[i].y>maxy) speed[i]=new Point(speed[i].x, -speed[i].y);
    if (c[i].x<minx) speed[i]=new Point(-speed[i].x, speed[i].y);
    ;
    if (c[i].y<miny) speed[i]=new Point(speed[i].x, -speed[i].y);

    ptset[i]=addEllipse(c[i], a[i], b[i], theta[i], nb, i);
  }

  radius=0;
  iter=0;
  circumcenter[0]=ptset[0][0].x;
  circumcenter[1]=ptset[0][0].y;
  
  BCIteration(nbiterations);
//OneBCIteration();
   
}

void draw()
{
  int i, j;
  background(255);
  stroke(0);
  //fill(0);
  noFill();

boolean [] basis=new boolean[n];


 for(i=0;i<n;i++)
 for(j=0;j<nb;j++)
 {
 if (Math.abs(Distance(circumcenter,ptset[i][j])-radius)<1.e-3*radius)
basis[i]=true;
 }
 

  strokeWeight(1);
  for (i=0; i<n; i++)
  {
    if (basis[i])
    {strokeWeight(3);
    stroke(0,0,255);
    push();
    translate((float)c[i].x, (float)c[i].y);
    push();
    rotate((float)theta[i]);
    ellipse(0, 0, (float)(2.0*a[i]), (float)(2.0*b[i]));
    pop();
    pop();
    }
    else
    {strokeWeight(1);
    stroke(0,0,0);
          push();
    translate((float)c[i].x, (float)c[i].y);
    push();
    rotate((float)theta[i]);
    ellipse(0, 0, (float)(2.0*a[i]), (float)(2.0*b[i]));
    pop();
    pop();
    }

  }

  /*
 strokeWeight(1);
   stroke(0,255,0);
   for(i=0;i<n;i++)
   for(j=0;j<nb;j++)
   {ellipse((float)ptset[i][j].x,(float)ptset[i][j].y,(float)1,(float)1);}
   */

  noFill();
  strokeWeight(5);
  stroke(255, 0, 0);
  ellipse((float)circumcenter[0], (float)circumcenter[1], (float)(2.0*radius), (float)(2.0*radius));

  fill(255, 0, 0);
  ellipse((float)circumcenter[0], (float)circumcenter[1], 10.0, 10.0);


/*
stroke(0,0,255);
ellipse((float)ptset[winneri][winnerj].x, (float)ptset[winneri][winnerj].y, 10.0, 10.0);
*/


stroke(0,255,0);
 fill(0,255,0);
   strokeWeight(3);
   
    for(i=0;i<n;i++)
 for(j=0;j<nb;j++)
 {
 if (Math.abs(Distance(circumcenter,ptset[i][j])-radius)<1.e-3*radius)
 {ellipse((float)ptset[i][j].x, (float)ptset[i][j].y, 10.0, 10.0);
 break;}
 }

 
  if (anim) animate();
}
