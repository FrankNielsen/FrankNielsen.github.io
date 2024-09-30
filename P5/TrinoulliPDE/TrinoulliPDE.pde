import processing.pdf.*;

int side = 512;
int ww = side;
int hh = side;


double delta=0.015;
double minx=-delta;
double maxx=1+delta;
double miny=-delta;
double maxy=1+delta;

float ptsize=5;

boolean toggleRectify=false;


int n;
double [][] ps; // stored 2d coordinates of 3-mixtures

double [] a, g, c;

double sqr(double x){return x*x;}


void TestEnergy0()
{double aa=a[0],gg=g[0], x=c[0];

      double E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
      +Math.log(1-gg))*sqr(x)+
      (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

      System.out.println("Energy derivative 0:"+E);
      
}


void TestEnergy()
{double aa=a[0],gg=g[0], x=c[0];

      double E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
      +Math.log(1-gg))*sqr(x)+
      (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

      System.out.println("Energy derivative 0:"+E);
      
      aa=a[1];gg=g[1]; x=c[1];

       E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
      +Math.log(1-gg))*sqr(x)+
      (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

      System.out.println("Energy derivative 1:"+E);
      
      
}


void testBernoulli()
{
  //n=256;
  n=2;
  
  int i;
  ps=new double[n][2];
  for (i=0; i<n; i++) {
    ps[i][0]=Math.random();
    
    ps[i][1]=1-ps[i][0];
  }

  a=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps);
  g=StandAloneJeffreysHistogramCentroid.NormalizedGeometricMean(ps);
  c=StandAloneJeffreysHistogramCentroid.NormalizedExactJeffreysCentroid(ps);
  
  TestEnergy0();
}


void initialize()
{
  n=256;
 // n=2;
  
  int i;
  ps=new double[n][3];
  for (i=0; i<n; i++) {
    ps[i][0]=Math.random();
    ps[i][1]=(1-ps[i][0])*Math.random();
    ps[i][2]=1-ps[i][0]-ps[i][1];
  }

  a=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps);
  g=StandAloneJeffreysHistogramCentroid.NormalizedGeometricMean(ps);
  
  c=StandAloneJeffreysHistogramCentroid.NormalizedExactJeffreysCentroid(ps);
  
  
  double leftkli=StandAloneJeffreysHistogramCentroid.leftKLInfo(ps,c);
  double rightkli=StandAloneJeffreysHistogramCentroid.rightKLInfo(ps,c);
  
  println("Left KL info:\t"+leftkli);
  println("Right KL info:\t"+rightkli);
  
  TestEnergy();
}

void setup()
{
  size(512, 512);
  initialize();
}

void MyLine(double x1, double y1, double x2, double y2)
{
  if (toggleRectify) MyLineRectify(x1, y1, x2, y2);
  else  MyLineNoRectify(x1, y1, x2, y2);
}


void MyPoint(double x, double y)
{

  if (toggleRectify) MyPointRectify(x, y);
  else MyPointNoRectify(x, y);
}

void MyLineRectify(double x1, double y1, double x2, double y2)
{
  int nbstep=10;
  double x, xx, y, yy;
  line(x2X(x1+0.5*y1), y2Y(y1*sqrt(3)/2.0), x2X(x2+0.5*y2), y2Y(y2*sqrt(3)/2.0)) ;
}

void MyLineNoRectify(double x1, double y1, double x2, double y2)
{
  int nbstep=10;
  double x, xx, y, yy;
  line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
}


void MyPointRectify(double x, double y)
{
  ellipse((float)x2X(x+0.5*y), (float)y2Y(y*sqrt(3)/2.0), ptsize, ptsize);
}

void MyPointNoRectify(double x, double y)
{
  ellipse((float)x2X(x), (float)y2Y(y), ptsize, ptsize);
}

void strokefill(int r, int g, int b) {
  stroke(r, g, b);
  fill(r, g, b);
}


void draw()
{
  int i, j, ii, jj;


  surface.setTitle("Standard simplex (trinoulli)");



  background(255, 255, 255);

  strokefill(0, 0, 0);
  strokeWeight(3);

MyLine(0,0, 0,1);
MyLine(0,1, 1,0);
MyLine(0,0,1,0);

  strokeWeight(1);

  for (i=0; i<n; i++) {
    MyPoint(ps[i][0], ps[i][1]);
  }
  ptsize*=2;

  strokefill(255, 0, 0);
  MyPoint(a[0], a[1]);// red
  strokefill(0, 0, 255);
  MyPoint(g[0], g[1]);// blue


  strokefill(255, 0, 255);
  MyPoint(c[0], c[1]);// pruple

  ptsize/=2;
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
  int s=0;
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "Trinoulli-"+suffix+".pdf");


  draw();

  save("Trinoulli-"+suffix+".png");
  endRecord();
}



void keyPressed()
{
  if (key=='q') exit();
  
  
  if (key=='b') {
    testBernoulli();
    draw();
  }
  
  if (key==' ') {
    initialize();
    draw();
  }

  if ((key=='p')||(key=='P')) savepdffile();

  if (key=='r') {
    toggleRectify=!toggleRectify;
    draw();
  }
}
