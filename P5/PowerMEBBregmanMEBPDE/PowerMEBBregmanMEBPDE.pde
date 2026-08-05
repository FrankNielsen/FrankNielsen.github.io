// Frank.Nielsen@acm.org
// July 2026
//
// C:\Travail\GitHub\FrankNielsen.github.io\P5\PowerMEBBregmanMEBPDE

import processing.pdf.*;

int side = 800;
int ww = side;
int hh = side;

double border=0.0;
double delta=0.2;
double minx=-border-delta;
double maxx=1.0+border+ delta;
double miny=-border-delta;
double maxy=1.0+border+delta;

boolean toggleText=true;
boolean toggleAnimation=true;
boolean toggleRectify=false;


int n;
//int nstart=8;
//int nstart=2;
int nstart=8;


double [][] point; // stored 2d coordinates
double [] weight; // weight
float ptsize=3;

color colgen=color(255, 0, 0);
color colVor=color(0, 0, 0);



PowerDiagram diagram;
OpenList sites;
PolygonSimple rootPolygon;




// 2d inner product
public   double inner(double [] pt1, double [] pt2)
{
  return pt1[0]*pt2[0] + pt1[1]*pt2[1];
}


WeightedPoint [] wset;
WeightedPoint PMEB, PMEB2;
int nbiter=1000000;

WeightedPoint BMEB;
double [][] bregset;



public static double[] barycentric(double[][] vertices, double[] x) {

  int d = x.length;
  int n = d + 1;

  double[][] A = new double[n][n];
  double[] b = new double[n];

  // coordinate equations
  for (int i = 0; i < d; i++) {
    for (int j = 0; j < n; j++)
      A[i][j] = vertices[j][i];
    b[i] = x[i];
  }

  // sum lambda_i = 1
  for (int j = 0; j < n; j++)
    A[d][j] = 1.0;
  b[d] = 1.0;

  return gaussianSolve(A, b);
}

private static double[] gaussianSolve(double[][] A, double[] b) {

  int n = b.length;

  // Forward elimination
  for (int p = 0; p < n; p++) {

    int max = p;
    for (int i = p + 1; i < n; i++)
      if (Math.abs(A[i][p]) > Math.abs(A[max][p]))
        max = i;

    double[] temp = A[p];
    A[p] = A[max];
    A[max] = temp;

    double t = b[p];
    b[p] = b[max];
    b[max] = t;

    for (int i = p + 1; i < n; i++) {
      double alpha = A[i][p] / A[p][p];

      b[i] -= alpha * b[p];

      for (int j = p; j < n; j++)
        A[i][j] -= alpha * A[p][j];
    }
  }

  // Back substitution
  double[] x = new double[n];

  for (int i = n - 1; i >= 0; i--) {
    double sum = b[i];
    for (int j = i + 1; j < n; j++)
      sum -= A[i][j] * x[j];
    x[i] = sum / A[i][i];
  }

  return x;
}

  int [] sv;

 int nbsv;
 
void Test()
{
  int i, j, rr;
  n=nstart;
  wset=new WeightedPoint [n];
  for (i=0; i<n; i++) {
    wset[i]=WeightedPoint.Random(2);
    wset[i].w=0;
  }


  PMEB=PowerMEB.PowerMEB(wset, nbiter);

  println("all weights to 0 Sqr radius="+PMEB.w);


 sv=PowerMEB.SupportPoints(wset, PMEB.x, PMEB.w);
  nbsv=sv.length;
  println("#support points:"+sv.length);
  double RR=0;

  if (nbsv==2)
  {

    for (i=0; i<nbsv; i++)
      for (j=0; j<nbsv; j++)
        RR+=PowerMEB.SqrDistance(wset[sv[i]].x, wset[sv[j]].x);


    RR/=8.0;
  }

  if (nbsv==3)
  {
    double [][] vertex=new double [3][2];
 
    for (i=0; i<3; i++)
      for (j=0; j<2; j++) vertex[i][j]=wset[sv[i]].x[j];

    double [] lambda=barycentric( vertex, PMEB.x);

    for (i=0; i<nbsv; i++)
      for (j=0; j<nbsv; j++)
        RR+=lambda[i]*lambda[j]*PowerMEB.SqrDistance(wset[sv[i]].x, wset[sv[j]].x);


    RR/=2.0;
  }


  println("pairwise reconstr RR="+RR);
}



void Welzl()
{double [][] pts=new double[n][3];
int i;
for(i=0;i<n;i++) {pts[i][0]=wset[i].x[0];pts[i][1]=wset[i].x[1];pts[i][2]=wset[i].w;}

 double[] ball=PowerMEBWelzl.powerMiniball(pts); 

System.out.println("Welzl power meb:"+ball[0]+" "+ball[1]+ " w^*="+ball[2]);
}



// Initialize weighted point set
void initializeWS()
{
  n=nstart;

  bregset=new double [n][2];
  int i, j;

  Test();

  /*
  for(i=0;i<n;i++) {wset[i]=WeightedPoint.Random(2);
   for(j=0;j<2;j++) bregset[i][j]=wset[i].x[j];
   //println(wset[i].w);
   }
   */

  for (i=0; i<n; i++) {
    for (j=0; j<2; j++) bregset[i][j]=Math.random();

    wset[i]=new WeightedPoint(2);
    wset[i].x[0]=BregmanMEB.fprime(bregset[i][0]);
    wset[i].x[1]=BregmanMEB.fprime(bregset[i][1]);
    wset[i].w=sqr(wset[i].x[0])+sqr(wset[i].x[1])+2*BregmanMEB.g(wset[i].x[0])+2*BregmanMEB.g(wset[i].x[1]);
    
   // remove later
  // wset[i].w=0;
  wset[i].w=Math.random()*0.02;
  }


// Frank-Wolfe
  PMEB=PowerMEB.PowerMEB(wset, nbiter);
  
  if (n==2){  PMEB2=PowerMEB.ExactPowerMEB2(wset);
println("Exact:"+PMEB2.x[0]+" "+PMEB2.x[1]+ " w="+PMEB2.w);
println("Approximated:"+PMEB.x[0]+" "+PMEB.x[1]+ " w="+PMEB.w);

double distc1=PowerMEB.PowerDistance(wset[0],PMEB2);
double distc2=PowerMEB.PowerDistance(wset[1],PMEB2);

println("PMEB Orthogonal to basis spheres? "+distc1+ " " +distc2);
}
  
  
  BMEB=BregmanMEB.BregmanMEB(bregset, nbiter);
  

  
  
  PowerMEB.CheckBarycentricIdentity(wset,PMEB);
  
}

void setup()
{
  sandbox.Test();
  
  size(800, 800);
  n=nstart;
  initialize();

   initializeWS();
}







void MyLine(double x1, double y1, double x2, double y2)
{
  double x, xx, y, yy;
  line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
}



void MyPoint(double x, double y)
{
  ellipse((float)x2X(x), (float)y2Y(y), ptsize, ptsize);
}

void MyCircle(float xx, float yy, float rr)
{
  int i;
  float theta, theta2;
  double x, y, x2, y2;
  for (i=0; i<100; i++)
  {
    theta=(float)(2.0*Math.PI*i/(float)100);
    theta2=(float)(2.0*Math.PI*(i+1)/(float)100);

    x=(float)(xx+rr*Math.cos(theta));
    y=(float)(yy+rr*Math.sin(theta));

    x2=(float)(xx+rr*Math.cos(theta2));
    y2=(float)(yy+rr*Math.sin(theta2));

    MyLine(x, y, x2, y2);
  }

  // circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
}

boolean supportVector(int label)
{ if (sv==null) return false;
 int i;
 for(i=0;i<nbsv;i++) if (sv[i]==label) return true;
 return false;
}

public static double[] tangentPoint(
        WeightedPoint center, WeightedPoint pp, int side) {
          double[] c=pp.x;
        double r=Math.sqrt(pp.w);
        
        double[] p=center.x;
        
       // println("side="+side);
         
         
         double dx = p[0] - c[0];
    double dy = p[1] - c[1];

    double d2 = dx*dx + dy*dy;

    if (d2 <= r*r)
        return null;   // point is inside/on disk

    double factor1 = r*r / d2;
    double factor2 = side * r * Math.sqrt(d2 - r*r) / d2;

    // perpendicular vector to (dx,dy)
    double px = -dy;
    double py = dx;

    double qx = c[0] + factor1*dx + factor2*px;
    double qy = c[1] + factor1*dy + factor2*py;

    return new double[]{qx, qy};
    
    /*
         
             double dx = p[0] - c[0];
    double dy = p[1] - c[1];

    double d2 = dx*dx + dy*dy;

    if (d2 <= r*r)
        return null;   // point is inside/on disk

    double factor1 = r*r / d2;
    double factor2 = side * r * Math.sqrt(d2 - r*r) / d2;

    // perpendicular vector to (dx,dy)
    double px = -dy;
    double py = dx;

    double qx = c[0] + factor1*dx + factor2*px;
    double qy = c[1] + factor1*dy + factor2*py;
    
         
     
    return new double[]{qx, qy};
    */
}


public static double[] GoodtangentPoint(WeightedPoint center, WeightedPoint pp, int side)
{
          double[] c=pp.x;
        double r=Math.sqrt(pp.w);
        
        double[] p=center.x;
         
             
    double dx = p[0] - c[0];
    double dy = p[1] - c[1];

    double d2 = dx*dx + dy*dy;

    // Point inside or on disk: no proper tangent
    if (d2 <= r*r)
        return null;

    double alpha = r*r / d2;

    double beta =
        side * r * Math.sqrt(d2 - r*r) / d2;

    // perpendicular vector (-dy,dx)
    double qx =
        c[0] + alpha*dx - beta*dy;

    double qy =
        c[1] + alpha*dy + beta*dx;

    return new double[]{qx,qy};
}

boolean toggleSV=false;

// drawgin
void draw()
{

  int i, j, ii, jj;



  surface.setTitle("n="+n);



  background(255, 255, 255);

// Blue circumcenter MEB
  stroke(0, 0, 255);
  MyPoint(PMEB.x[0], PMEB.x[1]);

if (n==2){
  stroke(255, 0, 255);
 // MyPoint(PMEB2.x[0], PMEB2.x[1]);
  MyCircle((float)(PMEB2.x[0]), (float)(PMEB2.x[1]), (float)0.01);
  
 //  MyCircle((float)(PMEB2.x[0]), (float)(PMEB2.x[1]), (float)Math.sqrt(PMEB2.w)+0.01);
  strokeWeight(1);
}


  stroke(0, 0, 0);
  
  if (PMEB.w>0)
   {strokeWeight(5); MyCircle((float)(PMEB.x[0]), (float)(PMEB.x[1]), (float)Math.sqrt(PMEB.w));}

  strokeWeight(2);
  fill(colgen);
  stroke(colgen);

// SV
  for (i=0; i<n; i++) {
    
    
    if (Math.abs(PowerMEB.PowerDistance(PMEB,wset[i]))<1.e-4) {stroke(0,255,0);strokeWeight(3);} else {stroke(120);strokeWeight(1);}
    {}
    
    double[] tp=tangentPoint(PMEB, wset[i],+1);
    if (tp!=null) MyLine((float)(PMEB.x[0]), (float)(PMEB.x[1]),(float)(tp[0]), (float)(tp[1]));
      tp=tangentPoint(PMEB, wset[i],-1);
    if (tp!=null) MyLine((float)(PMEB.x[0]), (float)(PMEB.x[1]),(float)(tp[0]), (float)(tp[1]));
    
    if ((toggleSV)&&(supportVector(i))){strokeWeight(3);
    fill(240);
    stroke(0,255,0);
    //circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
    MyCircle((float)(wset[i].x[0]), (float)(wset[i].x[1]), (float)Math.sqrt(wset[i].w));
    MyCircle((float)(wset[i].x[0]), (float)(wset[i].x[1]), (float)Math.sqrt(wset[i].w)+0.01);

    fill(colgen);
    stroke(colgen);
    MyPoint(wset[i].x[0], wset[i].x[1]);
    //   ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ptsize,ptsize);}
  }
    else
    {//strokeWeight(1);
     //    fill(120);
    //stroke(120);
    //circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
    MyCircle((float)(wset[i].x[0]), (float)(wset[i].x[1]), (float)Math.sqrt(wset[i].w));

    //fill(colgen);
    //stroke(colgen);
    MyPoint(wset[i].x[0], wset[i].x[1]);
    //   ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ptsize,ptsize); 
      strokeWeight(1);
    }
    
  }

if (false){
// Bregman circumcenter green
  stroke(0, 255, 0);
  MyPoint(BMEB.x[0], BMEB.x[1]);
}

}


void drawPD()
{
  int i, j, ii, jj;
  Site site;
  PolygonSimple polygon;

  println("n="+n);
  surface.setTitle("Power diagram n="+n);



  background(255, 255, 255);


  strokeWeight(2);
  fill(colgen);
  stroke(colgen);

  for (i=0; i<n; i++) {
    fill(240);
    stroke(240);
    //circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
    MyCircle((float)(point[i][0]), (float)(point[i][1]), (float)Math.sqrt(weight[i]));

    fill(colgen);
    stroke(colgen);
    MyPoint(point[i][0], point[i][1]);
    //   ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ptsize,ptsize);
  }


  strokeWeight(1);
  stroke(colVor);
  fill(colVor);

  for ( i=0; i<sites.size; i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0; j<polygon.length; j++)
      {// next vertex of the polygon
        jj=(j+1)%polygon.length;
        MyLine( polygon.x[j], polygon.y[j], polygon.x[jj], polygon.y[jj]   );
      }
    }
  }





  float rr;

  strokeWeight(1);
  fill(colgen);
  noFill();

  if (toggleText)
  {
    String msg="PD n="+n;
    textSize(32);
    fill(0, 0, 0);
    stroke(0, 0, 0);
    text(msg, 100, 30);
  }
}

public static double mind(double x, double y)
{
  if (x<y) return x;
  else return y;
}

public static double sqr(double x) {
  return x;
}


void computePD()
{
  int i;
  diagram = new PowerDiagram();
  sites = new OpenList();

  for (i = 0; i < n; i++) {
    Site site = new Site(point[i][0], point[i][1] );
    site.setWeight(weight[i]);
    sites.add(site);
  }
  diagram.setSites(sites);
  diagram.setClipPoly(rootPolygon);
  diagram.computeDiagram();
}

// Initialization procedure
void initialize()
{
  int i;

  point=new double[n][2];
  weight=new double[n];

  for ( i = 0; i < n; i++) {
    point[i][0]=Math.random();
    point[i][1]=Math.random();
    weight[i]=0.1*Math.random();
  }

  rootPolygon = new PolygonSimple();

  rootPolygon.add(minx, miny);
  rootPolygon.add(maxx, miny);
  rootPolygon.add(maxx, maxy);
  rootPolygon.add(miny, maxy);





  computePD();
}



void keyPressed()
{
   if (key=='w') {Welzl();}
  if (key=='q') exit();

  if (key==' ') {
    initialize();
    initializeWS();
    println("Power FW MEB : "+PMEB.x[0]+" "+PMEB.x[1]+" w="+PMEB.w );
    draw();
  }

  if (key=='2') {
    n=2;
    initialize();
    draw();
  }
  
   if (key=='3') {
    nstart=3;
    initialize();  initializeWS();
    draw();
    
  }
  
  if (key=='8') {
    nstart=8;
    initialize();  initializeWS();
    draw();
    
  }

if (key=='>') {nstart+=10;  
    initialize();
    initializeWS();
    draw(); }
    
    
if (key=='<') {nstart=max(8,nstart-10);  
    initialize(); initializeWS();
    draw(); }

if (key=='i')
{int i; for(i=0;i<n;i++) wset[i].w+=0.01;
  computePD();initializeWS();
    draw();
}

  if (key=='n') {
    n=nstart;
    initialize();
    draw();
  }

  if ((key=='p')||(key=='P')) savepdffile();

  if (key=='t') {
    toggleText=!toggleText;
    draw();
  }

  if (key=='a') {
    println("same weights");
    int i;
    for (i=0; i<n; i++) weight[i]=0;
    computePD();
    draw();
  }


  if (key=='e') {
    println("add same weight");
    int i;
    for (i=0; i<n; i++) weight[i]+=0.2;
    computePD();
    draw();
  }
}


public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

public  float X2x(double X)
{
  return (float)(minx+(maxx-minx)*((X)/(float)side));
}



public  float y2Y(double y)
{
  return (float)(side- ((y-miny)*side/(maxy-miny)));
}

public  float Y2y(double Y)
{
  return (float)(miny+(maxy-miny)*((side-Y)/(float)side));
}



void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "BregmanPDMEB-"+n+"-"+suffix+".pdf");


  draw();

  save("BregmanPDMEB-"+n+"-"+suffix+".png");
  endRecord();
}



void strokefill(color cc)
{
  stroke(cc);
  fill(cc);
}
