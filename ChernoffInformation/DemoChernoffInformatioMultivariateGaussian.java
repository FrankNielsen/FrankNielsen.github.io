// Frank.Nielsen@acm.org, cleaned this code on 22 June 2022
// Demo code for the bisection search for finding the Chernoff exponent in
//
// An information-geometric characterization of Chernoff information, SPL 2003
//
// Entry code is TestChernoffMVN()
// it calls the main procedure ChernoffExponentMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
//
// all the equations below are for the dually flat space of MVNs can be found in
// On the Jensen?Shannon Symmetrization of Distances Relying on Abstract Means
// https://www.mdpi.com/1099-4300/21/5/485
// Since there is several ways to decompose an exponential family, we may have equivalent formula. For example, F is defined up to affine terms.
//
// This code should be written as the intersection of a e-geodesic with an m-bisector for the Bregman manifold induced
// by the pair of convex functions (F,F^*),  F(theta) with convex conjugate F^*(eta) written here asGe(eta)

import java.lang.Math; 
import Jama.*;

/*
Download JAMA jar from
https://math.nist.gov/javanumerics/jama/
unzip the Jama repository in the current directory for compilation
*/


// compound (vector,Matrix) type for encoding multivariate normal distributions
class vM
{
Matrix v, M;

vM(Matrix vv, Matrix MM)
{
v=vv.copy();
M=MM.copy();
}

// compound inner product
public static double inner(vM p1, vM p2)
{
return ((p1.v.transpose()).times(p2.v)).trace() + ((p1.M).times(p2.M)).trace();
}


public vM times(double l)
{
return new vM(v.times(l),M.times(l));	
}

// compound subtraction
public vM minus(vM p)
{
Matrix vv,MM;

vv=v.minus(p.v);
MM=M.minus(p.M);

return new vM(vv,MM);	
}

public static String ToString(Matrix M)
{int c=M.getColumnDimension();
int l=M.getRowDimension();
int i,j;
String res="";

for(i=0;i<l;i++)
{for(j=0;j<c;j++)
{res+=M.get(i,j)+" ";}
res=res+"\n";
}

return res;
}

public String toString()
{String res="";
res+="v=\n"+ToString(v)+"\nM=\n"+ToString(M);
return res;
}
}

 
class MVNChernoff{
	
	
public static boolean primaldualsearch=false;
	
public static double sqr(double x){return x*x;}	
	
//	
// canonical density for exponential families with k(x)=0	
//
public static double gaussianDensityEF(Matrix x, vM theta)
  {
    Matrix vtx=x.copy();
    Matrix Mtx=x.times(x.transpose().times(-1));  
    // sufficient statistic 	
    vM tx=new vM(vtx,Mtx);	
    	
    double result=Math.exp(vM.inner(tx,theta)-F(theta)); 
    
    return result;
  }
  
 // usual density 	(mu,Sigma)
  public static double gaussianDensity(Matrix x, vM l)
  {
    int d=l.M.getRowDimension();	
    	
    double result=Math.pow(Math.PI*2.0, (double)(d)/2.0)*Math.sqrt(l.M.det());
    
    double distMah=  ( ( (x.minus(l.v)).transpose()).times( (l.M.inverse()).times(x.minus(l.v)))).trace();
    result=Math.exp(-0.5*distMah)/result;
    return result;
  }
  
   public static double gaussianDensity1D(double x, double m, double v)
  {
  	return (1.0/(Math.sqrt(2*Math.PI*v)))*Math.exp(-0.5*sqr(x-m)/v);
  	}
  	

// KLD between two multivariate normals
 public static double KLMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
 {
 int d=S1.getColumnDimension();	
 Matrix Deltam=m1.minus(m2);
 	
 return 0.5*(
 	((S2.inverse()).times(S1)).trace()-d+
 	((Deltam.transpose().times(S2.inverse())).times(Deltam)).trace()
 		+Math.log(S2.det()/S1.det()) 
 			);
 
 }
 
 public static double KLMVN(vM l1, vM l2)
 {
 	return KLMVN(l1.v,l1.M,l2.v,l2.M);
 }
 
 
 

 
// ordinary to natural coordinates
// lambda to theta coordinate transform
//
public static vM L2T(vM l)
{
vM res;

Matrix v=(l.M.inverse()).times(l.v);
Matrix M=(l.M.inverse()).times(0.5);	

return new vM(v,M);
} 

// natural to ordinary (mu,Sigma) coordinates
public static vM T2L(vM t)
{
vM res;
Matrix M=(t.M.inverse()).times(0.5);	
Matrix v= M.times(t.v); 
return new vM(v,M);
} 


// natural to expectation parameters
public static vM T2E(vM t)
{
vM res;

Matrix v=(((t.M).inverse()).times(t.v)).times(0.5);
Matrix tmp=(t.M.inverse()).times(t.v);

Matrix M=(((t.M).inverse()).times(-0.5)).minus((tmp).times(tmp.transpose()).times(0.25));

res=new vM(v,M);
return res;	
} 	

public static vM gradF(vM t)
{
return T2E(t);	
}

public static vM E2T(vM e)
{
vM res;

Matrix tmp=e.M.plus(e.v.times(e.v.transpose())).inverse();

Matrix v=(tmp.times(e.v)).times(-1); 
Matrix M=tmp.times(-0.5); 

res=new vM(v,M);
return res;	
} 


// lambda to expectation parameters
public static vM L2E(vM l)
{
vM res;

Matrix v=l.v;
Matrix M=(l.M.times(-1)).minus(l.v.times(l.v.transpose()));
res=new vM(v,M);
return res;	
} 	

//  expectation to lambda parameters
public static vM E2L(vM e)
{
vM res;

Matrix v=e.v;
Matrix M=(e.M.times(-1)).minus(e.v.times(e.v.transpose()));

res=new vM(v,M);
return res;	
} 


// quadratic form
public static double QuadForm(Matrix x, Matrix Q)
{
return ((x.transpose().times(Q)).times(x)).trace();	
}

// the cumulant function or log normalizer F(theta)
public static double F(vM t)
{int d=t.M.getColumnDimension();

return 0.5*( d*Math.log(Math.PI)-Math.log((t.M).det())
+0.5*QuadForm(t.v,t.M.inverse()));	
}

public static double Ftheta(vM t)
{return F(t);
}
 
public static double BhattacharyyaDistance(vM t1, vM t2)
{// a JensenDivergence when densities are from an exponential family
	
return 0.5*(F(t1)+F(t2))-F(LERP(t1,t2,0.5));	
}

public static double BhattacharyyaDistance(vM t1, vM t2, double alpha)
{// a Jensen Divergence
	// bcs of convention for LERP, put 1-alpha
return (alpha*F(t1)+(1-alpha)*F(t2))-F(LERP(t1,t2,1-alpha));	
}

public static double BhattacharyyaDistanceSigma(Matrix S1, Matrix S2, double alpha)
{ 
return 0.5*Math.log(Math.sqrt(S1.det()*S2.det())/
(S1.inverse().times(alpha).plus(S2.inverse().times(1-alpha))).inverse().det());	
}

 
// verified: ok! 
public static double BhattacharyyaDistanceMuSigma(Matrix m1, Matrix S1, Matrix m2, Matrix S2, double alpha)
{ 
Matrix SigmaAlpha=((S1.inverse().times(alpha)).plus(S2.inverse().times(1-alpha))).inverse();
Matrix muAlpha=SigmaAlpha.times(
	(S1.inverse().times(alpha).times(m1)).plus( S2.inverse().times(1-alpha).times(m2) )
);

double term1=(m1.transpose().times(S1.inverse()).times(m1).times(alpha)).trace();
double term2=(m2.transpose().times(S2.inverse()).times(m2).times(1-alpha)).trace();
double term3=(muAlpha.transpose().times(SigmaAlpha.inverse()).times(muAlpha)).trace();
double term4=Math.log(Math.pow(S1.det(),alpha)*Math.pow(S2.det(),1-alpha)/SigmaAlpha.det());

return 0.5*(term1+term2-term3+term4);
}
 
 
// log normalizer in ordinary coordinate system F in lambda 
public static double Fl(vM l)
{int d=l.M.getColumnDimension();

return 0.5*( QuadForm(l.v,l.M.inverse())+Math.log(l.M.det())+d*Math.log(2*Math.PI));	
} 


// log-normalize in moment parameter F in eta
public static double Feta(vM e)
{int d=e.M.getColumnDimension();
double term1, term2;

term1=((e.v.transpose()).times( e.M.minus(e.v.times(e.v.transpose())).inverse() ).times(e.v)).trace();

term2= Math.log( ((e.M.minus(e.v.times(e.v.transpose()))).times(2.0*Math.PI)).det());

return 0.5*(term1+term2);	
}


// convex conjugate function in eta coordinate system
public static double Ge(vM e)
{int d=e.M.getColumnDimension();

return -0.5*( Math.log(1+QuadForm(e.v,e.M.inverse())) 
+Math.log((e.M.times(-1)).det())+d*(1+Math.log(2*Math.PI))
);	
} 
 

// Shannon entropy is neg log-normalizer of convex conjugate in eta coordinate
public static double ShannonEntropyE( vM e)
{
double res;

res=-Ge(e);

return res;
}

public static double ShannonEntropyCF( vM l)
{double d=l.M.getRowDimension();
	return Math.log(Math.sqrt(Math.pow(2.0*Math.PI*Math.E,d)*l.M.det()));
}
 
 

// Bregman divergence
public static double BD(vM t1, vM t2)
{
return F(t1)-F(t2)-vM.inner(t1.minus(t2),T2E(t2));	
}
 	
public static double BDdual(vM e1, vM e2)
{
return Ge(e1)-Ge(e2)-vM.inner(e1.minus(e2),E2T(e2));	
}

 	
// Canonical divergence = Fenchel-Young divergence
 public static double CD(vM t1, vM e2)
{
return F(t1)+Ge(e2)-vM.inner(t1,e2);	
}	
 	
 public static double CDdual(vM e1, vM t2)
{
return Ge(e1)+F(t2)-vM.inner(e1,t2);	
}
	
public static void testConversion()
{
Matrix m1,m2,S1,S2;

double [][] am1={{0},{0}};
double [][] aS1={{2,-1},{-1,1}};

double [][] am2={{1},{1}};
double [][] aS2={{3,0},{0,2}};

m1=new Matrix(am1);
m2=new Matrix(am2);
S1=new Matrix(aS1);
S2=new Matrix(aS2);	

vM l1,l2,t1,t2,e1,e2;
l1=new vM(m1,S1);
l2=new vM(m2,S2);

t1=L2T(l1);
t2=L2T(l2);

e1=T2E(t1);
e2=T2E(t2);

vM l2e1, l2e2;
l2e1=L2E(l1);
l2e2=L2E(l2);

System.out.println("Lambda -> Expectation");
System.out.println(e1+"\nvs\n"+l2e1);
System.out.println(e2+"\nvs\n"+l2e2);

vM e2l1, e2l2;
e2l1=E2L(e1);
e2l2=E2L(e2);

System.out.println("Expectation -> Lambda");
System.out.println(l1+"\nvs\n"+e2l1);
System.out.println(l2+"\nvs\n"+e2l2);

System.out.println("Theta -> Lambda");
vM t2l1, t2l2;
t2l1=T2L(t1);
t2l2=T2L(t2);
System.out.println(l1+"\nvs\n"+t2l1);
System.out.println(l2+"\nvs\n"+t2l2);

System.out.println("Eta -> Theta");
vM e2t1, e2t2;
e2t1=E2T(e1);
e2t2=E2T(e2);
System.out.println(t1+"\nvs\n"+e2t1);
System.out.println(t2+"\nvs\n"+e2t2);

}	

// the quasi-arithmetic mean
public static vM NLERPl(vM l1, vM l2, double alpha)
{

Matrix malpha, Salpha, Deltam,tmp;
Deltam=l1.v.minus(l2.v);
Matrix S1inv=l1.M.inverse();
Matrix S2inv=l2.M.inverse();

Salpha=(((S1inv).times(1-alpha)).plus((S2inv.times(alpha)))).inverse();
tmp=(((S1inv).times(l1.v)).times(1-alpha)).plus( ((S2inv).times(l2.v)).times(alpha) );
malpha=Salpha.times(tmp);

return new vM(malpha,Salpha);
}

public static double ZMVNl(vM l1, vM l2, double alpha)
{int d=l2.M.getColumnDimension();
	Matrix zero=new Matrix(d,1);
vM l12a=NLERPl(l1,l2,alpha);
double res=Math.pow(gaussianDensity(zero,l1),1-alpha)*Math.pow(gaussianDensity(zero,l2),alpha)
/gaussianDensity(zero,l12a);

return res;	
}
	
public static void testDivergence()
{
Matrix m1,m2,S1,S2;

double [][] am1={{0},{0}};
double [][] am2={{1},{1}};
double [][] aS1={{1,0},{0,1}};
double [][] aS2={{3,0},{0,2}};

m1=new Matrix(am1);
m2=new Matrix(am2);
S1=new Matrix(aS1);
S2=new Matrix(aS2);	

double kl=KLMVN(m1,S1,m2,S2);
double klrev=KLMVN(m2,S2,m1,S1);
System.out.println("KL="+kl);
System.out.println("KLrev="+klrev);

vM l1,l2,t1,t2,e1,e2;
l1=new vM(m1,S1);
l2=new vM(m2,S2);

//System.out.println("L1:"+l1);

t1=L2T(l1);
t2=L2T(l2);

e1=T2E(t1);
e2=T2E(t2);
 

double cd=CD(t2,e1);
double cdr=CD(t1,e2);
double dcd=CDdual(e1,t2);
double dcdr=CDdual(e2,t1);

System.out.println("CD="+cd);
System.out.println("CD*="+cdr);
System.out.println("dual CD="+dcd);
System.out.println("dual CD*="+dcdr);

double bd=BD(t2,t1);
double bdr=BD(t1,t2);
double dbd=BDdual(e2,e1);
double dbdr=BDdual(e1,e2);


System.out.println("BD="+bd);
System.out.println("BD*="+bdr);
System.out.println("dual BD="+dbd);
System.out.println("dual BD*="+dbdr);
}

// Linear interpolation in natural parameter
public static vM LERP(vM t1, vM t2, double a)
{
Matrix va,Ma;
va=t1.v.times(1-a).plus(t2.v.times(a));
Ma=t1.M.times(1-a).plus(t2.M.times(a));
return new vM(va,Ma);	
}

// Jensen difference
public static double JDiv(vM t1, vM t2, double a)
{
Matrix va=t1.v.times(1-a).plus(t2.v.times(a));
Matrix Ma=t1.M.times(1-a).plus(t2.M.times(a));
vM ta=new vM(va,Ma);	
return (1-a)*F(t1)+a*F(t2)-F(ta);	
}
 	
 

//
// exponential geodesic 
//

public static vM eGeodesic(vM l1, vM l2, double a)
{
Matrix SigmaInva=((l1.M.inverse().times(1-a)).plus(l2.M.inverse().times(a))).inverse();
Matrix mua=(l1.M.inverse().times(l1.v).times(1-a)).plus(l2.M.inverse().times(l2.v).times(a));
Matrix Deltamu=l1.v.minus(l2.v);



return new vM(
	SigmaInva.times(mua),
	SigmaInva);	
}

 
public static vM mGeodesic(vM l1, vM l2, double a)
{
Matrix Sigmaa=(l1.M.times(1-a)).plus(l2.M.times(a));
Matrix mua=(l1.v.times(1-a)).plus(l2.v.times(a));

Matrix Deltamu=l1.v.minus(l2.v);

Matrix term1=(l1.v.times(l1.v.transpose()).times(1-a)).plus(
	(l2.v.times(l2.v.transpose()).times(a)));
	
//	System.out.println("term");

Matrix Ma=Sigmaa.plus(term1);
Ma=Ma.minus(mua.times(mua.transpose()));

return new vM(
	mua,
	Ma);	
}

public static void testGeodesic()
{
double [][] am1={{0},{0}};
double [][] aS1={{2,-1},{-1,1}};

double [][] am2={{1},{1}};
double [][] aS2={{3,0},{0,2}};
Matrix m1,m2,S1,S2;

m1=new Matrix(am1);
S1=new Matrix(aS1);
m2=new Matrix(am2);
S2=new Matrix(aS2);
 	
vM l1,t1,l2,t2,e1,e2;
l1=new vM(m1,S1);
t1=L2T(l1);
e1=L2E(l1);
l2=new vM(m2,S2);
t2=L2T(l2);
e2=L2E(l2);

double a=Math.random();	

vM lat, latcf, lae, laecf, lat2,lae2;

lat=T2L(LERP(t1,t2,a));
lae=E2L(LERP(e1,e2,a));

lae2=mGeodesic(l1,l2,a);

System.out.println(lae+"\n versus cf\n"+lae2);

lat2=eGeodesic(l1,l2,a);

System.out.println(lat+"\n versus cf\n"+lat2);

}

 

public static double vMInnerProduct(vM t1, vM t2)
{
return t1.v.transpose().times(t2.v).trace()+t1.M.times(t2.M).trace();	
}

//ok
public static double ChernoffExactSameSigma(Matrix mu1, Matrix mu2, Matrix Sigma)
{
Matrix DeltaMu=mu1.minus(mu2);
	
return (1/8.0)*	((DeltaMu.transpose()).times((Sigma.inverse()).times(DeltaMu))).trace();
}

// ok
public static double ChernoffExactSigmaIdentity(Matrix mu1, Matrix mu2)
{
Matrix DeltaMu=mu1.minus(mu2);
	
return (1/8.0)*	((DeltaMu.transpose()).times(DeltaMu)).trace();
}

// 
public static double BhatScaledSigma(Matrix Sigma, double s,double alpha)
{
int d= Sigma.getRowDimension();

return (d/2.0)*((1-alpha)*Math.log(s)+Math.log(alpha+(1-alpha)/s));

}

public static  Matrix randomMu(int d)
{
int i;
double [][] array=new double[d][1];
 
  
for(i=0;i<d;i++)
    {array[i][0]=Math.random();}

return new Matrix(array);
}


public static  Matrix randomSPDCholesky(int d)
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


  
public static double ChernoffExponentMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
{
vM l1,t1,l2,t2;

l1=new vM(m1,S1);t1=L2T(l1);

l2=new vM(m2,S2);t2=L2T(l2);
 
double alphamin=0, alphamax=1, alphamid, eps=1.0e-8;
vM theta;
int iter=1;
// Bisection search on the theta-geodesic
// (could be more effective if we use the Hessian norm and not halving alpha)
do{
alphamid=0.5*(alphamin+alphamax);

theta=LERP(t1,t2,alphamid);

if (BD(t1,theta)<BD(t2,theta))
{alphamin=alphamid;}
else
alphamax=alphamid;
//System.out.println(iter+":\t"+alphamid+" "+BD(t1,theta)+" "+BD(t1,theta));	
	iter++;
}
while(Math.abs(alphamax-alphamin)>eps);

System.out.println("nbiter:"+iter);
// here we reverse the conversion interpolation LERP-traditional exponent convention
return 1-(0.5*(alphamin+alphamax));
}
  
public static double ChernoffInformationMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
{
double alphastar= ChernoffExponentMVN(m1,S1,m2,S2);
vM l1,t1,l2,t2;

l1=new vM(m1,S1);t1=L2T(l1);
l2=new vM(m2,S2);t2=L2T(l2);
return	BhattacharyyaDistance(t1,t2,alphastar);
}
 
 
  
 
public static void TestChernoffMVN()
{
System.out.println("Chernoff information between multivariate Gaussians");
//int d=10;
int d=3;
Matrix m1=randomMu(d);
Matrix m2=randomMu(d);
Matrix S1=randomSPDCholesky(d);
Matrix S2=randomSPDCholesky(d);

double mu,v;
double mu1,v1;
double mu2,v2;

 
 
double alphastar=ChernoffExponentMVN(m1,S1,m2,S2);
System.out.println("dimension:"+d);
System.out.println("alphastar:"+alphastar);
 
 
double CI=ChernoffInformationMVN(m1,S1,m2,S2);
double CIcf=BhattacharyyaDistanceMuSigma(m1,S1,m2,S2,alphastar);

 
System.out.println("Chernoff information CI:"+CI);

System.out.println("CI Bhat cf mu sigma:"+CIcf);

vM l1,t1,l2,t2;
l1=new vM(m1,S1);t1=L2T(l1);
l2=new vM(m2,S2);t2=L2T(l2);

// Attention: convention eithe geodesic is tp+(1-t)q or (1-t)p+tq!
vM t12=LERP(t1,t2,1-alphastar);

double BD1=BD(t1,t12);
double BD2=BD(t2,t12);

System.out.println("Chernoff information Bregman Divergences should be equal:"+BD1+"\t"+BD2);
}

 
// Main entry of the program	
public static void main(String [] args)
{
System.out.println("Chernoff information of multivariate normal distributions");	
TestChernoffMVN();	
	 
}

}