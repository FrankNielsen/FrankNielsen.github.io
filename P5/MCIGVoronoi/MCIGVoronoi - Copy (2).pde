// Frank.Nielsen@acm.org  
// March 2019
//
// C:\Travail\SVN-Acreuser\____MonteCarloInformationGeometry
//
// Min skeleton program for computing MCIG Voronoi diagrams for a 2D mixture family
// https://arxiv.org/abs/1803.07225
// Monte Carlo Information Geometry: The dually flat case
//
// sample iid s variates from proposal distribution q
// then consider 2-mixture (mixtures of 3 prescribed distributions)


// https://gifmaker.me/


import processing.pdf.*;

int side = 512;
int ww = side;
int hh = side;

double minx=0;
double maxx=1;
double miny=0;
double maxy=1;

boolean toggleText=true;
boolean toggleAnimation=true;

int n;
//int nstart=16;

int nstart=64;

double [][] point; // stored 2d coordinates of 3-mixtures
double [][] Epoint; //equivalent points for power diagram 
double [] weight; // weight
float ptsize=3;

color colgen=color(255,0,0);
color colVor=color(0,0,0);

 

PowerDiagram diagram;
OpenList sites;
PolygonSimple rootPolygon;

// we sample from proposal normal distribution

int s=512;
double []  Ssample;


public static double CauchypStd(double x)
{
return   1.0/(Math.PI*(1+x*x));
}

public static double CauchyDensity(double x,double gamma)
{
return   (1.0/gamma)*CauchypStd(x/gamma);
}


    public static double LaplacianDensity(double x, double m, double s)
{
return   (1.0/(2.0*s))*Math.exp(-Math.abs(x-m)/s);
}

 public static double GaussianDensity(double x, double m, double s)
  {
    return 1.0/(Math.sqrt(2.0*Math.PI)*s)*Math.exp(-0.5*sqr((x-m)/s));
  }
  
// a standard normal variate
   public static double GaussianVariate1D()
  {
    double u1=Math.random();
    double u2=Math.random();
    
    return Math.sqrt(-2.0*Math.log(u1))*Math.cos(2.0*Math.PI*u2);
  }

//
// The three fixed probability distributions of a 2d mixture family
//
public   double p0(double x)
{
return CauchyDensity(x,1);
}

public   double p1(double x)
{
return GaussianDensity(x,1,1);
}

public   double p2(double x)
{
return LaplacianDensity(x,2,1);
}

// the proposal distribution
public   double q(double x)
{
return  GaussianDensity(x,0,4);
}


//
// Randomized Bregman generator for a mixture family
//
public   double F(double [] theta)
{
int j;
double cumS=0;
double m, theta2;

//println();
 theta2=(1-(theta[0]+theta[1]));
 if (theta2<0 ) {println("error "+theta2); System.exit(1);}
 
for(j=0;j<s;j++)
{
 

 // mixture density
 m=  theta[0]*p1(Ssample[j]) + theta[1]*p2(Ssample[j]) + theta2*p0(Ssample[j]);
 
 //println("m="+m);
 
 cumS+= (m*Math.log(m)/q(Ssample[j]));
}

return (1.0/(double)s) * cumS;
}


// 2d inner product
public   double inner(double [] pt1, double [] pt2)
{
return pt1[0]*pt2[0]+pt1[1]*pt2[1];
}

//
// MC gradient of negentropy
//
public   double [] gradF(double [] theta)
{
int j;
double [] grad=new double [2];
double gradx=0,grady=0,m;
double theta2=(1-(theta[0]+theta[1]));
 
for(j=0;j<s;j++)
{
  m= theta[0]*p1(Ssample[j])+ theta[1]*p2(Ssample[j])+ theta2*p0(Ssample[j]);
  
  gradx += (p1(Ssample[j])-p0(Ssample[j]))*(1+Math.log(m))/q(Ssample[j]);
  grady += (p2(Ssample[j])-p0(Ssample[j]))*(1+Math.log(m))/q(Ssample[j]);
}

grad[0]=gradx/(double)s;
grad[1]=grady/(double)s;

return grad;
}



void setup()
{
size(512,512);
n=nstart;
initialize();
}



void MyLine(double x1, double y1, double x2, double y2)
{int nbstep=10;
double x, xx, y,yy;
line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
}
 



void draw()
{int i,j,ii,jj; 
Site site;
PolygonSimple polygon;

if (toggleAnimation){initializeGen();
// savepdffile();
}

surface.setTitle("MCIG Voronoi 3-mixture s="+s);



background(255, 255, 255);

strokeWeight(1);
 stroke(colVor);
 fill(colVor);

for ( i=0;i<sites.size;i++) {
    site=sites.array[i];
    polygon=site.getPolygon();

    if (polygon!=null) {
      for (j=0;j<polygon.length;j++)
      {// next vertex of the polygon
        jj=(j+1)%polygon.length;
          MyLine( polygon.x[j], polygon.y[j], polygon.x[jj], polygon.y[jj]   );
      }}}
      
      
      
strokeWeight(2);
 fill(colgen);
      stroke(colgen);
  for (i=0;i<n;i++) {   
    ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ptsize,ptsize);
  }
  
  
  float rr;
  
  strokeWeight(1);
 fill(colgen);
 noFill();
 
 if (toggleText)
 {String msg="n="+n+" s="+s;
 textSize(32);
  fill(0,0,0);
      stroke(0,0,0);
text(msg, 100, 30); 
 }
  
}

public static double mind(double x, double y)
{
if (x<y) return x; else return y;
}

public static double sqr(double x){return x;}


void initializeGen()
{double minw=1.e8;

diagram = new PowerDiagram();
sites = new OpenList();

int i;
Ssample=new double[s];

// s iid samples
for (i = 0; i < s; i++) {
Ssample[i]=GaussianVariate1D();
 }


    for ( i = 0; i < n; i++) {

      
      // center of sphere
      Epoint[i]=gradF(point[i]);
      
    //  println(Epoint[i][0]+" "+Epoint[i][1]);
 
 
      weight[i]=inner(Epoint[i],Epoint[i])+ 2*( F(point[i])-inner(point[i],Epoint[i]) );
  minw=mind(minw,weight[i]);    
      
//println(weight[i]);
 

        }

for (i = 0; i < n; i++) {
       // Equivalent power diagram
        Site site = new Site(Epoint[i][0],Epoint[i][1] );
        site.setWeight(weight[i]-minw);
        sites.add(site);
}
        
diagram.setSites(sites);
diagram.setClipPoly(rootPolygon);
diagram.computeDiagram();
}

// Initialization procedure
void initialize()
{int i;


point=new double[n][2];
Epoint=new double[n][2];
weight=new double[n];

    for ( i = 0; i < n; i++) {
      // random inside proba simplex (but not uniform)
      point[i][0]=Math.random();
       point[i][1]=Math.random()*(1-point[i][0]);
    }

rootPolygon = new PolygonSimple();

// cut by 2D probability simplex
rootPolygon.add(0, 0);
rootPolygon.add(maxx, 0);
rootPolygon.add(0, maxy);


initializeGen();
}

void keyPressed()
{
 if (key=='q') exit();
 if (key==' ') {initialize(); draw();}
  if (key=='2') {n=2;initialize(); draw();}
  if (key=='>') {s*=2; initializeGen(); draw();}
   if (key=='s') {initializeGen(); draw();}
   if (key=='<') {s/=2; initializeGen(); draw();}
   if (key=='n') {n=nstart;initialize(); draw();}
 if ((key=='p')||(key=='P')) savepdffile();
  if (key=='t') {toggleText=!toggleText; draw();}
   if (key=='a') {toggleAnimation=!toggleAnimation; draw();}
 
}


public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

public  float X2x(double X)
{return (float)(minx+(maxx-minx)*((X)/(float)side));}



public  float y2Y(double y)
{
  return (float)(side- ((y-miny)*side/(maxy-miny)));
}

public  float Y2y(double Y)
{return (float)(miny+(maxy-miny)*((side-Y)/(float)side));}



void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  

  beginRecord(PDF, "MCIG-VD-s"+s+"-"+suffix+".pdf");
  
 
  draw();
 
  save("MCIG-VD-s"+s+"-"+suffix+".png");
  endRecord();
  
}
 
  

void strokefill(color cc)
{  
  stroke(cc);
  fill(cc);
}
