// Frank Nielsen, April 21st, 2025

/*
wolfram alpha:
integral(a + 2 (1 - a) x) log(a + 2 (1 - a) x) dx = ((-2 a x + a + 2 x)^2 log(-2 a x + a + 2 x) - 2 (1 - a) x (a (-x) + a + x))/(2 (2 - 2 a)) 

maxima:
mh(a,x):= (((-2* a* x + a + 2* x)**2) *log(-2 *a* x + a + 2 *x) - 2* (1 - a) *x *(a* (-x) + a + x))/(2* (2 - 2* a));
mh(a,1)-mh(a,0); ratsimp(%);
F(a):=''%;
derivative(F(a),a,1);ratsimp(%);
gradF(a):=''%;
BF(theta1,theta2):=F(theta1)-F(theta2)-(theta1-theta2)*gradF(theta2);
derivative(gradF(a),a,1);ratsimp(%);
g(a):=''%;
*/


double sqr(double x){return x*x;}

double m(double a,double x)
{
 return a+(1-a)*x*2; 
}

double minush(double a, double x)
{
 return   ((sqr(-2* a* x + a + 2* x)) *Math.log(-2 *a* x + a + 2 *x) - 2* (1 - a) *x *(a* (-x) + a + x))/(2* (2 - 2* a));
}

// neg entropy
double F(double a)
{return minush(a,1)-minush(a,0);}

double gradF(double a)
{
  
    return    (a*(a-2)*Math.log(a)-a*a*Math.log(2-a)+2*a*(Math.log(2-a)+1)-2)/(4*sqr(a-1));
    
    //-(a*a*Math.log(a))/(2.0*sqr(a-1))  + ((a*Math.log(a))/(a-1)) + (a/(2.0*(a-1))) - 1.0/4.0;
     
//return 0;
}

double BregmanDivergence(double a,double b)
{
return F(a)-F(b)-(a-b)*gradF(b);
}


double approxKL(double a,double b)
{
 double res=0;
 double x; int nbstep=0;
 double mass=0;
 
 for(x=0;x<=1;x+=0.001)
 {mass+=m(a,x);
   res+=m(a,x)*Math.log(m(a,x)/m(b,x))+m(b,x)-m(a,x);
 nbstep++;}
 
 mass=mass/(double)nbstep;
 println("checking mixture mass:"+mass);
 
 
 return res/(double)nbstep;
}

void setup()
{
 println("mixture family 1d"); 
 
 double theta1=Math.random();
 double theta2=Math.random();
 
 
 double bd=BregmanDivergence(theta1,theta2);
  double akl=approxKL(theta1,theta2);
 
  println("theta1:"+theta1+"\t theta2="+theta2);
 
 println("Bregman divergence:\t"+bd);
  println("Approximate KLD:\t\t"+akl);
  
  double err=Math.abs(bd-akl);
  println("error:"+err);
  
}
