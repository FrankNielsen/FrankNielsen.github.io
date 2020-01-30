/*
(C) Frank Nielsen January 2020. 
          Frank.Nielsen@acm.org

A generalization of the ƒ¿-divergences based on comparable and distinct weighted means
https://arxiv.org/abs/2001.09660
*/

class GenAlphaDivergence
{
public static double KLe(double x, double y)
{return (x*Math.log(x/y))+y-x;
}

public static double Iordinary(double a, double x, double y)
{return (1.0/(a*(1.0-a))) * (a*x+(1-a)*y - Math.pow(x,a)*Math.pow(y,1.0-a));
}	


public static double IPowerMean(double r, double s, double a, double x, double y)
{return (1.0/(a*(1.0-a))) * ( Math.pow(a*Math.pow(x,r)+(1-a)*Math.pow(y,r),1.0/r)
- Math.pow(a*Math.pow(x,s)+(1-a)*Math.pow(y,s),1.0/s))
;
}

public static double IPowerMean1(double r, double s,  double x, double y)
{return  
( 
((Math.pow(y,r)-Math.pow(x,r))/(r*Math.pow(x,r-1)))-
((Math.pow(y,s)-Math.pow(x,s))/(s*Math.pow(x,s-1))) 
) ;
}

//
// The ordinary alpha-divergence is the (A,G) divergence
// OK!
public static void TestOrdinaryI()
{
	AlphaDivergence I=new AlphaDivergence(new ArithmeticMean(),new GeometricMean());
	double x=Math.random();
	double y=Math.random();
	double a=1.0e-2;
	
	double diva=Iordinary(a,x,y);
	double divga=I.AlphaDivergence(a,x,y);
	
	double divg0=I.I0(x,y);
	double divg1=I.I1(x,y);
	
	double div1=KLe(x,y);
	double div0=KLe(y,x);// reverse eKL

System.out.println("Ordinary AG alpha-divergence:\ndiva=\t"+diva+"\ndivg\t"+divga+"\n\ndivg0=\t"+divg0+"\ndiv0=\t"+div0+"\n\ndiv1=\t"+div1+"\ndivg1=\t"+divg1);	
}

//
// (r,s)-Power alpha-divergences
//
public static void TestPowerAlphaDivergence()
{    double s=Math.random();
	 double r=s+Math.random();
	QuasiArithmeticMean M=new PowerMean(r);
	QuasiArithmeticMean N=new PowerMean(s);
	AlphaDivergence I=new AlphaDivergence(M,N);
	double x=Math.random();
	double y=Math.random();
	double a=1.0e-2;
	
	double diva=IPowerMean(r,s,a,x,y);
	double divga=I.AlphaDivergence(a,x,y);
	
	double divg0=I.I0(x,y);
	double divg1=I.I1(x,y);
	
	double div1=IPowerMean1(r,s,x,y);
	double div0=IPowerMean1(r,s,y,x);// reverse  

System.out.println("Power mean alpha-divergence:\ndiva=\t"+diva+"\ndivg\t"+divga+"\n\ndivg0=\t"+divg0+"\ndiv0=\t"+div0+"\n\ndiv1=\t"+div1+"\ndivg1=\t"+divg1);	
}

public static double IAH(double a, double x, double y)
{
return (1.0/(a*(1.0-a))) *( a*x+(1-a)*y-(x*y)/(a*y+(1-a)*x));
}

public static double IAH1(double x, double y)
{
return y-2*x+x*x/y;
}


public static void TestAHAlphaDivergence()
{    double s=Math.random();
	 double r=s+Math.random();
	QuasiArithmeticMean M=new PowerMean(1);
	QuasiArithmeticMean N=new PowerMean(-1);
	AlphaDivergence I=new AlphaDivergence(M,N);
	double x=Math.random();
	double y=Math.random();
	double a=1.0e-2;
	
	double diva=IAH(a,x,y);
	double divga=I.AlphaDivergence(a,x,y);
	
	double divg0=I.I0(x,y);
	double divg1=I.I1(x,y);
	
	double div1=IAH1(x,y);
	double div0=IAH1(y,x);// reverse  

System.out.println("(A,H) mean alpha-divergence:\ndiva=\t"+diva+"\ndivg\t"+divga+"\n\ndivg0=\t"+divg0+"\ndiv0=\t"+div0+"\n\ndiv1=\t"+div1+"\ndivg1=\t"+divg1);	
}

public static double IGH(double a, double x, double y)
{
return (1.0/(a*(1.0-a))) *( Math.pow(x,a)*Math.pow(y,1-a)  -(x*y)/(a*y+(1-a)*x));
}

public static double IGH1(double x, double y)
{
return x*Math.log(y/x)-x+x*x/y;
}


public static void TestGHAlphaDivergence()
{    double s=Math.random();
	 double r=s+Math.random();
	QuasiArithmeticMean M=new PowerMean(0);
	QuasiArithmeticMean N=new PowerMean(-1);
	AlphaDivergence I=new AlphaDivergence(M,N);
	double x=Math.random();
	double y=Math.random();
	double a=1.0e-2;
	
	double diva=IGH(a,x,y);
	double divga=I.AlphaDivergence(a,x,y);
	
	double divg0=I.I0(x,y);
	double divg1=I.I1(x,y);
	
	double div1=IGH1(x,y);
	double div0=IGH1(y,x);// reverse  

System.out.println("(G,H) alpha-divergence:\ndiva=\t"+diva+"\ndivg\t"+divga+"\n\ndivg0=\t"+divg0+"\ndiv0=\t"+div0+"\n\ndiv1=\t"+div1+"\ndivg1=\t"+divg1);	
}




	
 


public static void main(String [] args)
{
System.out.println("Generalization of the alpha-divergences");	
System.out.println("------------------------------------------");
TestOrdinaryI();
System.out.println("------------------------------------------");
TestPowerAlphaDivergence();
System.out.println("------------------------------------------");
TestAHAlphaDivergence();
System.out.println("------------------------------------------");
TestGHAlphaDivergence();
System.out.println("------------------------------------------"); 
}	
}


class AlphaDivergence
{
// Mean M should majorize mean N
// For quasiarithmetic mean, this holds when f\circ g^{-1} is strictly convex	
QuasiArithmeticMean M,N;

AlphaDivergence(QuasiArithmeticMean MM, QuasiArithmeticMean NN)
{M=MM;N=NN;}

// Generic alpha divergence
public double	AlphaDivergence(double a, double x, double y)
	{
		if (a==0.0) return I0(x,y);
		if (a==1.0) return I1(y,x);
		else
		return (1.0/(a*(1-a))) * (M.weightedMean(1-a,x,y)-N.weightedMean(1-a,x,y));
	}
	
public double	I0(double x, double y)
{return I1(y,x);
}

public double	I1(double x, double y)
{
return M.E(x,y)-N.E(x,y);	
}	
}

abstract class QuasiArithmeticMean
{
	abstract double f(double u);
	abstract double finv(double u);
	abstract double gradf(double u);
	
	public double weightedMean(double a, double x, double y)
	{
	return	finv((1-a)*f(x)+a*f(y));
	}
	
		public double E(double x, double y)
		{
		return (f(y)-f(x))/gradf(x);	
		}
}

class PowerMean extends QuasiArithmeticMean
{
public double r;
	
	PowerMean(double rr) {r=rr;}
	
  double f(double u){
		if (r!=0.0) return Math.pow(u,r);
		else return Math.log(u);
		}
	
	  double finv(double u){
		if (r!=0.0) return Math.pow(u,1.0/r);
		else return Math.exp(u);
		}
	
	
	  double gradf(double u) 
		{
		if (r!=0.0) return r*Math.pow(u,r-1.0);
		else return 1.0/u;
		}
}

class ArithmeticMean extends  PowerMean
{
ArithmeticMean(){super(1.0);}
}

class GeometricMean extends  PowerMean
{
GeometricMean(){super(0.0);}
}


class HarmonicMean extends  PowerMean
{
HarmonicMean(){super(-1.0);}
}


class QuadraticMean extends  PowerMean
{
QuadraticMean(){super(2.0);}
}

