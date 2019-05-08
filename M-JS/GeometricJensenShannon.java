// Frank.Nielsen@acm.org
// April/May 2019 

/*
Implement the paper entitled:

On the Jensen-Shannon symmetrization of distances relying on abstract means
*/

import Jama.*;
/*
Download JAMA jar from
https://math.nist.gov/javanumerics/jama/
*/


// compound (vector,Matrix) type
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

// Geometric Jensen-Shannon divergence 
// (for exponential families instanced for Gaussians here)
class GJSEF{
	
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
 
public static double GJSKLMVN(vM l1, vM l2, double a)
{
vM la=NLERPl(l1,l2,a);	
return (1-a)*KLMVN(l1,la)+a*KLMVN(l2,la);	
} 

// Direct formula
public static double GJSMVN(vM l1, vM l2, double a)
{int d=l1.M.getRowDimension();
vM la=NLERPl(l1,l2,a);
double term1, term2,term3,term4;
term1=((la.M.inverse()).times((l1.M.times(1-a)).plus(l2.M.times(a)))).trace();
term2=Math.log(la.M.det()/(Math.pow(l1.M.det(),1-a)*Math.pow(l2.M.det(),a)));
term3=((la.v.minus(l1.v).transpose()).times(la.M.inverse()).times(la.v.minus(l1.v))).trace();
term4=((la.v.minus(l2.v).transpose()).times(la.M.inverse()).times(la.v.minus(l2.v))).trace();

double res=term1+term2+(1-a)*term3+a*term4-d;

return 0.5*res;	
}
 
 
public static double JSGt(vM t1, vM t2, double a)
{
vM ta=LERP(t1,t2,a);	
return (1-a)*BD(ta,t1)+a*BD(ta,t2);	
} 

public static double JSGDualt(vM t1, vM t2, double a)
{
return  JDiv(t1,t2,a);
}


public static double JSGDual(vM l1, vM l2, double a)
{
vM la=NLERPl(l1,l2,a);	
return (1-a)*KLMVN(la,l1)+a*KLMVN(la,l2);	
} 


 


public static double JSGDualCF(vM l1, vM l2, double a)
{
Matrix Deltam=l1.v.minus(l2.v);

vM la=NLERPl(l1,l2,a);
Matrix term1=l1.v.transpose().times(l1.M.inverse()).times(l1.v).times(1-a);
Matrix term2=l2.v.transpose().times(l2.M.inverse()).times(l2.v).times(a);
Matrix term3=la.v.transpose().times(la.M.inverse()).times(la.v);

return  0.5*(term1.trace()+term2.trace()-term3.trace()-Math.log(la.M.det()/(Math.pow(l1.M.det(),1-a)*Math.pow(l2.M.det(),a)))) ;
}

 
// 
// lambda to theta coordinate transform
//
public static vM L2T(vM l)
{
vM res;

Matrix v=(l.M.inverse()).times(l.v);
Matrix M=(l.M.inverse()).times(0.5);	

return new vM(v,M);
} 


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

// F(theta)
public static double F(vM t)
{int d=t.M.getColumnDimension();

return 0.5*( d*Math.log(Math.PI)-Math.log((t.M).det())
+0.5*QuadForm(t.v,t.M.inverse()));	
}
 
// F in lambda 
public static double Fl(vM l)
{int d=l.M.getColumnDimension();

return 0.5*( QuadForm(l.v,l.M.inverse())+Math.log(l.M.det())+d*Math.log(2*Math.PI));	
} 

// convex conjugate eta
public static double Ge(vM e)
{int d=e.M.getColumnDimension();

return -0.5*( Math.log(1+QuadForm(e.v,e.M.inverse())) 
+Math.log((e.M.times(-1)).det())+d*(1+Math.log(2*Math.PI))
);	
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

 	
// Canonical divergence
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
double [][] am2={{1},{1}};
double [][] aS1={{2,-1},{-1,1}};
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


public static vM LERP(vM t1, vM t2, double a)
{
Matrix va,Ma;
va=t1.v.times(1-a).plus(t2.v.times(a));
Ma=t1.M.times(1-a).plus(t2.M.times(a));
return new vM(va,Ma);	
}


public static double JDiv(vM t1, vM t2, double a)
{
Matrix va=t1.v.times(1-a).plus(t2.v.times(a));
Matrix Ma=t1.M.times(1-a).plus(t2.M.times(a));
vM ta=new vM(va,Ma);	
return (1-a)*F(t1)+a*F(t2)-F(ta);	
}
 	
public static void test1()
{
Matrix m1,m2,S1,S2;


// 2D
double [][] am1={{0},{0}};
double [][] am2={{1},{1}};
double [][] aS1={{1,0},{0,1}};
double [][] aS2={{3,0},{0,2}};
double [][] xa={{0.5},{0.25}};


// 1D
/*
double [][] am1={{0}};
double [][] am2={{1}};
double [][] aS1={{1}};
double [][] aS2={{3}};
double [][] xa={{2}};
*/

m1=new Matrix(am1);
m2=new Matrix(am2);
S1=new Matrix(aS1);
S2=new Matrix(aS2);	

vM l1,l2,t1,t2,e1,e2;
l1=new vM(m1,S1);
l2=new vM(m2,S2);


Matrix x=new Matrix(xa);

//System.out.println("L1:"+l1);

t1=L2T(l1);
t2=L2T(l2);

e1=T2E(t1);
e2=T2E(t2);
   
//double alpha=0.5;  
double alpha=Math.random();

double gd, gdt;
gd=gaussianDensity(x,l1);
gdt=gaussianDensityEF(x,t1);
System.out.println("density :  direct " +gd+" canonical EF:\t "+gdt);

//System.out.println("direct 1D:"+gaussianDensity1D(xa[0][0],am1[0][0],aS1[0][0]));

gd=gaussianDensity(x,l2);
gdt=gaussianDensityEF(x,t2);

System.out.println("density :" +gd+" \t "+gdt);

/*
Matrix malpha, Salpha, Deltam;
Deltam=m1.minus(m2);
Matrix S1inv=S1.inverse();
Matrix S2inv=S2.inverse();

Salpha=(((S1inv).times(1-alpha)).plus((S2inv.times(alpha)))).inverse();

Matrix tmp=(((S1inv).times(m1)).times(1-alpha)).plus( ((S2inv).times(m2)).times(alpha) );
malpha=Salpha.times(tmp);

vM la=new vM(malpha,Salpha);
*/
vM la=NLERPl(l1,l2,alpha);
vM la2=T2L(LERP(t1,t2,alpha));

System.out.println("alpha:"+alpha);
System.out.println(la+"\nvs\n"+la2);

double Jalpha=JDiv(t1,t2,alpha);

double Zalpha=Math.exp(-Jalpha);
double ZG=ZMVNl(l1,l2,alpha);

System.out.println("ZJ="+Zalpha+" vs ZDirect "+ZG);

double lhs,rhs;

lhs=Math.pow(gaussianDensity(x,l1),1-alpha)*Math.pow(gaussianDensity(x,l2),alpha)/ZG;
rhs=gaussianDensity(x,la);

System.out.println("alpha="+alpha+"\t"+lhs+" vs "+rhs);


double jsgl=GJSKLMVN(l1, l2, alpha);
double jsgt=JSGt(t1,t2, alpha);

System.out.println("JSG/ alpha="+alpha+"\tDirect KL\t"+jsgl+" vs BF "+jsgt);

double djsgl=JSGDual(l1, l2, alpha);
double djsgt= JSGDualt(t1,t2, alpha); ;//JDiv(t1,t2,alpha);   //JSGDualt(t1,t2, alpha);

System.out.println("dualJSG/ alpha="+alpha+"\tDirect KL\t"+djsgl+" vs BF "+djsgt);

System.out.println("CF="+JSGDualCF(l1,l2,alpha));

}



public static void testGJSMVN()
{// means and covariance matrices
Matrix m1,m2,S1,S2;
// 2D
double [][] am1={{0},{0}};
double [][] am2={{1},{1}};
double [][] aS1={{1,0},{0,1}};
double [][] aS2={{3,0},{0,2}};
double [][] xa={{0.5},{0.25}};
m1=new Matrix(am1);
m2=new Matrix(am2);
S1=new Matrix(aS1);
S2=new Matrix(aS2);	

vM l1,l2,t1,t2,e1,e2;
l1=new vM(m1,S1);
l2=new vM(m2,S2);
Matrix x=new Matrix(xa);

t1=L2T(l1);
t2=L2T(l2);
e1=T2E(t1);
e2=T2E(t2);
   
//double alpha=0.5;  
double alpha=Math.random();

vM la=NLERPl(l1,l2,alpha);
vM la2=T2L(LERP(t1,t2,alpha));

System.out.println("alpha:"+alpha);


double jsgl=GJSKLMVN(l1, l2, alpha);
double jsgt=JSGt(t1,t2, alpha);
double gjsmvn=GJSMVN(l1, l2, alpha);
System.out.println("Geometric Jensen-Shannon divergence for alpha="+alpha+
"\nDirect KL MVN\t"+jsgl+" versus via Bregman\t"+jsgt);
System.out.println("Direct formula from mu/Sigma parameters:"+gjsmvn);
}


// Main entry of the program	
public static void main(String [] args)
{
System.out.println("G-Jensen-Shannon divergence between multivariate Gaussians");	

testGJSMVN();
//testConversion();System.exit(-1);
//test1();
}	
}