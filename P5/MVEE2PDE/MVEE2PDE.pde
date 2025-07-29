// Frank Nielsen, July 2025

import processing.pdf.*;
import Jama.*;


// we can compute minimax between two 1d normal distributions by 2d centered normal CO embedding + VPM transformation + Hilbert distance

int side=800;

//double  minx=-0.3, maxx=-minx, miny=-0.3, maxy=-miny;
double  minx=-1, maxx=-minx, miny=minx, maxy=-miny;

BB bb=new BB(minx, maxx, miny, maxy, side, side);
 
Matrix E1,E2, mvee, supE; // two ellipsoids and their MVEE

 
 void exportPDF()
{
  beginRecord(PDF, "MVEE2-"+millis()+".pdf");
  draw();
  endRecord();
}


void initSet()
{
  
 E1=SPD.randomSPDCholesky(2);
 E2=SPD.randomSPDCholesky(2);
 
 supE=SPD.Max(E1,E2);
 mvee=SPD.MVEE(E1,E2);
}

void setup()
{
  size(800, 800);
  initSet();
}

float ptsize;

void draw()
{
  int i;
  background(255);

  stroke(0);
  fill(0);
  strokeWeight(1);
  ptsize=3;
  
 
    MyEllipse(E1);MyPoint(0,0);
    MyEllipse(E2);MyPoint(0,0);
    
    
     stroke(0, 255, 0);
   MyEllipse(supE);
   
  strokeWeight(3);
  stroke(255, 0, 0);
 MyEllipse(mvee);
  stroke(0);
  strokeWeight(1);
}



void MyPoint(double x, double y)
{
  ellipse((float)bb.x2X(x), (float)bb.y2Y(y), ptsize, ptsize);
}

void MyLine(double x1, double y1, double x2, double y2)
{

  line((float)bb.x2X(x1), (float)bb.y2Y(y1), (float)bb.x2X(x2), (float)bb.y2Y(y2)) ;
}


void MyLine(Matrix v1, Matrix v2)
{

  line((float)bb.x2X(v1.get(0, 0)), (float)bb.y2Y(v1.get(1, 0)),
    (float)bb.x2X(v2.get(0, 0)), (float)bb.y2Y(v2.get(1, 0))) ;
}

void MyEllipse(Matrix Sigma)
{
  int nbpoints=1000, i;
  double x1, y1, theta1;
  double x2, y2, theta2;
  Matrix v1, v2;
  v1=new Matrix(2, 1);
  v2=new Matrix(2, 1);

  CholeskyDecomposition CD=new CholeskyDecomposition(Sigma);
  Matrix M=CD.getL().transpose();



  double scale=0.2;

  for (i=0; i<nbpoints; i++)
  {
    theta1=Math.PI*2.0*i/(double)nbpoints;
    theta2=Math.PI*2.0*(i+1)/(double)nbpoints;
    x1=scale*Math.cos(theta1);
    y1=scale*Math.sin(theta1);
    x2=scale*Math.cos(theta2);
    y2=scale*Math.sin(theta2);
    v1.set(0, 0, x1);
    v1.set(1, 0, y1);
    v2.set(0, 0, x2);
    v2.set(1, 0, y2);
    v1=M.times(v1);
    v2=M.times(v2);
    x1=v1.get(0, 0);
    y1=v1.get(1, 0);
    x2=v2.get(0, 0);
    y2=v2.get(1, 0);
    MyLine(x1, y1, x2, y2);
  }
}

void keyPressed()
{
  if (key==' ') {
    initSet();
    draw();
  }

  if (key=='p')
  {
    println("Export in PDF");
    exportPDF();
  }
  
   if (key=='q') {
    exit();
  }
  
}
