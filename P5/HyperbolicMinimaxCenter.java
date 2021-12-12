// (C) December 2011  Frank Nielsen
// Minimax center in the hyperbolic Klein disk
// programmed by FN 

import java.util.Random;


class HyperbolicMinimaxCenter
{
	
public static double arccosh(double x)
{return Math.log(x+Math.sqrt(x*x-1.0));}

public static double KleinDistance(Point2D p, Point2D q)
{
double np2=p.x*p.x+p.y*p.y;
double nq2=q.x*q.x+q.y*q.y;
return arccosh( (1.0-(p.x*q.x+p.y*q.y))/Math.sqrt((1.0-np2)*(1.0-nq2)));
}

// Klein line segment geodesic
public static Point2D KleinGeodesic(Point2D p, Point2D q, double t)
{
double lambdamin=0.0, lambdamax=1.0, lambda;	
double targetdist=KleinDistance(p,q)*t, bdist;
Point2D m=new Point2D();

// machine precision
while(Math.abs(lambdamax-lambdamin)>1.0e-5)
{
// mid-parameterization on the geodesic	
lambda=0.5*(lambdamin+lambdamax); 
m.x=(1.0-lambda)*p.x+lambda*q.x;
m.y=(1.0-lambda)*p.y+lambda*q.y;

bdist=KleinDistance(p,m);
//System.out.println("\t"+lambda+" "+bdist);

if (bdist<targetdist) 
	{lambdamin=lambda;}
		else {lambdamax=lambda;}

}
// end of geodesic bisection search

return m;
}

public static Point2D FarthestPoint2D(Point2D [] set, Point2D q)
{
int winner=-1;
double maxdist=0.0;
int i;

for(i=0;i<set.length;i++)
{
if (KleinDistance(set[i],q)>maxdist)
	{maxdist=KleinDistance(set[i],q); winner=i;}	
}

//System.out.println("max dist="+maxdist);

return set[winner];	
}

public static Point2D OneIteration(Point2D [] set, Point2D c, double t)
{
Point2D f=FarthestPoint2D(set,c);
return KleinGeodesic(c,f,t);		
}

public static Point2D GEOALG(Point2D [] set, int nbiter)
{
Point2D c=new Point2D(set[0]);
int i;
Point2D f;
double t;

for(i=1;i<=nbiter;i++)
{
t=1.0/(i+1.0);	
c=OneIteration(set,c,t);	
}	

return c;	
}

public static Point2D GEOALGVerbatim(Point2D [] set, int nbiter)
{
Point2D c=new Point2D(set[0]);
int i;
Point2D f;
double t;

epsilon[0]=KleinDistance(c,cstar)/rstar;
r[0]=KleinDistance(c,FarthestPoint2D(set,c));

for(i=1;i<=nbiter;i++)
{
t=1.0/(i+1.0);	
f=FarthestPoint2D(set,c);
c=KleinGeodesic(c,f,t);	

// measure approximation
epsilon[i]=(KleinDistance(c,cstar)/rstar);
r[i]=KleinDistance(c,FarthestPoint2D(set,c));
}	

return c;	
}

static Point2D cstar;
static double rstar;


static double [] epsilon;
static double [] r;

public static void main(String [] args)
{
System.out.println("Hyperbolic 1-center.");	

int n=100, i;
Point2D set[]=new Point2D[n];
for(i=0;i<n;i++)
	{set[i]=new Point2D();set[i].rand();}

cstar=GEOALG(set,100000);
rstar=KleinDistance(cstar,FarthestPoint2D(set,cstar));

System.out.println("cstar="+cstar+" rstar="+rstar);

int nbiter=1000;
epsilon=new double[nbiter+1];
r=new double[nbiter+1];

GEOALGVerbatim(set,nbiter);

for(i=0;i<nbiter;i++)
{
System.out.println(i+"\t"+epsilon[i]+"\t"+r[i]);	
}

}




public static void testGeoAlg()
{
int n=100, i;
Point2D set[]=new Point2D[n];
for(i=0;i<n;i++)
	{set[i]=new Point2D();set[i].rand();}

Point2D minimax=GEOALG(set,1000);
double radius=KleinDistance(minimax,FarthestPoint2D(set,minimax));
	
System.out.println(minimax+" radius="+radius);	
}

public static void testGeodesicBisection()
{
// Test geodesic bisection search
Point2D p,q;

p=new Point2D(); p.rand();
q=new Point2D(); q.rand();

Point2D m=KleinGeodesic(p,q,0.5);


System.out.println(KleinDistance(p,q)*0.5);
System.out.println(KleinDistance(p,m));	
}
	
}


//
// Class for manipulating a 2D Point2D
// 

class Point2D
{
public double x,y;


public   String toString()
{
return "[x:"+x+" y:"+y+"]";
}

// Constructor
Point2D()
	{
	x=0.0;
	y=0.0;
	}
	
Point2D(Point2D p)
{x=p.x;y=p.y;
}	
	
Point2D (double xx, double yy)
{x=xx; y=yy;}	

// Draw a random Point2D inside the unit disk
void rand()
{double r=Math.random()*0.5; double theta=Math.random()*2.0*Math.PI;
x=r*Math.cos(theta); 
y=r*Math.sin(theta); 
}

double distSqr(Point2D q)
{
	return (q.x-x)*(q.x-x)+(q.y-y)*(q.y-y);
}
 
public void AddPoint2D(Point2D p)
{
x=x+p.x;
y=y+p.y;
}

public void MultCste(double cste)
{
x=cste*x;
y=cste*y;
}

}

