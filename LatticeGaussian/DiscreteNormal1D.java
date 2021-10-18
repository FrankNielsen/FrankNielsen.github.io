// Frank.Nielsen@acm.org
// Last updated 15 Oct

class DiscreteNormal1D
{
  // lattice range 
  public static int xmin=-15;
  public static int xmax=15;

  public static double unnormalizedPMF(double i, double   a, double b)
  {
    return Math.exp(2.0*Math.PI*(i*a-0.5*b*i*i));
  }

  // normalizer
  public static double Theta(  double   a, double b)
  {
    double res=0.0d;
    int i, j;

    for (i=xmin; i<=xmax; i++)
    { 
      res+=unnormalizedPMF(i, a, b);
    }  

    return res;
  }


  public static double Theta(  double L, double   a, double b)
  {
    double res=0.0d;
    int i, j;

    for (i=xmin; i<=xmax; i++)
    { 
      double p=i*L;
      res+=unnormalizedPMF(p, a, b);
    }  

    return res;
  }



  public static double RieMean1D(  double   a, double b)
  {
    double res=0.0d;
    int i, j;


    double Z=Theta(a, b);

    for (i=xmin; i<=xmax; i++)
    { 
      res+=i*unnormalizedPMF(i, a, b);
    }  

    return res/Z;
  }

  public static double sqr(double x) {
    return x*x;
  }

  // bug why 2PI
  public static double RieVar1D(  double   a, double b)
  {
    double res=0;
    int i, j;

    double Z=Theta(a, b);
    double mu=RieMean1D(a, b);

    for (i=xmin; i<=xmax; i++)
    { 
      res+=sqr(i-mu)*unnormalizedPMF(i, a, b);
    }  

    return res/Z;
  }

 

 public static double RieCauchySchwarz1D(double   a1, double b1, double   a2, double b2)
  {return RieHolder1D(2,2,a1,b1,a2,b2);
  }
  	

 public static double RieHolder1D(double alpha, double gamma,  double   a1, double b1, double   a2, double b2)
  {
  	double beta=1.0/(1.0-(1.0/alpha)); // conjugate exponent
    double res=0.0;
    int i, j;

double t1,t2,t12;

    double Z1=Theta(a1, b1);
       double Z2=Theta(a2, b2);


t1=t2=t12=0;

    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1)/Z1;
      double q=unnormalizedPMF(i, a2, b2)/Z2;
      
      t12+=Math.pow(p,gamma/alpha)*Math.pow(q,gamma/beta);
      t1+=Math.pow(p,gamma);
      t2+=Math.pow(q,gamma);
       
    }  

    return Math.abs(Math.log(t12/(Math.pow(t1,1.0/alpha)*Math.pow(t2,1.0/beta))));
  }

 public static double Holder1D(double alpha, double gamma,  double   a1, double b1, double   a2, double b2)
  {	double beta=1/(1-(1.0/alpha)); // conjugate exponent
  
  	return Math.abs(Math.log(Math.pow(Theta(gamma*a1,gamma*b1),1.0/alpha)*Math.pow(Theta(gamma*a2,gamma*b2),1.0/beta)/
  	Theta((gamma/alpha)*a1+(gamma/beta)*a2,(gamma/alpha)*b1+(gamma/beta)*b2)));
  }
  
  
   public static double CauchySchwarz1D(   double   a1, double b1, double   a2, double b2)
  {
  	return Math.log(Math.sqrt(Theta(2*a1,2*b1)*Theta(2*a2,2*b2))/(Theta(a1+a2,b1+b2)));
  }
  

  // Stochastic integration
  public static double RieH1D(  double   a, double b)
  {
    double res=0;
    int i, j;


    double Z=Theta(a, b);


    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a, b)/Z;
      res+=p*Math.log(p);
    }  

    return -res;
  }


  public static double H1D(double a, double b)
  {
    double mu=RieMean1D(a, b);
    double var=RieVar1D(a, b);

    return Math.log(Theta(a, b)) -2.0*Math.PI*a*mu + Math.PI*b*(var+mu*mu);
  }



  // Stochastic integration
  public static double RieCrossH1D(  double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;


    double Z1=Theta(a1, b1);
    double Z2=Theta(a2, b2);


    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1)/Z1;
      double q=unnormalizedPMF(i, a2, b2)/Z2;

      res += p*Math.log(q);
    }  

    return -res;
  }

  public static double CrossH1D(double a1, double b1, double a2, double b2)
  {
    double mu1=RieMean1D(a1, b1);
    double var1=RieVar1D(a1, b1);

    return Math.log(Theta(a2, b2)) -2.0*Math.PI*a2*mu1 + Math.PI*b2*(var1+mu1*mu1);
  }



  // Stochastic integration
  public static double RieKL1D(  double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;


    double Z1=Theta(a1, b1);
    double Z2=Theta(a2, b2);


    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1)/Z1;
      double q=unnormalizedPMF(i, a2, b2)/Z2;

      // to avoid NaN
      if (q>1.e-10) res+=p*Math.log(p/q)+q-p;
    }  

    return res;
  }



  public static double RieRenyi1D(double alpha, double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;


    double Z1=Theta(a1, b1);
    double Z2=Theta(a2, b2);


    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1)/Z1;
      double q=unnormalizedPMF(i, a2, b2)/Z2;

      res+= Math.pow(p, alpha)*Math.pow(q, 1-alpha);
    }  

    return Math.log(res)/(alpha-1);
  }

  public static double Renyi1D(double alpha, double   a1, double b1, double a2, double b2)
  {
    return ((alpha/(1-alpha))*Math.log(Theta(a1, b1)/Theta(alpha*a1+(1-alpha)*a2, alpha*b1+(1-alpha)*b2)))
      +Math.log(Theta(a2, b2)/Theta(alpha*a1+(1-alpha)*a2, alpha*b1+(1-alpha)*b2));
  }



  public static double Igamma(double gamma, double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;



    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1); 
      double q=unnormalizedPMF(i, a2, b2);

      res+= p*Math.pow(q, gamma-1);
    }  

    return res;
  }


  public static double RieGamma1D(double gamma, double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;

    return (1/(gamma*(gamma-1)))*Math.log(Igamma(gamma, a1, b1, a1, b1)*Math.pow(Igamma(gamma, a2, b2, a2, b2), gamma-1)/Math.pow(Igamma(gamma, a1, b1, a2, b2), gamma));
  }


  public static double Gamma1D(double gamma, double   a1, double b1, double a2, double b2)
  {
    return (1/(gamma*(gamma-1)))*Math.log(Theta(gamma*a1, gamma*b1)*Math.pow(Theta(gamma*a2, gamma*b2), gamma-1)/Math.pow(Theta(a1+(gamma-1)*a2, b1+(gamma-1)*b2), gamma));
  }


  public static double RieSquaredHellinger1D( double   a1, double b1, double a2, double b2)
  {
    double res=0;
    int i, j;


    double Z1=Theta(a1, b1);
    double Z2=Theta(a2, b2);


    for (i=xmin; i<=xmax; i++)
    { 
      double p=unnormalizedPMF(i, a1, b1)/Z1;
      double q=unnormalizedPMF(i, a2, b2)/Z2;

      res+= sqr(Math.sqrt(p)-Math.sqrt(q));
    }  

    return 0.5*res;
  }


  public static double SquaredHellinger1D( double   a1, double b1, double a2, double b2)
  {
    return 1-(Theta(0.5*(a1+a2), 0.5*(b1+b2))/(Math.sqrt(Theta(a1, b1)*Theta(a2, b2))));
  }


  public static double KL1D(  double   a1, double b1, double a2, double b2)
  {
    //  return  CrossH1D(a1,b1,a2,b2)- CrossH1D(a1,b1,a1,b1);
    double Z1=Theta(a1, b1);
    double Z2=Theta(a2, b2);
    double mu1=RieMean1D(a1, b1);
    double var1=RieVar1D(a1, b1);

    return Math.log(Z2/Z1)-2.0*Math.PI*mu1*(a2-a1)+Math.PI*((b2-b1)*(mu1*mu1+var1));
  }

  // main
  public static void main(String [] args)
  {
    double a1=Math.random(), b1=0.1+Math.random();
    double a2=Math.random(), b2=0.1+Math.random();
    double error;

    System.out.println("a1="+a1+" b1="+b1);
    System.out.println("a2="+a2+" b2="+b2); 

    double rh12=RieCrossH1D(a1, b1, a2, b2);
    double h12=CrossH1D(a1, b1, a2, b2);
    error=Math.abs(h12-rh12);

    System.out.println("Approx cross-entropy:"+rh12+" Exact formula:"+h12+" error:"+error);

    double rKL12=RieKL1D(a1, b1, a2, b2);
    double KL12=KL1D(a1, b1, a2, b2);
    error=Math.abs(rKL12-KL12);

    System.out.println("Approx KL:"+rKL12+" Exact formula:"+KL12+" error:"+error);


    double rHellinger12=RieSquaredHellinger1D(a1, b1, a2, b2);
    double Hellinger12=SquaredHellinger1D(a1, b1, a2, b2);
    error=Math.abs(rHellinger12-Hellinger12);

    System.out.println("Approx sqr Hellinger:"+rHellinger12+" Exact formula:"+Hellinger12+" error:"+error);


    double alpha=Math.random();
    double rRenyi12=RieRenyi1D(alpha, a1, b1, a2, b2);
    double Renyi12=Renyi1D(alpha, a1, b1, a2, b2);
    error=Math.abs(rRenyi12-Renyi12);

    System.out.println("alpha="+alpha+" Approx Renyi:"+rRenyi12+" Exact formula:"+Renyi12+" error:"+error);

    double eps=1.0e-5;
    alpha=1+eps;
    rRenyi12=RieRenyi1D(alpha, a1, b1, a2, b2);
    Renyi12=Renyi1D(alpha, a1, b1, a2, b2);
    error=Math.abs(rRenyi12-Renyi12);

    System.out.println("KL] alpha="+alpha+" Approx Renyi:"+rRenyi12+" Exact formula:"+Renyi12+" error:"+error);

    double gamma=Math.random();
    double rgamma12=RieGamma1D(gamma, a1, b1, a2, b2);
    double gamma12=Gamma1D(gamma, a1, b1, a2, b2);
    error=Math.abs(rgamma12-gamma12);

    System.out.println("gamma="+gamma+" Approx gamma div:"+rgamma12+" Exact formula:"+gamma12+" error:"+error);

    gamma=1+1.0e-5;
    rgamma12=RieGamma1D(gamma, a1, b1, a2, b2);
    gamma12=Gamma1D(gamma, a1, b1, a2, b2);
    error=Math.abs(rgamma12-gamma12);

    System.out.println("KL] gamma="+gamma+" Approx gamma div:"+rgamma12+" Exact formula:"+gamma12+" error:"+error);


double Holder12, rHolder12;

//alpha=1+Math.random(); gamma=Math.random();
alpha=Math.random(); gamma=Math.random();


Holder12=Holder1D(alpha,gamma,a1,b1,a2,b2);
rHolder12=RieHolder1D(alpha,gamma,a1,b1,a2,b2);

  System.out.println("Holder alpha="+alpha+" gamma:"+gamma+" Rie Holder:"+rHolder12+" formula:"+Holder12);
 
double CauchySchwarz12, rCauchySchwarz12;

CauchySchwarz12=CauchySchwarz1D(a1,b1,a2,b2);
rCauchySchwarz12=RieCauchySchwarz1D(a1,b1,a2,b2);


  System.out.println("Rie Cauchy-Schwarz:"+rCauchySchwarz12+" formula:"+CauchySchwarz12);
 
 

    double error1=Math.abs(KL12-Renyi12);
    double error2=Math.abs(KL12-gamma12);
    System.out.println("\n\nKL] exact="+KL12+" approx Renyi:"+Renyi12+" error:"+error1+" approx Gamma:"
      +gamma12+" error:"+error2);
    /*
    double mu=RieMean1D(a0,b0);
     double var=RieVar1D(a0,b0);
     System.out.println("mean:"+mu+" variance:"+var);
     
     ah1d=RieH1D(a1, b1);
     h1d=H1D(a1, b1);
     
     System.out.println("Formula:"+h1d+" Rie:"+ah1d);
     */

    /*
    ah1d=RieH1D(a2, b2);
     h1d=H1D(a2, b2);
     
     System.out.println("Formula entropy:"+h1d+" Rie:"+ah1d);  
     */
    /*
    double l=2.5;
     double tl=Theta(l,a1,b1);
     double tlz=Theta(l*a1,l*b1*l);
     
     System.out.println("theta lattice:"+tl+" theta new param:"+tlz); 
     
     
     double   Z=Theta(a2,b2);
     double Zf=Math.sqrt(2.0*Math.PI)*b2;
     System.out.println("Theta:"+Z+" "+Zf); 
     */

    /*    
     double hcross12=RieCrossH1D(a1, b1,a2,b2);
     double formulahcross12=CrossH1D(a1, b1, a2,b2);
     
     System.out.println("Formula cross entropy:"+formulahcross12+" Rie:"+hcross12);
     
     
     double riekl12=RieKL1D(a1, b1,a2,b2);
     double fkl12=formulaKL1D(a1, b1,a2,b2);
     
     System.out.println("KL12: Rie "+riekl12+" Exact formula:"+fkl12);
     */
    System.exit(0);
  }
}
