//
// Calculate the Kullback-Leibler divergence between truncated exponential distributions
//
// The duo Fenchel-Young divergence
// https://arxiv.org/abs/2202.10726
//
// Frank.Nielsen@acm.org
// March 2022

class KLDTruncatedExponentialDistribution
{
	
	  // CDF of an exponential distribution
  public static double Phi(double lambda, double x)
  {
    return 1.0-Math.exp(-lambda*x);
  } 
  	
// Log-normalizer of the truncated exponential family
  public static double F(double lambda, double a, double b) 
  {
    return -Math.log(lambda)+Math.log(Phi(lambda, b)-Phi(lambda, a));
  }	
  	
  	// KLD between truncated exponential distributions as a duo Bregman divergence B_{F_2,F_1} 
  public static double KLDTruncatedExponential(double lambda1, double a1, double b1, 
  	double lambda2, double a2, double b2)
  {
  	// -(lambda2-lambda1)*(-moment)
  	return  F(lambda2, a2, b2)-F(lambda1, a1, b1)-(lambda2-lambda1)*MinusMean(lambda1,a1,b1);
  }
  
  
    public static double KLDTruncatedExponential(double lambda1, 
  	double lambda2, double a, double b)
  {
  	 
  	return  Math.log(lambda1/lambda2)+Math.log((Phi(lambda2,b)-Phi(lambda2,a))/(Phi(lambda1,b)-Phi(lambda1,a)))
  		-(lambda2-lambda1)*MinusMean(lambda1,a,b);
  }
  
  
  
  /* in maxima
p(x,lambda):=lambda*exp(-lambda*x);
CDF(x,lambda):=1-exp(-lambda*x);
assume(lambda>0);
assume(b>a);
integrate(p(x,lambda)/(CDF(b,lambda)-CDF(a,lambda)),x,a,b);
ratsimp(%);
integrate(x*p(x,lambda)/(CDF(b,lambda)-CDF(a,lambda)),x,a,b);
ratsimp(%);
*/
  // -E[x]
  public static double MinusMean(double lambda, double a, double b)
  {double num,den;
  
  num= (1+lambda*a)*Math.exp(lambda*b)-(1+lambda*b)*Math.exp(lambda*a) ;
  den=lambda*Math.exp(lambda*b)-lambda*Math.exp(lambda*a);
  
  return -num/den;
  }
  
  // numerical integration of -E[X]
  public static double  NumericalIntegrationMean(double lambda, double a, double b, 
    double nbsteps) 
    {
    double dx=(b-a)/(double)nbsteps;
    double sum=0;
    double x;
    double p, q;

    for ( x=a; x<=b; x+=dx)
    {
      p=truncDensity(lambda,x,a,b);
      sum+=p*x;
    }

    return sum*dx;
  } 
  	
  // Truncated exponential distribution density
 public static double truncDensity(double lambda,double x,double a,double b)
 {
 return lambda*Math.exp(-lambda*x)/(Phi(lambda,b)-Phi(lambda,a));	
 }
  	
  	

public static double  NumericalIntegrationKLDTruncatedExponential(double lambda1, double a1, double b1, 
    double lambda2, double a2, double b2, 
    double nbsteps) 

  {
    double alpha, beta;
    double dx=(b1-a1)/(double)nbsteps;
    double sum=0;
    double x;
    double mp=0;
    double mq=0;
    double p, q;

    for ( x=a1; x<=b1; x+=dx)
    {
      p=truncDensity(lambda1,x,a1,b1);
      q=truncDensity(lambda2,x,a2,b2);
      sum+=p*Math.log(p/q);
    }

    return sum*dx;
  } 
  	
  
  public static void main(String [] args)
  {
  	System.out.println("Kullback-Leibler divergence between two truncated exponential distributions");
  	
  	double a1=1+Math.random()*5;
  	double b1=a1+Math.random()*5;
  	double a2=a1-Math.random();
  	double b2=b1-Math.random();
  	double lambda1=1+Math.random();
  	double lambda2=1+Math.random();
  	int nbsteps=10000;
  	
  	 	System.out.println("lambda2:"+lambda2+" a2:"+a2+" b2:"+b2);
  	
  	double mint=NumericalIntegrationMean(lambda2,a2,b2,nbsteps);
  	double m=MinusMean(lambda2,a2,b2);
  	  	System.out.println("moment formula:"+m+" numerical:"+mint);
  		
  	
  	double KLD=KLDTruncatedExponential(lambda1,a1,b1,lambda2,a2,b2);
  	double kld=NumericalIntegrationKLDTruncatedExponential(lambda1,a1,b1,lambda2,a2,b2,nbsteps);
  	
  	System.out.println("formula:"+KLD+" numerical:"+kld);
  	
  	a2=a1;b2=b1;
  	
  	 KLD=KLDTruncatedExponential(lambda1,lambda2,a2,b2);
   kld=NumericalIntegrationKLDTruncatedExponential(lambda1,a1,b1,lambda2,a2,b2,nbsteps);
  	System.out.println("KLD with same truncation support");
  	System.out.println("formula:"+KLD+" numerical:"+kld);
  	
  	
  }
	
}