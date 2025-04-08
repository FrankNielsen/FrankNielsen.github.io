// Frank Nielsen, 2nd April 2025


// Implements the Table 1 of
// Nielsen, Frank, and Richard Nock. 
// "The dual Voronoi diagrams with respect to representational Bregman divergences." 2009 Sixth International Symposium on Voronoi Diagrams. IEEE, 2009.

 

double alphaDivergence(double a, double q1, double q2)
{
 return (4.0/(1.0-(a*a))) * ( ((1.0-a)/2.0) *q1 + ((1.0+a)/2.0) *q2 - Math.pow(q1, (1.0-a)/2.0)*Math.pow(q2, (1.0+a)/2.0)  );   
}

// extended
double ekl(double q1, double q2)
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
 
 alpha=0.99;
 
 double k1, k2, k2star;
 
  println("alpha="+alpha);
 
 double alphadiv=alphaDivergence(alpha,q1,q2);
 
 
 double bd,yf,ekl ;
 
 k1=krep(alpha,q1);
  k2=krep(alpha,q2);
  k2star=krep(-alpha,q2);
  
 
 println("alpha divergence:\t\t\t\t"+alphadiv);
 
  bd=BD(alpha,k1,k2);
   println("Bregman divergence on krep:\t\t\t"+bd);
  
  yf=YF(alpha,k1,k2star);
  println("Fenchel-Young divergence on krep:\t\t"+yf);
  
  double aa=-0.99;
  
  k1=krep(aa,q1);
  k2=krep(aa,q2);
 
  bd=BD(aa,k1,k2);
  ekl=ekl(q1,q2);
  
  println("Rep BD "+bd+" vs "+ekl+" (alpha=-1)");
  
}
 
void setup()
{
println("alpha divergences as representational Bregman divergences");
test();}
