// Frank.Nielsen@acm.org April 27th 2021
//
class Point2D
{double x,y;

Point2D(){}

Point2D(double xx, double yy){x=xx; y=yy;}


void rand(){double theta=2*Math.PI*Math.random(); double r=Math.random();
x=r*Math.cos(theta);
y=r*Math.sin(theta);
}

void rand(double R){
	double theta=2*Math.PI*Math.random(); 
		double r=R*Math.random();
x=r*Math.cos(theta);
y=r*Math.sin(theta);
}


double norm(){return Math.sqrt(sqrnorm());}

double inner(Point2D q){return x*q.x+y*q.y;}

Point2D minus(Point2D q)
{
	return new Point2D(x-q.x,y-q.y);
}

double sqrnorm(){return (x*x+y*y);}
}


public class KleinGeodesic
{
	
	static double kappa=-1;
	static double R=Math.sqrt(1.0/(-kappa));
	static double R2=R*R;
	
		public static double cosh(double x)
{return 0.5*(Math.exp(x)+Math.exp(-x));}

	public static double sqr(double x)
{return x*x;}

	public static double arccosh(double x)
{return Math.log(x+Math.sqrt(x*x-1.0));}


public static double KleinDistance(Point2D p, Point2D q)
{
double np2=p.sqrnorm();
double nq2=q.sqrnorm();
//p.x=p.x/R; p.y=p.y/R; q.x/=R; q.y/=R;
return Math.sqrt(-kappa)*arccosh( (1-(p.x*q.x+p.y*q.y))/Math.sqrt((1-np2)*(1-nq2)));
}

// Klein line segment geodesic
public static double KleinPreGeodesic(Point2D p, Point2D q, double t)
{
double lambdamin=0.0, lambdamax=1.0, lambda=0;	
double targetdist=KleinDistance(p,q)*t, bdist;
Point2D m=new Point2D();

// machine precision
while(Math.abs(lambdamax-lambdamin)>1.0e-8)
{
// mid-parameterization on the geodesic	
lambda=0.5*(lambdamin+lambdamax);
m=LERP(p,q,lambda); 
 

bdist=KleinDistance(p,m);
//System.out.println("\t"+lambda+" "+bdist);

if (bdist<targetdist) 
	{lambdamin=lambda;}
		else {lambdamax=lambda;}

}
// end of geodesic bisection search

return lambda;
}

public static Point2D LERP(Point2D p, Point2D q, double alpha)
{
Point2D res=new Point2D();
res.x=p.x+alpha*(q.x-p.x);
res.y=p.y+alpha*(q.y-p.y);

return res;
}

public static double max(double a, double b)
{if (a<b) return b; else return a;
}

// alpha is LERP, returns c(alpha) the arclength param.
public static double KleinGeodesicC(Point2D p, Point2D q, double alpha)
{
double a=1-p.sqrnorm();
double b=p.inner(q.minus(p));
double c=(q.minus(p)).sqrnorm();
double d=cosh(alpha*KleinDistance(p,q));
 
//return (  Math.sqrt(a*a*a*c*d*d*d*d-a*a*a*c*d*d+a*a*b*b*d*d*d*d-a*a*b*b*d*d)  -a*b*d*d+a*b )/(a*c*d*d+b*b);

return (  a*d*Math.sqrt((a*c+b*b)*(d*d-1))  +a*b*(1-d*d)  )/(a*c*d*d+b*b);

}


public static void main(String [] args)
{
Point2D p,q;
p=new Point2D(); q=new Point2D();
 
p.rand();
//p.x=p.y=0;
 q.rand();	

double alpha=Math.random();

double calphadichoLERP=KleinPreGeodesic(p,q,alpha);

System.out.println("asked alpha="+alpha+" obtained dichotomy calphadichoLERP="+calphadichoLERP);
Point2D r= LERP(p,q,calphadichoLERP);

double distpr=KleinDistance(p,r);
double distask=KleinDistance(p,q)*alpha;
System.out.println("asked distance:"+distask+" got by dichotomy="+distpr);

double sol=KleinGeodesicC(p,q, alpha);

double err=Math.abs(sol-calphadichoLERP)/max(sol,calphadichoLERP);
System.out.println("closed form formula for c(alpha):"+sol+ " vs dicho:"+calphadichoLERP);
System.out.println("relative error:"+err);

double s=Math.random();
double t=Math.random();

Point2D u=LERP(p,q,KleinGeodesicC(p,q, s));
Point2D v=LERP(p,q,KleinGeodesicC(p,q, t));

double dist1=Math.abs(s-t)*KleinDistance(p,q);
double dist2=KleinDistance(u,v);
double err2=Math.abs(dist1-dist2)/max(dist1,dist2);
System.out.println("Check geodesic metric space: s="+s+" t="+t);
System.out.println("dist(u,v)="+dist2+"vs |s-t|dist(p,q)="+dist1+"\nRelative error:"+err2);
}

}