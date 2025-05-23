/*
Frank.Nielsen@acm.org 
2nd May 2025

On geodesic triangles with right angles in a dually flat space
arXiv:1910.03935

Solve Ax-Bx^A=C
for C=u((1-alpha^2)/4)- (1-\alpha)/2c
A=(1+\alpha)/2

Newton-Raphson

Get exact chi^2 ball

*/

import processing.pdf.*;
 

float ptsize=3;
boolean first=true;
boolean animation=true;
int side = 512;
double minxTheta=0.01;
double maxxTheta=3.5;
double minyTheta=minxTheta;
double maxyTheta=maxxTheta;

BB bbTheta;
double xx=0, yy=0, rr=0;

float u=0;
float du=0.01;


double ExtAlphaDivergence(double a, double p, double q)
{
  return (4.0/(1.0-a*a))*( ((1-a)/2.0) *p + ((1+a)/2.0)*q - Math.pow(p,((1-a)/2.0))*Math.pow(q,((1+a)/2.0)) );
}

void InitializeCircle()
{ 
  xx=3*Math.random()*0.5;
  yy=3*Math.random()*0.5; 
  rr=Math.random();
}
void Initialize()
{

  minyTheta=minxTheta;
  maxyTheta=maxxTheta;

  bbTheta=new BB(minxTheta, maxxTheta, minyTheta, maxyTheta, side, side);

  InitializeCircle();
  first=true;
}

void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
  beginRecord(PDF, "eKLCircle-"+suffix+".pdf");
  draw();
  save("eKLCircle-"+suffix+".png");
  endRecord();
}

void draw()
{
String str="eKL circle for ("+nf((float)xx, 1, 3)+","+nf((float)yy, 1, 3)+") radius="+nf((float)rr, 1, 3);
  background(255);
strokefill(0,0,0);
textSize(16);
text(str,10,20);

double ratio=100*u/rr;
str=nf((float)ratio, 2, 2)+"%";
text(str,10,35);

  strokefill(0, 0, 0);
  line((float)bbTheta.x2X(xx), (float)bbTheta.x2X(minyTheta), (float)bbTheta.x2X(xx), 
    (float)bbTheta.x2X(maxyTheta));
  line((float)bbTheta.x2X(minxTheta), (float)bbTheta.y2Y(yy), (float)bbTheta.x2X(maxxTheta), 
    (float)bbTheta.y2Y(yy));


  ellipse((float)bbTheta.x2X(xx), (float)bbTheta.y2Y(yy), ptsize, ptsize);

  drawEKL(xx, yy, rr); 

  if (animation) {
    //InitializeCircle();
    //delay(1000);
    
    double x1,y1,x2,y2;
    x1=-xx*W0(-Math.exp(-u/xx-1));
    y1=-yy*W0(-Math.exp(-(rr-u)/yy-1));

    x2=-xx*WNeg1(-Math.exp(-u/xx-1));
    y2=-yy*WNeg1(-Math.exp(-(rr-u)/yy-1));
    
     strokefill(255, 0, 0);
    ellipse((float)bbTheta.x2X(x1), (float)bbTheta.y2Y(y1), 3*ptsize, 3*ptsize);
    
    // green  
    strokefill(0, 255, 0);
    ellipse((float)bbTheta.x2X(x2), (float)bbTheta.y2Y(y2), 3*ptsize, 3*ptsize);

    //blue
    strokefill(0, 0, 255);
    ellipse((float)bbTheta.x2X(x2), (float)bbTheta.y2Y(y1), 3*ptsize, 3*ptsize);

    // magenta
    strokefill(0, 255, 255);
    ellipse((float)bbTheta.x2X(x1), (float)bbTheta.y2Y(y2), 3*ptsize, 3*ptsize);
    
    if (u>rr) du=-du;
    if (u<0) du=-du;
    u+=du;
  }
}


void setup()
{
  size(512, 512);
  Initialize();
}


void strokefill(int r, int g, int b)
{
  stroke(r, g, b); 
  fill(r, g, b);
}


void drawEKL(double cx, double cy, double r)
{
  int nbsteps=1000;
  double u, du=r/(double)nbsteps;
  double xr1, yr1, xr2, yr2;
  double a, b;

  strokefill(0, 255, 0);

  for (u=0; u<=r; u+=du)
  {

    xr1=-cx*W0(-Math.exp(-u/cx-1));
    yr1=-cy*W0(-Math.exp(-(r-u)/cy-1));

    xr2=-cx*WNeg1(-Math.exp(-u/cx-1));
    yr2=-cy*WNeg1(-Math.exp(-(r-u)/cy-1));

    //red 
    strokefill(255, 0, 0);
    ellipse((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr1), ptsize, ptsize);

    // green  
    strokefill(0, 255, 0);
    ellipse((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr2), ptsize, ptsize);

    //blue
    strokefill(0, 0, 255);
    ellipse((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr1), ptsize, ptsize);

    // magenta
    strokefill(0, 255, 255);
    ellipse((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr2), ptsize, ptsize);
  }
}

// Lambert W principal branch
double W0(double x)
{
  return LambertW.branch0(x);
}

double WNeg1(double x)
{
  return LambertW.branchNeg1(x);
}


void keyPressed()
{
  if (key=='q') exit();


  if (key==' ') {
    Initialize(); 
    first=true;
    draw();
  }

  if (key=='a') {
    animation=!animation;
  }
  if (key=='p') savepdffile();
}
