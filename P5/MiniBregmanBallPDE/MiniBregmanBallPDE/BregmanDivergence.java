class BregmanDivergence
{
String name;
double dd=0.001; // for computing gradients
int type;

BregmanDivergence()
{name="Bregman divergence";
type=0; // not linear
}


double DotProduct(Point p,Point q)
{
return p.x*q.x+p.y*q.y;
}

PPoint BregmanBisector(Point p, Point q)
{
Point  gradp,gradq;
PPoint result=new PPoint();

//System.out.println("Bregman bisector of "+p.x+" "+p.y+" with "+q.x+" "+q.y);

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


double Divergence(Point p, Point q)
	{
	return divergence(p,q)+divergence(q,p);
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


//
// The squared Euclidean distance is a usual Bregman divergence
// F(x)=x^2
//
class EXP extends BregmanDivergence
{

EXP()
{
name="Exponential distance";
}

double Fx(double x)
{
return Math.exp(x);	
}

// Gradient operator
Point gradF(Point p)
{
return new Point(Math.exp(p.x),Math.exp(p.y));
}

// Inverse Gradient Operator
Point gradFinv(Point q)
{
return new Point(Math.log(q.x),Math.log(q.y));
}

// Exponential Euclidean distance
double divergence(Point p, Point q)
{
return Math.exp(p.x)-Math.exp(q.x)-(p.x-q.x)*Math.exp(q.x)+Math.exp(p.y)-Math.exp(q.y)-(p.y-q.y)*Math.exp(q.y);
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

class Csiszar extends BregmanDivergence
{
Csiszar()
	{
	name="Csiszar Divergence (Alpha=0.5)";
	}

double Fx(double x)
{
	return -4.0*Math.sqrt(x);
}

// Gradient operator
Point gradF(Point p)
{
return new Point(-2.0/Math.sqrt(p.x), -2.0/Math.sqrt(p.y));
}

// Inverse Gradient Operator
Point gradFinv(Point p)
{
return new Point(4.0/(p.x*p.x), 4.0/(p.y*p.y));
}

// Csiszar
double divergence(Point p, Point q)
{
return 4.0 * (Math.sqrt(q.x) - Math.sqrt(p.x) + ((p.x-q.x) / (2.0*Math.sqrt(q.x)))) + 4.0 * (Math.sqrt(q.y) - Math.sqrt(p.y) + ((p.y-q.y) / (2.0*Math.sqrt(q.y)))) ;
}

}

//
// Logistic loss 
//
class LogisticLoss extends BregmanDivergence
{
LogisticLoss()
	{
	name="Logistic Loss Divergence";
	}

double Fx(double x)
{
return 	x*Math.log(x)+(1.0-x)*Math.log(1.0-x);
}

// Gradient operator

Point gradF(Point p)
{
return new Point( Math.log(p.x/(1.0-p.x)), Math.log(p.y/(1.0-p.y)) );
}

Point gradFinv(Point p)
{
return new Point( Math.exp(p.x)/(1.0+Math.exp(p.x)), Math.exp(p.y)/(1.0+Math.exp(p.y)));
}


// Logistic loss

double divergence(Point p, Point q)
{
return p.x*Math.log(p.x/q.x)+(1.0-p.x)*Math.log((1.0-p.x)/(1.0-q.x))+ p.y*Math.log(p.y/q.y)+(1.0-p.y)*Math.log((1.0-p.y)/(1.0-q.y));
}


}


//
// Mahalanobis   
//

class Mahalanobis extends BregmanDivergence
{
double[][]A;
double s;

	
Mahalanobis()
	{
	name="Mahalanobis Divergence";
	//type=1;
	
	A=new double[2][2];
	
   	A[0][0]=0.6;
   	A[0][1]=0.4;
   	A[1][0]=0.1;
  	A[1][1]=0.5;
  	
  	s=4.0*A[0][0]*A[1][1]-((A[0][1]+A[1][0])*(A[0][1]+A[1][0]));
    s=1.0/s;
   
    //A is the inverse of the covariance matrix for Mahalanobis distortion
	}


double F(Point p)
{
	return (A[0][0]*p.x*p.x+A[1][1]*p.y*p.y+(A[1][0]+A[0][1])*p.x*p.y);
}

double divergence(Point p, Point q)
{
Point r=new Point(p.x-q.x , p.y-q.y);
return F(r);	
}


Point gradF(Point p)
{
return new Point( 2.0*A[0][0]*p.x+p.y*(A[0][1]+A[1][0]) ,  2.0*A[1][1]*p.y+p.x*(A[0][1]+A[1][0]) );
}


Point gradFinv(Point p)
{


return new Point( s*(2.0*A[1][1]*p.x-(A[0][1]+A[1][0])*p.y)  , s*(2.0*A[0][0]*p.y-(A[0][1]+A[1][0])*p.x ) ) ;
}


}


// End of divergence classes    

