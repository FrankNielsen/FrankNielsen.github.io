// Frank Nielsen, 2nd April 2025

/*
F(alpha,theta):=(2/(1+alpha)) *(1+((1-alpha)/2)*theta)**(2/(1-alpha));
derivative(F(alpha,theta),theta,1);
derivative(F(alpha,theta),theta,2);
*/

double alphaDivergence(double q1, double q2)
{
 return (4.0/(1-alpha*alpha)) * ( ((1-alpha)/2.0)*q1 + ((1+alpha)/2.0)*q2 - Math.pow(q1,(1-alpha)/2.0)*Math.pow(q2,(1+alpha)/2.0)  );   
  
}


double klplus(double q1, double q2)
{
 return q1*Math.log(q1/q2)+q2-q1; 
}

double F(double theta)
{
 return (2.0/(1+alpha))*Math.pow(1+((1-alpha)/2.0)*theta,2.0/(1.0-alpha)); 
}

double gradF(double theta)
{
  return (2.0/(1+alpha))*Math.pow(1+((1-alpha)/2)*theta,(1+alpha)/(1-alpha));
}

double BD(double theta1, double theta2)
{
 return F(theta1)-F(theta2)-(theta1-theta2)*gradF(theta2); 
}

// double alpha=Math.random()*5;
//double alpha=Math.random();
double alpha=-0.99;

void test()
{
 double q1=Math.random()*10;
 double q2=Math.random()*10;
 
 double alphadiv=alphaDivergence(q1,q2);
 
 println("alpha divergence:"+alphadiv);
 
 double bd=BD(q1,q2);
  double rbd=BD(q2,q1);
  
 println("Bregman divergence:"+bd);
   println("reverse Bregman divergence:"+rbd);
   
   double kl=klplus(q1,q2);
      println("klplus  divergence:"+kl);
}

void setup()
{
println("alpha divergences as Bregman divergences");
test();}
