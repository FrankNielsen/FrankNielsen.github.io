// Frank.Nielsen@acm.org

// see 
// Quasi-arithmetic Centers, Quasi-arithmetic Mixtures, and the Jensen-Shannon-Divergences

class LegendreTransformation
{
  
static double F(double theta)
{return theta*Math.log(theta)-theta;} 
  
static double gradF(double theta)
{return Math.log(theta);} 

static double gradG(double eta)
{return Math.exp(eta);} 

static double G(double eta)
{
//double theta=gradG(eta); 
//return eta*theta-F(theta);
return Math.exp(eta);
} 
// ok


static double BDF(double x1, double x2)
{return F(x1)-F(x2)-(x1-x2)*gradF(x2);}


static double BDG(double y1, double y2)
{return G(y1)-G(y2)-(y1-y2)*gradG(y2);}

static double YFDF(double x1, double y2)
{return F(x1)+G(y2)-(x1*y2);}

// transformed set of functions

static double lambda,a,b,c,d;

static double Ft(double x)
{return lambda*F(a*x+b)+c*x+d;} 
  
static double gradFt(double x)
{return lambda*a*gradF(a*x+b)+c;} 

static double gradGt(double y)
{return (1/a)*gradG((y-c)/(lambda*a))-b/a;} 

static double Gt(double y)
{
return lambda*G((y-c)/(lambda*a)) - (b*(y-c)/a) - d;
//double xt=gradGt(y); return y*xt-Ft(xt);
}


static double BDFt(double x1, double x2)
{return Ft(x1)-Ft(x2)-(x1-x2)*gradFt(x2);}


static double BDGt(double y1, double y2)
{return Gt(y1)-Gt(y2)-(y1-y2)*gradGt(y2);}


static double YFDFt(double x1, double y2)
{return Ft(x1)+Gt(y2)-(x1*y2);}


static void test()
{
System.out.println("Legendre transformation test...");  
lambda=1 +Math.random()*4;
a=Math.random()*3+1; b=Math.random()*3; c=Math.random()*3; d=Math.random()*3;
//a=1; b=0; c=0; d=0;

double iszero;


double x=3+Math.random()*30, y=gradF(x);

 iszero=F(x)+G(y)-y*x;
 System.out.println("Fenchel-Young zero equality:"+iszero); // yes

double xt=x; // =a*x+b;
double yt=gradFt(xt);
double xxt=gradGt(yt);

System.out.println("reciprocal? "+xt+" vs "+ xxt); // yes


  iszero=Ft(xt)+Gt(yt)-yt*xt;

System.out.println("gen Fenchel-Young zero equality:"+iszero);


double x1=3+Math.random()*30;
double x2=3+Math.random()*30;
double y1=gradF(x1), y2=gradF(x2);

double xt1, xt2;

xt1=(x1-b)/a;
xt2=(x2-b)/a;

double yt1, yt2;



double bd=BDF(x1,x2);
double dbd=BDG(y2,y1);
double yfd=YFDF(x1,y2);

System.out.println("BD(x1,x2)="+bd+" "+dbd+" "+yfd);

double bdbar=(1.0/lambda)*BDFt(xt1,xt2);

yt1=gradFt(xt1); // ????lambda*a*y1+c;
yt2=gradFt(xt2);

double dbdbar=(1.0/lambda)*BDGt(yt2,yt1);
double yfdbar=(1.0/lambda)*YFDFt(xt1,yt2);


System.out.println("BDt(xt1,xt2)="+bdbar); // ok

  
}

}
