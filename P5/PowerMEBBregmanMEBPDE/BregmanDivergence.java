
//
// Generic Bregman divergence class
//
class BregmanDivergence
{
String name;
double dd=0.001; // for computing gradients
int type;

BregmanDivergence()
{name="Bregman divergence";
type=0; // not linear
}

//
// The convex function F defining the Bregman divergence
//
double Fx(double x)
{
return 1.0;  
}

double Fy(double y)
{
return Fx(y); // by default the same on each axis
}

double F(Point p)
{
return  Fx(p.x)+Fy(p.y);
}
  
/*
Point gradF_Discrete(Point p)
{
Point px=new Point(p.x+dd,p.y);
Point py=new Point(p.x,p.y+dd);
  
return new Point((F(px)-F(p))/dd, (F(py)-F(p))/dd);

}

Point gradFinv_Discrete(Point p)
{
Point px=new Point(p.x+dd,p.y);
Point py=new Point(p.x,p.y+dd);
  
return new Point((p.x*dd)/(F(px)-F(p)), (p.y*dd)/(F(py)-F(p)));    
}
*/
//
// Compute the gradient operators by discretization 
// (In case we do not compute symbolically the exact derivatives)
//
Point gradF(Point p)
{
  return new Point(0,0);
//return gradF_Discrete(p);
}

Point gradFinv(Point q)
{
return new Point(0,0);  
//return gradFinv_Discrete(q);
}

//
// return 0 iff p=q
// return >0 if both p<>q and p,q belongs to the domain
// return <0 if p or q is out of the domain
// F(p)-F(q)-DotProduct(p-q,gradF(q))
//
double divergence(Point p, Point q)
  {
  Point gradFq=gradF(q);
  
  return F(p)-F(q)-((p.x-q.x)*gradFq.x+(p.y-q.y)*gradFq.y);
  }
}

//
// The squared Euclidean distance is a usual Bregman divergence
// F(x)=x^2
//
class L22 extends BregmanDivergence
{

double Fx(double x)
{
return x*x;  
}

L22()
{
name="squared Euclidean distance";
type=1;
}
// Gradient operator
Point gradF(Point p)
{
return new Point(2*p.x,2*p.y);
}

// Inverse Gradient Operator
Point gradFinv(Point q)
{
return new Point(0.5*q.x,0.5*q.y);
}

// Squared Euclidean distance
double divergence(Point p, Point q)
{
return (p.x-q.x)*(p.x-q.x)+(p.y-q.y)*(p.y-q.y);
}

}


class ItakuraSaito extends BregmanDivergence
{
ItakuraSaito()
  {
  name="Itakura-Saito Divergence";
  }

double Fx(double x)
{
return -Math.log(x);
}

// Gradient operator
Point gradF(Point p)
{
return new Point(-1.0/p.x, -1.0/p.y);
}

// Inverse Gradient Operator
Point gradFinv(Point p)
{
return new Point(-1.0/p.x, -1.0/p.y);
}

// Itakura-Saito
double divergence(Point p, Point q)
{
return (p.x/q.x)-Math.log(p.x/q.x)-1.0 + p.y/q.y-Math.log(p.y/q.y)-1.0;
}

}




class KullbackLeibler extends BregmanDivergence
{

KullbackLeibler()
{
name="Kullback-Leibler divergence";
}

double Fx(double x)
{
return x*Math.log(x);  
}

// Gradient operator
Point gradF(Point p)
{
return new Point(Math.log(p.x)+1.0, Math.log(p.y)+1.0);
}

// Inverse Gradient Operator
Point gradFinv(Point p)
{
return new Point(Math.exp(p.x-1.0),Math.exp(p.y-1.0));
}

// Kullback-Leibler divergence
double divergence(Point p, Point q)
{
return p.x*Math.log(p.x/q.x)-(p.x-q.x)+p.y*Math.log(p.y/q.y)-(p.y-q.y);
}

}




class  GaussianKLDivergence extends BregmanDivergence
{
String name="Bregman Divergence Gaussian";
  double dd=0.001; // for computing gradients
  int type;

  GaussianKLDivergence()
{ name="Gaussian KL divergence equivalent BD";
    type=0; // not linear
    System.out.println("Gaussian generator initiated");
  }
 
 
 // Bregman divergence
double divergence(Point p, Point q)
  {
  Point gradFq=gradF(q);
  
  return F(p)-F(q)-((p.x-q.x)*gradFq.x+(p.y-q.y)*gradFq.y);
  }

  double DotProduct(Point p,Point q)
  {
    return p.x*q.x  +  p.y*q.y;
  }

/*
  PPoint BregmanBisector(Point p, Point q)
  {
    Point  gradp,gradq;
    PPoint result=new PPoint();
 
    gradp=gradF(p);
    gradq=gradF(q);

    //
    // Equation of the bisector stored as a projective point
    //
    result.x=gradp.x-gradq.x;
    result.y=gradp.y-gradq.y;

    result.w=F(p)-F(q)+DotProduct(q,gradq)-DotProduct(p,gradp);

    return result;
  }
*/
 
// symmetrized divergence
  double Divergence(Point p, Point q)
  {
    return divergence(p,q)+divergence(q,p);
  }
  
  double F(Point p)
{double theta1=p.x,theta2=p.y;
return    -theta1*theta1/(4.0*theta2)+0.5*Math.log(-Math.PI/theta2);
}

 
 


// Gradient operator \eta
Point gradF(Point p)
{double theta1=p.x,theta2=p.y;
return new Point(-theta1/(2.0*theta2),-1/(2.0*theta2)+(theta1*theta1/(4.0*theta2*theta2)));
}

// Inverse Gradient Operator
Point gradFinv(Point q)
{double eta1=q.x,eta2=q.y;
return new Point(-eta1/(eta1*eta1-eta2),1/(2.0*(eta1*eta1-eta2)));
}

 

}
