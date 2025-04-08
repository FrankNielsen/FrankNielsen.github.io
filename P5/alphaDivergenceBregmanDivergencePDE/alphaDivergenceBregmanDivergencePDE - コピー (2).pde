// Frank Nielsen, 2nd April 2025


// Implements the Table 1 of
// Nielsen, Frank, and Richard Nock. 
// "The dual Voronoi diagrams with respect to representational Bregman divergences." 2009 Sixth International Symposium on Voronoi Diagrams. IEEE, 2009.

/*
F(alpha,theta):=(2/(1+alpha)) *(1+((1-alpha)/2)*theta)**(2/(1-alpha));
derivative(F(alpha,theta),theta,1);
derivative(F(alpha,theta),theta,2);
*/

/*
B0(r1,r2):=2*(1+r1)**2-2*(1+r2)**2-4*(r1-r2)*(1+r2);
*/

double alphaDivergence(double q1, double q2)
{
 return (4.0/(1.0-(alpha*alpha))) * ( ((1.0-alpha)/2.0) *q1 + ((1.0+alpha)/2.0) *q2 - Math.pow(q1, (1.0-alpha)/2.0)*Math.pow(q2, (1.0+alpha)/2.0)  );   
}

double alphaDivergence(double a, double q1, double q2)
{
 return (4.0/(1.0-(a*a))) * ( ((1.0-a)/2.0) *q1 + ((1.0+a)/2.0) *q2 - Math.pow(q1, (1.0-a)/2.0)*Math.pow(q2, (1.0+a)/2.0)  );   
}

// extended
double klplus(double q1, double q2)
{
 return q1*Math.log(q1/q2)+q2-q1; 
}

//
double BD(double alpha, double theta1, double theta2)
{
 return F(alpha,theta1)-F(alpha,theta2)-(theta1-theta2)*gradF(alpha,theta2); 
}

double krep(double a, double u)
{
  return (2.0/(1.0-a))*(Math.pow(u,(1-a)/2.0));
}

// alpha-potential function
double F(double a, double theta)
{
 return (2.0/(1+a))*Math.pow(( (1.0-a)/2.0)*theta, 2.0/(1.0-a) ); 
}

double gradF(double a, double theta)
{
  return (2.0/(1.0+a))  * Math.pow(((1-a)/2.0)*theta, (1.0+a)/(1.0-a));
}


double F(double theta)
{
 return (2.0/(1+alpha))*Math.pow(((1-alpha)/2.0)*theta, 2.0/(1.0-alpha) ); 
}



double gradF(double theta)
{
  return (2.0/(1.0+alpha))  * Math.pow(((1-alpha)/2.0)*theta, (1.0+alpha)/(1.0-alpha));
}




double BD(double theta1, double theta2)
{
 return F(theta1)-F(theta2)-(theta1-theta2)*gradF(theta2); 
}




double YF(double a, double theta1, double eta2)
{ // convex conjugate for -alpha
  return  F(a,theta1)+F(-a,eta2)-theta1*eta2;
}

 double alpha=-10+20*Math.random();
//double alpha=0;// Math.random();
//double alpha=0.999;


void test()
{
 double q1=Math.random()*10;
 double q2=Math.random()*10;
 
 double k1=krep(alpha,q1);
 double k2=krep(alpha,q2);
  double k2star=krep(-alpha,q2);
 
  println("alpha="+alpha);
 
 double alphadiv=alphaDivergence(alpha,q1,q2);
 
 
 double bd,yf ;
 
 println("alpha divergence:"+alphadiv);
 
  bd=BD(alpha,k1,k2);
   println("Bregman divergence on krep:"+bd);
  
  yf=YF(alpha,k1,k2star);
  println("Fenchel-Young divergence on krep:"+yf);
  
}

void test2()
{
 double q1=Math.random()*10;
 double q2=Math.random()*10;
 double eq2=gradF(q2);
 double eq1=gradF(q1);
 
 println("alpha="+alpha);
 
 double alphadiv=alphaDivergence(q1,q2);
 
 println("alpha divergence:"+alphadiv);
 
 double bd=BD(q1,q2);
 double yf=YF(alpha,q1,eq2);
 
  double rbd=BD(q2,q1);
  
 println("Bregman divergence:"+yf);
  println("Fenchel-Young divergence:"+bd);
 
   println("reverse Bregman divergence:"+rbd);
   
   double kl=klplus(q1,q2);
      println("klplus  divergence:"+kl);
      double rkl=klplus(q2,q1);
      println("klplus reverse  divergence:"+rkl);
}

void setup()
{
println("alpha divergences as Bregman divergences");
test();}
