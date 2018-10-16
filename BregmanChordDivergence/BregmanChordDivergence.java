// 
// Bregman chord divergences
// Bregman tangent divergences
//
// (c) Frank.Nielsen@acm.org October 2018
//

class BregmanChordDivergence
{
 
static double lambda2gamma(double alpha,double beta, double lambda)
{
return lambda*(beta-alpha)+alpha;
}

static double gamma2lambda(double alpha,double beta,double gamma)
{return (gamma-alpha)/(beta-alpha);}	

static double F(double x)
{return x*Math.log(x)-x;
}	


static double gradF(double x)
{return Math.log(x);
}	

static double gradFinv(double x)
{return Math.exp(x);
}	
 
static double BregmanChordDivergence1D(double alpha, double beta,double p, double q)
{
double pprime=(1-alpha)*p+alpha*q;
double qprime=(1-beta)*p+beta*q;

return F(p)-F(pprime)-(((alpha)/(beta-alpha))*(F(pprime)-F(qprime)));	
}


static double BregmanTangentDivergence(double alpha, double p, double q)
{double pprime=(1-alpha)*p+alpha*q;
return F(p)-F(pprime)-alpha*(p-q)*gradF(pprime);
}

 

// Equation of the chord/secant
static double L(double p1, double p2, double x)
{if (p1!=p2)
{
return ((F(p2)-F(p1))/(p2-p1))*(x-p1)+F(p1);
}
else
{ // tangent divergence
return gradF(p1)*(x-p1)+F(p1);
}


}

static double BregmanChordDivergence(double alpha, double beta,double p, double q)
{
double pprime=(1-alpha)*p+alpha*q;
double qprime=(1-beta)*p+beta*q;

return F(p)-L(pprime,qprime,p);	
}

static double BregmanChordDivergenceExpand(double alpha, double beta,double p, double q)
{
double pprime=(1-alpha)*p+alpha*q;
double qprime=(1-beta)*p+beta*q;

return F(p)-(((alpha)/(beta-alpha))*(F(pprime)-F(qprime)))-F(pprime);	
}

static double ChordDivergence(double alpha, double beta, double gamma,double p, double q)
{
double pprime=(1-alpha)*p+alpha*q;
double qprime=(1-beta)*p+beta*q;
double lambda=gamma2lambda(alpha,beta,gamma);
return (1-gamma)*F(p)+gamma*F(q)-((1-lambda)*F(pprime)+lambda*F(qprime));	
}

static double BregmanDivergence(double p, double q)
{return F(p)-F(q)-(p-q)*gradF(q);}



static double JensenDivergence(double a,double p, double q)
{
return ((1-a)*F(p)+a*F(q))-F((1-a)*p+a*q);	
}
 




static double JensenBregmanDivergence(double a,double p, double q)
{double mid=(1-a)*p+a*q;
return (1-a)*BregmanDivergence(p,mid)+a*BregmanDivergence(q,mid);	
}


 



static double ChordDivergence2(double alpha, double beta, double gamma, double p, double q)
{
double pprime=(1-alpha)*p+alpha*q;
double qprime=(1-beta)*p+beta*q;
double lambda=gamma2lambda(alpha,beta,gamma);	
return JensenDivergence(gamma,p,q)-JensenDivergence(lambda,pprime,qprime);	
}
 

 

// Univariate case
public static void Test1()
{
double alpha=Math.random();
double beta=Math.random();
double p=Math.random();
double q=Math.random();
 
 
 System.out.println("alpha="+alpha+" beta="+beta);
 
 
double CBD=BregmanChordDivergence(alpha,beta,p,q);	
double CBDex=BregmanChordDivergenceExpand(alpha,beta,p,q);
double BD=BregmanDivergence(p,q);	
double BDr=BregmanDivergence(q,p);

System.out.println("Bregman chord Div="+CBD+" "+CBDex+"<="+BD);

double CBD1=BregmanChordDivergence(alpha,beta,p,q);
double CBD2=BregmanChordDivergence(beta,alpha,p,q);
System.out.println("Symmetry "+CBD1+" "+CBD2);
double CBDpq=BregmanChordDivergence(alpha,beta,p,q);
double CBDqp=BregmanChordDivergence(alpha,beta,q,p);
System.out.println("Oriented distance "+CBDpq+" "+CBDqp);

double TBD=BregmanChordDivergence(alpha,alpha,p,q);
double TBDex=BregmanTangentDivergence(alpha,p,q);
System.out.println("tangent BD:"+TBD+" "+TBDex);

System.out.println("Two approximations of Bregman divergences");
double epsilon=0.001;
double approx1=(1.0/epsilon)*JensenDivergence(epsilon,p,q);
double approx2=BregmanChordDivergence(1-epsilon,1,p,q);
System.out.println("aJ="+approx1+" aBCD="+approx2+" BD="+BD+" BDr="+BDr+ " eps="+epsilon);
}

 

public static void main(String[] a)
{int i;
System.out.println("Bregman chord divergences");
System.out.println("(c) 2018 Frank Nielsen");


Test1();
 
System.out.println("--- completed ! ---");
 
		
}	
}