// Frank Nielsen, April 20 2025

/*
integral(a + (1 - a) x) log(a + (1 - a) x) dx = 
1/2 (1/2 (a - 1) x^2 - a x - ((a (-x) + a + x)^2 log(a (-x) + a + x))/(a - 1)) 

% cross-entropy

integral(-a + (1 - a) x) log(b + (1 - b) x) dx = -(((1 - a) x (-2 a b + a + b))/(1 - b) - ((-2 a b + a + b)^2 log(b (-x) + b + x))/(b - 1)^2 + ((a - 1) x + a)^2 log(b (-x) + b + x) - 1/2 (a x + a - x)^2)/(2 (a - 1)) + 定数
(複素数値の対数を仮定しています)

% maxima
kill(all);
mh(a,x):=(1/2)* ((1/2)* (a - 1) *x**2 - a *x - ( ((a* (-x) + a + x)**2) * log(a *(-x) + a + x))/(a - 1));
mh(a,1)-mh(a,0); ratsimp(%);
F(a):=''%;
derivative(F(a),a,1);ratsimp(%);
gradF(a):=''%;
BF(theta1,theta2):=F(theta1)-F(theta2)-(theta1-theta2)*gradF(theta2);
derivative(gradF(a),a,1);ratsimp(%);
g(a):=''%;
plot2d(g(a),[a,0.01,0.99]);
solve([gradF(theta)=eta],theta);
rhs(%[1]);
eta(theta):=''%;
Fstar(eta):=eta*theta(eta)-F(theta(eta));
ratsimp(%);
*/


double sqr(double x){return x*x;}

double m(double a,double x)
{
 return a+(1-a)*x; 
}

double minush(double a, double x)
{
 return  (1.0/2.0) * ((1.0/2.0)* (a - 1.0) * x*x - a* x - ( Math.pow(a* (-x) + a + x,2)*Math.log(a *(-x) + a + x))/(a - 1));
}

// neg entropy
double F(double a)
{return minush(a,1)-minush(a,0);}

double gradF(double a)
{
  
    return    -(a*a*Math.log(a))/(2.0*sqr(a-1))  + ((a*Math.log(a))/(a-1)) + (a/(2.0*(a-1))) - 1.0/4.0;
     
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
 
 for(x=0;x<=1;x+=0.001)
 {
   res+=m(a,x)*Math.log(m(a,x)/m(b,x))+m(b,x)-m(a,x);
 nbstep++;}
 
 
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
