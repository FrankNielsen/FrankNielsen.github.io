// Frank Nielsen, Frank.Nielsen.x@gmail.com
// December 2025
// Implements the log-extrinsic mean (purple) of SPD matrices and compare it with the affine-invariant Riemannian mean (AIRM, red) and the log-Euclidean mean (blue)
// Because in 2D AIRM and log-extrinsic mean are very closed, we dynamically display one of top in the other, with order of probability 1/2 so that the blinking indicate the closeness of these means

// Fast Equivariant K-Means on SPD Matrices Using Log-Extrinsic Means
// https://link.springer.com/chapter/10.1007/978-3-032-03924-8_27
// https://hal.science/hal-04642282/


/*
Keys:
' ' : draw a new 2D data set
't' : run at test in higher dimension
'x' : print the data set and means
'p' : Export in PDF
'r' : toggle display of AIRM mean
'l' : toggle display of log-Eucidean mean
'e' : toggle display of log-extrinsic mean
'q' : exit
*/

import processing.pdf.*;
import Jama.*;


int side=800;
double  minx=-0.3, maxx=-minx, miny=-0.3, maxy=-miny;

boolean toggleAIRM=true;
boolean toggleLogEuc=true;
boolean toggleLogExt=true;

BB bb=new BB(minx, maxx, miny, maxy, side, side);
int N=3;
//int N=5;
//int N=2;
int n=2;

Matrix [] X;
Matrix LogExtMean, LogEuclMean, AIRMean, AIRMean2;

void setup()
{
  size(800, 800);
  initSet();
}

int nbiter=10000;

void Test()
{
 Matrix LE,AIRM,AIRM2,LEM;
  int i;
  int d=5;
  Matrix [] XX;
  
  println("Test in dimension:"+d);

  XX=new Matrix[N];

  for (i=0; i<N; i++)
  {
    XX[i]=SPD.randomSPDCholesky(d);
  }

  LE=SPDMean.LogEuclideanMean(XX);
  AIRM=SPDMean.AIRMean(XX,1000);
  AIRM2=SPDMean.AIRecursiveMean(XX,1000);
  LEM=SPDMean.LogExtrinsicMean(XX);
  
  double diff=(AIRM.minus(AIRM2)).norm2();
  println("Difference AIRMean between two methods:"+diff);
  
  
  double diffAIRMLE=(AIRM.minus(LEM)).norm2();
  println("Difference AIRMean minus LogExt:"+diffAIRMLE);
 
  
}

void initSet()
{
  int i;

  X=new Matrix[N];

  for (i=0; i<N; i++)
  {
    X[i]=SPD.randomSPDCholesky(n);
  }

  LogEuclMean=SPDMean.LogEuclideanMean(X);
  AIRMean=SPDMean.AIRMean(X,nbiter);
  AIRMean2=SPDMean.AIRecursiveMean(X,nbiter);
  LogExtMean=SPDMean.LogExtrinsicMean(X);
  
  double diff=(AIRMean.minus(AIRMean2)).norm2();
  println("Difference AIRMean between two methods:"+diff);
  
  
  double diffAIRMLE=(AIRMean.minus(LogExtMean)).norm2();
  println("Difference AIRMean minus LogExt:"+diffAIRMLE);
}



float ptsize=3;



void draw()
{
  int i;
  background(255);

  stroke(0);
  fill(0);
  strokeWeight(1);
  ptsize=3;
  for (i=0; i<N; i++)
  {
    MyEllipse(X[i]);
  }


  strokeWeight(3);




 
if (toggleLogEuc){
  stroke(0, 0, 255);
  MyEllipse(LogEuclMean);
}

if (random(1.0)<0.5){
if (toggleAIRM){
  stroke(255, 0, 0);
  MyEllipse(AIRMean);
}

if (toggleLogExt){
  stroke(255, 0, 255);
  MyEllipse(LogExtMean);
}
}
else
{
 if (toggleLogExt){
  stroke(255, 0, 255);
  MyEllipse(LogExtMean);
} 
if (toggleAIRM){
  stroke(255, 0, 0);
  MyEllipse(AIRMean);
}
}

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



void MyDashedEllipse(Matrix Sigma)
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
    
    if (random(1.0)<0.5){
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
}



void exportPDF()
{
  beginRecord(PDF, "SPDMeans-"+millis()+".pdf");
  draw();
  endRecord();
}


void keyPressed()
{
  if (key==' ') {
    initSet();
    draw();
  }

if (key=='t') {
    Test();
    
  }
  
  
  if (key=='x')
  {println("Data set:");
  
  for(int i=0;i<n;i++)
  X[i].print(6,6);
  
  
    println("Affine-invariance Riemannian mean:");
   AIRMean.print(6,6); 
    println("Log-extrinsic mean:");
   LogExtMean.print(6,6); 
  }
  
  if (key=='p')
  {
    println("Export in PDF");
    exportPDF();
  }

 if (key=='r')
  {
toggleAIRM=!toggleAIRM; draw();}

 if (key=='l')
  {
toggleLogEuc=!toggleLogEuc; draw();}

 if (key=='e')
  {
toggleLogExt=!toggleLogExt; draw();}

 



  if (key=='q') exit();
}
