// June 30 2020, updated July 2025 with E[KL]=d/(2n)
// Sensitivity and accuracy of estimators for the normal distribution family]
// Frank.Nielsen@acm.org
// i: Inverse FIM, C: Cov, p: export PDF, SPACE: new set,  a: animation , q :quit etc
// Initialize is the main part where we perform experiments


import processing.pdf.*;
int nbsamples=200;

int maxnbtrials=200;
int nbtrials=100;

double [][] mu;
double [][][] cov;

double [][][] pos;

double [][][] msa;
//msa=new double [nbpos][nbtrials][2];

boolean showIFIM=true;
boolean showCov=true;
boolean animation=false;
boolean animations=false;

double minmu=-5, maxmu=-minmu;
double minsigma=1;
double maxsigma=10.0;
int side=800;

int step=8;

double [][] inverse2x2(double[][] matrix)
{
  double [][]res=new double[2][2];
  double det=matrix[0][0]*matrix[1][1]-matrix[0][1]*matrix[1][0];
  res[0][0] = (double)matrix[1][1] / det;
  res[0][1] = -(double)matrix[0][1] / det;
  res[1][0] = -(double)matrix[1][0] / det;
  res[1][1] = (double)matrix[0][0] / det;
  return res;
}


int nbpos=step*step;
float [][] rgb;

// Box-Muller transform
double standardNormalVariate()
{
  double u1=Math.random(), u2=Math.random();
  return Math.sqrt(-2.0*Math.log(u1))*Math.cos(2.0*Math.PI*u2);
}


double NormalVariate(double mu, double sigma)
{
  return mu+sigma*standardNormalVariate();
}

// draw iid random variates
double [] NormalSamples(double mu, double sigma, int n)
{
  double [] result=new double[n];
  for (int i=0; i<n; i++) result[i]=NormalVariate(mu, sigma);
  return result;
}

double sqr(double x) {
  return x*x;
}

// Maximum Likelihood estimate
double [] MLEstimate(double [] set)
{
  int n=set.length;
  double [] res=new double [2];
  int i;
  double cx=0, cx2=0;
  double m=0, s2=0;

  // cumulative sufficient statistics
  for (i=0; i<n; i++)
  {
    cx+=set[i];
    cx2+=sqr(set[i]);
  }

  m=cx/(double)n;
  s2=(cx2/(double)n)-sqr(m);

  res[0]=m; //mu
  res[1]=Math.sqrt(s2); //sigma  (biased)

  return res;
}

double KLD(double m1, double s1, double m2, double s2)
{
return (sqr(m2-m1)/(2*sqr(s2)))+0.5*(sqr(s1)/sqr(s2)-Math.log(sqr(s1)/sqr(s2))-1);  
  
}

void Initialize()
{
  int i, j, t;
  double mm=(maxmu-minmu)/(double)step;
  double ss=(maxsigma-minsigma)/(double)step;
  double m, s;

  //double [][][] mu=new double [step][step][ ;
  //double [][][][] cov;

  // for each grid point the MLE
  mu=new double [nbpos][2];
  cov=new double[nbpos][2][2];

  // the true mu, sigma positions
  pos=new double[step][step][2];
  int ipos=0;

  // for each position, save the nbtrials estimator
  msa=new double [nbpos][nbtrials][2];

  for (int mi=0; mi<step; mi++)
    for (int si=0; si<step; si++)
    {
      m=minmu+(maxmu-minmu)*mi/(double)step;
      s=minsigma+(maxsigma-minsigma)*si/(double)step;

      // ipos
      pos[mi][si][0]=m;
      pos[mi][si][1]=s;

      double [][] mlearray=new double [nbtrials][2];

      for (t=0; t<nbtrials; t++)
      {
        mlearray[t]=MLEstimate(NormalSamples(m, s, nbsamples));
      }

      double [] ms=new double [2];
      double [][] ccov=new double [2][2];

      //
      // Build sample mean and covariance matrix for the estimator
      //
      for (t=0; t<nbtrials; t++)
      {
        msa[ipos][t][0]=mlearray[t][0];
        msa[ipos][t][1]=mlearray[t][1];

        // cumulative sums
        ms[0]+=mlearray[t][0];
        ms[1]+=mlearray[t][1];
      }

      // mean mu sigma
      ms[0]/=(double)nbtrials;
      ms[1]/=(double)nbtrials;

      double v11=0, v12=0, v22=0;

      // calculate variance-covariance matrix
      for (t=0; t<nbtrials; t++)
      {
        v11+= sqr(mlearray[t][0]-ms[0]);
        v22+= sqr(mlearray[t][1]-ms[1]);
        v12+=  (mlearray[t][0]-ms[0])*(mlearray[t][1]-ms[1]);
      }

      v11/=(double)nbtrials;
      v12/=(double)nbtrials;
      v22/=(double)nbtrials;


      mu[ipos][0]=ms[0];
      mu[ipos][1]=ms[1];  // mu[pos]=ms; //
      cov[ipos][0][0]=v11;
      cov[ipos][1][1]=v22;
      cov[ipos][0][1]=cov[ipos][1][0]=v12;

      ipos++;
    }
}


void setup()
{
  size(800, 800);
  int i;

  // choose color
  rgb=new float[nbpos][3];
  for (i=0; i<nbpos; i++)
  {
    rgb[i][0]=(float)Math.random()*255;
    rgb[i][1]=(float)Math.random()*255;
    rgb[i][2]=(float)Math.random()*255;
  }

  Initialize();

  println("completed initialization!");
}


void draw()
{
  background(255, 255, 255);
  int i, j, t;

  stroke(0, 0, 0);

  int ipos=0;

  for (int mi=0; mi<step; mi++)
  {
    for (int si=0; si<step; si++)
    {
      noFill();

      //draw the MLEs
      stroke(rgb[ipos][0], rgb[ipos][1], rgb[ipos][2]);
      for (t=0; t<nbtrials; t++)
      {
        ellipse(x2X(msa[ipos][t][0]), y2Y(msa[ipos][t][1]), 1, 1);
      }

      // Gaussian asymptomality
      stroke(0, 0, 0);
      fill(0, 0, 0);
      ellipse(x2X(mu[ipos][0]), y2Y(mu[ipos][1]), 5, 5);

      if (showCov)
      {//double [][]icov=inverse2x2(cov[ipos]);
        drawEllipse(mu[ipos], cov[ipos]);
        //drawEllipse(mu[ipos],icov);
      }

      // exact parameter : show inverse Fisher information matrix
      if (showIFIM)
      {
        stroke(255, 0, 0); // red
        fill(255, 0, 0);
        ellipse(x2X(pos[mi][si][0]), y2Y(pos[mi][si][1]), 5, 5);

        double [][] CRLB=new double[2][2];
        double sigma=pos[mi][si][1];

        CRLB[0][0]=sqr(sigma)/(double)nbsamples;
        CRLB[1][1]=(sqr(sigma)/2.0)/(double)nbsamples;
        CRLB[0][1]=CRLB[1][0]=0; // orthogonal parameters
        stroke(255, 0, 0);
        drawEllipse(pos[mi][si], CRLB);
      }

      ipos++;
    }
  }

  if (animations) {
    //nbtrials++;
    nbsamples=(int)(1.1*nbsamples);
  }

  if (animation) {
    //nbtrials++;
    nbtrials=(int)(1.1*nbtrials);
  }

  if ((animations)||(animation)) {
    Initialize();
  }


  surface.setTitle("Accuracy normal MLE n="+nbsamples+" t="+nbtrials);
}

public  float x2X(double x)
{
  return (float)((x-minmu)*side/(maxmu-minmu));
}

// inverse
public  float X2x(double X)
{
  return (float)(minmu+(maxmu-minmu)*((X)/(float)side));
}

public  float Y2y(double Y)
{
  return (float)(minsigma+(maxsigma-minsigma)*((side-Y)/(float)side));
}

public  float y2Y(double y)
{
  return (float)(side-(y-minsigma)*side/(maxsigma-minsigma));
}


void exportPDF()
{
  beginRecord(PDF, "SensitivityAccuracyGaussian-"+millis()+"-samples"+nbsamples+"-trials"+nbtrials+".pdf");
  draw();
  endRecord();
}


void drawEllipse(double [] c, double [][] Cov)
{
  int i, nb=100;
  for (i=0; i<nb; i++)
  {
    double angle1=2.0*Math.PI*i/(double) nb;
    double angle2=2.0*Math.PI*(i+1)/(double) nb;

    double xx1=Math.cos(angle1);
    double yy1=Math.sin(angle1);

    double xx2=Math.cos(angle2);
    double yy2=Math.sin(angle2);

    double x1=c[0]+Cov[0][0]*xx1+Cov[0][1]*yy1;
    double y1=c[1]+Cov[1][0]*xx1+Cov[1][1]*yy1;

    double x2=c[0]+Cov[0][0]*xx2+Cov[0][1]*yy2;
    double y2=c[1]+Cov[1][0]*xx2+Cov[1][1]*yy2;

    line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2));
  }
}

void keyPressed() {

  if (key=='r') {
    nbsamples=256;

    maxnbtrials=200;
    nbtrials=32;
  }

  if (key=='a') {
    animation=!animation;
    println(animation);
  }

  if (key=='s') {
    animations=!animations;
  }

  if (key=='i') {
    showIFIM=!showIFIM;
  }
  if (key=='c') {
    showCov=!showCov;
  }

  if (key=='q') {
    exit();
  }


  if (key==' ') {
    Initialize();
    redraw();
  }
  if (key=='p') {
    exportPDF();
  }
}
