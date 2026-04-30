// Frank Nielsen
// April 10 2026


class BetaDivergence
{
  
static double sqr(double x){return x*x;}  
  
// Guaranteed to be non-negative  
static  double eKL(double p, double q)
{return p*Math.log(p/q)+ q-p;}

// Itakura-Saito
static double IS(double p, double q)
{return (p/q)-Math.log(p/q)-1;}

// Half squared
static  double HalfL22(double p, double q)
{return 0.5*sqr(p-q);}
  
// beta>0 and not=1
static  double betaDivergence(double beta, double p, double q)
{


double res= Math.pow(p,beta)+(beta-1)*Math.pow(q,beta)-(beta)*p*Math.pow(q,beta-1);

return res/(beta*(beta-1));
}

static double U(double beta, double u)
{return Math.pow(1+(beta-1)*u,beta/(beta-1));
}

static double Uprime(double beta, double u)
{return Math.pow(1+(beta-1)*u,(beta-1));
}

static double k(double beta, double u)
{return (Math.pow(u,beta-1)-1)/(beta-1);
}


static double kstar(double beta, double u)
{return u;
}


static double Ustar(double beta, double x)
{
 return (Math.pow(x,beta-1)-1)/beta; 
}

static double BDbeta(double beta,double p, double q)
{
 return U(beta,k(beta,p))- U(beta,k(beta,q))-(p-q)* Uprime(beta,k(beta,q));
}

static void Test()
{
  double p=10+10*Math.random();
  double q=10+10*Math.random();
  double beta=Math.random()*3;
  double eps=1.0e-15;
  
System.out.println("beta=0\t"+betaDivergence(eps,p,q)+"\t eKL="+eKL(p,q)) ;  
System.out.println("beta=1\t"+betaDivergence(1-eps,p,q)+"\t IS="+IS(p,q)) ;  
System.out.println("beta=2\t"+betaDivergence(2,p,q)+"\t HalfL22="+HalfL22(p,q)) ;  


 System.out.println("beta="+beta+"\t"+betaDivergence(beta,p,q)+"\t Bregman beta="+BDbeta(beta,p,q)) ;  
}

  
  
}
