/*
 Hilbert projective metric distance for covariance matrices
 Hilbert metric distance for correlation matrices
 
 You need the Jama jar file from
 https://math.nist.gov/javanumerics/jama/
 
 
 Frank Nielsen (Frank.Nielsen@acm.org) and Ke Sun
 **/
 
 import Jama.*;

class CovarianceProjectiveMetric
{
	

// Rejection method:
// A symmetric positive definite matrix has all its eigen values positive!
public static Matrix randomSPD(int d)
{
int i,j;
double [][] array=new double[d][d];
Matrix R;


do{
	
for(i=0;i<d;i++)
	for(j=0;j<=i;j++)
		{array[i][j]=array[j][i]=Math.random();}
	
	R=new Matrix(array);	
		
} while (!isPD(R));
return R;	
}



public static Matrix randomCorrelation(int d)
{
int i,j;
double [][] array=new double[d][d];
Matrix R;


do{
for(i=0;i<d;i++)
array[i][i]=1.0;
	
for(i=0;i<d;i++)
	for(j=0;j<i;j++)
		{array[i][j]=array[j][i]=Math.random();}
	
	R=new Matrix(array);	
		
} while (!isPD(R));
return R;	
}

	
public static boolean isPD(Matrix M)
{
boolean spd=true;
EigenvalueDecomposition evd=M.eig();
Matrix diag=evd.getD();

for(int i=0;i<diag.getColumnDimension();i++)
	if (diag.get(i,i)<=0)
			spd=false;	
			
return spd;
}


public static boolean isCorr(Matrix C)
{
boolean corr=true;
EigenvalueDecomposition evd=C.eig();
Matrix diag=evd.getD();
double tolerance=1.e-8;

for(int i=0;i<C.getColumnDimension();i++)
	if (Math.abs(C.get(i,i)-1)>tolerance)
			corr=false;
		
	if (!corr) return corr;
			
for(int i=0;i<diag.getColumnDimension();i++)
	if (diag.get(i,i)<=0)
			corr=false;
			
return corr;
}	
	

public static double max(double x, double y)
{if (x>y) return x; else return y;}

public static double min(double x, double y)
{if (x<y) return x; else return y;}



public static double lambdaMax(double [] x)
{double res=0.0;
for(int i=0;i<x.length;i++)
res=max(res,x[i]);

return res;	
}


public static double lambdaMin(double [] x)
{double res=x[0];
for(int i=0;i<x.length;i++)
res=min(res,x[i]);

return res;	
}


public static void print(double [] x)
{
for(int i=0;i<x.length;i++)
System.out.print(x[i]+" ");
System.out.print("\n");	
}


public static double HilbertDistance(Matrix S1, Matrix S2)
{
Matrix M=(S1.inverse()).times(S2);
EigenvalueDecomposition evd=M.eig();
double [] lambda=evd.getRealEigenvalues();
// Matrix D=evd.getD();
// int d=D.getColumnDimension();
// print(lambda);
int d=lambda.length;
return Math.log(lambdaMax(lambda))-Math.log(lambdaMin(lambda));	
}

public static Matrix LERP(Matrix M1, Matrix M2, double alpha)
{
Matrix M=M1.copy();
return (M.times(1-alpha)).plus(M2.times(alpha));
}
	
	
public static void main(String [] args)
{
System.out.println("Hilbert metric/Birkhoff projective metric.");

int d=3;
Matrix S1,S2;
S1=randomSPD(d);
S2=randomSPD(d);
Matrix sS1=S1.times(Math.random());
Matrix sS2=S2.times(Math.random());

double dist12=	HilbertDistance(S1,S2);
double sdist12=	HilbertDistance(sS1,sS2);

System.out.println(dist12+"  projective metric? "+sdist12);

System.out.println(" should be close to zero:"+HilbertDistance(S1,sS1));

Matrix C1,C2,C3;
C1=randomCorrelation(d);
C2=randomCorrelation(d);
C3=LERP(C1,C2,Math.random());

double d13=HilbertDistance(C1,C3);
double d32=HilbertDistance(C3,C2);
double d12=HilbertDistance(C1,C2);
double err=Math.abs(d12-(d13+d32));

System.out.println("Triangular inequality metric :"+d13+" "+d32+" ="+d12+ " error="+err);


dist12=	HilbertDistance(C1,C2);


}	
}