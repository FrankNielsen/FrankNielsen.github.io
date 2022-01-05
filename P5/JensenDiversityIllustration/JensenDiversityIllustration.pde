// Visualizing Jensen diversity
// January 2022
// Frank.Nielsen@acm.org

import processing.pdf.*;

boolean toggleU=true, toggleL=true;
boolean toggleAnim=false;
//boolean toggleGrid=true;
boolean toggleGrid=false;
boolean toggleText=true;

boolean toggleDynamic=true;

float minx=-1, maxx=3;
float plotminx=0.005, plotmaxx=maxx;
float miny=-1.2, maxy=0.5;
float WW=800;
float stepx=(maxx-minx)/WW;
float stepy=(maxy-miny)/WW;
float PTSIZE=5;
float FONTSIZE=25;


int n=2;

float [] theta, Ftheta, thetaspeed;
float thetabar, Fthetabar;




// alpha symbol is here  α  you can visualize it or not depending on the font
String divname="Extended Shannon information";

float F(float x)
{
  return (float)(x*Math.log(x)-x);
}

float xp, xq, yp, yq;
float alpha, beta, gamma, lambda, dd=1.0/(float)20.0;
float xpqalpha, xpqbeta, xpqgamma;
float ypqalpha, ypqbeta, ypqgamma;

float Ux, Uy, Lx, Ly;
float CDG, JUpper, JLower;


void computeGamma()
{
  gamma=lambda*(beta-alpha)+alpha;
  Update();
}

void initJensenDiv()
{
  theta=new float[n];
  thetaspeed=new float[n];
  Ftheta=new float[n];

  thetabar=0; 
  Fthetabar=0;

  for (int i=0; i<n; i++) 
  {
    theta[i]=(float)(Math.random()*maxx);
    thetaspeed[i]=0.001*(float)(Math.random()*maxx);
  }

  theta = sort(theta);

  for (int i=0; i<n; i++) {
    Ftheta[i]=F(theta[i]);
    thetabar+=theta[i];
    Fthetabar+=Ftheta[i];
  }

  thetabar/=(float)n;
  Fthetabar/=(float)n;
}

float threshold=0.05;

void updateJensenDiv()
{

  thetabar=0; 
  Fthetabar=0;

  for (int i=0; i<n; i++) {
    theta[i]+=thetaspeed[i];
    if ((theta[i]>maxx-threshold)||(theta[i]<threshold)) thetaspeed[i]=-thetaspeed[i];
  }

  theta = sort(theta);

  for (int i=0; i<n; i++) {
    Ftheta[i]=F(theta[i]);
    thetabar+=theta[i];
    Fthetabar+=Ftheta[i];
  }

  thetabar/=(float)n;
  Fthetabar/=(float)n;
}

void init()
{
  xp=plotminx+(plotmaxx-plotminx)*random(1);
  xq=plotminx+(plotmaxx-plotminx)*random(1);
  //if (xp>xq) init();
  alpha=random(1);
  beta=random(1);
  lambda=random(1);
  gamma=lambda*(beta-alpha)+alpha;

  initJensenDiv();

  Update();
}

void Update() {

  yp=F(xp);
  yq=F(xq);
  Ux=(1-gamma)*xp+gamma*xq;
  Uy=(1-gamma)*F(xp)+gamma*F(xq);

  xpqalpha=(1-alpha)*xp+alpha*xq;
  ypqalpha=F(xpqalpha);

  xpqbeta=(1-beta)*xp+beta*xq;
  ypqbeta=F(xpqbeta);

  xpqgamma=(1-gamma)*xp+gamma*xq;
  ypqgamma=F(xpqgamma);

  Lx=Ux;
  Ly=(1-lambda)*F(xpqalpha)+lambda*F(xpqbeta);

  CDG=Uy-Ly;
  JUpper=Uy-ypqgamma;
  JLower=Ly-ypqgamma;
}

void setup() 
{
  size(800, 800);
  init();
}


void Point(float x, float y)
{
  float ptsize=0.00003;
  float delta=5;
  //point((float)xtoX(x)-delta, (float)ytoY(y));
  line((float)xtoX(x)-delta, (float)ytoY(y), (float)xtoX(x)+delta, (float)ytoY(y));
  line((float)xtoX(x), (float)ytoY(y)-delta, (float)xtoX(x), (float)ytoY(y)+delta);
  //ellipse(((float)xtoX(x))-ptsize, ((float)ytoY(y))-ptsize,((float)xtoX(x))+ptsize, ((float)ytoY(y))+ptsize);
}


void Line(float x1, float y1, float x2, float y2)
{
  line((float)xtoX(x1), (float)ytoY(y1), (float)xtoX(x2), (float)ytoY(y2));
  //println(ytoY(y1));
}

void strokefill(int r, int g, int b)
{
  stroke(r, g, b); 
  fill(r, g, b);
}


void Ellipse(float x, float y, float xx, float yy)
{
  ellipse(xtoX(x), ytoY(y), xx, yy);
}

// Draw chord gap divergence
void drawGapDivergence()
{
  strokefill(0, 0, 0); 
  strokeWeight(1);
  Ellipse(xp, yp, PTSIZE, PTSIZE);
  Ellipse(xq, yq, PTSIZE, PTSIZE);
  Line(xp, yp, xq, yq);

  Ellipse(xpqalpha, ypqalpha, PTSIZE, PTSIZE);
  Ellipse(xpqbeta, ypqbeta, PTSIZE, PTSIZE);
  Line(xpqalpha, ypqalpha, xpqbeta, ypqbeta);

  if (toggleU) {
    strokeWeight(10);
    strokefill(0, 255, 0);  
    Line(Ux, Uy, xpqgamma, ypqgamma);
  }

  if (toggleL) {
    strokeWeight(3);
    strokefill(0, 0, 255);  
    Line(Lx, Ly, xpqgamma, ypqgamma);
  }

  strokeWeight(5);
  strokefill(255, 0, 0);  
  Line(Ux, Uy, Lx, Ly);

  strokefill(0, 0, 0);

  Ellipse(Ux, Uy, PTSIZE, PTSIZE);
  Ellipse(Lx, Ly, PTSIZE, PTSIZE);

  if (toggleText) printDivergence();
}


void addSignature()
{
  textSize(1);
  //stroke(128, 128, 128);
  //fill(0, 0, 0);
  strokefill(254, 254, 254);
  text("(C) 2018 Frank Nielsen. All rights reserved.", 2, WW-2);
}

void printDivergence()
{
  int rl=2; // return line
  textSize(FONTSIZE-2);
  strokefill(5, 5, 5);
  text(divname, 2, FONTSIZE);
  text("p="+xp+" q="+xq, 2, rl++*FONTSIZE);
  text("alpha="+alpha, 2, rl++*FONTSIZE);
  text("beta="+beta, 2, rl++*FONTSIZE);
  text("gamma="+gamma, 2, rl++*FONTSIZE);
  text("lambda="+lambda, 2, rl++*FONTSIZE);
  text("Chord Gap Divergence="+CDG, 2, rl++*FONTSIZE);
  text("Jensen Upper="+JUpper, 2, rl++*FONTSIZE);
  text("Jensen Lower="+JLower, 2, rl++*FONTSIZE);
}

void drawAxis()
{
  strokeWeight(5);
  stroke(128);
  fill(128);
  Line(minx, 0, maxx, 0);
  Line(0, miny, 0, maxy);

  strokeWeight(1);
}



void drawGrid()
{
  strokeWeight(1);
  strokefill(50, 50, 50);

  for (float xx=minx; xx<=maxx; xx+=30*stepx)
  {
    Line(xx, miny, xx, maxy);
  }

  for (float yy=miny; yy<=maxy; yy+=30*stepy)
  {
    Line(minx, yy, maxx, yy);
  }

  strokeWeight(1);
}


void drawJensenDiversity()
{
  int i;
  float x1, y1, x2, y2; 

  stroke(255, 0, 0);
  strokeWeight(3);

  for (i=0; i<n-1; i++)
  {
    x1=theta[i];
    y1=Ftheta[i];
    x2=theta[i+1];
    y2=Ftheta[i+1];

    Line(x1, y1, x2, y2);
  }
  // closing the convex hull
  x1=theta[n-1];
  y1=Ftheta[n-1];
  x2=theta[0];
  y2=Ftheta[0];
  Line(x1, y1, x2, y2);

  for (i=0; i<n; i++) Point(theta[i], Ftheta[i]);

  strokeWeight(3);

  x1=thetabar;
  y1=Fthetabar;
  x2=thetabar;
  y2=F(x2);

  stroke(0, 255, 0);
  Line(x1, y1, x2, y2);

  stroke(0, 0, 255);
  Point(x1, y1);
  Point(x2, y2);

  if (toggleDynamic) updateJensenDiv();
}


//
// Main drawing procedure
//
void draw()
{
  float x1, y1, x2, y2; 
  background(255);
  stroke(0);
  fill(0);

  if (toggleGrid)  drawGrid();

  drawAxis();

  stroke(0);
  strokeWeight(2.0);

  // Draw function plot
  for (float x=plotminx; x<=plotmaxx; x+=stepx)
  {
    x1=x;
    y1=F(x1);
    x2=x+stepx;
    y2=F(x2);
    Line(x1, y1, x2, y2);
  }

  strokeWeight(1.0);

  drawJensenDiversity();

  //drawGapDivergence();

  /*
if (toggleAnim) {lambda=min(1,lambda+dd);
   computeGamma();
   String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
   save("anim."+suffix+".png");
   
   if (lambda==1) toggleAnim=false;
   draw();
   }
   */
}



void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
  beginRecord(PDF, "JensenDiversity-"+suffix+".pdf");
  addSignature();
  background(255);
  draw();

  if (toggleAnim) save("anim."+suffix+".png"); 
  else save("CGD."+suffix+".png");
  endRecord();
}


void saveAnimation()
{
  float l;
  String suffix;
  int fframe=0;

  // increasing
  for (l=0; l<=1; l+=0.1)
  {
    suffix=nf(fframe, 2)+"-"; 
    lambda=l; 
    computeGamma();
    draw();
    save("anim."+suffix+".png");
    fframe++;
  }

  // and then decreasing
  for (l=1; l>=1; l-=0.1)
  {
    suffix=nf(fframe, 2)+"-"; 
    lambda=l; 
    computeGamma();
    draw();
    save("anim."+suffix+".png");
    fframe++;
  }
}


void keyPressed()
{ 
  if (key=='d') {
    toggleDynamic=!toggleDynamic;
  }

  if (key=='+') {
    n++;
    init();
  }
  if (key=='-') {
    n--; 
    if (n<2) n=2; 
    init();
  }


  if (key=='g') toggleGrid=!toggleGrid;
  if (key=='t') toggleText=!toggleText;
  if (key=='a') saveAnimation();

  // toggleAnim=!toggleAnim;

  if (key=='j') {
    alpha=beta=0.5;
    computeGamma();
  }

  if ((key=='U') || (key=='u')) toggleU=!toggleU;
  if ((key=='L') || (key=='l'))  toggleL=!toggleL;

  if (key==' ') init();

  if (key=='s') {
    println("Saving PDF...");
    savepdffile();
  }


  if (key=='g') {
    xp=0.5; 
    xq=0.2; 
    alpha=0.4; 
    beta=0.8; 
    lambda=0.2;
    computeGamma();
  }


  if (key=='q') exit();

  if (key == CODED) {
    if (keyCode==LEFT) {
      alpha=max(0, alpha-dd);
      computeGamma();
    }

    if (keyCode==RIGHT) {
      beta=min(1, beta+dd);
      computeGamma();
    }

    if (keyCode==DOWN) {
      lambda=min(1, lambda+dd);
      computeGamma();
    }

    if (keyCode==UP) {
      lambda=max(0, lambda-dd);
      computeGamma();
    }
  }

  //draw();
}

public  float Xtox(int x)
{
  return minx+(maxx-minx)/(float)width;
}

public  float Ytoy(int y)
{
  return miny+(maxy-miny)/(float)height;
}


public  int xtoX(float X)
{
  return (int)(width*((X-minx)/(maxx-minx)))  ;
}

public  int ytoY(float Y)
{
  return (int)(height*((maxy-Y)/(maxy-miny)));
}
