// (C) 2019 Frank.Nielsen@acm.org
// Frank.Nielsen@acm.org
 
 // Press '4' for Itakura-Saito and then '.' for parallel transport
// write inner angles


import processing.pdf.*;
import processing.svg.*;

double ii=0;
boolean displaybb=false;

boolean DEBUG=false;

boolean showTheta=true;
boolean showEta=false;
boolean showPD=false;

boolean showAllEdges=false;

boolean showDualV=false;
boolean showPrimalV=true;

double clipM=100, clipm=-clipM;
double eclipm=clipm, eclipM=clipM;

int side = 512;
int ww = side;
int hh = side;
int nbsteps=100;

double alphapt=0.;

/*
p:1.2032095921917694 1.9255928493063978
q:1.5136629241381097 1.3903604327104517
r:0.1333682543427159 0.21343991816006025
*/

// for orthogonal

 double minxTheta=0.5;
 double maxxTheta=5.0;
 double minyTheta=0.5;
 double maxyTheta=5.0;
 
 /*
  double minxTheta=0.5;
 double maxxTheta=0.9;
 
 double minyTheta=0.5;
 double maxyTheta=0.9;
 */
 /*
double minxTheta=0.5;
double maxxTheta=1.0;
double minyTheta=0.5;
double maxyTheta=1.0;
*/
double minxEta=-1/maxxTheta;
double maxxEta=-1/minxTheta;
double minyEta=-1/maxyTheta;
double maxyEta=-1/minyTheta;


double minxThetaIS=0.4;
double maxxThetaIS=0.9;
double minyThetaIS=0.4;
double maxyThetaIS=0.9;

double minxEtaIS=-1/maxxThetaIS;
double maxxEtaIS=-1/minxThetaIS;
double minyEtaIS=-1/maxyThetaIS;
double maxyEtaIS=-1/minyThetaIS;

double deltaxTheta=0.05;
double deltayTheta=0.05;


double deltayEta=0.1;
double deltaxEta=0.1;

double fixedangle1=toRad(90);
double fixedangle2=toRad(50);



// boolean sampleOrthogonal=true;
boolean sampleOrthogonal=false;


boolean doublyRightAngle=false;
boolean doubleRightAngle=true;
 
 
// convert radians to degrees
public static double toDeg(double x)
{
  return x*180.0/Math.PI;
}

public static double toRad(double x)
{
  return x*Math.PI/180.0;
}


BB bbTheta, bbEta;

double [] p, q, r, s;
EDGETYPE [] edgetype; // triangle

double [] thetap, thetaq, thetar, thetas;
double [] etap, etaq, etar, etas;

// points in primal and dual spaces
double [][] pointP, pointD; 

// equiv points in power diagrams, primal and dual
double [][] PDP, PDD; 

// weight, and weight in primal/dual
double [] weight, weightP, weightD; 



// Equivalent power diagrams
PowerDiagram diagramP, diagramD;

// sites
OpenList sitesP, sitesD;

// Voronoi cells
PolygonSimple rootPolygonP, rootPolygonD;

//double constant=10000;

//TYPE type=TYPE.ITAKURASAITO;
TYPE type=TYPE.KLE;

int n;
int nstart=16;

float ptsize=6;

color colgen=color(255, 0, 0);
color colVor=color(0, 0, 0);


public void eKL3RightAngles()
{

  //a=0.5, b=0.5, c=1.0, (c-a)*b*(y-a)+(x-b)*a*(z-b)=0,(y-c)*x*(a-c)+(z-x)*c*(b-x)=0,(a-y)*z*(c-y)+(b-z)*y*(x-z)=0
  // double a=0.5, b=0.5, c=1.0;
  
  double a=5, b=4, c=3.0;
  
  double x,y,z;
  
  
p[0]=a;
p[1]=b;

q[0]=c;
x=q[1]=45.5; // free param?

 
//y=r[0]=x*(2*x-1)/(x-1);
//z=r[1]=-sqr(x)/((x-1)*(2*x-1));


y=r[0]=-15*(x*x-10*x+24)/(2*(5*x-12));
z=r[1]=8*(x*x-6*x)/((x-4)*(5*x-12));


println("rpoint "+r[0]+"   "+r[1]);

 

/*
solve([0.25*(y-0.5)+(x-0.5)*0.5*(z-0.5)=0, (y-1)*x*(-0.5)+(z-x)*(0.5-x)=0,(0.5-y)*z*(1-y)+(0.5-z)*y*(x-z)],[x,y,z]);
*/

double eq1= (c-a)*b*(y-a)+(x-b)*a*(z-b);
double eq2= (y-c)*x*(a-c)+(z-x)*c*(b-x);
double eq3= (a-y)*z*(c-y)+(b-z)*y*(x-z);

println(eq1+" "+eq2+" "+eq3);

double angle1, angle2, angle3;
angle1=anglePrimalPrimal(p,q,r);
angle2=anglePrimalPrimal(q,p,r);
angle3=anglePrimalPrimal(r,p,q);
double suma=angle1+angle2+angle3;

println("primal angle at p:"+toDeg(angle1));
println("primal angle at q:"+toDeg(angle2));
println("primal angle at r:"+toDeg(angle3));

println("sum angles:"+toDeg(suma));
/*
\theta_q^y=x
\theta_r^x=y
\theta_r^y=z

0.25*(y-0.5)+(x-0.5)*0.5*(z-0.5)=0
(y-1)*x*(-0.5)+(z-x)*(0.5-x)=0
(0.5-y)*z*(1-y)+(0.5-z)*y*(x-z)=0

For $\theta_q^y\not=1$ and $\theta_q^y\not=\frac{1}{2}$, we get
$\theta_r^x=\frac{\theta_q^y(2\theta_q^y-1)}{\theta_q^y-1}$
and
$\theta_r^y=-\frac{\sqr(\theta_q^y)}{2\sqr(\theta_q^y)-3\theta_q^y+1}$
  
  */
  
}

public   double det(double [][] m)
{return m[0][0]*m[1][1]-m[0][1]*m[1][0];
}

public  double [] solveLinearSystem(double [][] A, double [] b)
{
double [] res=new double [2];
double [][] A1,A2;
A1=new double [2][2];
A2=new double [2][2];
A1[0][0]=b[0];A1[0][1]=A[0][1];A1[1][0]=b[1];A1[1][1]=A[1][1];
A2[0][0]=A[0][0];A2[0][1]=b[0];A2[1][0]=A[1][0];A2[1][1]=b[1];

res[0]=det(A1)/det(A);
res[1]=det(A2)/det(A);

return res;  
}


public   double [] MatVec(double [][] A, double [] b)
{double [] res=new double [2];
res[0]=A[0][0]*b[0]+A[0][1]*b[1];
res[1]=A[1][0]*b[0]+A[1][1]*b[1];
return res;  
}

//
// Construct point r so that we have geodesic triangles with two interior right angles
//
public double [] DoubleRightAngle(double [] p, double [] q)
{
double [] b =new double [2];
double [][]  A =new double [2][2];

double [] thetapq=new double [2];
thetapq[0]=thetap[0]-thetaq[0];
thetapq[1]=thetap[1]-thetaq[1];

/*
b[0]= thetaq[0]*hessF(thetaq[0])*thetapq[0] +   thetaq[1]*hessF(thetaq[1])*thetapq[1];
b[1]= thetap[0]*hessF(thetap[0])*thetapq[0] +   thetap[1]*hessF(thetap[1])*thetapq[1] ;
*/

b[0]= thetaq[0]*hessF(thetaq[0])*thetapq[0] +   thetaq[1]*hessF(thetaq[1])*thetapq[1] + Math.cos(fixedangle1);
b[1]= thetap[0]*hessF(thetap[0])*thetapq[0] +   thetap[1]*hessF(thetap[1])*thetapq[1] + Math.cos(fixedangle2);

A[0][0]= hessF(thetaq[0])*thetapq[0]; A[0][1]= hessF(thetaq[1])*thetapq[1];
A[1][0]= hessF(thetap[0])*thetapq[0]; A[1][1]= hessF(thetap[1])*thetapq[1];

double [] thetar= solveLinearSystem(A,b);
r=thetar;

println("Checking Angles:");

 double alpha1=anglePrimalPrimal(thetap, thetaq, thetar);
 double  alpha2=anglePrimalPrimal(thetaq, thetar, thetap);
 double  alpha3=anglePrimalPrimal(thetar, thetap, thetaq);
 
  double  sumalpha=alpha1+alpha2+alpha3;
  
    println("alpha1 pqr:"+alpha1+" "+toDeg(alpha1));
        println("alpha2 qrp:"+alpha2+" "+toDeg(alpha2));
            println("alpha3 rpq:"+alpha3+" "+toDeg(alpha3));
            
  println("sum angles alpha:"+sumalpha+" "+toDeg(sumalpha));
  
return r;

}


public double [] solvethetar(double [] thetap, double [] thetaq)
{

  double [] etap=new double [2]; etap[0]=gradF(thetap[0]);etap[1]=gradF(thetap[1]);
   double [] etaq=new double [2]; etaq[0]=gradF(thetaq[0]);etaq[1]=gradF(thetaq[1]);
   
double a,b,A,B,C;
double etapqx=etap[0]-etaq[0];
double etapqy=etap[1]-etaq[1];

double thetapqx=thetap[0]-thetaq[0];
double thetapqy=thetap[1]-thetaq[1];
a=-etapqx/etapqy;
b=(etapqx*thetaq[0]+etapqy*thetaq[1])/etapqy ;

A= -(a*(thetapqx*etaq[0]+thetapqy*etaq[1]));
B= -thetapqx*a-thetapqy-b*(thetapqx*etaq[0]+thetapqy*etaq[1]);
C= -thetapqx*b;

double [] X=solveQuadratic(A,B,C);

// take the first solution
double [] r=new double [2];
r[0]=X[0];
r[1]=a*X[0]+b;


// take the second solution
/*
r[0]=X[1];
r[1]=a*X[1]+b;
*/

return r;
}

// calculate all the angles of the triangles
void calculateAngle()
{
  double alpha1, alpha2, alpha3;

  println("-------------calculate angles: begin -----");
  println("p:"+thetap[0]+" "+thetap[1]);
  println("q:"+thetaq[0]+" "+thetaq[1]);
  println("r:"+thetar[0]+" "+thetar[1]);


  alpha1=anglePrimalPrimal(thetap, thetaq, thetar);
  alpha2=anglePrimalPrimal(thetaq, thetar, thetap);
  alpha3=anglePrimalPrimal(thetar, thetap, thetaq);
  double  sumalpha=alpha1+alpha2+alpha3;
  println("sum angles alpha:"+sumalpha+" "+toDeg(sumalpha));


  double beta1, beta2, beta3;

  beta1=angleDualDual(etap, etaq, etar);
  beta2=angleDualDual(etaq, etar, etap);
  beta3=angleDualDual(etar, etap, etaq);

  double  sumbeta=beta1+beta2+beta3;
  println("sum angles beta:"+sumbeta+" "+toDeg(sumbeta));

  println("total sum angles alpha+beta:"+toDeg(sumbeta+sumalpha));

  double [] deltatheta1=new double[2]; 
  deltatheta1[0]=p[0]-q[0]; 
  deltatheta1[1]=p[1]-q[1];
  double [] deltaeta1=new double[2]; 
  deltaeta1[0]=etar[0]-etaq[0]; 
  deltaeta1[1]=etar[1]-etaq[1];

  double angleo1=anglePrimalDual(thetap, deltatheta1, deltaeta1);
  println(toDeg(angleo1));

  double [] deltatheta2=new double[2]; 
  deltatheta2[0]=r[0]-q[0]; 
  deltatheta2[1]=r[1]-q[1];
  double [] deltaeta2=new double[2]; 
  deltaeta2[0]=etap[0]-etaq[0]; 
  deltaeta2[1]=etap[1]-etaq[1];

  double angleo2=angleDualPrimal(thetap, deltaeta2, deltatheta2);
  println(toDeg(angleo2));
  
   println("<<<-------------calculate angles: end -----");
}

public  double innerDualAt(double [] eta, double [] eta1, double [] eta2)  
{
  double sum=0;
  int i;

  for (i=0; i<2; i++)
  {
    sum+=(eta1[i]*eta2[i]*hessG(eta[i]));
  }
  return sum;
}



double anglePrimalDual(double [] thetap, double [] deltatheta, double [] deltaeta)
{ 
  double alpha=Math.acos((deltatheta[0]*deltaeta[0]+deltatheta[1]*deltaeta[1])/(normAt(thetap, deltatheta)*normDualAt(thetap, deltaeta)));

  return alpha;
}



double angleDualPrimal(double [] thetap, double [] deltaeta, double [] deltatheta)
{ 
  double alpha=Math.acos((deltatheta[0]*deltaeta[0]+deltatheta[1]*deltaeta[1])/(normAt(thetap, deltatheta)*normDualAt(thetap, deltaeta)));

  return alpha;
}



// primal angle from thetap
double anglePrimalPrimal(double [] thetap, double [] thetaq, double [] thetar)
{ 
  double [] thetaqp=new double[2];
  double [] thetarp=new double[2];
  int i;

  for (i=0; i<2; i++)
  {
    thetaqp[i]=thetaq[i]-thetap[i];
    thetarp[i]=thetar[i]-thetap[i];
  }

//("->"+innerPrimalAt(thetap, thetaqp, thetarp));
//println("normaat->"+normAt(thetap, thetaqp));

  double alpha=Math.acos(innerPrimalAt(thetap, thetaqp, thetarp)/(normAt(thetap, thetaqp)*normAt(thetap, thetarp)));

  return alpha;
}

// primal norm
public  double normAt(double [] thetap, double [] theta)
{ //println("Debug->"+innerPrimalAt(thetap, theta, theta));
  return Math.sqrt(innerPrimalAt(thetap, theta, theta));
}


public  double normDualAt(double [] etap, double [] eta)
{
  return Math.sqrt(innerDualAt(etap, eta, eta));
}

double angleDualDual(double [] etap, double [] etaq, double [] etar)
{ 
  double [] etaqp=new double[2];
  double [] etarp=new double[2];
  int i;

  for (i=0; i<2; i++)
  {
    etaqp[i]=etaq[i]-etap[i];
    etarp[i]=etar[i]-etap[i];
  }

  double beta=Math.acos(innerDualAt(etap, etaqp, etarp)/(normDualAt(etap, etaqp)*normDualAt(etap, etarp)));

  return beta;
}



public double [] convertVectorTheta2EtaAt(double [] thetap, double [] theta)
{
  double [] res=new double [2];
  int i;

  for (i=0; i<2; i++)
  {
    res[i]=hessF(thetap[i])*theta[i];
  }
  return res;
}


public  double [] convertVectorEta2ThetaAt(double [] etap, double [] eta)
{
  double [] res=new double [2];
  int i;

  for (i=0; i<2; i++)
  {
    res[i]=hessG(etap[i])*eta[i];
  }
  return res;
}


// assume diagonal matrix
public   double innerPrimalAt(double [] theta, double [] theta1, double [] theta2)  
{
  double sum=0;
  int i;

  for (i=0; i<2; i++)
  {
    //println(theta1[i]+" "+theta2[i]);
    sum += (theta1[i]*theta2[i]*hessF(theta[i]));
  }
  return sum;
}



public   double [] solveQuadratic(double a, double b, double c)
{
  double delta=b*b-4*a*c;

  if (delta<0) return null;
  else {
    double [] res=new double [2];
    res[0]=(-b-Math.sqrt(delta))/(2.0*a); 
    res[1]=(-b+Math.sqrt(delta))/(2.0*a);
    return res;
  }
}  
double min(double a,double b){if (a<b) return a; else return b;}
double max(double a,double b){if (a>b) return a; else return b;}

double min(double a,double b,double c)
{return min(a,min(a,b));}

double max(double a,double b,double c)
{return max(a,max(a,b));}

double max(double a,double b,double c, double d)
{return max(max(a,b),max(c,d));}


void initializePoints()
{
  p=new double[2];
  q=new double[2];
  r=new double[2];
   s=new double[2];
   
   float [] a=new float [4];
   a[0]=(float)(minxTheta+(maxxTheta-minxTheta)*Math.random());
   a[1]=(float)(minxTheta+(maxxTheta-minxTheta)*Math.random());
   a[2]=(float)(minxTheta+(maxxTheta-minxTheta)*Math.random());
   a[3]=(float)(minxTheta+(maxxTheta-minxTheta)*Math.random());
   
   a=sort(a);
  

// in theta coordinates
/*
  p[0]=minxTheta+(maxxTheta-minxTheta)*Math.random();
  p[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  q[0]=minxTheta+(maxxTheta-minxTheta)*Math.random();
  q[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  r[0]=minxTheta+(maxxTheta-minxTheta)*Math.random();
  r[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  
  s[0]=minxTheta+(maxxTheta-minxTheta)*Math.random();
  s[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  */
  
    p[0]=a[0];
  p[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  
  q[0]=a[1];
  q[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  
  r[0]=a[2];
  r[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  
  s[0]=a[3];
  s[1]=minyTheta+(maxyTheta-minyTheta)*Math.random();
  

/*
p: 1.9255928493063978
q:1.5136629241381097 1.3903604327104517
r:0.1333682543427159 0.21343991816006025
*/

/*
    p[0]=1.2;
  p[1]=1.9;
  q[0]=1.50;
  q[1]=1.4;
  r[0]=0.95;
  r[1]=0.6;
  */


/* orthogonal
p:0.8087930118190731 0.7449812699773244
q:0.60420667667294 0.9090638763345258
r:0.16728640297818817 0.15408792499372842

*/

/* good
p:1.0661099909085556 1.781160119115225
q:1.3814292466347315 1.1923494328396633
r:0.13974665756930799 0.23347607222963657
*/

/*
 p[0]=1+Math.random();
  p[1]=1+Math.random();
  q[0]=1+Math.random();
  q[1]=1+Math.random();
  r[0]=1+Math.random();
  r[1]=1+Math.random();
  */
  
  /*
  p[0]=minxTheta+(maxxTheta-minxTheta)*1*Math.random();
  p[1]=minyTheta+(maxyTheta-minyTheta)*1*Math.random();
  
  q[0]=minxTheta+(maxxTheta-minxTheta)*1*Math.random();
  q[1]=minyTheta+(maxyTheta-minyTheta)*1*Math.random();
  */
  
//if (sampleOrthogonal) r=solvethetar(p,q);

//if ((r[0]>maxxTheta)||(r[0]<minxTheta)||(r[1]>maxyTheta)||(r[1]<minyTheta)) initializePoints();


  /*
p[0]=0.9170839462667955;  p[1]=0.6839376565477681; 
   q[0]=0.4281335443119453;  q[1]=0.4645485096069144;  
   r[0]=0.4851141596939842;  r[1]=0.3617856826410093;
   */

  println("p:"+p[0]+" "+p[1]);
  println("q:"+q[0]+" "+q[1]);
  println("r:"+r[0]+" "+r[1]);
 println("s:"+r[0]+" "+s[1]);

  thetap=new double[2]; 
  thetap[0]=p[0];
  thetap[1]=p[1];
  etap=new double[2]; 
  etap[0]=gradF(thetap[0]);
  etap[1]=gradF(thetap[1]);


  thetaq=new double[2]; 
  thetaq[0]=q[0];
  thetaq[1]=q[1];
  etaq=new double[2]; 
  etaq[0]=gradF(thetaq[0]);
  etaq[1]=gradF(thetaq[1]);


  thetar=new double[2]; 
  thetar[0]=r[0];
  thetar[1]=r[1];
  etar=new double[2]; 
  etar[0]=gradF(thetar[0]);
  etar[1]=gradF(thetar[1]);
  
  thetas=new double[2]; 
    thetas[0]=s[0];
  thetas[1]=s[1];
  etas=new double[2]; 
  etas[0]=gradF(thetas[0]);
  etas[1]=gradF(thetas[1]);
  

  //if (doubleRightAngle) r=DoubleRightAngle(p,q);

  edgetype=new  EDGETYPE [3];
  edgetype[0]=EDGETYPE.PRIMAL;
  edgetype[1]=EDGETYPE.PRIMAL;
  edgetype[2]=EDGETYPE.PRIMAL;
  
  /*
minxTheta=min(thetap[0],thetaq[0],thetar[0]);
 maxxTheta=max(thetap[0],thetaq[0],thetar[0]);
 
 minyTheta=min(thetap[1],thetaq[1],thetar[1]);
 maxyTheta=max(thetap[1],thetaq[1],thetar[1]);

minxEta=min(etap[0],etaq[0],etar[0]);
 maxxEta=max(etap[0],etaq[0],etar[0]);
 
minyEta=min(etap[1],etaq[1],etar[1]);
maxyEta=max(etap[1],etaq[1],etar[1]);


double dsidetheta=max(maxxTheta-minxTheta, maxyTheta-minyTheta);
double dsideeta=max(maxxEta-minxEta, maxyEta-minyEta);

minxTheta=minxTheta-0.1*dsidetheta;
maxxTheta=minxTheta+1.2*dsidetheta;
minyTheta=minyTheta-0.1*dsidetheta;
maxyTheta=minyTheta+1.2*dsidetheta;


minxEta=minxEta-0.1*dsideeta;
maxxEta=minxEta+1.2*dsideeta;
minyEta=minyEta-0.1*dsideeta;
maxyEta=minyEta+1.2*dsideeta;
 */
 
 

}

void setup()
{
  size(512, 512);
  initializePoints();
  initialize();
  
  // eKL3RightAngles();
}

void MyLine(BB bb, double x1, double y1, double x2, double y2)
{
  line(bb.x2X(x1), bb.y2Y(y1), bb.x2X(x2), bb.y2Y(y2)) ;
}


// draw the metric tensor field
void drawMetricTheta()
{float arrowsize=0.05;
 float scale=0.015;
 
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

double px,py;
   
  
   strokefill(255, 0, 0);
  noFill();
  for(px=minxTheta+0*deltaxTheta; px<=maxxTheta; px+=deltaxTheta)
  {
    for(py=minyTheta+0*deltayEta; py<=maxyTheta; py+=deltayTheta)
  {noFill();
  ellipse((float)bbTheta.x2X(px), (float)bbTheta.y2Y(py), scale*bbTheta.x2X(hessF(px)),  scale*bbTheta.y2Y(hessF(py)) );
  }
  }
  
  //draw tangent vector now
} 
  
  
  

void drawTangentTheta()
{float arrowsize=0.05;
 
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

  strokefill(255, 0, 0);
  MyLine(bbTheta, p[0], p[1], q[0], q[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic(p[0], p[1], q[0], q[1] );
  
  // parallel transport
  double tx,ty,tx2,ty2;
  
  // tangent vector on nabla-geodesic
  tx2=thetaq[0]-thetap[0];
  ty2=thetaq[1]-thetap[1];
  
  // tangent vector on nabla*-geodesic
  double etapqx=(1-alphapt)*etap[0]+alphapt*etaq[0];
  double etapqy=(1-alphapt)*etap[1]+alphapt*etaq[1];
  
  //tx = (hessG(etap[0])*(etaq[0]-etap[0]));
  //ty = (hessG(etap[1])*(etaq[1]-etap[1]));
  
  tx = (hessG(etapqx)*(etaq[0]-etap[0]));
  ty = (hessG(etapqy)*(etaq[1]-etap[1]));
  
   strokefill(0, 0, 0);
  MyLine(bbTheta, gradG(etapqx), gradG(etapqy),gradG(etapqx)+tx,gradG(etapqy)+ty  );
  
 //  MyLine(bbTheta, gradG(etapqx), gradG(etapqy),gradG(etapqx)+tx2,gradG(etapqy)+ty2  );
  
 // MyLine(bbTheta,  p[0]+tx,p[1]+ty, p[0]+tx-arrowsize,p[1]+ty-arrowsize );
 // MyLine(bbTheta,  p[0]+tx,p[1]+ty, p[0]+tx+arrowsize,p[1]+ty-arrowsize );
  
    ellipse((float)bbTheta.x2X(gradG(etapqx)), (float)bbTheta.y2Y(gradG(etapqy)), 2*ptsize, 2*ptsize);
    ellipse((float)bbTheta.x2X(gradG(etapqx)+tx), (float)bbTheta.y2Y(gradG(etapqy)+ty), ptsize, ptsize);
    
  ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), 2*ptsize, 2*ptsize);
  ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), 2*ptsize, 2*ptsize);
  
  
  //draw tangent vector now
} 
  
  
  
  void drawTangentEta()
{float arrowsize=0.05;
 
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

  strokefill(255, 0, 0);
  
  
   strokefill(0, 0, 255); 
  MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1])  );
strokefill(255, 0, 0);
  drawEtaThetaGeodesic(gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1]) );


  
  double tx,ty;
  tx = (hessF(thetap[0])*(thetaq[0]-thetap[0]));
  ty = (hessF(thetap[1])*(thetaq[1]-thetap[1]));
  
   strokefill(0, 0, 0);
  MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(p[0])+tx,gradF(p[1])+ty  );
  
 // MyLine(bbTheta,  p[0]+tx,p[1]+ty, p[0]+tx-arrowsize,p[1]+ty-arrowsize );
 // MyLine(bbTheta,  p[0]+tx,p[1]+ty, p[0]+tx+arrowsize,p[1]+ty-arrowsize );
    ellipse((float)bbEta.x2X(gradF(p[0])), (float)bbEta.y2Y(gradF(p[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(q[0])), (float)bbEta.y2Y(gradF(q[1])), ptsize, ptsize);
 
  
  //draw tangent vector now
} 


// Main drawing procedure
void draw()
{
  
  
 // if (showTheta) drawP();  else drawD();
  
  
if (showTheta) drawTangentTheta();  else drawTangentEta();


//if (showTheta) drawAllQuadrangleTheta();  else drawAllQuadrangleEta();  



//if (showTheta)  drawMetricTheta(); else drawTangentEta();

 
 
/*

 calculateAngle();

if (sampleOrthogonal==true)
{
  
  if (showTheta) 
  {drawPOrthogonal();}
   if (showEta) 
  {drawDOrthogonal();}
  
}

else{

  if (showTheta) 
  {// draw primal



    if (!showAllEdges)  drawP(); 
    else  drawAllGeodesicTrianglesTheta();
  }
  if (showEta) 
  {

    // draw dual
    if (!showAllEdges)   drawD(); 
    else  drawAllGeodesicTrianglesEta();
  }
  
}

*/
}


void strokefill(int r, int g, int b)
{
  stroke(r, g, b); 
  fill(r, g, b);
}

//
// draw the 6 edges of a geodesic triangle



void  drawAllQuadrangleTheta()
{
  //println("draw all quadrangle edges");
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

  strokefill(255, 0, 0);
  MyLine(bbTheta, p[0], p[1], q[0], q[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic(p[0], p[1], q[0], q[1] );

  strokefill(255, 0, 0);  
  MyLine(bbTheta, q[0], q[1], r[0], r[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic(q[0], q[1], r[0], r[1]  );

  strokefill(255, 0, 0); 
  MyLine(bbTheta, r[0], r[1], s[0], s[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic( r[0], r[1], s[0], s[1]  );

  strokefill(255, 0, 0); 
  MyLine(bbTheta, s[0], s[1], p[0], p[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic( s[0], s[1], p[0], p[1]  );




  strokefill(0, 0, 0);

  ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), ptsize, ptsize);
  ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), ptsize, ptsize);
  ellipse((float)bbTheta.x2X(r[0]), (float)bbTheta.y2Y(r[1]), ptsize, ptsize);
   ellipse((float)bbTheta.x2X(s[0]), (float)bbTheta.y2Y(s[1]), ptsize, ptsize);
}


void drawAllGeodesicTrianglesTheta()
{
  println("draw all edges");
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

  strokefill(255, 0, 0);
  MyLine(bbTheta, p[0], p[1], q[0], q[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic(p[0], p[1], q[0], q[1] );

  strokefill(255, 0, 0);  
  MyLine(bbTheta, q[0], q[1], r[0], r[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic(q[0], q[1], r[0], r[1]  );

  strokefill(255, 0, 0); 
  MyLine(bbTheta, r[0], r[1], p[0], p[1]  );
  strokefill(0, 0, 255); 
  drawThetaEtaGeodesic( r[0], r[1], p[0], p[1]  );

  strokefill(0, 0, 0);

  ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), ptsize, ptsize);
  ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), ptsize, ptsize);
  ellipse((float)bbTheta.x2X(r[0]), (float)bbTheta.y2Y(r[1]), ptsize, ptsize);
}



 
void drawAllQuadrangleEta()
{
  println("draw all edges");
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

// pq
    strokefill(0, 0, 255); 
  MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1])  );
strokefill(255, 0, 0);
  drawEtaThetaGeodesic(gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1]) );

//qr
  strokefill(0, 0, 255); 
  MyLine(bbEta, gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  );
   strokefill(255, 0, 0);  
  drawEtaThetaGeodesic(gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  );

//rp
 strokefill(0, 0, 255);  
  MyLine(bbEta, gradF(r[0]), gradF(r[1]), gradF(s[0]), gradF(s[1])  );
  strokefill(255, 0, 0); 
  drawEtaThetaGeodesic( gradF(r[0]), gradF(r[1]), gradF(s[0]), gradF(s[1]) );


 strokefill(0, 0, 255);  
  MyLine(bbEta, gradF(s[0]), gradF(s[1]), gradF(p[0]), gradF(p[1])  );
  strokefill(255, 0, 0); 
  drawEtaThetaGeodesic( gradF(s[0]), gradF(s[1]), gradF(p[0]), gradF(p[1]) );
  
  
  strokefill(0, 0, 0);

  ellipse((float)bbEta.x2X(gradF(p[0])), (float)bbEta.y2Y(gradF(p[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(q[0])), (float)bbEta.y2Y(gradF(q[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(r[0])), (float)bbEta.y2Y(gradF(r[1])), ptsize, ptsize);
   ellipse((float)bbEta.x2X(gradF(s[0])), (float)bbEta.y2Y(gradF(s[1])), ptsize, ptsize);
}




void drawAllGeodesicTrianglesEta()
{
  println("draw all edges");
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

// pq
    strokefill(0, 0, 255); 
  MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1])  );
strokefill(255, 0, 0);
  drawEtaThetaGeodesic(gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1]) );

//qr
  strokefill(0, 0, 255); 
  MyLine(bbEta, gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  );
   strokefill(255, 0, 0);  
  drawEtaThetaGeodesic(gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  );

//rp
 strokefill(0, 0, 255);  
  MyLine(bbEta, gradF(r[0]), gradF(r[1]), gradF(p[0]), gradF(p[1])  );
  strokefill(255, 0, 0); 
  drawEtaThetaGeodesic( gradF(r[0]), gradF(r[1]), gradF(p[0]), gradF(p[1]) );

  strokefill(0, 0, 0);

  ellipse((float)bbEta.x2X(gradF(p[0])), (float)bbEta.y2Y(gradF(p[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(q[0])), (float)bbEta.y2Y(gradF(q[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(r[0])), (float)bbEta.y2Y(gradF(r[1])), ptsize, ptsize);
}



void drawPCoordinateLines()
{
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;
  double ttheta;
  
       strokefill(128,128,128);
       
   for(  ttheta=minyTheta;ttheta<=maxyTheta; ttheta+=deltayTheta)
   {
    MyLine(bbTheta, minxTheta, ttheta,maxxTheta, ttheta  );
   }
   for( ttheta=minxTheta;ttheta<=maxxTheta; ttheta+=deltaxTheta)
   {
    MyLine(bbTheta, ttheta, minyTheta, ttheta,maxyTheta  );
   }
  
   /*
 
   double sx=0.5*(minxTheta+maxxTheta);
   double sy=0.5*(minyTheta+maxyTheta);
   double step=0.1;
   
   strokefill(128,128,128);
   MyLine(bbTheta, sx,sy , sx+step, sy  );
    MyLine(bbTheta, sx,sy , sx, sy+step  );
    
    
     strokefill(0,0,255);
   MyLine(bbTheta, sx,sy , sx+step, sy  );
    MyLine(bbTheta, sx,sy , sx, sy+step  );
    */
   
   /*
   double eta;
     strokefill(0, 0, 200);
     
   for(  eta=minyEta;eta<=maxyEta; eta+=deltayEta)
   {
    drawThetaEtaGeodesic(gradF(minxEta), gradF(eta), gradF(maxxEta), gradF(eta)  );
    //println(".");
   }
   for(  eta=minyEta;eta<=maxyEta; eta+=deltayEta)
   {
   drawThetaEtaGeodesic(gradF(eta), gradF(minyEta), gradF(eta), gradF(maxyEta) );
   }
   */
   
    strokefill(0, 0, 255); 
    
 
   
}

//
// Draw in primal coordinate system
//
void drawP()
{
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;
  
  if (displaybb){
  textSize(20);
  strokefill(color(0, 0, 0));
  text("Primal theta-coordinate system", 2, side-15);
  text(info(bbTheta), 2, side-35);
  // println(info(bbTheta));
  }
  
//drawPCoordinateLines();

  if (edgetype[0]==EDGETYPE.PRIMAL) {  
    strokefill(255, 0, 0);
    MyLine(bbTheta, p[0], p[1], q[0], q[1]  );
  } else { 
    strokefill(0, 0, 255); 
    drawThetaEtaGeodesic(p[0], p[1], q[0], q[1] );
  }



  if (edgetype[1]==EDGETYPE.PRIMAL) {
    strokefill(255, 0, 0);  
    MyLine(bbTheta, q[0], q[1], r[0], r[1]  );
  } else
  { 
    strokefill(0, 0, 255); 
    drawThetaEtaGeodesic(q[0], q[1], r[0], r[1]  );
  }

  if (edgetype[2]==EDGETYPE.PRIMAL) { 
    strokefill(255, 0, 0); 
    MyLine(bbTheta, r[0], r[1], p[0], p[1]  );
  } else
  { 
    strokefill(0, 0, 255); 
    drawThetaEtaGeodesic( r[0], r[1], p[0], p[1]  );
  }

  strokefill(0, 0, 0);

  ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), ptsize, ptsize);
  ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), ptsize, ptsize);
  
 
  ellipse((float)bbTheta.x2X(r[0]), (float)bbTheta.y2Y(r[1]), 2*ptsize, 2*ptsize);

/*
double etapqx=etap[0]-etaq[0];
double etapqy=etap[1]-etaq[1];
double thetaqx=q[0];
double thetaqy=q[1];

double thetapqx=thetap[0]-thetaq[0];
double thetapqy=thetap[1]-thetaq[1];

double thetary1=(etapqx*thetaqx+etapqy*thetaqy-etapqx*minxTheta)/etapqy;
double thetary2=(etapqx*thetaqx+etapqy*thetaqy-etapqx*maxxTheta)/etapqy;

strokefill(0, 255, 0); 
MyLine(bbTheta, minxTheta, thetary1, maxxTheta, thetary2  );
*/
  // drawThetaEtaGeodesic(gradG(p[0]), gradG(p[1]), gradG(r[0]), gradG(r[1]  ));
}


// Draw in primal theta coordinates the dually right-angle geodesic triangle
void drawPOrthogonal()
{
  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;
  
  if (displaybb){
  textSize(20);
  strokefill(color(0, 0, 0));
  text("Primal theta-coordinate system", 2, side-15);
  text(info(bbTheta), 2, side-35);
  // println(info(bbTheta));
  }

strokeWeight(3);

/* very good
p:1.0741352824135721 1.8178393301643436
q:1.3756917263446562 1.0110204671860323
r:0.30265205434525744 0.5122006666679936
*/

double etapqx=etap[0]-etaq[0];
double etapqy=etap[1]-etaq[1];


double thetaqx=q[0];
double thetaqy=q[1];

double etaqx=etaq[0];
double etaqy=etaq[1];


double thetapqx=thetap[0]-thetaq[0];
double thetapqy=thetap[1]-thetaq[1];


double thetary1=(etapqx*thetaqx+etapqy*thetaqy-etapqx*minxTheta)/etapqy;
double thetary2=(etapqx*thetaqx+etapqy*thetaqy-etapqx*maxxTheta)/etapqy;

strokefill(128,128,128); 
MyLine(bbTheta, minxTheta, thetary1, maxxTheta, thetary2  );

double etary1=(thetapqx*etaqx+thetapqy*etaqy-thetapqx*minxEta)/thetapqy;
double etary2=(thetapqx*etaqx+thetapqy*etaqy-thetapqx*maxxEta)/thetapqy;

 strokefill(128, 128, 128); 
    drawThetaEtaGeodesic(gradF(minxEta), gradF(etary1),  gradF(maxxEta), gradF(etary2)  );


// draw 4 edges
strokeWeight(1);
  
    strokefill(255, 0, 0);
    MyLine(bbTheta, p[0], p[1], q[0], q[1]  );
  
    strokefill(0, 0, 255); 
    drawThetaEtaGeodesic(p[0], p[1], q[0], q[1] );
   



  
    strokefill(255, 0, 0);  
    MyLine(bbTheta, q[0], q[1], r[0], r[1]  );
  
    strokefill(0, 0, 255); 
    drawThetaEtaGeodesic(q[0], q[1], r[0], r[1]  );
 

  

  strokefill(0, 255, 0);

  ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), ptsize, ptsize);
  
   strokefill(255, 0, 255); 
  ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), ptsize, ptsize);
  
  strokefill(0, 0, 0);
  ellipse((float)bbTheta.x2X(r[0]), (float)bbTheta.y2Y(r[1]), 2*ptsize, 2*ptsize);



  // drawThetaEtaGeodesic(gradG(p[0]), gradG(p[1]), gradG(r[0]), gradG(r[1]  ));
}

// Draw in the dual
void drawD()
{ /*
background(255, 255, 255);
 strokeWeight(1);
 if (p==null) return;
 
 */

  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

if (displaybb){
  strokefill(color(0, 0, 0));
  textSize(20);
  strokefill(color(0, 0, 0));
  text("Dual eta-coordinate system", 2, side-15);
  text(info(bbEta), 2, side-35);
}

  if (edgetype[0]==EDGETYPE.PRIMAL) {  
    strokefill(255, 0, 0);
    drawEtaThetaGeodesic(gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1]) );
  } else { 
    strokefill(0, 0, 255); // blue are straight
    MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1])  );
  }



  if (edgetype[1]==EDGETYPE.PRIMAL) {
    strokefill(255, 0, 0);  
    drawEtaThetaGeodesic(gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  ) ;
  } else
  { 
    strokefill(0, 0, 255);    
    MyLine(bbEta, gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1]  ));
  }

  if (edgetype[2]==EDGETYPE.PRIMAL) { 
    strokefill(255, 0, 0);  
    drawEtaThetaGeodesic( gradF(r[0]), gradF(r[1]), gradF(p[0]), gradF(p[1])  );
  } else
  { 
    strokefill(0, 0, 255);
  MyLine(bbEta, gradF(r[0]), gradF(r[1]), gradF(p[0]), gradF(p[1])  );
  strokefill(0, 0, 0);
  }
strokefill(0,0,0);

  ellipse((float)bbEta.x2X(gradF(p[0])), (float)bbEta.y2Y(gradF(p[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(q[0])), (float)bbEta.y2Y(gradF(q[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(r[0])), (float)bbEta.y2Y(gradF(r[1])), 2*ptsize, 2*ptsize);


  /*
 
   
   if (edgetype[0]==EDGETYPE.PRIMAL) {  strokefill(255,0,0);MyLine(bbTheta, p[0], p[1], q[0],q[1]  );}
   else  { strokefill(0,0,255); drawThetaEtaGeodesic(p[0], p[1], q[0],q[1] );}
   
   
   
   if (edgetype[1]==EDGETYPE.PRIMAL)  {strokefill(255,0,0);  MyLine(bbTheta, q[0], q[1], r[0],r[1]  );}
   else
   { strokefill(0,0,255); drawThetaEtaGeodesic(q[0], q[1], r[0],r[1]  );}
   
   if (edgetype[2]==EDGETYPE.PRIMAL)  { strokefill(255,0,0); MyLine(bbTheta, r[0], r[1], p[0],p[1]  );}
   else
   { strokefill(0,0,255); drawThetaEtaGeodesic( r[0], r[1], p[0],p[1]  );}
   
   strokefill(0,0,0);
   
   ellipse((float)bbTheta.x2X(p[0]), (float)bbTheta.y2Y(p[1]), ptsize,ptsize);
   ellipse((float)bbTheta.x2X(q[0]), (float)bbTheta.y2Y(q[1]), ptsize,ptsize);
   ellipse((float)bbTheta.x2X(r[0]), (float)bbTheta.y2Y(r[1]), ptsize,ptsize);
   
   */
}




void drawDOrthogonal()
{ /*
background(255, 255, 255);
 strokeWeight(1);
 if (p==null) return;
 
 */

  background(255, 255, 255);
  strokeWeight(1);
  if (p==null) return;

if (displaybb){
  strokefill(color(0, 0, 0));
  textSize(20);
  strokefill(color(0, 0, 0));
  text("Dual eta-coordinate system", 2, side-15);
  text(info(bbEta), 2, side-35);
}

   
    strokefill(255, 0, 0);
    drawEtaThetaGeodesic(gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1]) );
   
    strokefill(0, 0, 255); // blue are straight
    MyLine(bbEta, gradF(p[0]), gradF(p[1]), gradF(q[0]), gradF(q[1])  );
   



   
    strokefill(255, 0, 0);  
    drawEtaThetaGeodesic(gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1])  ) ;
   
    strokefill(0, 0, 255);    
    MyLine(bbEta, gradF(q[0]), gradF(q[1]), gradF(r[0]), gradF(r[1]  ));
   

 
strokefill(0,0,0);

  ellipse((float)bbEta.x2X(gradF(p[0])), (float)bbEta.y2Y(gradF(p[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(q[0])), (float)bbEta.y2Y(gradF(q[1])), ptsize, ptsize);
  ellipse((float)bbEta.x2X(gradF(r[0])), (float)bbEta.y2Y(gradF(r[1])), ptsize, ptsize);


  
double etapqx=etap[0]-etaq[0];
double etapqy=etap[1]-etaq[1];


double thetaqx=q[0];
double thetaqy=q[1];

double etaqx=etaq[0];
double etaqy=etaq[1];


double thetapqx=thetap[0]-thetaq[0];
double thetapqy=thetap[1]-thetaq[1];


double thetary1=(etapqx*thetaqx+etapqy*thetaqy-etapqx*minxTheta)/etapqy;
double thetary2=(etapqx*thetaqx+etapqy*thetaqy-etapqx*maxxTheta)/etapqy;

strokefill(0,0,0); 
//MyLine(bbTheta, minxTheta, thetary1, maxxTheta, thetary2  );

double etary1=(thetapqx*etaqx+thetapqy*etaqy-thetapqx*minxEta)/thetapqy;
double etary2=(thetapqx*etaqx+thetapqy*etaqy-thetapqx*maxxEta)/thetapqy;

 strokefill(128, 128, 128); 
    MyLine(bbEta,minxEta, etary1,  maxxEta, etary2  );



}




public String info(BB bb)
{ 
  return "Bounding box:"+nf((float)bb.minx, 1, 1)+" "+nf((float)bb.maxy, 1, 1)+" "+nf((float)bb.miny, 1, 1)+" "+nf((float)bb.maxy, 1, 1);
}


// Draw in moment coordinate system






double sqr(double x) {
  return x*x;
}

// e-affine geodesic inme-coordinate system
void drawEtaThetaGeodesic(double x1, double y1, double x2, double y2)
{
  int i;
  double xx, yy, xxx, yyy, l, ll;
  double ex1, ex2, ey1, ey2;

  ex1=gradG(x1);
  ey1=gradG(y1);

  ex2=gradG(x2);
  ey2=gradG(y2);

  for (i=0; i<nbsteps; i++)
  {
    l=i/(double)(nbsteps);
    ll=(i+1)/(double)(nbsteps);

    xx=gradF((1-l)*ex1+l*ex2);
    yy=gradF((1-l)*ey1+l*ey2);

    xxx=gradF((1-ll)*ex1+ll*ex2);
    yyy=gradF((1-ll)*ey1+ll*ey2);

    MyLine(bbEta, xx, yy, xxx, yyy);
  }
}

// Status: checked
// m-affine geodesic in e-coordinate system
void drawThetaEtaGeodesic(double x1, double y1, double x2, double y2)
{
  int i;
  double xx, yy, xxx, yyy, l, ll;
  double ex1, ex2, ey1, ey2;

  ex1=gradF(x1);
  ey1=gradF(y1);

  ex2=gradF(x2);
  ey2=gradF(y2);

  for (i=0; i<nbsteps; i++)
  {
    l=i/(double)(nbsteps);
    ll=(i+1)/(double)(nbsteps);

    xx=gradG((1-l)*ex1+l*ex2);
    yy=gradG((1-l)*ey1+l*ey2);

    xxx=gradG((1-ll)*ex1+ll*ex2);
    yyy=gradG((1-ll)*ey1+ll*ey2);
// raster small portion
    MyLine(bbTheta, xx, yy, xxx, yyy);
  }
}


void RandomPoints()
{
  int i;

  pointP=new double[n][2];
  weight=new double[n];

  for (  i = 0; i < n; i++) {

    // Draw points at random inside domain
    pointP[i][0]=minxTheta+(maxxTheta-minxTheta)*Math.random();
    pointP[i][1]=minyTheta+(maxyTheta-minyTheta)*Math.random();

    weight[i]=0;
  }
}

//
// Initialization procedure: compute dually affine Voronoi diagrams
//

void initialize()
{
  int i;


 initializePoints();
  // separable div
 // minyTheta=minxTheta;
  //maxyTheta=maxxTheta;

  bbTheta=new BB(minxTheta, maxxTheta, minyTheta, maxyTheta, side, side);

  minxEta=gradF(minxTheta);
  minyEta=gradF(minyTheta);
  maxxEta=gradF(maxxTheta);
  maxyEta=gradF(maxyTheta);

  bbEta=new BB(minxEta, maxxEta, minyEta, maxyEta, side, side);

 
}


void initializeold()
{
  int i;

  // primal diagram  
  diagramP = new PowerDiagram();
  sitesP = new OpenList();

  // dual diagram
  diagramD = new PowerDiagram();
  sitesD = new OpenList();

  // separable div
  minyTheta=minxTheta;
  maxyTheta=maxxTheta;

  bbTheta=new BB(minxTheta, maxxTheta, minyTheta, maxyTheta, side, side);

  minxEta=gradF(minxTheta);
  minyEta=gradF(minyTheta);
  maxxEta=gradF(maxxTheta);
  maxyEta=gradF(maxyTheta);

  bbEta=new BB(minxEta, maxxEta, minyEta, maxyEta, side, side);


  rootPolygonP = new PolygonSimple();
  rootPolygonD = new PolygonSimple();

  // to avoid bugs in PD.jar, large bounding boxes...
  rootPolygonP.add(clipm, clipm);
  rootPolygonP.add(clipM, clipm);
  rootPolygonP.add(clipM, clipM);
  rootPolygonP.add(clipm, clipM);

  /*
rootPolygonD.add(bbEta.minx, bbEta.miny);
   rootPolygonD.add(bbEta.maxx, bbEta.miny);
   rootPolygonD.add(bbEta.maxx, bbEta.maxy);
   rootPolygonD.add(bbEta.minx, bbEta.maxy);
   */

  rootPolygonD.add(eclipm, eclipm );
  rootPolygonD.add(eclipM, eclipm);
  rootPolygonD.add(eclipM, eclipM);
  rootPolygonD.add(eclipm, eclipM);

  // primal Voronoi diagram and equivalent affine power diagram

  PDP=new double[n][2];
  weightP=new double[n];

  // dual Voronoi diagram and equivalent affine power diagram
  pointD=new double[n][2];
  PDD=new double[n][2];
  weightD=new double[n];


  weight=new double[n];

  for (  i = 0; i < n; i++) {

    weight[i]=0.0;

    // equivalent primal power diagram
    PDP[i][0]=gradF(pointP[i][0]);
    PDP[i][1]=gradF(pointP[i][1]);

    // see formula from http://arxiv.org/abs/0709.2196
    weightP[i]=sqr(gradF(pointP[i][0]))+sqr(gradF(pointP[i][1]))
      +  2* ( F(pointP[i][0])+F(pointP[i][1])
      -gradF(pointP[i][0])*pointP[i][0]-gradF(pointP[i][1])*pointP[i][1] )
      -weight[i]
      ;


    // equivalent dual power diagram
    // convert in eta coordinate system
    pointD[i][0]=gradF(pointP[i][0]);
    pointD[i][1]=gradF(pointP[i][1]);

    PDD[i][0]=gradG(pointD[i][0]); // we  find pointP
    PDD[i][1]=gradG(pointD[i][1]);

    weightD[i]= sqr(gradG(pointD[i][0]))+sqr(gradG(pointD[i][1]))+
      2*(G(pointD[i][0])+G(pointD[i][1])-pointD[i][0]*gradG(pointD[i][0])
      -gradG(pointD[i][1])*pointD[i][1] )-weight[i];


    // primal Voronoi diagram
    Site site = new Site(PDP[i][0], PDP[i][1] );
    site.setWeight(weightP[i]);
    sitesP.add(site);

    // dual Voronoi diagram
    Site siteD = new Site(PDD[i][0], PDD[i][1] );
    siteD.setWeight(weightD[i]);
    sitesD.add(siteD);
  }

  double constant;
  // ensure all weights are positive so that PD.jar works well
  constant=weightP[0];
  for (  i = 1; i < n; i++) { // get min   
    if (weightP[i]<constant) constant=weightP[i];
  }

  for (  i = 0; i < n; i++) { 
    weightP[i]=weightP[i]-constant;
  }

  constant=weightD[0];
  for (  i = 1; i < n; i++) {    
    if (weightD[i]<constant) constant=weightD[i];
  }
  for (  i = 0; i < n; i++) { 

    weightD[i]=weightD[i]-constant;
  }


  diagramP.setSites(sitesP);
  diagramP.setClipPoly(rootPolygonP);
  diagramP.computeDiagram();

  diagramD.setSites(sitesD);
  diagramD.setClipPoly(rootPolygonD);
  diagramD.computeDiagram();
}



//// array of x y w
void initialize(double [][] pts)
{
  int i;


  // primal diagram  
  diagramP = new PowerDiagram();
  sitesP = new OpenList();

  // dual diagram
  diagramD = new PowerDiagram();
  sitesD = new OpenList();


  rootPolygonP = new PolygonSimple();
  rootPolygonD = new PolygonSimple();


  // to avoid bugs in PD.jar, large bounding box...
  rootPolygonP.add(clipm, clipm);
  rootPolygonP.add(clipM, clipm);
  rootPolygonP.add(clipM, clipM);
  rootPolygonP.add(clipm, clipM);



  rootPolygonD.add(eclipm, eclipm );
  rootPolygonD.add(eclipM, eclipm);
  rootPolygonD.add(eclipM, eclipM);
  rootPolygonD.add(eclipm, eclipM);

  // primal Voronoi diagram and equivalent affine power diagram

  PDP=new double[n][2];
  weightP=new double[n];

  // dual Voronoi diagram and equivalent affine power diagram
  pointD=new double[n][2];
  PDD=new double[n][2];
  weightD=new double[n];


  weight=new double[n];

  for (  i = 0; i < n; i++) {


    pointP[i][0]=pts[i][0];
    pointP[i][1]=pts[i][1];
    weight[i]=pts[i][2];


    // equivalent primal power diagram
    PDP[i][0]=gradF(pointP[i][0]);
    PDP[i][1]=gradF(pointP[i][1]);

    //
    weightP[i]=sqr(gradF(pointP[i][0]))+sqr(gradF(pointP[i][1]))
      +  2* ( F(pointP[i][0])+F(pointP[i][1])
      -gradF(pointP[i][0])*pointP[i][0]-gradF(pointP[i][1])*pointP[i][1] )
      -weight[i]
      ;


    // equivalent dual power diagram
    // convert in eta coordinate system
    pointD[i][0]=gradF(pointP[i][0]);
    pointD[i][1]=gradF(pointP[i][1]);

    PDD[i][0]=gradG(pointD[i][0]); // we  find pointP
    PDD[i][1]=gradG(pointD[i][1]);

    weightD[i]= sqr(gradG(pointD[i][0]))+sqr(gradG(pointD[i][1]))+
      2*(G(pointD[i][0])+G(pointD[i][1])-pointD[i][0]*gradG(pointD[i][0])
      -gradG(pointD[i][1])*pointD[i][1] )-weight[i];


    // primal Voronoi diagram
    Site site = new Site(PDP[i][0], PDP[i][1] );
    site.setWeight(weightP[i]);
    sitesP.add(site);

    // dual Voronoi diagram
    Site siteD = new Site(PDD[i][0], PDD[i][1] );
    siteD.setWeight(weightD[i]);
    sitesD.add(siteD);
  }

  double constant;
  // ensure all weights are positive
  constant=weightP[0];
  for (  i = 1; i < n; i++) {    
    if (weightP[i]<constant) constant=weightP[i];
  }
  for (  i = 0; i < n; i++) { 

    weightP[i]=weightP[i]-constant;
  }

  constant=weightD[0];
  for (  i = 1; i < n; i++) {    
    if (weightD[i]<constant) constant=weightD[i];
  }
  for (  i = 0; i < n; i++) { 

    weightD[i]=weightD[i]-constant;
  }


  diagramP.setSites(sitesP);
  diagramP.setClipPoly(rootPolygonP);
  diagramP.computeDiagram();

  diagramD.setSites(sitesD);
  diagramD.setClipPoly(rootPolygonD);
  diagramD.computeDiagram();
}
////


String divname()
{
  if (type==TYPE.SQREUCLIDEAN)  return "squared Euclidean";
  if (type==TYPE.EXP)  return "exponential";
  if (type==TYPE.LOGISTIC)  return "logistic";
  if (type==TYPE.ITAKURASAITO)  return "Itakura-Saito";
  if (type==TYPE.KLE)  return "extended Kullback-Leibler";
  if (type==TYPE.HELLINGER)  return "Hellinger type";

  return "unknown (bug!)";
}


TYPE divname2type(String s)
{
  if  (s.equals("squared Euclidean")== true)   return TYPE.SQREUCLIDEAN;
  if (s.equals("exponential")== true)   return TYPE.EXP ;
  if (s.equals("logistic") == true) return TYPE.LOGISTIC;
  if (s.equals("Itakura-Saito")== true) return TYPE.ITAKURASAITO;
  if (s.equals("extended Kullback-Leibler")== true) return TYPE.KLE;
  if (s.equals("Hellinger type")== true) return TYPE.HELLINGER;
  else  return TYPE.SQREUCLIDEAN;
}

void allPTmovie()
{
  double framestep=1.0/(5*60.0);
  ii=0;
  for(alphapt=0.0;alphapt<=1.0;alphapt+=framestep)
  {
    draw();
    String framenbs=nf((int)ii,4);
 save("PT/PT-"+framenbs+".png"); ii++;
  }
  
  println("completed PT movie");
  
}

void keyPressed()
{
  if (key=='q') exit();
  
  if (key=='.') { println("ALL PT movie"); allPTmovie();}
  
    if (key=='o') {sampleOrthogonal=!sampleOrthogonal;initializePoints();initialize();draw();}
    
     if (key=='a')  {showAllEdges=!showAllEdges;draw();}
   
      if (key=='c') {
    calculateAngle();
  }
  
    
  if (key==' ') {
    RandomPoints();
    initialize(); 
    draw();
  }

  if (key=='p') {
    showPrimalV=!showPrimalV; 
    draw();
  }
  if (key=='d') {
    showDualV=!showDualV; 
    draw();
  }

  if (key=='t') {
    showTheta=true; 
    showEta=false;
    draw();
  }

  if (key=='e') {
    showTheta=false; 
    showEta=true;
    draw();
  }

  // for Laguerre
  if (key=='l') {
    showPD=!showPD;
    draw();
  }

  if (key=='x') savepdffile();
  
  if (key=='s') savesvgfile();

  if (key=='g') savePts();

  if (key=='j') loadPts("BregmanGeneratorPts.txt");

  //SQREUCLIDEAN, EXP, LOGISTIC, ITAKURASAITO, KLE, HELLINGER
  if (key=='1') {
    type=TYPE.SQREUCLIDEAN;
    initialize(); 
    draw();
  }

  if (key=='2') {
    minxTheta=1;
    maxxTheta=2;

    clipm=-5;
    clipM=10;
    eclipm=0;
    eclipM=10;
    RandomPoints();
    type=TYPE.EXP;
    initialize(); 
    draw();
  }


  if (key=='3') {
    type=TYPE.LOGISTIC;
    initialize(); 
    draw();
  }



  if (key=='4') {   // Itakura-Saito
    minxTheta=0.1;
    maxxTheta=0.9;
    minyTheta=minxTheta;
    maxyTheta=maxxTheta;
    type=TYPE.ITAKURASAITO;
    initialize(); 
    draw();
  }


  if (key=='5') {
    minxTheta=0.1;
    maxxTheta=3;
    minyTheta=minxTheta;
    maxyTheta=maxxTheta;
    type=TYPE.KLE;
    initialize(); 
    draw();
  }


  if (key=='6') {
    minxTheta=0.1;
    maxxTheta=0.6;
    minyTheta=minxTheta;
    maxyTheta=maxxTheta;

    type=TYPE.HELLINGER;
    initialize(); 
    draw();
  }


  if (key=='/') {
    showAllEdges=false;
    showTheta=true;
    showEta=false;

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/1-theta-ppp");


    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/2-theta-ppd");

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/3-theta-pdd");

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/4-theta-pdp");


    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/5-theta-dpp");


    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/6-theta-dpd");

    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/7-theta-ddp");

    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/8-theta-ddd");

    //dual
    showTheta=false;
    showEta=true;

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/1-eta-ppp");


    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/2-eta-ppd");

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/3-eta-pdd");

    edgetype[0]=EDGETYPE.PRIMAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/4-eta-pdp");


    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/5-eta-dpp");


    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.PRIMAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/6-eta-dpd");

    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.PRIMAL;
    draw();
    savepdffile("export/7-eta-ddp");

    edgetype[0]=EDGETYPE.DUAL; 
    edgetype[1]=EDGETYPE.DUAL; 
    edgetype[2]=EDGETYPE.DUAL;
    draw();
    savepdffile("export/8-eta-ddd");

    showAllEdges=true; 
    // 6 edges
    beginRecord(PDF, "export/allgeodesicedges-theta.pdf");
    drawAllGeodesicTrianglesTheta();
    save("export/allgeodesicedges-theta.png");
      beginRecord(PDF, "export/allgeodesicedges-theta.pdf");
              drawAllGeodesicTrianglesTheta();
    addSignature();
    //savepdffile("export/allgeodesicedges-eta");
      endRecord();
    //savepdffile("export/allgeodesicedges-theta");


    drawAllGeodesicTrianglesEta();
    save("export/allgeodesicedges-eta.png");
    
    beginRecord(PDF, "export/allgeodesicedges-eta.pdf");
       drawAllGeodesicTrianglesEta();
    addSignature();
    //savepdffile("export/allgeodesicedges-eta");
      endRecord();
  }
}

void savepdffile(String suffix)
{

  beginRecord(PDF, suffix+".pdf");

  addSignature();
  draw();

  //save( "t-"+suffix+".png");
  endRecord();
}

void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  

  beginRecord(PDF, ""+suffix+".pdf");

  addSignature();
  draw();

  save(""+suffix+".png");
  endRecord();
}

//  beginRecord(SVG, "C:\\Travail\\image.svg");

void savesvgfile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  

  beginRecord(SVG, "VD-"+suffix+".svg");



  draw();


  endRecord();
}

void addSignature()
{
  textSize(1);
  strokefill(color(255, 255, 254));
  text("(C) 2019 Frank Nielsen. All rights reserved.", 2, side-2);
}

void strokefill(color cc)
{  
  stroke(cc);
  fill(cc);
}




// Bregman generator

// {SQREUCLIDEAN, EXP, LOGISTIC, ITAKURASAITO, KLE, HELLINGER};


double F(double x)
{
  
  if (type==TYPE.CUBIC)
    return x*x*x*x;
    
    
  if (type==TYPE.SQREUCLIDEAN)
    return 0.5*x*x;

  if (type==TYPE.EXP)
    return Math.exp(x);


  if (type==TYPE.LOGISTIC)
    return x*Math.log(x)+(1-x)*Math.log(1-x);

  if (type==TYPE.HELLINGER)
    return -Math.sqrt(1-x*x);


  if (type==TYPE.KLE)
  {
    return x*Math.log(x)-x;
  }

  if (type==TYPE.ITAKURASAITO)
    return -Math.log(x);

  return 0.5*x*x;
}

// Gradient of Bregman generator
double gradF(double x)
{
  
  if (type==TYPE.CUBIC)
    return 0.5*x*x;
    
    
  if (type==TYPE.SQREUCLIDEAN)
    return x;

  if (type==TYPE.EXP)
    return Math.exp(x);

  if (type==TYPE.KLE)
  {
    return Math.log(x);
  }

  if (type==TYPE.ITAKURASAITO)
    return -1.0/x;

  if (type==TYPE.LOGISTIC)
    return Math.log(x)-Math.log(1-x);

  if (type==TYPE.HELLINGER)
    return -x/Math.sqrt(1-x*x);

  return x;
}
// to complete
double hessF(double x) {
  if (type==TYPE.ITAKURASAITO) return 1.0/(x*x); 
  else if (type==TYPE.KLE) return 1.0/(x);  else {println("Not implemented!");return -1;}
}
double hessG(double x) {
  if (type==TYPE.ITAKURASAITO) return 1.0/(x*x); 
  else if (type==TYPE.KLE) return 1.0/Math.exp(x);  else {println("Not implemented!");return -1;}
}

// reciprocal gradients
double gradG(double x)
{
  if (type==TYPE.SQREUCLIDEAN)
    return x;

  if (type==TYPE.EXP)
    return Math.log(x);

  if (type==TYPE.KLE)
  {
    return Math.exp(x);
  }

  if (type==TYPE.ITAKURASAITO)
    return -1.0/x;

  if (type==TYPE.LOGISTIC)
    return Math.exp(x)/(1+Math.exp(x));

  if (type==TYPE.HELLINGER)
    return x/Math.sqrt(1+x*x);

  return x;
}


double G(double x)
{
  return x*gradG(x)-F(gradG(x));
}



void savePts()
{
  int i;
  String [] list=new String[n+3];

  list[0]=divname(); 
  list[1]=minxTheta+"\t"+maxxTheta+"\t"+minyTheta+"\t"+maxyTheta;
  list[2]=minxEta+"\t"+maxxEta+"\t"+minyEta+"\t"+maxyEta;

  for (i=0; i<n; i++)
  {
    list[i+3]=pointP[i][0]+"\t"+pointP[i][1]+"\t"+weight[i];
  }

  saveStrings("BregmanGeneratorPts.txt", list);

  list[0]=divname(); 
  list[1]=minxTheta+"\t"+maxxTheta+"\t"+minyTheta+"\t"+maxyTheta;
  list[2]=minxEta+"\t"+maxxEta+"\t"+minyEta+"\t"+maxyEta;

  for (i=0; i<n; i++)
  {
    list[i+3]=pointD[i][0]+"\t"+pointD[i][1]+"\t"+weight[i];
  }

  saveStrings("BregmanDualGeneratorPts.txt", list);

  //
  list[0]=divname()+" primal power diagram equivalent"; 
  list[1]=minxTheta+"\t"+maxxTheta+"\t"+minyTheta+"\t"+maxyTheta;
  list[2]=minxEta+"\t"+maxxEta+"\t"+minyEta+"\t"+maxyEta;

  for (i=0; i<n; i++)
  {
    list[i+3]=PDP[i][0]+"\t"+PDP[i][1]+"\t"+weightP[i];
  }

  saveStrings("equivPrimalPowerDiagramPts.txt", list);

  list[0]=divname()+" dual power diagram equivalent"; 
  list[1]=minxTheta+"\t"+maxxTheta+"\t"+minyTheta+"\t"+maxyTheta;
  list[2]=minxEta+"\t"+maxxEta+"\t"+minyEta+"\t"+maxyEta;

  for (i=0; i<n; i++)
  {
    list[i+3]=PDD[i][0]+"\t"+PDD[i][1]+"\t"+weightD[i];
  }

  saveStrings("equivDualPowerDiagramPts.txt", list);
}


void loadChoosePts() {
  selectInput("Select a file to process:", "" );// "BregmanGeneratorPts.txt"
}


void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("selected file "+selection.getAbsolutePath());
  }
}


void loadPts(String s)
{// n+3 lines


  String lines[] = loadStrings(s);

  type=divname2type(lines[0]);
  String[] bbs = split(lines[1], '\t');
  minxTheta=float(bbs[0]);
  maxxTheta=float(bbs[1]);
  minyTheta=float(bbs[2]);
  maxyTheta=float(bbs[3]);

  bbs = split(lines[2], '\t');
  minxEta=float(bbs[0]);
  maxxEta=float(bbs[1]);
  minyEta=float(bbs[2]);
  maxyEta=float(bbs[3]);



  n=lines.length-3 ;
  double [][] ptset=new double[n][3];

  for (int i = 0; i < n; i++) {

    String[] coord = split(lines[i+3], '\t');
    println("parsing " +i+"  "+ "x=" +coord[0]+" y="+coord[1]+ " w="+coord[2]);


    ptset[i][0]=float(coord[0]);
    ptset[i][1]=float(coord[1]);
    ptset[i][2]=float(coord[2]);
  }

  initialize(ptset);
  draw();
  println(divname());
}
