// Frank Nielsen, 1st July 2024

double lambda,a,b,c,d;

// for Poisson 1D
double F(double t){return Math.exp(t);}
double gradF(double t){return Math.exp(t);}

double gradG(double e){return Math.log(e);}
double G(double e){return e*Math.log(e)-e;}

double BF(double t1, double t2)
{return F(t1)-F(t2)-(t1-t2)*gradF(t2);}

double BG(double e1, double e2)
{return G(e1)-G(e2)-(e1-e2)*gradG(e2);}

double YFG(double t1, double e2)
{return F(t1)+G(e2)-t1*e2;}

double YGF(double e1, double t2)
{return F(t2)+G(e1)-t2*e1;}




///



double Fbar(double t){return lambda*F(a*t+b)+c*t+d;}

double gradFbar(double t){return lambda*a*gradF(a*t+b)+c;}


double gradGbar(double e){return (1/a)*gradG((e-c)/(lambda*a))-(b/a);}

double Gbar(double e){return e*gradGbar(e)-Fbar(gradGbar(e));}

double barBF(double t1, double t2)
{return Fbar(t1)-Fbar(t2)-(t1-t2)*gradFbar(t2);}

double barBG(double e1, double e2)
{return Gbar(e1)-Gbar(e2)-(e1-e2)*gradGbar(e2);}

double barYFG(double t1, double e2)
{return Fbar(t1)+Gbar(e2)-t1*e2;}

double barYGF(double e1, double t2)
{return Fbar(t2)+Gbar(e1)-t2*e1;}


void TestAffLegendre()
{
double t1,t2,e1,e2;
double bf12, bg21, yfg12, ygf21;


t1=Math.random(); t2=Math.random();

bf12=BF(t1,t2);

e1=gradF(t1);
e2=gradF(t2);

bg21=BG(e2,e1);

yfg12=YFG(t1,e2);
ygf21=YGF(e2,t1);

println(bf12+" "+bg21+" "+yfg12+" "+ygf21);
  
  double bart1,bart2,bare1,bare2;
  double barbf12, barbg21, baryfg12, barygf21;

  bart1=(t1-b)/a;
  bart2=(t2-b)/a;
  
  bare1=gradFbar(bart1);
  bare2=gradFbar(bart2);
  
  double res=(1.0/lambda)*barBF(bart1,bart2);
  
  println("check invariance BFbar: "+ res);
  
  double res2=  (1.0/lambda)*barBG(bare2,bare2);
 println("check invariance BGbar: "+ res);
  
}


void setup()
{
 println("Affine Legendre 1D invariance"); 
 println("Poisson"); 

lambda=Math.random();
a=Math.random();
b=Math.random();
c=Math.random();
d=Math.random();

TestAffLegendre();

}
