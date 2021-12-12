/*
  Marc Arnaudon and Frank Nielsen
  November 2010, revised December 2011.

  On the Riemannian 1-Center
  Computational Geometry: Theory and Its Applications
  http://www.journals.elsevier.com/computational-geometry/
*/

/* Get Java SDK:
http://www.oracle.com/technetwork/java/javase/downloads/index.html
Get the friendly JCreator editor JCreator LE V3.5
 This program implements the Riemannian L-inf center.
Download the JAMA package from
http://math.nist.gov/javanumerics/jama/
and install the jar file into the local directory
*/

import Jama.*;

public class MiniMaxSPD
{
public static double sqr(double x){return x*x;}	
	
public static Matrix randomSPDCholesky(int d)
{
int i,j;
double [][] array=new double[d][d];
Matrix L;
	
for(i=0;i<d;i++)
	for(j=0;j<=i;j++)
		{array[i][j]=Math.random();}

L=new Matrix(array);
// Cholesky
return L.times(L.transpose());	
}	


// Non-integer power of a matrix
public static Matrix power(Matrix M, double p)
{
EigenvalueDecomposition evd=M.eig();
Matrix D=evd.getD();
// power on the positive eigen values
for(int i=0; i<D.getColumnDimension();i++)
	D.set(i,i,Math.pow(D.get(i,i),p));

Matrix V=evd.getV();

return V.times(D.times(V.transpose()));
}



// Exponential of a SPD matrix	
public static Matrix exp(Matrix M)
{
EigenvalueDecomposition evd=M.eig();
Matrix D=evd.getD();

// exponential on the positive eigen values
for(int i=0; i<D.getColumnDimension();i++)
	D.set(i,i,Math.exp(D.get(i,i)));

Matrix V=evd.getV();

return V.times(D.times(V.transpose()));
}

// Logarithm of a SPD matrix	
public static Matrix log(Matrix M)
{
EigenvalueDecomposition evd=M.eig();
Matrix D=evd.getD();

// Logarithm on the positive eigen values
for(int i=0; i<D.getColumnDimension();i++)
	D.set(i,i,Math.log(D.get(i,i)));

Matrix V=evd.getV();

return V.times(D.times(V.transpose()));
}	


public static Matrix LogEuclideanMean(Matrix [] set)
{
int i;
int n=set.length; 
int d=set[0].getColumnDimension();
Matrix R=new Matrix(d,d);

for(i=0;i<n;i++)
{
R=R.plus(log(set[i]).times(1.0/n))	;
}

return exp(R);
}

public static double RiemannianDistance(Matrix P, Matrix Q)
{
double result=0.0d;
Matrix M=P.inverse().times(Q);
EigenvalueDecomposition evd=M.eig();
Matrix D=evd.getD();

for(int i=0; i<D.getColumnDimension();i++)
	result+=sqr(Math.log(D.get(i,i)));

return Math.sqrt(result);	
}

public static Matrix RiemannianGeodesic(Matrix P, Matrix Q, double lambda)
{
Matrix result;
Matrix Phalf=power(P,0.5);
Matrix Phalfinv=power(P,-0.5);

result=Phalfinv.times(Q).times(Phalfinv);
result=power(result,lambda);

return (Phalf.times(result)).times(Phalf);	
}

// Cut the geodesic [PQ] into [PR] and [RQ] so that d(P,R)=cut*d(P,Q)
// For SPD matrices, the geodesic lambda split is equal to cut so we do not need the while loop
// see paper for explanation.
public static Matrix CutGeodesic(Matrix P, Matrix Q, double cut)
{
double dist=RiemannianDistance(P,Q);
double minl=0, maxl=1.0, maxm=0.5;
Matrix M=null; 
double distc;

while (maxl-minl>1.0e-5)
{
maxm=0.5*(minl+maxl);
M=RiemannianGeodesic(P,Q,maxm);
distc=RiemannianDistance(P,M);

if (distc>dist*cut)
	maxl=maxm; else minl=maxm;	
}

//System.out.println("wanted:"+cut+" obtained for lambda="+maxm);
	
return M;	
}

// Maximum distance from the current centerpoint C
public static double MaxCenter(Matrix[] set, Matrix C)
{
double result=0.0;

for(int i=0;i<set.length;i++)
	{
	if	(RiemannianDistance(set[i],C)>result)
		result=RiemannianDistance(set[i],C);
	}

return result;	
}

// Return the index of the farthest point
public static int argMaxCenter(Matrix[] set, Matrix C)
{
int winner=-1; double result=0.0;

for(int i=0;i<set.length;i++)
	{
	if	(RiemannianDistance(set[i],C)>result)
		{result=RiemannianDistance(set[i],C); winner=i;}
	}

return winner;	
}

// Performs the generalization of Badoiu-Clarkson algorithm:
// see paper: Smaller core-sets for balls. SODA 2003: 801-802
public static Matrix MinMax(Matrix[] set, int nbIter)
{
int i,j,f;
double ratio;
Matrix C=new Matrix(set[0].getArrayCopy());
	
for(i=1;i<=nbIter;i++)
{
f=argMaxCenter(set,C);
ratio=1.0/(i+1);
C=CutGeodesic(C,set[f],ratio);	
//System.out.println(i+"\t"+MaxCenter(set,C));
}

return C;	
}

static Matrix COpt;
static double ropt;

// Print on the console the statistics
public static Matrix MinMaxVerbose(Matrix[] set, int nbIter)
{
int i=0,j,f;
double ratio, distance, radius;

Matrix C=new Matrix(set[0].getArrayCopy());
distance=RiemannianDistance(C,COpt)/ropt;
radius=RiemannianDistance(C,set[argMaxCenter(set,C)]);

System.out.println(i+"\t"+distance+"\t"+radius);
	
for(i=1;i<=nbIter;i++)
{
f=argMaxCenter(set,C);
ratio=1.0/(i+1);
C=CutGeodesic(C,set[f],ratio);	

distance=RiemannianDistance(C,COpt)/ropt;
radius=RiemannianDistance(C,set[argMaxCenter(set,C)]);
System.out.println(i+"\t"+distance+"\t"+radius);
}

return C;	
}


	
public static void main (String[] args)
{
// Number of matrices
int n=100;

// Dimension of square matrices
int d=5;

System.out.println("Approximating the Riemannian Minimax\n on "+n+" symmetric positive definite matrices (SPD) of dimension "+d);
System.out.println("October 2010, Rev. December 2011.");

int i;

// Create data-set
Matrix [] set=new Matrix[n];
for(i=0;i<n;i++)
		{
		set[i]=randomSPDCholesky(d);
		}

// Norm-based center
System.out.println("Log-Euclidean mean:");
Matrix LECenter=LogEuclideanMean(set);
LECenter.print(6,5);

// Intrinsic circumcenter
System.out.println("Riemannian intrinsic circumcenter (1000 iterations):");
Matrix C=MinMax(set,1000);
C.print(6,5);

// A good approximation of the optimal 1-center
COpt=new Matrix(C.getArrayCopy());
ropt=RiemannianDistance(COpt,set[argMaxCenter(set,COpt)]);
// Verbose first 200 iterations statistics
Matrix M=MinMaxVerbose(set,200);



System.out.println("That is all folks.");	
	
}	
	
}