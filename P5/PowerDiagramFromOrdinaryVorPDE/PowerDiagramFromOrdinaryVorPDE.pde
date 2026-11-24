// Frank.Nielsen@acm.org
// November 2026
// Show that 1D power diagram can be obtained as 2D ordinary Voronoi diagram

import processing.pdf.*;

int side = 800;
int ww = side;
int hh = side;

double delta=0.2;
double minx=-delta;
double maxx=1.0+delta;
double miny=-delta;
double maxy=1.0+delta;

boolean toggleText=true;
boolean toggleAnimation=true;
boolean toggleRectify=false;


int n;
int nstart=8; //16; //32;


double [][] point; // stored 2d coordinates

double [][] opoint; // in ordinary

double [] weight; // weight
float ptsize=5;

color colgen=color(255, 0, 0);
color colVor=color(0, 0, 0);



PowerDiagram diagram, diagramE;
OpenList sites, sitesE;
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

// Rendering
void draw()
{
  int i, j, ii, jj;
  Site site;
  PolygonSimple polygon;

  println("n="+n);
  surface.setTitle("Equivalence 1D Power/ 2D Ordinary Voronoi diagrams, n="+n);



  background(255, 255, 255);

 stroke(0,0,0);fill(0,0,0);
  strokeWeight(2);

  MyLine(minx, 0, maxx, 0); // xaxis

  fill(colgen);
  stroke(colgen);

  for (i=0; i<n; i++) {
    fill(240);
    stroke(240);
    //circle((float)x2X(point[i][0]), (float)y2Y(point[i][1]), (float)x2X(Math.sqrt(weight[i])));
    MyCircle((float)(point[i][0]), (float)(point[i][1]), (float)Math.sqrt(weight[i]));

    fill(colgen);
    stroke(colgen);
    //MyPoint(point[i][0], point[i][1]);
       ellipse((float)x2X(point[i][0]), (float)y2Y(point[i][1]), ptsize,ptsize);
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


  stroke(0, 255, 0);
  fill(0, 255, 0);
  for (i=0; i<n; i++) {
    MyPoint(opoint[i][0], opoint[i][1]);
  }

  for ( i=0; i<sites.size; i++) {
    site=sitesE.array[i];
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


void computePDEuc()
{
  int i;
  diagramE = new PowerDiagram();
  sitesE = new OpenList();

  for (i = 0; i < n; i++) {
    Site siteE = new Site(opoint[i][0], opoint[i][1] );
    siteE.setWeight(0);
    sitesE.add(siteE);
  }
  diagramE.setSites(sitesE);
  diagramE.setClipPoly(rootPolygon);
  diagramE.computeDiagram();
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

double max(double a, double b) {
  if (a>b) return a;
  else return b;
}

// Initialization procedure
void initialize()
{
  int i;

  point=new double[n][2];
  weight=new double[n];
  double W=0;
  opoint=new double[n][2];

  for ( i = 0; i < n; i++) {
    point[i][0]=Math.random();
    // point[i][1]=Math.random(); point[i][1]=0;
    weight[i]=0.01*Math.random();
    W=max(W, weight[i]);
  }

  println("Max weight W="+W);

  for ( i = 0; i < n; i++) {
    opoint[i][0]=point[i][0];
    opoint[i][1]=Math.sqrt(W-weight[i]);
  }

  rootPolygon = new PolygonSimple();

  rootPolygon.add(minx, miny);
  rootPolygon.add(maxx, miny);
  rootPolygon.add(maxx, maxy);
  rootPolygon.add(miny, maxy);





  computePD();
  computePDEuc();
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
