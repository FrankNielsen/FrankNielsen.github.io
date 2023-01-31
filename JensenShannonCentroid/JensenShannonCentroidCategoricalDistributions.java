// Frank.Nielsen@acm.org
// (C) Dec. 2019, All rights reserved

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

  public static double alphaKL(double  alpha, double [] p, double [] q)
  {
    double res=0.0;
    int i;
    int d=p.length;

    for (i=0; i<d; i++)  
    {
      res+=p[i]*Math.log(p[i]/((1.0-alpha)*p[i]+alpha*q[i]));
    }


    return res;
  }


  public static double alphaJS(double  alpha, double [] p, double [] q)
  { 
    return 0.5*(alphaKL(alpha, p, q)+alphaKL(alpha, q, p));
  }

  public static double min(double a, double b)
  {
    if (a<b) return a; 
    else return b;
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



  public static  double hcrossPos( double p[], double[] q)
  {
    int d=p.length;
    double   res=0;
    for (int i=0; i<d; i++)
      res+= p[i]*Math.log(q[i])+q[i];

    return -res;
  }    



  public static  double hPos( double p[])
  {
    return hcrossPos(p, p);
  }    


  public static  double KLPos ( double p[], double[] q)
  { 
    return hcrossPos(p, q)-hPos(p);
  }   


  public static  double KLPoscf ( double p[], double[] q)
  {
    int d=p.length;
    double   res=0;
    for (int i=0; i<d; i++)
      res+= p[i]*Math.log(p[i]/q[i])+q[i]-p[i];

    return res;
  }    



  public static  double KLcf ( double p[], double[] q)
  {
    int d=p.length;
    double   res=0;
    for (int i=0; i<d; i++)
      res+= p[i]*Math.log(p[i]/q[i]);

    return res;
  }    



  public static  double [] LERP (double a, double p[], double[] q)
  {
    int d=p.length;
    double [] res=new double[d];
    for (int i=0; i<d; i++)
      res[i]=(1-a)*p[i]+a*q[i];

    return res;
  }


  public static  double K (double a, double p[], double[] q)
  { 
    return KL(p, LERP(a, p, q));
  }

  public static  double JS (double a, double p[], double[] q)
  {
    return 0.5*(K(a, p, q)+K(a, q, p));
  }


  public static  double JSs (double a, double p[], double[] q)
  {
    return 0.5*(KL(LERP(a, p, q), LERP(0.5, p, q))+KL(LERP(1-a, p, q), LERP(0.5, p, q)));
  }


  public static  double JS (double p[], double[] q)
  {

    return 0.5*KL(p, LERP(0.5, p, q))+  0.5*KL(q, LERP(0.5, p, q));
  }


  public static  double JSsetavg (double [][] p, double[] q)
  {
    int n=p.length;
    double res=0.0;
    int i;

    for (i=0; i<n; i++)
    {
      //res+=0.5*KL(p[i], LERP(0.5, p[i], q))+  0.5*KL(q, LERP(0.5, p[i], q));
      res+=JS(p[i], q);
    }

    return res/(double)n;
  }


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

  // primal parameter of a mixture family
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

    //res=CenterMass(p);
    theta=CenterMass(thetaset);
    res=Theta2Lambda(theta);

    double loss=JSsetavg(p, res);

    System.out.println("Initial loss for center of mass:"+loss);
iter=0;

    //for (iter=0; iter<nbiter; iter++)
    while(error>1.e-12)
    {iter++;
      double [] term=new double [D];

      // for all points
      for (k=0; k<n; k++)
      {
        // for all gradF terms to add
        //  System.out.println(theta.length+" "+thetaset[i].length);

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

      System.out.println("update theta");
      
      theta=gradG(term);
      
      res=Theta2Lambda(theta);
      
      double ll=JSsetavg(p, res);
      error=Math.abs(loss-ll);
      loss=ll;

      System.out.println(iter+"\t"+loss+"\t Error:"+error);
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



  public static void JSCentroidCCCP(double [][] p)
  {
   
    int d=p[0].length;
    int n=p.length;
    int i;
    //double [][] p=new double [n][d];
   // for (i=0; i<n; i++) p[i]=randomSimplex(d);
/*
    double [] theta0=Lambda2Theta(p[0]);
    double [] theta1=Lambda2Theta(p[1]);

    double hp=h(p[0]);
    double hfp=-F(theta0);
    System.out.println(hp+" equals "+hfp);

    double js=JS(p[0], p[1]); 
    double jf=J(theta0, theta1);
    System.out.println(js+" equals "+js);

    double [] ttheta0=gradG(gradF(theta0));

    printVector(theta0);
    printVector(ttheta0);


    double [] ttheta1=gradG(gradF(theta1));

    printVector(theta1);
    printVector(ttheta1);
*/
    System.out.println("CCCP"); 
    double [] centroid= JSCentroid(p);
  }



  public static  double JSKL (double [] alpha, double [] w, double p[], double[] q)
  {
    int k=alpha.length;
    double res=0;
    int i;
    double baralpha=0;
    for (i=0; i<k; i++) baralpha+=w[i]*alpha[i];

    for (i=0; i<k; i++)
      res+=w[i]*KL(LERP(alpha[i], p, q), LERP(baralpha, p, q));



    return res;
  }

 


  public static  double JSh (double [] alpha, double [] w, double p[], double[] q)
  {
    int k=alpha.length;
    double res=0;
    int i;
    double baralpha=0;
    for (i=0; i<k; i++) baralpha+=w[i]*alpha[i];

    for (i=0; i<k; i++)
      res+=w[i]*h(LERP(alpha[i], p, q));



    return h(LERP(baralpha, p, q))-res;
  }

  public static double [] randomSimplex(int d)
  {
    double [] res=new double[d];
    int i;
    double csum=0;

    for (i=0; i<d; i++) {
      res[i]=Math.random(); 
      csum+=res[i];
    }
    for (i=0; i<d; i++) {
      res[i]/=csum;
    }
    return res;
  }

  public static double [] randomCube(int d)
  {
    double [] res=new double[d];
    int i;
    double csum=0;

    for (i=0; i<d; i++) {
      res[i]=Math.random();
    }

    return res;
  }
 

 

public static void main(String [] args)
{int n=100; int d=5; int i;

	double [][] pointset=new double [n][d];
	for(i=0;i<n;i++) pointset[i]=drawRandom(d);
		
	double [] jsc=JSCentroid (pointset);
}
 

 
}// end class
