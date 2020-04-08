/*
Implement the formula/expressions for the cumulant-free Kullback-Leibler divergences
 between gamma or beta distributions.
 
 See 
 
 Cumulant-free closed-form formulas for some common (dis)similarities between densities of an exponential family
 https://arxiv.org/abs/2003.02469
 
 (C) 2020 Frank.Nielsen@acm.org
 */

public class CumulantFreeKullbackLeiblerGammaBetaDistributions
{


  public static double digamma(double x) {
  assert x > 0 : 
    x;
    double r, f, t;
    r = 0;
    while (x <= 5) {
      r -= 1 / x;
      x += 1;
    }
    f = 1 / (x * x);
    t = f * (-1 / 12.0 + f * (1 / 120.0 + f * (-1 / 252.0
      + f * (1 / 240.0 + f * (-1 / 132.0 + f * (691 / 32760.0 + f * (-1 / 12.0 + f * 3617 / 8160.0)))))));
    return r + Math.log(x) - 0.5 / x + t;
  }


  static double logGamma(double x) {
    double tmp = (x - 0.5) * Math.log(x + 4.5) - (x + 4.5);
    double ser = 1.0 + 76.18009173    / (x + 0)   - 86.50532033    / (x + 1)
      + 24.01409822    / (x + 2)   -  1.231739516   / (x + 3)
      +  0.00120858003 / (x + 4)   -  0.00000536382 / (x + 5);
    return tmp + Math.log(ser * Math.sqrt(2 * Math.PI));
  }

  static double gamma(double x) 
  { 
    return Math.exp(logGamma(x));
  }

  static double B(double a, double b) {
    return gamma(a)*gamma(b)/gamma(a+b);
  }

  static double pdfBeta(double x, double alpha, double beta)
  {
    return Math.pow(x, alpha-1)*Math.pow(1-x, beta-1.0)/B(alpha, beta);
  }


  static double pdfGamma(double x, double alpha, double beta)
  {
    return Math.pow(beta, alpha)*Math.pow(x, alpha-1.0)*Math.exp(-beta*x)/gamma(alpha);
  }


  static double KLDgamma(double a1, double b1, double a2, double b2)
  {
    return (a1-a2)*digamma(a1)
      -logGamma(a1)+logGamma(a2)
      +a2*Math.log(b1/b2)+a1*(b2-b1)/b1;
  }


  public static void GammaTest()
  {
    double alpha1=2+2*Math.random();
    double beta1=2+5*Math.random();
    double alpha2=2+2*Math.random();
    double beta2=2+5*Math.random();

    double a=alpha1/beta1;
    double b=digamma(alpha1)-Math.log(beta1);

    double omega1=a-Math.sqrt(a*a-Math.exp(2*b));
    double omega2=a+Math.sqrt(a*a-Math.exp(2*b));

    System.out.println("Kullback-Leibler divergence between Gamma densities");

    System.out.println("\talpha1="+alpha1+"\tbeta1="+beta1);
    System.out.println("\talpha2="+alpha2+"\tbeta1="+beta2);
    System.out.println("\t\tomega1="+omega1+"\tomega2="+omega2);
    double res=0.5*(Math.log(pdfGamma(omega1, alpha1, beta1)/pdfGamma(omega1, alpha2, beta2))
      +Math.log(pdfGamma(omega2, alpha1, beta1)/pdfGamma(omega2, alpha2, beta2)));

    double res2=KLDgamma(alpha1, beta1, alpha2, beta2);

    System.out.println("Kullback-Leibler divergence (avg sum of log density ratio:"+res);
    System.out.println("Kullback-Leibler divergence (ordinary formula):"+res2);
  }   



  public static void BetaTest()
  {
    double alpha1=2.0+2*Math.random();
    double beta1=2.0+2*Math.random();
    double alpha2=2.0+2*Math.random();
    double beta2=2.0+2*Math.random();

    System.out.println("\talpha1="+alpha1+"\tbeta1="+beta1);
    System.out.println("\talpha2="+alpha2+"\tbeta1="+beta2);


    double A=digamma(alpha1)-digamma(alpha1+beta1);
    double B=digamma(beta1)-digamma(alpha1+beta1);

    double a=Math.exp(2*A);
    double b=Math.exp(2*B);

    double Delta=b*b-2*(a+1)*b+a*a-2*a+1;

    double omega1=(-b+a+1 - Math.sqrt(Delta))/2.0;
    double omega2=(-b+a+1 + Math.sqrt(Delta))/2.0;

    System.out.println("\t\tomega1="+omega1+"\tomega2="+omega2);


    double klcf=0.5*(Math.log(pdfBeta(omega1, alpha1, beta1)/pdfBeta(omega1, alpha2, beta2))
      +Math.log(pdfBeta(omega2, alpha1, beta1)/pdfBeta(omega2, alpha2, beta2))  );

    System.out.println("Kullback-Leibler divergence between Beta densities");

    System.out.println("Kullback-Leibler divergence (avg sum of log density ratio:"+klcf);


    double kl=KLDbeta(alpha1, beta1, alpha2, beta2);



    System.out.println("Kullback-Leibler divergence (ordinary formula):"+kl);
  }

  static double KLDbeta(double a1, double b1, double a2, double b2)
  {
    return Math.log(B(a2, b2)/B(a1, b1))+(a1-a2)*digamma(a1)+(b1-b2)*digamma(b1)+
      (a2-a1+b2-b1)*digamma(a1+b1);
  }


  public static void main(String [] args)
  {
    System.out.println("Cumulant-free closed-form formulas for some common (dis)similarities between densities of an exponential family");
    GammaTest();
    System.out.println("------------------------------");
    BetaTest();
  }
}
