class BregmanIntRep
{
	static double min(double p,double q)
	{
		if (p<q) return p; else return q;
		}
	
static double KL(double p, double q)
{return p*Math.log(p/q)+q-p;}
	
static double Fa(double a, double x)
{
return -min(1-a,a*x);
}


static double gradFa(double a, double x)
{
 if (x<(1-a)/a) return a; else return 0;  
}

static double BFa(double a, double p, double q)
{return Fa(a,p)-Fa(a,q)-(p-q)*gradFa(a,q);}

static double Fpp(double x) {return 1.0/x;}

static double BFI(double p, double q)
{double res=0;
double a, dstep=0.001;
double scaling;

for(a=dstep;a<=1-dstep;a+=dstep)
{scaling=(1/(a*a*a))*Fpp((1-a)/a);
	res+=scaling*BFa(a,p,q);
	}

	return res*dstep;
	}
	
	
public static void main(String [] a)
{
double p=Math.random();
double q=Math.random();	

System.out.println("p="+p+" q="+q);


double KL=KL(p,q);
double BDKL=BFI(p,q);

System.out.println(KL+" "+BDKL);
}
	
}