// Frank.Nielsen@acm.org
// last revised July 2023, include Hilbert distance

// Remarks on geodesics for multivariate normal models
// Black-box optimization using geodesics in statistical manifolds
// faster than eigendecomposition


// geodesic with initial value condition v:
// $N(t)=\exp_N(tv)$ Riemannian exponential
// Eriksen showed show compute \exp_N from a matrix exponential of size $(2d+1)\times (2d+1)$, power series or eigendecomposition
// Calvo & Oller gave direct solution to the  geodesics/Riemannian exponential

import processing.pdf.*;

import Jama.*;
//import Jama.EivenvalueDecomposition;

int side=800;
//double  minx=-2.3, maxx=2.3, miny=-2.3, maxy=2.3;

// good double  minx=-0.3, maxx=1.5, miny=-0.3, maxy=1.5;

double  minx=-0.3, maxx=1.2, miny=-0.3, maxy=1.2;

BB bb=new BB(minx, maxx, miny, maxy, side, side);
vM N1, N2;
float ptsize=3;

Matrix m1, S1, m2, S2;

vM IV; // initial values;
vM Nstd;
Matrix eigv1, eigv2;

boolean toggleAuto=false;
//boolean toggleAuto=true;

boolean toggleKobayashi=true;
//boolean toggleIVP=true;
boolean toggleIVP=true;//false;

double sqr(double x) {
  return x*x;
}


void MyPoint(Matrix v)
{
  ellipse((float)bb.x2X(v.get(0,0)), (float)bb.y2Y(v.get(1,0)), ptsize, ptsize);
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

  line((float)bb.x2X(v1.get(0,0)), (float)bb.y2Y(v1.get(1,0)), 
  (float)bb.x2X(v2.get(0,0)), (float)bb.y2Y(v2.get(1,0))) ;
}

void MyEllipse(vM N)
{MyEllipse(N.v,N.M);}

void MyEllipse(Matrix m, Matrix Sigma)
{
  int nbpoints=1000, i;
  double x1, y1, theta1;
  double x2, y2, theta2;
  Matrix v1, v2;
  v1=new Matrix(2, 1);
  v2=new Matrix(2, 1);

  CholeskyDecomposition CD=new CholeskyDecomposition(Sigma);
  Matrix M=CD.getL().transpose();

//Matrix M=Sigma;

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
    x1=m.get(0, 0)+v1.get(0, 0);
    y1=m.get(1, 0)+v1.get(1, 0);
    x2=m.get(0, 0)+v2.get(0, 0);
    y2=m.get(1, 0)+v2.get(1, 0);
    MyLine(x1, y1, x2, y2);
  }
}

Matrix gv, gM;

void init()
{
  initEriksenIVC();
//initIVC();
//initBVC();
}
//
// test initial values conditions
//
void initIVC()
{
  /*
  m1=EmbedMVNSPD.randomMu(2);
  S1=EmbedMVNSPD.randomSPDCholesky(2);

  m2=EmbedMVNSPD.randomMu(2);
  S2=EmbedMVNSPD.randomSPDCholesky(2);
*/

/*
// standard bivariate normal
m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=Matrix.identity(2,2);
m2=new Matrix(2,1);m2.set(0,0,5);m2.set(1,0,0);
S2=new Matrix(2,2);
S2.set(0,0,1);S2.set(1,1,2);S2.set(0,1,-1);S2.set(1,0,-1);
*/

// Example from Han Park 2013

m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=new Matrix(2,2);
S1.set(0,0,1.0);S1.set(0,1,0);
S1.set(1,0,0);S1.set(1,1,0.1);

m2=new Matrix(2,1);m2.set(0,0,1);m2.set(1,0,1);
//m2=new Matrix(2,1);m2.set(0,0,0);m2.set(1,0,0);
S2=new Matrix(2,2);
S2.set(0,0,0.1);S2.set(0,1,0);
S2.set(1,0,0);S2.set(1,1,1);




/*
m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=new Matrix(2,2);
S1.set(0,0,1.0);S1.set(0,1,0);
S1.set(1,0,0);S1.set(1,1,1.0);

m2=new Matrix(2,1);m2.set(0,0,10000.0);m2.set(1,0,0.0);
S2=new Matrix(2,2);
S2.set(0,0,10.0);S2.set(0,1,0);
S2.set(1,0,0);S2.set(1,1,10.0);
*/

m1.print(6,6);S1.print(6,6);
m2.print(6,6);S2.print(6,6);


  N1=new vM(m1, S1);
  N2=new vM(m2, S2);
  
//  EmbedMVNSPD.DistanceCO(N1,N2);
  
 // EmbedMVNSPD.Distances(N1,N2);
  
  
  
  //Matrix ivv=EmbedMVNSPD.randomMu(2);
  //Matrix ivM=EmbedMVNSPD.randomSymmetricMatrix(2);
  
  Matrix ivv=EmbedMVNSPD.randomMu(2).minus(EmbedMVNSPD.randomMu(2));
  Matrix ivM=EmbedMVNSPD.randomSymmetricMatrix(2).minus(EmbedMVNSPD.randomSymmetricMatrix(2));
  
  //Matrix ivM=Matrix.identity(2,2); 
  
  IV=new vM(ivv,ivM);
  
  Matrix stdv=new Matrix(2,1);
  Matrix stdM=Matrix.identity(2,2);
  Nstd=new vM(stdv,stdM);
  
  N1.v=EmbedMVNSPD.randomMu(2);
  N1.M=EmbedMVNSPD.randomSPDCholesky(2);
  
  /*
  println("0 vector:");
  stdv.print(6,6);
  println("Id:");
  stdM.print(6,6);
  */
  
  // get initial condition
  Jama.EigenvalueDecomposition evd=ivM.eig();
    Matrix D=evd.getD();
    Matrix V=evd.getV();
     eigv1=new Matrix(2,1);
     eigv1.set(0,0,D.get(0,0)*V.get(0,0));
     eigv1.set(1,0,D.get(0,0)*V.get(1,0));
     
     eigv2=new Matrix(2,1);
     eigv2.set(0,0,D.get(1,1)*V.get(0,1));
     eigv2.set(1,0,D.get(1,1)*V.get(1,1));
    
       double FRI1=EmbedMVNSPD.FisherRaoDistanceFromI(IV, 1.0, 10000);
   println("Fisher-Rao distance from I, 1:"+FRI1);
   
    double FRI2=EmbedMVNSPD.FisherRaoDistanceFromI(IV, 2.0, 10000);
    println("Fisher-Rao distance from I, 2:"+FRI2);
    
    
   vM X1=EmbedMVNSPD.GeodesicStd(IV,1.0);
   X1.print();
   
   
   vM X2=EmbedMVNSPD.GeodesicStd(IV,2.0);
   X2.print();
   
  int  T=1000;
  double gFR1=EmbedMVNSPD.GuaranteedFisherRaoMVN(Nstd,X1,T).b;
   double gFR2=EmbedMVNSPD.GuaranteedFisherRaoMVN(Nstd,X2,T).b;
   
  System.out.println("for t=1:"+gFR1+" for t=2:"+gFR2);
   
 //  gv=EmbedMVNSPD.randomMu(2);
  //gM=EmbedMVNSPD.randomMatrix(2);
  
  N1=Nstd; N2=X1;
   
   EmbedMVNSPD.Distances(Nstd,X1);
   
}




void initEriksenIVC()
{
  Matrix ivv=EmbedMVNSPD.randomMu(2).minus(EmbedMVNSPD.randomMu(2));
  Matrix ivM=EmbedMVNSPD.randomSymmetricMatrix(2).minus(EmbedMVNSPD.randomSymmetricMatrix(2));
  IV=new vM(ivv,ivM);
  
  Matrix stdv=new Matrix(2,1);
  Matrix stdM=Matrix.identity(2,2);
  Nstd=new vM(stdv,stdM);
  
  // get initial condition eigenvectors of Symmetric matrice
  Jama.EigenvalueDecomposition evd=ivM.eig();
    Matrix D=evd.getD();
    Matrix V=evd.getV();
     eigv1=new Matrix(2,1);
     eigv1.set(0,0,D.get(0,0)*V.get(0,0));
     eigv1.set(1,0,D.get(0,0)*V.get(1,0));
     
     eigv2=new Matrix(2,1);
     eigv2.set(0,0,D.get(1,1)*V.get(0,1));
     eigv2.set(1,0,D.get(1,1)*V.get(1,1));
     
     double t1=1, t2=2;
     
   vM X1=EmbedMVNSPD.ErikenGeodesicFromStdN(IV,t1);
   X1.print();
   
   vM X2=EmbedMVNSPD.ErikenGeodesicFromStdN(IV,t2);
   X2.print();
   
  int  T=1000;
  double gFR1=EmbedMVNSPD.GuaranteedFisherRaoMVN(Nstd,X1,T).b;
   double gFR2=EmbedMVNSPD.GuaranteedFisherRaoMVN(Nstd,X2,T).b;
   
  System.out.println("[Eriksen; Fisher Rao] for t="+t1+":"+gFR1+" for t="+t2+":"+gFR2);
   
  N1=Nstd; N2=X1;   
   //EmbedMVNSPD.Distances(Nstd,X1);
}

static Clock cc=new Clock();

//Time inversion:0.1520805
//Time SVD:0.5015179000000001

static void measure()
{
 int dd=500; 
  Matrix SS=EmbedMVNSPD.randomSPDCholesky(dd);
  cc.Start();
  SS.inverse();
  System.out.println("Time inversion:"+cc.Stop());
  cc.Start();
  SS.eig();
   System.out.println("Time SVD:"+cc.Stop());
}

void init1D()
{// mean, sigma2
   m1=EmbedMVNSPD.randomMu(1);
  S1=EmbedMVNSPD.randomSPDCholesky(1);

  m2=EmbedMVNSPD.randomMu(1);
  S2=EmbedMVNSPD.randomSPDCholesky(1);
  
  
  EmbedMVNSPD.Mean1D(N1,N2);
}

void initAHM()
{
Matrix SS1, SS2; int dd=15;
  
  double t;
  //t=Math.random();
  t=0.5;
  
SS1=EmbedMVNSPD.randomSPDCholesky(dd);
SS2=EmbedMVNSPD.randomSPDCholesky(dd);

Matrix ahm=EmbedMVNSPD.InductiveAHM(SS1,SS2,t,100);
Matrix c=EmbedMVNSPD.RiemannianGeodesic(SS1,SS2,t);
 
System.out.println("weighted AHM versus Rie Geodesic with t="+t);
ahm.print(6,6);
c.print(6,6);
double error=(ahm.minus(c)).normF();
System.out.println("error Frobenius: "+error);
}

void initSPD()
{
m1=m2=EmbedMVNSPD.randomMu(2);
S1=EmbedMVNSPD.randomSPDCholesky(2);
S2=EmbedMVNSPD.randomSPDCholesky(2);
  N1=new vM(m1, S1);
  N2=new vM(m2, S2);
  Matrix IM,RM;
  double rho;
  
 for(int nbiter=1;nbiter<=100;nbiter++)
 {
   IM=EmbedMVNSPD.DualInductiveMean(N1,N2,nbiter).M;
  RM=EmbedMVNSPD.RiemannianGeodesic(S1,S2,0.5);
  rho=EmbedMVNSPD.RieSPDDistance(IM,RM);
 //System.out.println("Rie distance between RieM and IM:"+rho);
 System.out.println(nbiter+"\t"+rho);
 
 }
}

// BVP
void initBVC()
{

  m1=EmbedMVNSPD.randomMu(2);
  S1=EmbedMVNSPD.randomSPDCholesky(2);

  m2=EmbedMVNSPD.randomMu(2);
  S2=EmbedMVNSPD.randomSPDCholesky(2);


/*
// standard bivariate normal
m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=Matrix.identity(2,2);
m2=new Matrix(2,1);m2.set(0,0,5);m2.set(1,0,0);
S2=new Matrix(2,2);
S2.set(0,0,1);S2.set(1,1,2);S2.set(0,1,-1);S2.set(1,0,-1);
*/

// Example from Han Park 2013
// 3.1329


m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=new Matrix(2,2);
S1.set(0,0,1.0);S1.set(0,1,0);
S1.set(1,0,0);S1.set(1,1,0.1);

m2=new Matrix(2,1);m2.set(0,0,1);m2.set(1,0,1);
//m2=new Matrix(2,1);m2.set(0,0,0);m2.set(1,0,0);
S2=new Matrix(2,2);
S2.set(0,0,0.1);S2.set(0,1,0);
S2.set(1,0,0);S2.set(1,1,1);
 

/* // Han Park example
// 23.49, we find 44.443608552887
m1=new Matrix(2,1);
m1.set(0,0,0.0);m1.set(1,0,0.0);
S1=new Matrix(2,2);
S1.set(0,0,1.0);S1.set(0,1,0.0);
S1.set(1,0,0);S1.set(1,1,1.0);

m2=new Matrix(2,1);
m2.set(0,0,10000.0);m2.set(1,0,0.0);
S2=new Matrix(2,2);
S2.set(0,0,10.0);S2.set(0,1,0);
S2.set(1,0,0.0);S2.set(1,1,10.0);
*/


/*
m1=new Matrix(2,1);m1.set(0,0,0);m1.set(1,0,0);
S1=new Matrix(2,2);
S1.set(0,0,1.0);S1.set(0,1,0);
S1.set(1,0,0);S1.set(1,1,1.0);

m2=new Matrix(2,1);m2.set(0,0,10000.0);m2.set(1,0,0.0);
S2=new Matrix(2,2);
S2.set(0,0,10.0);S2.set(0,1,0);
S2.set(1,0,0);S2.set(1,1,10.0);
*/

//m1.print(6,6);S1.print(6,6);
//m2.print(6,6);S2.print(6,6);


  N1=new vM(m1, S1);
  N2=new vM(m2, S2);
  
//  EmbedMVNSPD.DistanceCO(N1,N2);
  
 // EmbedMVNSPD.Distances(N1,N2);
  
  
  /*
  Matrix ivv=EmbedMVNSPD.randomMu(2);
  Matrix ivM=EmbedMVNSPD.randomSymmetricMatrix(2);
  IV=new vM(ivv,ivM);
  
  Matrix stdv=new Matrix(2,1);
  Matrix stdM=Matrix.identity(2,2);
  Nstd=new vM(stdv,stdM);
  
  N1.v=EmbedMVNSPD.randomMu(2);
  N1.M=EmbedMVNSPD.randomSPDCholesky(2);
  
  /*
  println("0 vector:");
  stdv.print(6,6);
  println("Id:");
  stdM.print(6,6);
  */
  
  /*
  Jama.EigenvalueDecomposition evd=ivM.eig();
    Matrix D=evd.getD();
    Matrix V=evd.getV();
     eigv1=new Matrix(2,1);
     eigv1.set(0,0,D.get(0,0)*V.get(0,0));
     eigv1.set(1,0,D.get(0,0)*V.get(1,0));
     
     eigv2=new Matrix(2,1);
     eigv2.set(0,0,D.get(1,1)*V.get(0,1));
     eigv2.set(1,0,D.get(1,1)*V.get(1,1));
    
       double FRI=EmbedMVNSPD.FisherRaoDistanceFromI(IV, 1.0, 10000);
   println("Fisher-Rao distance from I:"+FRI);
   vM X1=EmbedMVNSPD.GeodesicStd(IV,1);
   X1.print();
   */
   
 //  gv=EmbedMVNSPD.randomMu(2);
  //gM=EmbedMVNSPD.randomMatrix(2);
  
//  N1=Nstd; N2=X1;
   
 //  EmbedMVNSPD.Distances(Nstd,X1);
 
 
  int T; Interval FR12;
  
  /*
  for(T=1;T<=100;T++)
  {
   FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
//    println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
  println(T+"\t"+FR12.b);
 
}
   */
  
    T=10;
   FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
    println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
    
    
    T=15;
   FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
    println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
    
  T=100;
   FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
    println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
  
  T=1000;
  FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
  
  println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
  
  /*
  T=10000;
    FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
  
  println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
  
  T=50000;
    FR12=EmbedMVNSPD.GuaranteedFisherRaoMVN(N1,N2,T);
  
  println("T="+T+" Interval for Fisher-Rao distance:"+FR12);
  */
  /*
   T=1000;
  double alpha=Math.random();
  double beta=alpha+(1.0-alpha)*Math.random();
  double FR=EmbedMVNSPD.FisherRaoMVN(N1,N2,0.0,1.0,T);
   double FRab=EmbedMVNSPD.FisherRaoMVN(N1,N2,alpha,beta,T);
   
   double check=(beta-alpha)*FR;
   
   println("metric geodesic: alpha="+alpha+" beta="+beta+" compare: "+check+" vs "+FRab);
   */
   
    EmbedMVNSPD.Mean(N1,N2);
    
    EmbedMVNSPD.TestKobayashiMethod(N1,N2);
}


void setup()
{
  size(800, 800);
  init();
  background(255, 255, 255);
}

//void drawRandomGeodesics()
int nbsteps=1000;

boolean toggleFR=true;
boolean toggleHilbert=true;

 //boolean toggleCO=true;
 boolean toggleCO=false;
 
  boolean toggleE=false;
 boolean toggleT=false;
 boolean toggleET=false;
 boolean toggleL=false;
 /*
 boolean toggleE=true;
 boolean toggleT=true;
 boolean toggleET=true;
 boolean toggleL=true;
 */
/*
boolean toggleE=false;
boolean toggleT=false;
boolean toggleET=false;
boolean toggleCO=false;
boolean toggleL=false;
*/
 
 
 void AllExportPDF()
{
  String ss=""+millis();
  
  toggleE=true; toggleT=toggleET=toggleCO=toggleL=false;
   beginRecord(PDF, "BivariateNormal-"+ss+"-E"+".pdf");
  draw();
  endRecord();
  
    toggleT=true; toggleE=toggleET=toggleCO=toggleL=false;
   beginRecord(PDF, "BivariateNormal-"+ss+"-T"+".pdf");
  draw();
  endRecord();
  
  
    toggleET=true; toggleT=toggleE=toggleCO=toggleL=false;
   beginRecord(PDF, "BivariateNormal-"+ss+"-ET"+".pdf");
  draw();
  endRecord();
  
    toggleCO=true; toggleT=toggleET=toggleE=toggleL=false;
   beginRecord(PDF, "BivariateNormal-"+ss+"-CO"+".pdf");
  draw();
  endRecord();
  
    toggleL=true; toggleT=toggleET=toggleCO=toggleE=false;
   beginRecord(PDF, "BivariateNormal-"+ss+"-L"+".pdf");
  draw();
  endRecord();
  
    toggleE=true; toggleT=toggleET=toggleCO=toggleL=true;
   beginRecord(PDF, "BivariateNormal-"+ss+"-A"+".pdf");
  draw();
  endRecord();
  
 
}
 
void exportPDF()
{
  beginRecord(PDF, "BivariateNormal-"+millis()+".pdf");
  draw();
  endRecord();
}


void drawGeodesic()
{double t,dt=0.05;
//surface.setTitle("Geodesic for bivariate normals with initial values");
surface.setTitle("Geodesic for bivariate normals with boundary conditions");
  background(255, 255, 255);
   vM X,Xn;


if(toggleIVP){
  strokeWeight(1);
  for(t=0;t<=1.0;t+=dt)
  {
    stroke((float)(255*t),0,0);
  

// correct
  X=EmbedMVNSPD.GeodesicStd(IV,t);
  Xn=EmbedMVNSPD.GeodesicStd(IV,t+dt);

  
  /*
  // need to debug
  X=EmbedMVNSPD.EriksenGeodesicStd(IV,t);
  Xn=EmbedMVNSPD.EriksenGeodesicStd(IV,t+dt);
  */
  
  MyEllipse(X.v, X.M);MyPoint(X.v);
  MyLine(X.v,Xn.v);
  }
}


  if (toggleKobayashi)
  {
  // Kobayashi method
  strokeWeight(1);stroke(0,0,255);
  for(t=0;t<=1.0;t+=dt)
  {
   // System.out.println("t="+t);
  X=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,t);
  Xn=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,t+dt);
 

 // X.print();
  MyEllipse(X.v, X.M);MyPoint(X.v);
  MyLine(X.v,Xn.v);
  }
  }
  
    stroke(0);
    
     stroke(255,0,0);
MyEllipse(N1.v, N1.M);MyPoint(N1.v);
 MyEllipse(N2.v, N2.M);MyPoint(N2.v);
  
  if (toggleIVP)
  {  if (Nstd!=null){
  MyEllipse(Nstd.v, Nstd.M);MyPoint(Nstd.v);
  
  stroke(255,0,0);
  X=EmbedMVNSPD.GeodesicStd(IV,1);
   MyEllipse(X.v, X.M);MyPoint(X.v);
  }
  stroke(0,0,255);strokeWeight(3);
  MyLine(0,0,IV.v.get(0,0),IV.v.get(1,0));
   
   stroke(0,255,0);strokeWeight(3);
  MyLine(0,0,eigv1.get(0,0),eigv1.get(1,0));
   MyLine(0,0,eigv2.get(0,0),eigv2.get(1,0));
  }

if (toggleAuto) {init();delay(1000);}
}

double beta1=1, beta2=1.5, beta3=3;


void draw()
{
  drawGeodesic();
 //good drawSeveralInterpolations();
}

void drawSeveralInterpolations()
{
  int i;
  int batch=50;
  vM [] X=new vM[nbsteps];
  surface.setTitle("Fisher-Rao Gaussian manifold: Bivariate normal interpolations");
  background(255, 255, 255);

if (toggleFR)
{
 stroke(0); 
 X=EmbedMVNSPD.PathFisherRao(IV, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
      if ((i%batch)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
    }  
}


if (toggleHilbert)
{
 stroke(255,0,255); 
 X=EmbedMVNSPD.PathHilbert(beta1, N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
      if ((i%batch)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
    }  
    
    // second path: same or not?
 //stroke(255,255,0); yellow
 stroke(0,255,255);// turquoise
 X=EmbedMVNSPD.PathHilbert(beta2, N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
      if ((i%batch)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
    } 
    
    stroke(250,180,10);
    // stroke(60,160,110);// vert
 X=EmbedMVNSPD.PathHilbert(beta3, N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
      if ((i%batch)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
    } 
    
    
}


  if (toggleL) {
    stroke(255, 255, 0);
    X=EmbedMVNSPD.PathLambda(N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
      if ((i%100)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
    }  
} // toggleL


  if (toggleT) {
    stroke(255, 0, 0);
    X=EmbedMVNSPD.PathTheta(N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    {
     MyLine(X[i].v,X[i+1].v);
    if ((i%100)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
  }
  } // toggleT

  if (toggleE) {
    stroke(0, 0, 255);
    X=EmbedMVNSPD.PathEta(N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++)
    { MyLine(X[i].v,X[i+1].v);
  if ((i%100)==0) {MyEllipse(X[i].v, X[i].M);MyPoint(X[i].v);}
}
    
  }// toggle E


  if (toggleET) {
    stroke(255, 0, 255);
    X=EmbedMVNSPD.PathThetaEta(N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) 
    { MyLine(X[i].v,X[i+1].v);
    if ((i%100)==0) {MyPoint(X[i].v);MyEllipse(X[i].v, X[i].M);}
  }
  }// toggleET

  if (toggleCO) {
    stroke(0, 255, 0);
    X=EmbedMVNSPD.PathProjectedMVN(N1, N2, nbsteps);
    for (i=0; i<nbsteps-1; i++) {
     MyLine(X[i].v,X[i+1].v);
    if ((i%batch)==0) {MyPoint(X[i].v);MyEllipse(X[i].v, X[i].M);}
  }
  }//toggleCO


  stroke(0);
  fill(0);
  //MyPoint(m1.get(0, 0), m1.get(1, 0));
  //MyPoint(m2.get(0, 0), m2.get(1, 0));
  
  strokeWeight(3);
  MyEllipse(N1);
  MyEllipse(N2);
   strokeWeight(1);
 // MyEllipse(m1, S1);
 // MyEllipse(m2, S2);
}



void keyPressed()
{ if (key=='a') {toggleAuto=!toggleAuto;}

if (key=='w') {init1D();initSPD();}
if (key=='h')
initAHM();

if (key=='c')
EmbedMVNSPD.TestAHM1D();

if (key=='m') measure();


  if (key==' ') init();
  if (key=='p') exportPDF();
  
  if (key=='k'){toggleKobayashi=!toggleKobayashi;}
  
  if (key=='i'){toggleIVP=!toggleIVP;}
  
  if (key=='a') {AllExportPDF();}
  if (key=='q') {
    exit();
  }
  if (key=='l') {
    toggleL=!toggleL;
    draw();
  }
  if (key=='e') {
    toggleE=!toggleE;
    draw();
  }
  if (key=='t') {
    toggleT=!toggleT;
    draw();
  }
  if (key=='v') {
    toggleET=!toggleET;
    draw();
  }
  if (key=='c') {
    toggleCO=!toggleCO;
    draw();
  }
}
