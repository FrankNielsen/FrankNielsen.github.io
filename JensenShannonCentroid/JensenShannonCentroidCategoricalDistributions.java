// (C) Dec. 2019, All rights reserved by Frank Nielsen, Frank.Nielsen@acm.org
/*
This program implements the convex-concave procedure for finding the Jensen-Shannon centroid
 of a set of n histograms.
 
 See: On a Generalization of the Jensen?Shannon Divergence and the Jensen?Shannon Centroid
 by Frank Nielsen
 Entropy 2020, 22(2), 221; https://doi.org/10.3390/e22020221
 https://www.mdpi.com/1099-4300/22/2/221
 
 */

class JensenShannonCentroidCategoricalDistribution
{

  //
  // Draw a normalized histogram or mutinoulli distribution
  //
  public static double [] drawRandom(int d)
  {
    int i;
    double csum=0.0;
    double [] res=new double[d];

    for (i=0; i<d; i++) {
      res[i]=Math.random();
      csum+=res[i];
    }
    for (i=0; i<d; i++) res[i]/=csum;

    return res;
  }

  public static  double hcross( double p[], double[] q)
  {
    int d=p.length;
    double   res=0;
    for (int i=0; i<d; i++)
      res+= p[i]*Math.log(q[i]);

    return -res;
  }

  public static  double h( double p[])
  {
    return hcross(p, p);
  }


  public static  double KL ( double p[], double[] q)
  {
    return hcross(p, q)-h(p);
  }




  // Linear interpolation
  public static  double [] LERP (double a, double p[], double[] q)
  {
    int d=p.length;
    double [] res=new double[d];
    for (int i=0; i<d; i++)
      res[i]=(1-a)*p[i]+a*q[i];

    return res;
  }



  public static  double JS (double p[], double[] q)
  {
    return 0.5*KL(p, LERP(0.5, p, q))+  0.5*KL(q, LERP(0.5, p, q));
  }

  // Objective function to minimize
  public static  double JSsetavg (double [][] p, double[] q)
  {
    int n=p.length;
    double res=0.0;
    int i;

    for (i=0; i<n; i++)
    {
      res+=JS(p[i], q);
    }

    return res/(double)n;
  }

  // center of mass of the histograms
  public static  double [] CenterMass (double [][] p)
  {
    int n=p.length;
    int d=p[0].length;
    double [] res=new double [d];

    int i, j;

    for (i=0; i<n; i++)
    {
      for (j=0; j<d; j++)
        res[j]+=p[i][j];
    }

    for (j=0; j<d; j++)
      res[j]/=(double)n;

    return res;
  }

  // primal parameter of a mixture family parameter, drop last coordinate
  public static  double [] Lambda2Theta(double [] lambda)
  {
    int D=lambda.length-1;
    int i;
    double [] res=new double [D];

    for (i=0; i<D; i++)
      res[i]=lambda[i];

    return res;
  }

  // Primal to source parameter conversion
  public static  double [] Theta2Lambda(double [] theta)
  {
    int D=theta.length;
    int i;
    double [] res=new double [D+1];
    double csum=0.0;

    for (i=0; i<D; i++)
    {
      res[i]=theta[i];
      csum+=theta[i];
    }

    // Normalized histogram
    res[D]=1.0-csum;

    return res;
  }

  // Shannon neg entropy for h(p)=-F(theta(p))
  public static  double F (double [] theta)
  {
    int D=theta.length;
    int i;
    double res=0;
    double csum=0.0;

    for (i=0; i<D; i++)
    {
      res+=theta[i]*Math.log(theta[i]);
      csum+=theta[i];
    }

    double theta0=1.0-csum;
    res+=theta0*Math.log(theta0);


    return res;
  }

  // Jensen divergence
  public static  double J(double [] theta1, double [] theta2)
  {
    return 0.5*(F(theta1)+F(theta2))-F(HalfVector(theta1, theta2));
  }

  public static  double [] gradF (double [] theta)
  {
    int D=theta.length;
    int i;
    double [] res=new double [D];
    double csum=0.0;

    for (i=0; i<D; i++)
      csum+=theta[i];

    for (i=0; i<D; i++)
    {
      res[i]=Math.log(theta[i]/(1.0-csum)) ;
    }


    return res;
  }


  // gradF^{-1}
  public static  double [] gradG (double [] eta)
  {
    int D=eta.length;
    int i;
    double [] res=new double [D];
    double csum=0.0;

    for (i=0; i<D; i++)
      csum+=Math.exp(eta[i]);



    for (i=0; i<D; i++)
    {
      res[i]=Math.exp(eta[i])/(1.0+csum);
    }



    return res;
  }


  public static  double []  HalfVector(double [] v1, double v2[])
  {
    int i, d=v1.length;
    double [] res=new double[d];

    for (i=0; i<d; i++) res[i]=0.5*(v1[i]+v2[i]);

    return res;
  }

  //
  // Convex ConCave Procedure (CCCP) for calculating the Jensen-Shannon centroid
  //
  public static  double [] JSCentroid (double [][] p)
  {
    int n=p.length;
    int d=p[0].length;
    int D=d-1; // order
    double [] res;
    double [] theta=new double[D];

    int iter, nbiter=5;
    int i, j, k;

    double [][] thetaset=new double[n][D];
    double error=1.0;

    for (i=0; i<n; i++) {
      thetaset[i]=Lambda2Theta(p[i]);
    }
    // initialize to center of mass
    theta=CenterMass(thetaset);
    res=Theta2Lambda(theta);

    double loss=JSsetavg(p, res);

    System.out.println("Initial objective function for histogram center of mass:"+loss);
    iter=0;


    while (error>1.e-12)
    {
      iter++;
      double [] term=new double [D];

      // compute a quasi-arithmetic mean
      // for all points
      for (k=0; k<n; k++)
      {
        // for all gradF terms to add
        double [] hv=HalfVector(theta, thetaset[k]);
        double [] gf=gradF(hv);

        // accumulate the sum of gradients per coordinate
        for (j=0; j<D; j++)
        {
          term[j]+=gf[j];
        }
      } // for all theta point parameters

      // normalize
      for (j=0; j<D; j++) {
        term[j]/=(double)n;
      }

      theta=gradG(term);
      // convert to histogram parameters
      
      res=Theta2Lambda(theta);
      // update objective function
      double ll=JSsetavg(p, res);
      // monotone convergence, shall be positive
      error=loss-ll;
      loss=ll;

      System.out.println("Iteration #"+iter+"\tObjective:"+loss+"\t Delta error:"+error);
    }


    return res;
  }


  public static void printVector(double [] v)
  {
    int d=v.length;
    String s="";
    for (int i=0; i<d; i++) s=s+" "+v[i];
    System.out.println(s);
  }


  public static void main(String [] args)
  {
  int n=15, d=10, i;
  double [][] pointset=new double [n][d];
 
   // int n=2, d=2, i; 
 // double [][] pointset={{0.1,0.9},{0.2,0.8}};
 // double [][] pointset={{0.15,0.85},{0.5,0.5}};
  	
    System.out.println("Jensen-Shannon centroids of n="+n+" normalized histograms with d="+d+" bins");
   
    for (i=0; i<n; i++) pointset[i]=drawRandom(d);
    double [] jsc=JSCentroid (pointset);

    System.out.println("Jensen-Shannon centroid:");
    printVector(jsc);
  }
}// end class
