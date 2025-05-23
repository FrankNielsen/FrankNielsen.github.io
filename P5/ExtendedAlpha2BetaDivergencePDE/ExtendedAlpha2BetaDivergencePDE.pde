// convert extended alpha divergences to beta divergenecs


// Frank Nielsen Feb 2019, revised and checked 2025
//
// See also
// Learning the information divergence, TPAMI, 2015

double eKL(double p, double q)
{
  return p*Math.log(p)+q-p;
}



// alpha
double alphaDivergence(double alpha, double p, double q)
{


  double res;

  if (alpha==1.0) {
    return eKL(p, q);
  } //forward
  if (alpha==0.0) {
    return eKL(q, p);
  } //backward

  res= Math.pow(p, alpha)*Math.pow(q, 1-alpha)-alpha*p-(1-alpha)*q;
  res/=(alpha*(alpha-1));

  return res;
}


// alpha for Amari, symmetric around 0
double alphaDivergenceA(double alpha, double p, double q)
{
  double e1=0.5*(1-alpha);
  double e2=0.5*(1+alpha);

  double res;

  if (alpha==1.0) {
    return eKL(q, p);
  }
  if (alpha==-1.0) {
    return eKL(p, q);
  }

  res  =  (e1*p) + (e2*q) -(Math.pow(p, e1)*Math.pow(q, e2));
  res/=(e1*e2);

  return res;
}

// beta>=0
double betaDivergence(double beta, double p, double q)
{
  if (beta==0.0) return eKL(p, q);
  if (beta==-1.0) return IS(p, q);

  double res= Math.pow(p, beta+1)+beta*Math.pow(q, beta+1)-(beta+1)*p*Math.pow(q, beta);
  return res/(beta*(beta+1));
}

// Itakura-Saito
double IS(double p, double q)
{
  return (p/q)-Math.log(p/q)-1;
}


// Eq 47
double betaDivergenceA(double beta, double p, double q)
{
  if (beta==0.0) return IS(p, q);  // Itakura-Saito divergence
  if (beta==1.0) return eKL(p, q); // extended KL divergence

  double res=((Math.pow(p, beta)-p*Math.pow(q, beta-1))/(beta-1)) - (Math.pow(p, beta)-Math.pow(q, beta))/beta;
  return res;
}


double betaDivergence2(double beta, double p, double q)
{
  if (beta==0.0) return eKL(q, p);
  
  double res=((Math.pow(p, beta+1)-Math.pow(q, beta+1))/(beta+1))-q*(Math.pow(p, beta)-Math.pow(q, beta))/beta;
  return res;
}

double sqr(double x) {
  return x*x;
}

double alpha2beta(double alpha)
{
  return (1.0/alpha)-1.0;
}

double embedAlpha2Beta(double alpha, double x)
{
  return Math.pow(x/sqr(alpha), alpha);
}

void setup()
{
  test();
}
 

void test()
{
  
  println("Test the equivalence of alpha-div as beta rep div");
  
  double p=random(0, 10);
  double q=random(0, 10);
  double alpha=random(-10, 10);
  println("p="+p+"\tq="+q+" alpha="+alpha);
  
  double alphaA=1-2*alpha;
  double divalpha=alphaDivergence(alpha, p, q);
  double divalphaA=alphaDivergenceA(alphaA, p, q);
    
  println("ext alpha divergence:\t\t "+divalpha);
  println("ext alph divergence Amari:\t "+divalphaA);
  

  double beta=random(-10, 10);
  double betaA=beta+1;

  double divbeta=betaDivergence(beta, p, q);
  double divbetaA=betaDivergenceA(betaA, p, q);

  println("beta divergence:\t\t\t "+divbeta);
  println("beta divergence Amari:\t\t "+divbetaA);

  //
  // equivalence of alpha divergence to beta
  //
  double dequiv=betaDivergence(alpha2beta(alpha), embedAlpha2Beta(alpha, p), embedAlpha2Beta(alpha, q));
  double error=Math.abs(divalpha-dequiv);

  println("\nEquivalence from alpha to beta:\t "+dequiv+"\tvs\t alpha div:"+divalpha);
  println("error:"+error);
  
 // double dequiv2=betaDivergence(1/alpha, embedAlpha2Beta(alpha, p), embedAlpha2Beta(alpha, q));
  //  println("equivalence from alpha to beta:\t "+dequiv2);
}
