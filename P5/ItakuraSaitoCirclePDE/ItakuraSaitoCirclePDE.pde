/*
Frank.Nielsen@acm.org 
April 2021
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
double maxxTheta=5;
double minyTheta=minxTheta;
double maxyTheta=maxxTheta;

BB bbTheta;
double xx=0, yy=0, rr=0;

float u=0;
float du=0.01;


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
  beginRecord(PDF, "ISCircle-"+suffix+".pdf");
  drawPDF();
  save("ISCircle-"+suffix+".png");
  endRecord();
}

void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
  beginRecord(PDF, "ISCircle-"+suffix+".pdf");
  draw();
  save("ISCircle-"+suffix+".png");
  endRecord();
}

void draw()
{drawPDF();}

void drawAnimation()
{
String str="Itakura-Saito circle for ("+nf((float)xx, 1, 3)+","+nf((float)yy, 1, 3)+") radius="+nf((float)rr, 1, 3);
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

  drawIS(xx, yy, rr); 

  if (animation) {
    //InitializeCircle();
    //delay(1000);
    
    double x1,y1,x2,y2;
double u1=u; double u2=rr-u1;
    // positive orthant: ok
    x1=-xx/W0(-Math.exp(-u1-1));
    y1=-yy/W0(-Math.exp(-u2-1));

  
    // negative orthant: ok
     x2=-xx/WNeg1(-Math.exp(-u1-1));
    y2=-yy/WNeg1(-Math.exp(-u2-1));
    
 

    //red 
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




void drawPDF()
{
background(255);
strokefill(200,200,200);  
 
String str="Itakura-Saito circle for center ("+nf((float)xx, 1, 3)+","+nf((float)yy, 1, 3)+") radius="+nf((float)rr, 1, 3);
  background(255);
strokefill(150,150,150);
textSize(8);
text(str,10,512-10);
  
  line((float)bbTheta.x2X(xx), (float)bbTheta.x2X(minyTheta), (float)bbTheta.x2X(xx), 
    (float)bbTheta.x2X(maxyTheta));
  line((float)bbTheta.x2X(minxTheta), (float)bbTheta.y2Y(yy), (float)bbTheta.x2X(maxxTheta), 
    (float)bbTheta.y2Y(yy));


  ellipse((float)bbTheta.x2X(xx), (float)bbTheta.y2Y(yy), ptsize, ptsize);
  
  strokefill(0, 0, 0);
drawISPDF(xx, yy, rr); 

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


void drawIS(double cx, double cy, double r)
{
  int nbsteps=1000;
  double u, du=r/(double)nbsteps;
  double xr1, yr1, xr2, yr2;
  double a, b;
  double u1,u2;

  strokefill(0, 255, 0);

  for (u=0; u<=r; u+=du)
  {

    u1=u;
    u2=r-u;

    // positive orthant: ok
    xr1=-cx/W0(-Math.exp(-u1-1));
    yr1=-cy/W0(-Math.exp(-u2-1));

  
    // negative orthant: ok
     xr2=-cx/WNeg1(-Math.exp(-u1-1));
    yr2=-cy/WNeg1(-Math.exp(-u2-1));
    
 

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



void drawISPDF(double cx, double cy, double r)
{
  int nbsteps=1000;
  double u, du=r/(double)nbsteps;
  double xr1, yr1, xr2, yr2;
  double nxr1, nyr1, nxr2, nyr2;
  double a, b;
  double u1,u2,nu1,nu2;

  strokefill(0, 0, 0);
  strokeWeight(1);

  for (u=0; u<=r; u+=du)
  {

    u1=u;
    u2=r-u;

    // positive orthant: ok
    xr1=-cx/W0(-Math.exp(-u1-1));
    yr1=-cy/W0(-Math.exp(-u2-1));

  
    // negative orthant: ok
     xr2=-cx/WNeg1(-Math.exp(-u1-1));
    yr2=-cy/WNeg1(-Math.exp(-u2-1));
    
  
    nu1=u+du;
    nu2=r-nu1;

    // positive orthant: ok
    nxr1=-cx/W0(-Math.exp(-nu1-1));
    nyr1=-cy/W0(-Math.exp(-nu2-1));

  
    // negative orthant: ok
     nxr2=-cx/WNeg1(-Math.exp(-nu1-1));
    nyr2=-cy/WNeg1(-Math.exp(-nu2-1));
    
    line((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr1), (float)bbTheta.x2X(nxr1), (float)bbTheta.y2Y(nyr1));

  line((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr1), (float)bbTheta.x2X(nxr2), (float)bbTheta.y2Y(nyr1));
   
 line((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr2), (float)bbTheta.x2X(nxr2), (float)bbTheta.y2Y(nyr2));
    line((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr2), (float)bbTheta.x2X(nxr1), (float)bbTheta.y2Y(nyr2));
/*
   

 */
 }
  
  /*
  u=r-du;   u1=u;
    u2=r-u;
    
  xr1=-cx/W0(-Math.exp(-u1-1));
    yr1=-cy/W0(-Math.exp(-u2-1));

  
    // negative orthant: ok
     xr2=-cx/WNeg1(-Math.exp(-u1-1));
    yr2=-cy/WNeg1(-Math.exp(-u2-1));
   

  line((float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr1),(float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr2));

    line((float)bbTheta.x2X(xr2), (float)bbTheta.y2Y(yr1), 
    (float)bbTheta.x2X(xr1), (float)bbTheta.y2Y(yr2));
*/

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

if (key=='p') {SavePDF();}

  if (key==' ') {
    Initialize(); 
    first=true;
    draw();
  }

  if (key=='a') {
    {animation=!animation;u=0;}
  }
  if (key=='x') savepdffile();
}
