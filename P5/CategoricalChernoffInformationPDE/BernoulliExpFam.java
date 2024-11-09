// Frank.Nielsen@acm.org

class BernoulliExpFam
{
  
static void  Test()
{
double p1=Math.random();
double p2=Math.random();

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


static double ChernoffExponent(double theta1, double theta2)
{
double alpha=(Gprime(deltaF/deltaTheta)-theta2)/(theta1-theta2);
return alpha;
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
static double eta2theta(double eta){return Gprime(eta);}
static double theta2eta(double theta){return Fprime(theta);}
  
}
