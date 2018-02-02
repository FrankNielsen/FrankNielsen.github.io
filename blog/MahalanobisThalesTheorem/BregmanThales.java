// Frank.Nielsen@acm.org
// October 2017
// Obvious that Thales theorem work for ellipses as well.
// Because remap to sphere and triangle remap to another triangle for which Thales' theorem work


class Point
{
double [] coord;	
}

class Sphere
{
double [] c;
double r;

Sphere(double a, double b, double rr)
{c=new double[2]; c[0]=a;c[1]=b; r=rr;
	}	
}

class BregmanThales
{

public static double inner(double [] x, double [] y)
{double res;
res=x[0]*y[0]+x[1]*y[1];
return res;
	}
	
public static double[] minus(double [] x, double [] y)
{double [] res=new double[2];
res[0]=x[0]-y[0];
res[1]=x[1]-y[1];
	return res;
	}
	
	
public static double primalDualAngle(double[] tp, double[] tq, double[] eq, double[] er)
{
return inner(minus(tp,tq),minus(eq,er)); // 0 if orthogonal	
}

public static double[] LERP(double[] p, double[] q, double l)
{
double [] res=new double[2];
res[0]=(1-l)*p[0]+l*q[0];
res[1]=(1-l)*p[1]+l*q[1];
return res;	
}


public static double[] Ray(double[] p, double[] q, double l)
{
double [] res=new double[2];
res[0]=p[0]+l*q[0];
res[1]=p[1]+l*q[1];
return res;	
}



 // squared Euclidean distance
//static double f(double x){return 0.5*x*x;}
//static double gradf(double x){return x;}

/*
static double f(double[] x){return 0.5*x[0]*x[0]+0.5*x[1]*x[1];}
static double [] gradf(double [] x){
	double [] res=new double[2];
	res[0]=x[0];res[1]=x[1];
	return res;}
*/



 // example of Mahalanobis distance
static double f(double[] x){return 5*x[0]*x[0]+3*x[1]*x[1];}
static double [] gradf(double [] x){
	double [] res=new double[2];
	res[0]=10*x[0];
	res[1]=6*x[1];
	return res;}

	
/*	
static double f(double[] x){return Math.exp(x[0])+Math.exp(x[1]);}

static double [] gradf(double [] x){
	double [] res=new double[2];
	res[0]=Math.exp(x[0]);
	res[1]=Math.exp(x[1]);
	return res;}
*/		
	

/*
static double f(double x){return x*Math.log(x)-x;}
static double gradf(double x){return Math.log(x);}
*/

/*
static double f(double x){return  Math.exp(x);}
static double gradf(double x){return Math.exp(x);}
*/

/*
static double[] gradf(double[] x){double[] res=new double[2]; 
res[0]=gradf(x[0]);
res[1]=gradf(x[1]);
return res;}
*/


//static double divergence(double p, double q){return f(p)-f(q)-(p-q)*gradf(q);}

// dual divergence
//static double divergenced(double p, double q){return f(q)-f(p)-(q-p)*gradf(p);}


 

static double Divergence(double[] p, double[] q)
{
return f(p)-f(q)-inner(minus(p,q),gradf(q));	
//return divergence(p[0],q[0])+divergence(p[1],q[1]);	
}

static double SDivergence(double[] p, double[] q)
{
return  Divergence(p,q)+Divergence(q,p);	
}


/*
static double Divergenced(double[] p, double[] q)
{
return divergenced(p[0],q[0])+divergenced(p[1],q[1]);	
}
*/


// Dichotomic search
/*
public static double [] primalGeo(double [] c, double a, double r)
{double [] res=new double[2];
double [] orient=new double[2];
orient[0]=c[0]+Math.cos(a);
orient[1]=c[1]+Math.sin(a);


double lambda, lambdamin=0, lambdamax=10;

 
 lambda=0.5*(lambdamin+lambdamax);
	
while(Math.abs(Divergence(c,LERP(c,orient,lambda))-r)>1.0e-5)
{
if 	(Divergence(c,LERP(c,orient,lambda))<r) lambdamin=lambda;
else lambdamax=lambda;
 lambda=0.5*(lambdamin+lambdamax);
}


return res;
}
*/


// Discretize a sphere by a polygon
public static double [][] spherePolygon(double [] c, double r, int nb)
{
double [][] res=new double[nb][];
double dangle=Math.PI*2.0/(double)nb;
int i;

for(i=0;i<nb;i++)
{
double a=dangle*i;
res[i]=primalGeo(c,a,r);
}


return res;
	}



// find a point on the ball at distance r up to precision
public static double [] primalGeo(double [] c, double a, double r)
{double [] res=new double[2];
double [] orient=new double[2];

// unit vector
orient[0]=Math.cos(a);
orient[1]=Math.sin(a);
double precision=1.0e-5;


double lambda, lambdamin=0, lambdamax=10; // 10 is out of the ball

 
 lambda=0.5*(lambdamin+lambdamax);
	
while(Math.abs(SDivergence(c,Ray(c,orient,lambda))-r)>precision)
{
if 	(SDivergence(c,Ray(c,orient,lambda))<r) lambdamin=lambda;
else lambdamax=lambda;

 lambda=0.5*(lambdamin+lambdamax);
}
//System.out.println(lambda);

res=Ray(c,orient,lambda);
return res;
}

// find a point on the ball at distance r up to precision
public static double [] symmetrizedGeo(double [] c, double a, double r)
{double [] res=new double[2];
double [] orient=new double[2];

// unit vector
orient[0]=Math.cos(a);
orient[1]=Math.sin(a);
double precision=1.0e-5;


double lambda, lambdamin=0, lambdamax=10; // 10 is out of the ball

 
 lambda=0.5*(lambdamin+lambdamax);
	
while(Math.abs(Divergence(c,Ray(c,orient,lambda))-r)>precision)
{
if 	(Divergence(c,Ray(c,orient,lambda))<r) lambdamin=lambda;
else lambdamax=lambda;

 lambda=0.5*(lambdamin+lambdamax);
}
//System.out.println(lambda);

res=Ray(c,orient,lambda);
return res;
}



public static void main(String[] a)
{
System.out.println("Bregman Thales");	
	
Sphere s=new Sphere(0.5,0.5,1);
double angle1=2*Math.PI*Math.random();
double angle2=2*Math.PI*Math.random();

angle1=Math.random(); 
angle2=angle1+Math.PI;

double angle3=2*Math.PI*Math.random();
System.out.println("angles "+angle1+" "+angle2+" "+angle3);

double [] p=primalGeo(s.c,angle1,s.r);
double [] q=primalGeo(s.c,angle2,s.r);
double [] r=primalGeo(s.c,angle3,s.r);


System.out.println(p[0]+" "+p[1]+" d(c,p)="+Divergence(s.c,p));
System.out.println(q[0]+" "+q[1]+" d(c,q)="+Divergence(s.c,q));
System.out.println(r[0]+" "+r[1]+" d(c,r)="+Divergence(s.c,r));
	
	
System.out.println("pqr primal angle:"+primalDualAngle(p,r,gradf(r),gradf(q)));
System.out.println("pqr dual angle:"+primalDualAngle(gradf(p),gradf(r),r,q));	



}	
	
}