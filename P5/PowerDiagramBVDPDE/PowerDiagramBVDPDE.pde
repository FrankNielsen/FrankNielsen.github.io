// Frank.Nielsen@acm.org
// July 2026
//

import processing.pdf.*;

int side = 800;
int ww = side;
int hh = side;



/*
double MINP=-20;
 double delta=0.2;
 double minx=MINP-delta;
 double maxx=-MINP+delta;
 double miny=MINP-delta;
 double maxy=-MINP+delta;
 
 double MIN=-10000000;
 double deltat=-0.005;
 double minxt=MIN;
 double maxxt=-MIN;
 double minyt=MIN;
 double maxyt=-MIN;
 */


/*
// L22
 double delta=0.2;
 double minx=-delta;
 double maxx=1.0+delta;
 double miny=-delta;
 double maxy=1.0+delta;
 
 
 double deltat=-0.005;
 double minxt=-deltat;
 double maxxt=1.0+deltat;
 double minyt=-deltat;
 double maxyt=1.0+deltat;
 */



boolean toggleText=true;



double MINP=-20;
double delta=0.2;
double minx=MINP-delta;
double maxx=-MINP+delta;
double miny=MINP-delta;
double maxy=-MINP+delta;

double MIN=0, MAX=10;
double deltat=0.005;
double minxt=MIN+delta;
double maxxt=MAX;
double minyt=MIN+delta;
double maxyt=MAX;


double F(double t) {
  return Math.log(t)-t;
}

double gradF(double t) {
  return Math.log(t);
}


/*
double F(double t) {
 return Math.exp(t);
 }
 
 double gradF(double t) {
 return Math.exp(t);
 }
 */


/*
double F(double t) {
 return 0.5*t*t;
 }
 double gradF(double t) {
 return t;
 }
 */

// Separable Bregman divergence
double F(double [] t) {
  return F(t[0])+F(t[1]);
}




int n;
int nstart=2; //16;//2;


double [][] point; // stored 2d coordinates
double [] weight; // weight

double [][] param; // Bregman
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



void setup()
{
  size(800, 800);
  n=nstart;
  initialize();
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

void draw()
{
  int i, j, ii, jj;
  Site site;
  PolygonSimple polygon;

  //  println("n="+n);
  surface.setTitle("Bregman Voronoi/Power diagram n="+n);



  background(255, 255, 255);


  strokeWeight(2);
  fill(colgen);
  stroke(colgen);

  for (i=0; i<n; i++) {
    fill(240);
    stroke(240);
    //circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
    MyCircle((float)(point[i][0]), (float)(point[i][1]), (float)Math.sqrt(weight[i]));

    fill(0, 0, 255);
    stroke(0, 0, 255);
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

  // BVD in red
  for (i=0; i<n; i++) {
    fill(255, 0, 0);
    stroke(255, 0, 0);
    MyPoint(param[i][0], param[i][1]);
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


double lambda=1;

// Initialization procedure
void initialize()
{
  int i;
  param=new double[n][2];
  point=new double[n][2];
  weight=new double[n];

  double [] eta=new double[2];

  for ( i = 0; i < n; i++) {

    // Bregman parameters
    param[i][0]=Math.random();
    param[i][1]=Math.random();

    eta[0]=gradF(param[i][0]);
    eta[1]=gradF(param[i][1]);

    // equivalent weighted points
    point[i][0]=lambda*gradF(eta[0]);
    point[i][1]=lambda* gradF(eta[1]);
    weight[i]=lambda*(inner(eta, eta)+2*(F(param[i])-inner(param[i], eta)));
  }


  double Wmin=weight[0];
  for ( i = 1; i < n; i++) Wmin=mind(Wmin, weight[i]);
  for ( i = 0; i < n; i++) {
    weight[i]+=Wmin;
    println(i+" "+weight[i]);
    println(param[i][0]+" "+param[i][1]+" -> "+point[i][0]+" "+point[i][1]);
  }

  // clip to domain
  rootPolygon = new PolygonSimple();

  rootPolygon.add(minxt, minyt);
  rootPolygon.add(maxxt, minyt);
  rootPolygon.add(maxxt, maxyt);
  rootPolygon.add(minyt, maxyt);





  computePD();
}

void keyPressed()
{
  if (key=='q') exit();

  if (key==' ') {
    initialize();
    draw();
  }

  if (key=='2') {
    n=2;
    initialize();
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

  beginRecord(PDF, "PD-"+n+"-"+suffix+".pdf");


  draw();

  save("PD-"+n+"-"+suffix+".png");
  endRecord();
}



void strokefill(color cc)
{
  stroke(cc);
  fill(cc);
}
