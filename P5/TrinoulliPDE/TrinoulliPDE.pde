// Frank.Nielsen@acm.org
// Revised, December 2024. Press 'r' for

import processing.pdf.*;

int side = 512;
int ww = side;
int hh = side;

int mode=1;

double delta=0.015;
double minx=-delta;
double maxx=1+delta;
double miny=-delta;
double maxy=1+delta;

float ptsize=5;

String supertest="";
boolean toggleRectify=false;
boolean toggleem=false; //true;// false;

boolean toggleGeodesic=false;
boolean toggleFR=true;
boolean toggleJ=true;
boolean toggleIM=true;

//boolean toggleA=false;
//boolean toggleG=false;

boolean toggleA=true;
boolean toggleG=true;


boolean toggleAnimation=false; //true;

int n;
double [][] ps; // stored 2d coordinates of 3-mixtures

double [][] speed;

double [] a, g, c, fr, cig, gb; // cig is via info geo method

// Fisher ball
double [] c0, s0; // center and speed vector
double r0;

// Map a trinoulli distribution (eta1,eta2,1-eta1-eta2) into a point in the 2D equilateral triangle
double []  Moment2EquilateralTriangle(double eta1, double eta2)
{
  double [] res=new double[2];

  res[0]=eta1+0.5*eta2;
  res[1]=eta2*sqrt(3.0)/2.0;

  return res;
}




double sqr(double x)
{
  return x*x;
}

static double sum(double [] array)
{
  double res=0;
  for (int i=0; i<array.length; i++) res+=array[i];
  return res;
}

static double [] Normalize(double [] array)
{
  int d=array.length;
  double [] res=new double [d];
  int i;
  double norm=sum(array);
  for (i=0; i<d; i++) res[i]=array[i]/norm;
  return res;
}

// Mixture geodesic
static double [] mGeodesic(double[] p, double [] q, double lambda)
{
  int i, dd=p.length;
  double [] res=new double [dd];

  for (i=0; i<dd; i++) {
    res[i]=(1-lambda)*p[i]+lambda*q[i];
  }


  return res;
}

static double FisherRaoDistance(double[] p, double [] q)
{
  double innerp=0;
  double dd=p.length;
  int i;
  for (i=0; i<dd; i++) innerp+=Math.sqrt(p[i]*q[i]);

  return 2.0*Math.acos(innerp);
}

static void TestFR(double[] p, double [] q)
{
  double lambda=Math.random();
  double [] r= FisherRaoGeodesicCategorical(p, q, lambda);
  double rhopr=FisherRaoDistance(p, r);
  double lhs=lambda*FisherRaoDistance(p, q);

  System.out.println("Sanity check:"+lhs+" vs "+rhopr);
}

static double mysqr(double x) {
  return x*x;
}
// Dawid 1977
static double [] FisherRaoGeodesicCategorical(double[] p, double [] q, double lambda)
{
  int i, dd=p.length;
  double rho=FisherRaoDistance(p, q);
  double [] f=new double[dd];
  double [] res=new double[dd];
  for (i=0; i<dd; i++)
  {
    f[i]= (Math.sqrt(q[i])-Math.sqrt(p[i])*Math.cos(rho/2.0))/Math.sin(rho/2.0);
  }


  for (i=0; i<dd; i++)
  {
    res[i]=mysqr(Math.sqrt(p[i])*Math.cos(lambda*rho/2.0)+f[i]*Math.sin(lambda*rho/2.0));
  }

  return res;
}

static double [] metricGeodesic(double[] p, double [] q, double lambda)
{
  int i, dd=p.length;
  double [] res=new double [dd];
  double [] aa, gg;


  for (i=0; i<dd; i++) {
    // Fisher-Rao for
    res[i]= (1-lambda)*p[i]+2.0*Math.sqrt((1-lambda)*p[i]*lambda*q[i])+lambda*q[i];
  }


  return Normalize(res);
}


static double [] eGeodesic(double[] p, double [] q, double lambda)
{
  int i, dd=p.length;
  double [] res=new double [dd];

  for (i=0; i<dd; i++) {
    res[i]=Math.pow(p[i], (1.0-lambda))*Math.pow(q[i], lambda);
  }


  return Normalize(res);
}

void TestEnergy0()
{
  double aa=a[0], gg=g[0], x=c[0];

  double E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
    +Math.log(1-gg))*sqr(x)+
    (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

  System.out.println("Energy derivative 0:"+E);
}


void TestEnergy()
{
  double aa=a[0], gg=g[0], x=c[0];

  double E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
    +Math.log(1-gg))*sqr(x)+
    (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

  System.out.println("Energy derivative 0:"+E);

  aa=a[1];
  gg=g[1];
  x=c[1];

  E=((sqr(x)-x)*Math.log(x)+((-Math.log(1-x))-Math.log(gg)
    +Math.log(1-gg))*sqr(x)+
    (Math.log(1-x)+Math.log(gg)-Math.log(1-gg)-1)*x+aa)/(sqr(x)-x);

  System.out.println("Energy derivative 1:"+E);
}

void PrintPoint(String msg, double [] p)
{
  int i;
  String str=msg;
  for (i=0; i<p.length; i++)
    str=str+p[i]+" ";

  System.out.println(str);
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
  c=StandAloneJeffreysHistogramCentroid.JeffreysFisherRaoCentroid(ps);

  TestEnergy0();
}

void calculateCenters()
{
  a=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps);
  g=StandAloneJeffreysHistogramCentroid.NormalizedGeometricMean(ps);

  c=StandAloneJeffreysHistogramCentroid.NumericalJeffreysCentroid(ps);
  //c=StandAloneJeffreysHistogramCentroid.NumericalJeffreysCentroid(ps,1.e-5);

  gb=StandAloneJeffreysHistogramCentroid.inductiveJeffreysCentroid(ps, 1.e-6);

  double deltakl=Math.abs(StandAloneJeffreysHistogramCentroid.KLD(c, g)-StandAloneJeffreysHistogramCentroid.KLD(a, c));
  System.out.println("Quality of Jeffreys centroid:"+deltakl);

  //   return NumericalJeffreysCentroid(  set,  1.e-5);
  double tv;

  fr=StandAloneJeffreysHistogramCentroid.JeffreysFisherRaoCentroid(ps);
  tv=StandAloneJeffreysHistogramCentroid.TotalVariation(fr, c);

  System.out.println("Difference in TV between Jeffreys numerical and Jeffreys-Fisher-Rao center:"+tv);



  cig=StandAloneJeffreysHistogramCentroid.JeffreysCentroidInfoGeo(ps);



  //double kl=StandAloneJeffreysHistogramCentroid.JeffreysDiv(cig,c);
  tv=StandAloneJeffreysHistogramCentroid.TotalVariation(cig, c);



  System.out.println("Difference in TV between Jeffreys numerical and computational information geometry:"+tv);

  PrintPoint("numerical W Jeffreys:\t\t", c);
  PrintPoint("information geometric Jeffreys:\t", cig);

  double leftkli=StandAloneJeffreysHistogramCentroid.leftKLInfo(ps, c);
  double rightkli=StandAloneJeffreysHistogramCentroid.rightKLInfo(ps, c);

  // println("Left KL info:\t"+leftkli);
  // println("Right KL info:\t"+rightkli);

  // TestEnergy();
}

void animate()
{
  int i;
  double ll=0.001;

  for (i=0; i<n; i++)
  {
    double px, py, pz;
    px=ps[i][0]+ll*speed[i][0];
    py=ps[i][1]+ll*speed[i][1];
    pz=1-px-py;

    // if (( px+py+pz >0)&&( px+py+pz <1) && (px>0)&&(py>0)&&(pz>0)) {
    if ((1-px-py>0) && (px>0) &&(py>0) ) {
      ps[i][0]+=ll*speed[i][0];
      ps[i][1]+=ll*speed[i][1];
      ps[i][2]=1-(ps[i][0]+ps[i][1]);
    } else {
      speed[i][0]=-speed[i][0];
      speed[i][1]=-speed[i][1]; //speed[i][2]=-speed[i][2];
    }
  }
  
  
  // FisherBall
if (mode==1){

 
  if ((1-c0[0]-c0[1]>0) && (c0[0]>0) &&(c0[1]>0) ) {
      c0[0]+=ll*s0[0];
  c0[1]+=ll*s0[1];
      c0[2]=1-(c0[0]+c0[1]);
    } else {
      speed[i][0]=-speed[i][0];
      speed[i][1]=-speed[i][1]; //speed[i][2]=-speed[i][2];
    }
}
    
  
}

double max(double  x, double y) {
  if (x>y) return x;
  else return y;
}

void testPaperSpecial(int dim)
{
  // int dim=1024;

  dim=3;

  int nn=2;
  int i, j, t, test, nbtests=10000;
  double[][] ds=new double[nn][dim];
  double [] GBcenter, JFRcenter, JeffreysCentroid;
  double infoGB, infoJFR, infoJeffreysCentroid;
  double TVGB, TVJFR;
  double epsGB, epsJFR;
  double MepsGB=0, MepsJFR=0;
  double avgGB=0, avgJFR=0;
  chrono JeffreysChrono, JFRChrono, GBChrono;
  double totaltimeJeffreys=0, totaltimeJFR=0, totaltimeGB=0;
  double avgtvGB, avgtvJFR, maxtvGB, maxtvJFR;

  avgtvGB= avgtvJFR= maxtvGB= maxtvJFR=0;

  for (double eps=0.1; eps>1.e-20; eps/=10.0)
  {
    System.out.println("Epsilon eps="+eps);

    JeffreysChrono=new chrono();
    JFRChrono=new chrono();
    GBChrono=new chrono();

    System.out.println("----------------------------------------");
    System.out.println("Test for paper with dim="+dim);

    for (t=0; t<nbtests; t++)
    {
      /*
    for (i=0; i<nn; i++) {
       ds[i]=StandAloneJeffreysHistogramCentroid.randomHistogram(dim);
       }
       */

      // Bad example
      ds[0][0]=1.0-eps;
      ds[0][1]=(1-ds[0][0])/2.0;
      ds[0][2]=1-ds[0][0]-ds[0][1];


      ds[1][0]=1.0/3.0;
      ds[1][1]=1.0/3.0;
      ds[1][2]=1.0-ds[1][0]-ds[1][1];


      // costly with Lambert W
      JeffreysChrono.reset() ;
      JeffreysCentroid=StandAloneJeffreysHistogramCentroid.NumericalJeffreysCentroid(ds);
      JeffreysChrono.time();

      // fast but recursive
      GBChrono.reset();
      GBcenter=StandAloneJeffreysHistogramCentroid.inductiveJeffreysCentroid(ds, 1.e-1 );//1.e-8
      GBChrono.time();

      // very fast closed-form
      JFRChrono.reset();
      JFRcenter=StandAloneJeffreysHistogramCentroid.JeffreysFisherRaoCentroid(ds);
      JFRChrono.time();


      totaltimeJeffreys+=JeffreysChrono.t;
      totaltimeJFR+=JFRChrono.t;
      totaltimeGB+=GBChrono.t;


      infoJeffreysCentroid =  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, JeffreysCentroid);
      infoGB=  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, GBcenter);
      infoJFR  =  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, JFRcenter);

      TVGB=StandAloneJeffreysHistogramCentroid.TotalVariation(JeffreysCentroid, GBcenter);
      TVJFR=StandAloneJeffreysHistogramCentroid.TotalVariation(JeffreysCentroid, JFRcenter);




      avgtvGB+=TVGB;
      maxtvGB=max(maxtvGB, TVGB);

      avgtvJFR+=TVJFR;
      maxtvJFR=max(maxtvGB, TVJFR);

      epsGB=(infoGB/infoJeffreysCentroid)-1.0;
      epsJFR=(infoJFR/infoJeffreysCentroid)-1.0;

      /*
    System.out.println("epsGB="+epsGB+"\tepsJFR="+epsJFR);
       System.out.println("TV(Jeffreys,GB)="+TVGB+"\t TV(Jeffreys,JFR)="+TVJFR);
       System.out.println("time Jeffreys="+JeffreysChrono.t+" time GB="+GBChrono.t+" time JFR="+JFRChrono.t);
       */

      MepsGB=max(MepsGB, epsGB);
      MepsJFR=max(MepsJFR, epsJFR);

      avgGB+=epsGB;
      avgJFR+=epsJFR;
    }

    avgGB/=(double)nbtests;
    avgJFR/=(double)nbtests;


    totaltimeJeffreys/=(double)nbtests;
    totaltimeJFR/=(double)nbtests;
    totaltimeGB/=(double)nbtests;

    double ratioGB, ratioJFR;

    ratioGB=totaltimeJeffreys/totaltimeGB;
    ratioJFR=totaltimeJeffreys/totaltimeJFR;

    avgtvGB/=(double)nbtests;
    avgtvJFR/=(double)nbtests;

    System.out.println("agv time Jeffreys:\t"+totaltimeJeffreys);
    System.out.println("agv time GB:\t"+totaltimeGB+"\t speed up GB="+ratioGB);
    System.out.println("agv time JFR:\t"+totaltimeJFR+"\t speed up JFR="+ratioJFR);

    System.out.println("\nmaximum approx GB:"+MepsGB+"\t JFR:"+MepsJFR);
    System.out.println("average approx GB:"+avgGB+"\t JFR:"+avgJFR);

    // dimension & JFR average $\eps$ & JFR maximum $\eps$ & JFR average time &  JFR speed factor &  GB average $\eps$ & GB maximum $\eps$ & GB average time &  JGB speed factor\\

    //  String export=  "d=" + dim+" & " + avgJFR +" & "+MepsJFR + " & " + ratioJFR+ " & ";
    //export=export+ avgGB +" & "+MepsGB + " & " + ratioGB+ " \\\\ ";
    String export=String.format("d=%d & %.3e & %.3e & %.3e & %.3e & %.3e & %.3f & %.3e & %.3e & %.3e & %.3e & %.3e & %.3f \\\\", dim,
      avgJFR, MepsJFR, avgtvJFR, maxtvJFR, totaltimeJFR, ratioJFR,
      avgGB, MepsGB, avgtvGB, maxtvGB, totaltimeGB, ratioGB);


    //$\alpha$ &    $\eps$ &      avg time &    $\times$ speed  &    $\eps$ &    avg time &    $\time$ speed \\ \hline

    export=String.format("%.3e & %.3e &   %.3e & %.3e  & %.3f & %.3e &  %.3e & %.3e &  %.3f  \\\\", eps,
      avgJFR, avgtvJFR, totaltimeJFR, ratioJFR,
      avgGB, avgtvGB, totaltimeGB, ratioGB);


    //String export=String.format("d=%d & %.3e", dim, avgJFR);




    System.out.println("\n"+export+"\n");

    supertest=supertest +"\n"+export;
    System.out.println("----------------------------------------");
    System.out.println(supertest);
    exit();
  }
}





void testPaperGeneral(int dim)
{
  // int dim=1024;
  int nn=2;
  int i, j, t, test, nbtests=10000;
  double[][] ds=new double[nn][dim];
  double [] GBcenter, JFRcenter, JeffreysCentroid;
  double infoGB, infoJFR, infoJeffreysCentroid;
  double TVGB, TVJFR;
  double epsGB, epsJFR;
  double MepsGB=0, MepsJFR=0;
  double avgGB=0, avgJFR=0;
  double avgtvGB, avgtvJFR, maxtvGB, maxtvJFR;
  chrono JeffreysChrono, JFRChrono, GBChrono;
  double totaltimeJeffreys=0, totaltimeJFR=0, totaltimeGB=0;


  avgtvGB= avgtvJFR= maxtvGB= maxtvJFR=0;


  JeffreysChrono=new chrono();
  JFRChrono=new chrono();
  GBChrono=new chrono();

  System.out.println("--[General test]--------------------------------------");
  System.out.println("Test for paper with dim="+dim);

  for (t=0; t<nbtests; t++)
  {

    for (i=0; i<nn; i++) {
      ds[i]=StandAloneJeffreysHistogramCentroid.randomHistogram(dim);
    }

    // costly with Lambert W
    JeffreysChrono.reset() ;
    JeffreysCentroid=StandAloneJeffreysHistogramCentroid.NumericalJeffreysCentroid(ds);
    JeffreysChrono.time();

    // fast but recursive
    GBChrono.reset();
    GBcenter=StandAloneJeffreysHistogramCentroid.inductiveJeffreysCentroid(ds, 1.e-1 );//1.e-8
    GBChrono.time();

    // very fast closed-form
    JFRChrono.reset();
    JFRcenter=StandAloneJeffreysHistogramCentroid.JeffreysFisherRaoCentroid(ds);
    JFRChrono.time();


    totaltimeJeffreys+=JeffreysChrono.t;
    totaltimeJFR+=JFRChrono.t;
    totaltimeGB+=GBChrono.t;


    infoJeffreysCentroid =  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, JeffreysCentroid);
    infoGB=  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, GBcenter);
    infoJFR  =  StandAloneJeffreysHistogramCentroid.JeffreysInformation(ds, JFRcenter);


    TVGB=StandAloneJeffreysHistogramCentroid.TotalVariation(JeffreysCentroid, GBcenter);
    TVJFR=StandAloneJeffreysHistogramCentroid.TotalVariation(JeffreysCentroid, JFRcenter);


    avgtvGB+=TVGB;
    maxtvGB=max(maxtvGB, TVGB);

    avgtvJFR+=TVJFR;
    maxtvJFR=max(maxtvGB, TVJFR);



    epsGB=(infoGB/infoJeffreysCentroid)-1.0;
    epsJFR=(infoJFR/infoJeffreysCentroid)-1.0;

    /*
    System.out.println("epsGB="+epsGB+"\tepsJFR="+epsJFR);
     System.out.println("TV(Jeffreys,GB)="+TVGB+"\t TV(Jeffreys,JFR)="+TVJFR);
     System.out.println("time Jeffreys="+JeffreysChrono.t+" time GB="+GBChrono.t+" time JFR="+JFRChrono.t);
     */

    MepsGB=max(MepsGB, epsGB);
    MepsJFR=max(MepsJFR, epsJFR);

    avgGB+=epsGB;
    avgJFR+=epsJFR;
  }

  avgGB/=(double)nbtests;
  avgJFR/=(double)nbtests;


  totaltimeJeffreys/=(double)nbtests;
  totaltimeJFR/=(double)nbtests;
  totaltimeGB/=(double)nbtests;

  avgtvGB/=(double)nbtests;
  avgtvJFR/=(double)nbtests;

  double ratioGB, ratioJFR;

  ratioGB=totaltimeJeffreys/totaltimeGB;
  ratioJFR=totaltimeJeffreys/totaltimeJFR;

  System.out.println("agv time Jeffreys:\t"+totaltimeJeffreys);
  System.out.println("agv time GB:\t"+totaltimeGB+"\t speed up GB="+ratioGB);
  System.out.println("agv time JFR:\t"+totaltimeJFR+"\t speed up JFR="+ratioJFR);

  System.out.println("\nmaximum approx GB:"+MepsGB+"\t JFR:"+MepsJFR);
  System.out.println("average approx GB:"+avgGB+"\t JFR:"+avgJFR);

  // dimension & JFR average $\eps$ & JFR maximum $\eps$ & JFR average time &  JFR speed factor &  GB average $\eps$ & GB maximum $\eps$ & GB average time &  JGB speed factor\\

  //  String export=  "d=" + dim+" & " + avgJFR +" & "+MepsJFR + " & " + ratioJFR+ " & ";
  //export=export+ avgGB +" & "+MepsGB + " & " + ratioGB+ " \\\\ ";
  String export=String.format("d=%d & %.3e & %.3e & %.3e  & %.3e & %.3e & %.3f & %.3e & %.3e & %.3e &  %.3e & %.3e & %.3f \\\\", dim,
    avgJFR, MepsJFR, avgtvJFR, maxtvJFR, totaltimeJFR, ratioJFR,
    avgGB, MepsGB, avgtvGB, maxtvGB, totaltimeGB, ratioGB);

  //String export=String.format("d=%d & %.3e", dim, avgJFR);




  System.out.println("\n"+export+"\n");

  supertest=supertest +"\n"+export;
  System.out.println("----------------------------------------");
}


void initialize()
{n=8;
  //n=32;
  //n=2;
  
  r0=0.05+Math.random();
c0=new double [3];

 c0[0]=Math.random();
    c0[1]=(1-c0[0])*Math.random();
    c0[2]=1-c0[0]-c0[1];
    
    s0=new double [2];
s0[0]=Math.random();
s0[1]=Math.random();
  int i;
  ps=new double[n][3];
  for (i=0; i<n; i++) {
    ps[i][0]=Math.random();
    ps[i][1]=(1-ps[i][0])*Math.random();
    ps[i][2]=1-ps[i][0]-ps[i][1];
  }


  speed=new double[n][3];
  for (i=0; i<n; i++) {
    speed[i][0]=Math.random();
    speed[i][1]=(1-ps[i][0])*Math.random();
    speed[i][2]=1-ps[i][0]-ps[i][1];
  }

  // very visible property, overwrite with bad example
  if (false) {
    // counter example
    //ps[0][0]=0.9999999;
    ps[0][0]=0.99;
    ps[0][1]=(1-ps[0][0])/2.0;
    ps[0][2]=1-ps[0][0]-ps[0][1];


    ps[1][0]=0.3333;
    ps[1][1]=0.3333;
    ps[1][2]=1-ps[1][0]-ps[1][1];
  }

  calculateCenters();

  System.out.println("Jeffreys centroid:\t"+ c[0]+" "+c[1]+" "+c[2]);
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

/*if (toggleRectify) MyPointRectify(x, y);
  else MyPointNoRectify(x, y);*/
  
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

void drawEGeodesic(double [] p, double [] q)
{
  double l, ll, i;
  int nbsteps=10;

  for (i=0; i<nbsteps; i++)
  {
    l=((double)i)/(double)nbsteps;
    ll=((double)i+1.0)/(double)nbsteps;

    double [] pp=eGeodesic(p, q, l);
    double [] ppp=eGeodesic(p, q, ll);

    MyLine(pp[0], pp[1], ppp[0], ppp[1]);
  }
}


void drawMGeodesic(double [] p, double [] q)
{
  double l, ll, i;
  int nbsteps=10;

  for (i=0; i<nbsteps; i++)
  {
    l=((double)i)/(double)nbsteps;
    ll=((double)i+1.0)/(double)nbsteps;

    double [] pp=mGeodesic(p, q, l);
    double [] ppp=mGeodesic(p, q, ll);

    MyLine(pp[0], pp[1], ppp[0], ppp[1]);
  }
}


void drawFisherRaoGeodesic(double [] p, double [] q)
{

  double l, ll, i;
  int nbsteps=10;

  for (i=0; i<nbsteps; i++)
  {
    l=((double)i)/(double)nbsteps;
    ll=((double)i+1.0)/(double)nbsteps;

    double [] pp=metricGeodesic(p, q, l);
    double [] ppp=metricGeodesic(p, q, ll);
    

 

    MyLine(pp[0], pp[1], ppp[0], ppp[1]);
  }
}

void drawEMFisherRao()
{
  surface.setTitle("Exponential, mixture, and Fisher-Rao geodesics");

  //TestFR(ps[0], ps[1]);

  background(255, 255, 255);

  stroke(0);
  strokeWeight(3);

  MyLine(0, 0, 0, 1);
  MyLine(0, 1, 1, 0);
  MyLine(0, 0, 1, 0);


// E and M geodesics
  strokeWeight(1);
  strokefill(255, 0, 0); // red
  drawEGeodesic(ps[0], ps[1]);
  strokefill(0, 0, 255);
  drawMGeodesic(ps[0], ps[1]);  //blue


  strokefill(255, 0, 255); // purple = red + blue
  drawFisherRaoGeodesic(ps[0], ps[1]);
  double stepx=0.2;

  double [] m;
  for (double l=0; l<=1+stepx; l+=stepx)
  {
    m=FisherRaoGeodesicCategorical(ps[0], ps[1], l);
    MyPoint(m[0], m[1]);
  }
}


static double scalarKLD(double p, double q)
{
  return p*Math.log(p/q);
}

static double KLD(double [] array1, double[] array2)
{
  int d=array1.length;
  double  res=0;
  int i;
  for (i=0; i<d; i++)  res+=scalarKLD(array1[i], array2[i]);
  return res;
}

//
//
//

static double [] ChernoffPoint(double [] p, double [] q)
{
  int dd=p.length;
  double lmin=0, lmax=1, l=0.5;
  double [] cp;

  while (Math.abs(lmax-lmin)>1.e-5)
  {
    l=(lmax+lmin)/2.0;
    cp=eGeodesic(p, q, l);
    if (KLD(cp, p)>KLD(cp, q)) {
      lmax=l;
    } else lmin=l;
  }

  return eGeodesic(p, q, l);
}


Line MBisector(double [] p, double [] q)
{
  double a, b, c;

  a=Math.log((q[0]/p[0])*(p[2]/q[2]));
  b=Math.log((q[1]/p[1])*(p[2]/q[2]));
  c=Math.log(q[2]/p[2]);

  return new Line(a, b, c);
}

double min(double a,double b){if (a<b) return a; else return b;}
//double max(double a,double b){if (a>b) return a; else return b;}

void drawChernoff()
{
  surface.setTitle("Chernoff distribution & Chernoff information");

  double bixmin=0;
  double yy,bixmax=1, startx=1, stopx=0, stepx=0.001;
 
  double [] p=ps[0];
  double [] q=ps[1];
  double [] cp=ChernoffPoint(p, q);
    Line bim=MBisector(p, q);
  
   for(double xx=0;xx<=1;xx+=stepx)
 {
 yy=bim.xtoy(xx);
 if ((yy>0)&&(yy<1-xx)) {startx=min(startx,xx); stopx=max(stopx,xx);}
 }
 
 
 
  background(255, 255, 255);

  stroke(0);
  strokeWeight(3);

  MyLine(0, 0, 0, 1);
  MyLine(0, 1, 1, 0);
  MyLine(0, 0, 1, 0);

  strokeWeight(1);



  stroke(255, 0, 0);
  drawEGeodesic(p, q);

  stroke(0, 0, 0);
  MyPoint(p[0], p[1]);
  MyPoint(q[0], q[1]);


  stroke(0, 0, 255);
  // Bisector

  //println(bim.a+"x+"+bim.b+"y+"+bim.c+"=0");

  // good MyLine(bixmin, bim.xtoy(bixmin), bixmax, bim.xtoy(bixmax));


   
   
MyLine(startx, bim.xtoy(startx), stopx, bim.xtoy(stopx));
  //  println(bixmin+" "+bim.xtoy(bixmin)+" ");

  stroke(0, 255, 0);
  ptsize*=2;
  MyPoint(cp[0], cp[1]);
  ptsize/=2.0;

/*
  if (toggleAnimation) {
    animate();
  }
  */
}


void draw()
{
if (mode==1) drawFisherBall();
if (mode==2) drawChernoff();
 if (mode==3) drawEMFisherRao();
if (mode==4) drawJFR();
if (mode==5) drawTriMiniball();

if (toggleAnimation) {
    animate();
  }
}

void drawFRBall(double [] cc0, double rr0)
{
  int i,j; double eta1,eta2;
  double [] pp=new double[3];
   strokeWeight(1);
stroke(255, 165, 0);// orange
fill(255, 165, 0);
for(i=0;i<512;i++)
for(j=0;j<512;j++)
{
  eta1=X2x(j);
  eta2=Y2y(i);
  pp[0]=eta1;pp[1]=eta2;pp[2]=1-eta1-eta2;
  
  if (FisherRaoDistance(cc0,pp)<rr0) 
  {
        double x=pp[0];double y=pp[1];

 if (toggleRectify) {ellipse((float)x2X(x+0.5*y), (float)y2Y(y*sqrt(3)/2.0), 1.0,1.0);}
  else {ellipse((float)x2X(x), (float)y2Y(y), 1.0,1.0);}
  
    //MyPoint(eta1,eta2);
  
  }
}
}

// Draw a Fisher-Rao ball in eta or lambda parameterization
// observe that the ball can meet the boundary!!!
void drawFisherBall()
{int i,j;
 double eta1,eta2;
 double [] pp=new double[3];
 background(255, 255, 255);



  strokeWeight(1);
stroke(255, 165, 0);// orange
fill(255, 165, 0);
for(i=0;i<512;i++)
for(j=0;j<512;j++)
{
  eta1=X2x(j);
  eta2=Y2y(i);
  pp[0]=eta1;pp[1]=eta2;pp[2]=1-eta1-eta2;
  
  if (FisherRaoDistance(c0,pp)<r0) 
  {
        double x=pp[0];double y=pp[1];

 if (toggleRectify) {ellipse((float)x2X(x+0.5*y), (float)y2Y(y*sqrt(3)/2.0), 1.0,1.0);}
  else {ellipse((float)x2X(x), (float)y2Y(y), 1.0,1.0);}
  
    //MyPoint(eta1,eta2);
  
  }
}

stroke(0);fill(0);
MyPoint(c0[0],c0[1]);

  stroke(0);
  strokeWeight(3);

  MyLine(0, 0, 0, 1);
  MyLine(0, 1, 1, 0);
  MyLine(0, 0, 1, 0);
  
  
}


void drawTriMiniball()
{
  int i, j, ii, jj;


  surface.setTitle("Parameter space of the trinoulli family (#trial=1)");



  background(255, 255, 255);

  int mgrey=128;
  strokefill(mgrey, mgrey, mgrey);
  strokeWeight(3);

  MyLine(0, 0, 0, 1);
  MyLine(0, 1, 1, 0);
  MyLine(0, 0, 1, 0);

  strokeWeight(1);

  double [] circumcenter=TrinoulliMiniball.TrinoulliFisherRaoBC(ps,1000);
  
//  System.out.println("circumcenter:"+circumcenter[0]+" "+circumcenter[1]+" "+circumcenter[2]);
  
  double rad=FisherRaoDistance(circumcenter,ps[TrinoulliMiniball.FarthestIndex(ps, circumcenter)]);
  
   /*int l;
   for(l=0;l<n;l++)
   {
    if (FisherRaoDistance(circumcenter,ps[l])>rad) System.out.println("error!"); 
   }
  */

drawFRBall(circumcenter, rad);



stroke(0);
fill(0);
 for (i=0; i<n; i++) {
    MyPoint(ps[i][0], ps[i][1]);
    //   println("!!! input point:"+ ps[i][0]+ "  "+ ps[i][1]);
  }
  

 stroke(255,0,0);fill(255,0,0);
ptsize*=2;MyPoint(circumcenter[0],circumcenter[1]);ptsize/=2.0;
}


void drawJFR()
{
  int i, j, ii, jj;


  surface.setTitle("Parameter space of the trinoulli family (#trial=1)");



  background(255, 255, 255);

  int mgrey=128;
  strokefill(mgrey, mgrey, mgrey);
  strokeWeight(3);

  MyLine(0, 0, 0, 1);
  MyLine(0, 1, 1, 0);
  MyLine(0, 0, 1, 0);

  strokeWeight(1);

  if (toggleem) {
    strokefill(255, 0, 0);
    drawEGeodesic(ps[0], ps[1]);   //drawEGeodesic(a,g);

    strokefill(0, 0, 255);
    drawMGeodesic(ps[0], ps[1]); //drawMGeodesic(a,g);


    strokefill(255, 0, 255);
    drawFisherRaoGeodesic(ps[0], ps[1]); //drawMGeodesic(a,g);
  }

  strokefill(0, 0, 0);

  /*
 
   strokefill(255, 0, 255);
   drawFisherRaoGeodesic(a,g);
   */

  if (toggleGeodesic) {
    strokefill(255, 0, 255);
    drawFisherRaoGeodesic(a, g); //drawMGeodesic(a,g);
  }

  ptsize*=2;

  if (toggleA) {
    strokefill(255, 0, 0);
    MyPoint(a[0], a[1]);// red arithmetic mean
  }

  if (toggleG) {
    strokefill(0, 0, 255);
    MyPoint(g[0], g[1]);// blue normalized geometric mean
  }

  noFill();
  stroke(0, 255, 0); // green
  MyPoint(c[0], c[1]);// purple Jeffreys

  ptsize*=2.0;

  if (toggleFR) {
    stroke(255, 0, 255);// purple
    MyPoint(fr[0], fr[1]);
  }

  ptsize*=1.5;
  if (toggleIM) {
    stroke(255, 255, 0);// yellow
    MyPoint(gb[0], gb[1]);
  }


  strokefill(0, 0, 0);
  ptsize=5.0f;


  for (i=0; i<n; i++) {
    MyPoint(ps[i][0], ps[i][1]);
    //   println("!!! input point:"+ ps[i][0]+ "  "+ ps[i][1]);
  }


  //if (toggleAnimation){ animate();calculateCenters();}
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
  
   if (key=='1') {mode=1;}
   if (key=='2') {mode=2;}
   if (key=='3') {mode=3;}
   if (key=='4') {mode=4;}
   if (key=='5') {mode=5;}
   
   
     
     
  if (key=='a') {
    toggleAnimation=!toggleAnimation;
  }
  if (key=='q') exit();


  if (key=='t') {
    StandAloneJeffreysHistogramCentroid.Test2();
  }


  if (key=='z') {
    int testd=2;
    while (testd<=256) {
      testPaperSpecial(testd);
      testd*=2;
    }
    // Table export
    System.out.println(supertest);
  }


  if (key=='x') {
    int testd=2;
    while (testd<=256) {
      testPaperGeneral(testd);
      testd*=2;
    }
    // Table export
    System.out.println(supertest);
  }



  if (key=='n') {
    StandAloneJeffreysHistogramCentroid.testJeffreysCentroid();
  }

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
