// Frank.Nielsen@acm.org
// (mu,sigma^2) parameterization for l
// (x,x^2) is sufficient statistic vector
// 28th July 2022

class UnivariateChernoffGaussian
{
  public static double sqr(double x) {
    return x*x;
  }

  public static double inner(double [] u, double [] v)
  {
    return u[0]*v[0]+u[1]*v[1];
  }

  public static double [] minus(double [] u, double [] v)
  {
    double [] res=new double [2];
    res[0]=u[0]-v[0];
    res[1]=u[1]-v[1];
    return res;
  }

  public static double [] plus(double [] u, double [] v)
  {
    double [] res=new double [2];
    res[0]=u[0]+v[0];
    res[1]=u[1]+v[1];
    return res;
  }
  
  public static double F(double [] t)
  {
    return (-sqr(t[0])/(4.0*t[1])) + 0.5*Math.log(-Math.PI/t[1]);
  }

  public static double G(double [] e)
  {double [] t=E2T(e);
    return inner(t,e)-F(t);
  }
  
  public static double Gcf(double [] e)
  {return -0.5*(Math.log(e[1]-sqr(e[0]))+1+Math.log(2.0*Math.PI));
  }

  public static double [] gradF(double [] t)
  {
    double [] res=new double [2];
    res[0]=-t[0]/(2.0*t[1]);
    res[1]=(-0.5/t[1])+0.25*sqr(t[0]/t[1]);
    return res;
  }

  public static double [] T2E(double [] t)
  {
    return gradF(t);
  }
  
    public static double [] E2T(double [] e)
  {
    double [] res=new double [2];
    res[0]=-e[0]/(sqr(e[0])-e[1]);
    res[1]=0.5/(sqr(e[0])-e[1]);
    return res;
  }
  


  public static double Fl(double [] l)
  {
    return 0.5*Math.log(2.0*Math.PI*l[1]) + (sqr(l[0])/(2.0*l[1]));
  }

  public static double [] L2T(double [] l)
  {
    double [] res=new double [2];
    res[0]=l[0]/l[1];
    res[1]=-0.5/l[1];
    return res;
  }
  
    public static double [] T2L(double [] t)
  {
    double [] res=new double [2];
    res[0]=-t[0]/(2.0*t[1]);
    res[1]=-0.5/t[1];
    return res;
  }
  

  public static double [] L2E(double [] l)
  {
    double [] res=new double [2];
    res[0]=l[0];
    res[1]=l[0]*l[0]+l[1];
    return res;
  }
  
    public static double [] E2L(double [] e)
  {
    double [] res=new double [2];
    res[0]=e[0];
    res[1]=e[1]-sqr(e[0]); 
    return res;
  }


  public static double KLD(double [] l1, double [] l2)
  {// 1/2 of squared Mahalanobis + Itakura-Saito divergence
    return 0.5*( (sqr(l2[0]-l1[0])/l2[1]) + (l1[1]/l2[1]) - Math.log(l1[1]/l2[1]) -1);
  }

  public static double BD(double [] t1, double [] t2)
  {
    return F(t1)-F(t2)-inner(minus(t1, t2), T2E(t2));
  }

  public static double BDdual(double [] e1, double [] e2)
  {
    return G(e1)-G(e2)-inner(minus(e1, e2), E2T(e2));
  }

  public static double FYD(double [] t1, double [] e2)
  {
    return F(t1)+G(e2)-inner(t1,e2);
  }

  public static double FYDdual(double [] e1, double [] t2)
  {
    return G(e1)+F(t2)-inner(e1,t2);
  }
  
   public static void print(double [] v)
   {
   	System.out.println(v[0]+" "+v[1]);
   }
   
     public static void checkInvariance()
     {
     	
     	 double [] l, ll1,ll2, l1, l2, t1, t2, e1, e2;
    l=new double [2];
    l1=new double [2];
    l2=new double [2];
    ll1=new double [2];
    ll2=new double [2];
    
    l[0]=Math.random();
    l[1]=1+5*Math.random();
    
    l1[0]=Math.random();
    l1[1]=1+5*Math.random();
    
    l2[0]=Math.random();
    l2[1]=1+5*Math.random();
    
    double kl12=KLD(l1,l2);
    
    ll1[0]=(l1[0]-l[0])/Math.sqrt(l[1]);
    ll1[1]=l1[1]/l[1];
    
    ll2[0]=(l2[0]-l[0])/Math.sqrt(l[1]);
    ll2[1]=l2[1]/l[1];
    
    double klinv12=KLD(ll1,ll2);
    
    System.out.println("KLD:"+kl12+ "  "+klinv12);
     }
     
     public static double malpha(double [] l1, double [] l2, double a)
     {
     	return (a*(l1[0]*l2[1]-l2[0]*l1[1])+l2[0]*l1[1])/(l1[1]+a*(l2[1]-l1[1]));
     }
     
      public static double valpha(double [] l1, double [] l2, double a)
     {
     	return (l1[1]*l2[1])/(l1[1]+a*(l2[1]-l1[1]));
     }
     
     public static double [] LERP(double [] t1, double [] t2, double a)
     {double [] res=new double [2];
     res[0]=(1-a)*t1[0]+a*t2[0];
      res[1]=(1-a)*t1[1]+a*t2[1];
     return res;
     }
     
     public static double ChernoffExponentMVN(double [] l1, double [] l2)
{
double []  t1, t2;
t1=L2T(l1);
t2=L2T(l2);
 
double alphamin=0, alphamax=1, alphamid, eps=1.0e-8;
double [] theta;
int iter=1;
// Bisection search on the theta-geodesic
// (could be more effective if we use the Hessian norm and not halving alpha)
do{
alphamid=0.5*(alphamin+alphamax);

theta=LERP(t1,t2,alphamid);

if (BD(t1,theta)<BD(t2,theta))
{alphamin=alphamid;}
else
alphamax=alphamid;	
	iter++;
}
while(Math.abs(alphamax-alphamin)>eps);

System.out.println("nbiter:"+iter);
// here we reverse the conversion interpolation LERP-traditional exponent convention
return (0.5*(alphamin+alphamax));
}
   
  public static void main(String [] args)
  {
    System.out.println("Chernoff information for univariate Gaussian distributions");
    
    
    //ok checkInvariance(); System.exit(0);
    
    double [] l1, l2, t1, t2, e1, e2, ll1,ll2, talpha;
    l1=new double [2];
    l2=new double [2];
    
    l1[0]=Math.random();
    l1[1]=1+5*Math.random();
    
    l2[0]=Math.random();
    l2[1]=1+5*Math.random();
    
    l1[0]=1;l1[1]=2;
    l2[0]=3;l2[1]=4;
        t1=L2T(l1);
    t2=L2T(l2);
    
    e1=T2E(t1);
    e2=T2E(t2);
    
    ll1=E2L(e1);
     ll2=E2L(e2);
    
    double alphastar=ChernoffExponentMVN(l1,l2);
    double [] thetaalphastar=LERP(t1,t2,alphastar);
    
    System.out.println("alphastar:"+alphastar+ " CI:"+BD(t1,thetaalphastar)+" "+BD(t2,thetaalphastar));
//1 2 3 4 alphastar 0.41842542216181755
// CI 0.201318867143498

double [] etastar=T2E(thetaalphastar);

double ma=malpha(l1,l2,1-alphastar);
double va=valpha(l1,l2,1-alphastar);

System.out.println("ma:"+etastar[0]+" "+ma);
System.out.println("va:"+etastar[1]+" "+va);

double testOC=inner(minus(t2,t1),etastar)-F(t2)+F(t1);
System.out.println("Check optimality condition:"+testOC); // ok

double a12, b12, c12;
a12=(l2[0]/l2[1])-(l1[0]/l1[1]);
b12=0.5/l1[1]-0.5/l2[1];
c12=0.5*Math.log(l1[1]/l2[1])+(sqr(l1[0])/(2*l1[1]))-(sqr(l2[0])/(2*l2[1]));
double testOCd=a12*etastar[0]+b12*etastar[1]+c12;
    System.out.println("Check optimality condition direct:"+testOCd);
    
double d12=l1[0]*l2[1]-l2[0]*l1[1];
double DeltaV=l2[1]-l1[1];
double A12=a12*d12*DeltaV;
double B12=l1[1]*a12*d12 + a12*l2[0]*l1[1]+c12*DeltaV;
double C12=b12*l1[1]*l2[1]+c12*l1[1];
      
double  Delta=B12*B12-4*A12*C12;
double alphaqe=(-B12-Math.sqrt(Delta))/(2*A12);
   	  System.out.println("Delta:"+Delta+" alpha:"+alphaqe);
    	
    //print(l1);print(ll1);
    
    
    // ok System.out.println(F(t1)+" "+Fl(l1));
    	
//System.out.println(G(e1)+" "+Gcf(e1));


    double kld12=KLD(l1, l2);
    double kld21=KLD(l2, l1);
    
    double bd21=BD(t2, t1);
     double bd12=BD(t1, t2);
     
    double bdd12=BDdual(e1,e2);
double bdd21=BDdual(e2,e1);

double fyd12=FYD(t1,e2);
double fydd12=FYDdual(e2,t1);
double fyd21=FYD(t2,e1);
double fydd21=FYDdual(e1,t2);

    System.out.println("KLD12:"+kld12+" BD21:"+bd21+" BD dual 12:"+bdd12+" "+fyd21+" "+fydd21);
    
    System.out.println("KLD21:"+kld21+" BD12:"+bd12+" BD dual 21:"+bdd21+" "+fyd12+" "+fydd12);
  }
}
