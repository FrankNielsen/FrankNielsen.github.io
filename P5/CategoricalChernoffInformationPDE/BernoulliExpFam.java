// Frank.Nielsen@acm.org

class BernoulliExpFam
{
  
static void  Test()
{
double p1=Math.random();
double p2=Math.random();

// p1=0.1; p2=0.2;

  double t1=lambda2theta(p1);
  double t2=lambda2theta(p2);
  
double kl=KL(p1,p2);
double bf=BF(t2,t1);

System.out.println("KL BF:"+kl+" vs "+ bf);

double e1=theta2eta(t1);
double e2=theta2eta(t2);

double bfe=BG(e1,e2);
double cd=CD(t2,e1);

System.out.println("BG CD :"+bfe+" vs "+ cd);

double alpha=ChernoffExponent(t1,t2);
double alphacf=ChernoffExponentCF(t1,t2);

System.out.println("Chernoff exponent:"+alpha+" vs CF="+alphacf);
 

double thetastar=alpha*t1+(1-alpha)*t2;

double lambdastar=theta2lambda( thetastar);
double lambdastarCF=ChernoffDistributionCF(p1,p2);

System.out.println("Chernoff distribution:"+lambdastar+" vs CF= "+lambdastarCF);



//
double cikl1=KL(lambdastar,p1);
double cikl2=KL(lambdastar,p2);

double ci=ChernoffInformationCF(p1,p2);
// KL(cd:p)=KL(cd:q)
System.out.println("Chernoff Information:"+cikl1+" "+cikl2+ " vs CF="+ci);

}

  
static double KL(double p, double q)
{return p*Math.log(p/q)+(1-p)*Math.log((1-p)/(1-q));
}  

static double BF(double theta1, double theta2)
{return F(theta1)-F(theta2)-(theta1-theta2)*Fprime(theta2);}


static double BG(double eta1, double eta2)
{return G(eta1)-G(eta2)-(eta1-eta2)*Gprime(eta2);}

static double CD(double theta1, double eta2)
{return F(theta1)+G(eta2)-theta1*eta2;}

  
static double F(double theta)
{return Math.log(1+Math.exp(theta));}

static double Fprime(double theta)
{return Math.exp(theta)/(1+Math.exp(theta));}


static double ChernoffDistributionCF(double p1, double p2)
{double a=(p1/p2);
double b=(1.0-p1)/(1.0-p2);

 double c=Math.log(-Math.log(b)/Math.log(a))/Math.log(a/b);
 
 return 1.0/(1.0+Math.exp(c*Math.log(b/a)));
}


static double skewBhattacharryaDivergence(double alpha,double p1, double p2)
{
 double res=0;
 res=Math.pow(p1,alpha)*Math.pow(p2,1-alpha)+Math.pow(1-p1,alpha)*Math.pow(1-p2,1-alpha);
 return -Math.log(res);
  
}

static double ChernoffInformationCF(double p1, double p2)
{
  double alpha=ChernoffExponentLambdaCF(p1,p2);
  return skewBhattacharryaDivergence(alpha,p1,p2);
}

static double ChernoffInformationCFfinal(double p1, double p2)
{double a=(p1/p2);
double b=(1.0-p1)/(1.0-p2);
double d=-Math.log(b)/Math.log(a);

  double t1,t2,t3;
  
  //t1=-Math.log(-(Math.log(b)/Math.log(a)) *1/(p1-p1*Math.log(a)/Math.log(b))) * (Math.log(b)/Math.log(a));
  
  t1=-Math.log(d/(p1*(1+d)))*Math.log(b) + Math.log(Math.log(a)/((1-p1)*Math.log(a/b)))*d;
  
  t2= Math.log(Math.log(a)/((1.0-p1)*Math.log(a/b)));
  
  t3=(1.0+d);
 
 return (t1+t2) /t3;
}


static double ChernoffExponent(double theta1, double theta2)
{
double deltaF=F(theta2)-F(theta1);
double deltaTheta=theta2-theta1;

double alpha=(Gprime(deltaF/deltaTheta)-theta2)/(theta1-theta2);

return alpha;
}


static double ChernoffExponentLambdaCF(double p1, double p2)
{
double a,b;
 

a=(p1/p2);
b=((1.0-p1)/(1.0-p2));


return Math.log( (Math.log(b)/Math.log(a))* (1-(1/p2) ))/(Math.log(a)-Math.log(b));

}


// CF= closed form
static double ChernoffExponentCF(double theta1, double theta2)
{
double a,b;
double p1=theta2lambda(theta1);
double p2=theta2lambda(theta2);

a=(p1/p2);
b=((1.0-p1)/(1.0-p2));


return Math.log( (Math.log(b)/Math.log(a))* (1-(1/p2) ))/(Math.log(a)-Math.log(b));

//return Math.log(Math.log(b)*(1-(1/p2))/Math.log(a))/Math.log(a/b);
}

static double Gprime(double eta)
{
return Math.log(eta/(1-eta));
}

// negentropy (bcs k(x)=0)
static double G(double eta)
{
  return eta*Math.log(eta)+(1-eta)*Math.log(1-eta);
//return eta*Math.log(eta/(1-eta))-Math.log(1/(1-eta));  
}
 
static double lambda2theta(double p) {return Math.log(p/(1-p));}

static double theta2lambda(double theta) {return Math.exp(theta)/(1+Math.exp(theta));}


static double eta2theta(double eta){return Gprime(eta);}
static double theta2eta(double theta){return Fprime(theta);}
  
}
