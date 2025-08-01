/*
Frank.Nielsen@acm.org
 July 2025
 https://franknielsen.github.io/BregmanSphere/
 
 On geodesic triangles with right angles in a dually flat space
 arXiv:1910.03935
 
 Press 'p' to export in PDF/PNG and space bar for a new random IS sphere
 */

import processing.pdf.*;


float ptsize=3;
boolean first=true;
boolean animation=true;
int side = 512;
double minxTheta=0.01;
double maxxTheta=3;
double minyTheta=minxTheta;
double maxyTheta=maxxTheta;

BB bbTheta;
double xx=0, yy=0, rr=0;

float u=0;
float du=0.01;


double Hellinger(double p, double q)
{
  return 4*(0.5*p+0.5*q-Math.sqrt(p*q));
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

void SavePDF()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  beginRecord(PDF, "HellingerCircle-"+suffix+".pdf");
  
  drawPDF();
  
  save("HellingerCircle-"+suffix+".png");
  
  endRecord();
}

void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  beginRecord(PDF, "HellingerCircle-"+suffix+".pdf");
  draw();
  save("HellingerCircle-"+suffix+".png");
  endRecord();
}

void draw()
{
  drawPDF();
}

void drawAnimation()
{
  String str="Hellinger circle for ("+nf((float)xx, 1, 3)+","+nf((float)yy, 1, 3)+") radius="+nf((float)rr, 1, 3);
  background(255);
  strokefill(0, 0, 0);
  textSize(16);
  text(str, 10, 20);

  double ratio=100*u/rr;
  str=nf((float)ratio, 2, 2)+"%";
  text(str, 10, 35);

  strokefill(0, 0, 0);
  line((float)bbTheta.x2X(xx), (float)bbTheta.x2X(minyTheta), (float)bbTheta.x2X(xx),
    (float)bbTheta.x2X(maxyTheta));
  line((float)bbTheta.x2X(minxTheta), (float)bbTheta.y2Y(yy), (float)bbTheta.x2X(maxxTheta),
    (float)bbTheta.y2Y(yy));


  ellipse((float)bbTheta.x2X(xx), (float)bbTheta.y2Y(yy), ptsize, ptsize);

  drawHellinger(xx, yy, rr);
}




void drawPDF()
{
  background(255);
  strokefill(200, 200, 200);

  String str="Hellinger circle for center ("+nf((float)xx, 1, 3)+","+nf((float)yy, 1, 3)+") radius="+nf((float)rr, 1, 3);
  background(255);
  strokefill(150, 150, 150);
  textSize(8);
  text(str, 10, 512-10);

  line((float)bbTheta.x2X(xx), (float)bbTheta.x2X(minyTheta), (float)bbTheta.x2X(xx),
    (float)bbTheta.x2X(maxyTheta));
  line((float)bbTheta.x2X(minxTheta), (float)bbTheta.y2Y(yy), (float)bbTheta.x2X(maxxTheta),
    (float)bbTheta.y2Y(yy));


  ellipse((float)bbTheta.x2X(xx), (float)bbTheta.y2Y(yy), ptsize, ptsize);

  strokefill(0, 0, 0);
  drawHellingerPDF(xx, yy, rr);
}



void setup()
{
  size(512, 512);
  Initialize();
  
  
  double c=0.2, r=0.1+0.1*Math.random();
  double x1=sqr(Math.sqrt(c)-Math.sqrt(0.5*r));
  double x2=sqr(Math.sqrt(c)+Math.sqrt(0.5*r));
 println(x1+" "+x2);
   println("r="+r+"\t "+Hellinger(c,x1)+" "+Hellinger(c,x2));
}


void strokefill(int r, int g, int b)
{
  stroke(r, g, b);
  fill(r, g, b);
}

double sqr(double x) {
  return x*x;
}

void drawHellinger(double cx, double cy, double r)
{
  int nbsteps=1000;
  double u, du=r/(double)nbsteps;
  double xr1, yr1, xr2, yr2;
  double a, b;
  double u1, u2;

  strokefill(0, 255, 0);

  for (u=0; u<=r; u+=du)
  {

    u1=u;
    u2=r-u;



    xr1=sqr(Math.sqrt(cx)-Math.sqrt(0.5*u1));
    yr1 =sqr(Math.sqrt(cy)+Math.sqrt(0.5*u1));

    xr2=sqr(Math.sqrt(cx)-Math.sqrt(0.5*u2));
    yr2 =sqr(Math.sqrt(cy)+Math.sqrt(0.5*u2));

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

// main drawing

void drawHellingerPDF(double cx, double cy, double r)
{
  int nbsteps=100;
  double u, du=r/(double)nbsteps;
  double xr1, yr1, xr2, yr2;
  double nxr1, nyr1, nxr2, nyr2;
  double a, b;
  double u1, u2, nu1, nu2;
  
 // println("Draw Hellinger PDF");
 
 r=0.3;
cx=0.5;
cy=0.7;

  strokefill(0, 0, 0);
  strokeWeight(1);

  for (u=0; u<=r; u+=du)
  {

    u1=u;
    u2=r-u;

    xr1 = sqr(Math.sqrt(cx)-Math.sqrt(0.5*u1));
    xr2 = sqr(Math.sqrt(cx)+Math.sqrt(0.5*u1));

    yr1 = sqr(Math.sqrt(cy)-Math.sqrt(0.5*u2));
    yr2 = sqr(Math.sqrt(cy)+Math.sqrt(0.5*u2));

// draw line segment
    nu1=u+du;
    nu2=r-nu1;

    nxr1=sqr(Math.sqrt(cx)-Math.sqrt(0.5*nu1));
    nxr2 =sqr(Math.sqrt(cx)+Math.sqrt(0.5*nu1));

    nyr1=sqr(Math.sqrt(cy)-Math.sqrt(0.5*nu2));
    nyr2 =sqr(Math.sqrt(cy)+Math.sqrt(0.5*nu2));


    line((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr1), (float)bbTheta.x2X(nxr1), (float)bbTheta.y2Y(nyr1));

    line((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr1), (float)bbTheta.x2X(nxr2), (float)bbTheta.y2Y(nyr1));

    line((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr2), (float)bbTheta.x2X(nxr2), (float)bbTheta.y2Y(nyr2));

    line((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr2), (float)bbTheta.x2X(nxr1), (float)bbTheta.y2Y(nyr2));
  
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

  if (key=='p') {
    SavePDF();
  }

  if (key==' ') {
    Initialize();
    first=true;
    draw();
  }

  if (key=='a') {
    {
      animation=!animation;
      u=0;
    }
  }
  if (key=='x') savepdffile();
}
