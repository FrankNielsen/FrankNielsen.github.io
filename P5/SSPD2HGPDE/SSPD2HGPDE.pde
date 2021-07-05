// Frank.Nielsen@acm.org
// revised June 2021
// 
// Special symmetric positive-definite matrices (SSPD)  and hyperbolic geometry
// https://raw.githubusercontent.com/OpenSourcePhysics/osp/master/src/org/opensourcephysics/numerics/Complex.java

/*
Analysis of a hyperbolic geometric model for visual texture perception
*/

import Jama.*;
import org.opensourcephysics.numerics.*;

public static void test()
{
  Complex w1=randomComplexDisk();
  Complex w2=randomComplexDisk();
  
  double Poincare12=PoincareDistance(w1,w2);
  Complex k1=Poincare2Klein(w1);
  Complex k2=Poincare2Klein(w2);  
  double Klein12=KleinDistance(k1,k2);
  
  System.out.println("Hyperbolic distance: Poincare:"+Poincare12+" Klein:"+Klein12);
  
  
 Matrix P1, P2;
 
 double det=10*Math.random();
 //double det=1;
 
 P1=randomSSPD(2,det);
 P2=randomSSPD(2,det);
 
 Matrix nP1=P1.times(1.0/Math.sqrt(P1.det())); 
 Matrix nP2=P2.times(1.0/Math.sqrt(P2.det())); 
 
  System.out.println("checking determinants for SSPD(det):"+P1.det()+" "+P2.det());
 
 double SPD12=RiemannianSPDDistance(P1,P2);
  double cfSPD12=RiemannianSPD2Distance(P1,P2);
  
  System.out.println("Rie. distance:"+SPD12+" closed-form 2x2:"+cfSPD12);
  
  double l=10*Math.random();
  Matrix lP1=P1.times(l);
  Matrix lP2=P2.times(l);
  double lSPD12=RiemannianSPDDistance(lP1,lP2);
    System.out.println("Checking scale invariance of SPD distance:"+lSPD12+" l="+l );
  
  Complex p1=SSPD2ComplexPoincareDisk(P1);
  Complex p2=SSPD2ComplexPoincareDisk(P2);
  
   double PoincareP12=Math.sqrt(2)*PoincareDistance(p1,p2);
   double nPoincareP12=Math.sqrt(2)*PoincareDistance(SSPD2ComplexPoincareDisk(nP1),SSPD2ComplexPoincareDisk(nP2));
   
   System.out.println("Rie. distance:"+SPD12+" isometry Poincare:"+PoincareP12);
   System.out.println("Rie. distance:"+SPD12+" normalized isometry Poincare:"+nPoincareP12);
   
    Complex pk1=SSPD2ComplexKleinDisk(nP1);
  Complex pk2=SSPD2ComplexKleinDisk(nP2);
   double KleinP12=Math.sqrt(2)*KleinDistance(pk1,pk2);
   System.out.println("Rie. distance:"+SPD12+" isometry Klein:"+KleinP12);
   
   
 double [] h1=SSPD2Hyperboloid(nP1);
 double [] h2=SSPD2Hyperboloid(nP2);
 
 double h12=Math.sqrt(2)*HyperboloidDistance(h1,h2);
 
 System.out.println("Riemannian SPD distance:"+SPD12+" via hyperboloid:"+h12);
 
/*
Matrix PP=randomSSPD(5,det);
System.out.println("det :"+PP.det());
*/
}


// transform a unit det 2x2 SPD matrix to an equivalent point in the Poincare disk
public static Complex SSPD2ComplexPoincareDisk(Matrix P)
{
 // double det=P.det(); P.times(1.0/det);
 double a,b;
 double den=2+P.get(0,0)+P.get(1,1);
 
 a=(P.get(0,0)-P.get(1,1))/den;
 b=(2.0*P.get(0,1))/den;
 
 return new Complex(a,b);
}


public static Complex SSPD2ComplexKleinDisk(Matrix P)
{
 double a,b;
 double A,B,C;
 
 A=P.get(0,0); B=P.get(1,1);C=P.get(0,1);
 
 double den=2+A+B;
 
 a=(A-B)/(2+A+B);
 b=(2.0*C)/(2+A+B);
 // convert to Klein
 
 double den2=1+a*a+b*b;
 
 /*
 double e1=2*a/den2;
double eq1=(A*A+2*A-B*B-2*B)/(A*A+2*A+B*B+2*B+2+2*C*C);
println("equiv. " +e1+" "+eq1);

 double e2=2*b/den2;
double eq2=2*C*(A+B+2)/(A*A+2*A+B*B+2*B+2+2*C*C);
println("equiv. " +e2+" "+eq2);
*/

//return new Complex(2*a/den2,2*b/den2);



return new Complex( (A*A+2*A-B*B-2*B)/(A*A+2*A+B*B+2*B+2+2*C*C) , 2*C*(A+B+2)/(A*A+2*A+B*B+2*B+2+2*C*C));

}

void setup()
{test();}


public static boolean isSPD(Matrix M)
{
  boolean spd=true;
  Jama.EigenvalueDecomposition evd=M.eig();
  Matrix diag=evd.getD();

  for (int i=0; i<diag.getColumnDimension(); i++)
    if (diag.get(i, i)<0)
      spd=false;  

  return spd;
}

//
// Riemannian distance with trace metric on SPD manifold
//
public static double RiemannianSPDDistance(Matrix P, Matrix Q)
{
double result=0.0d;
Matrix M=P.inverse().times(Q);
Jama.EigenvalueDecomposition evd=M.eig();
Matrix D=evd.getD();

for(int i=0; i<D.getColumnDimension();i++)
  result+=sqr(Math.log(D.get(i,i)));

return Math.sqrt(result);  
}


public static double RiemannianSPD2Distance(Matrix P, Matrix Q)
{
double result=0.0d;
Matrix M=P.inverse().times(Q);
double lambda1=0.5*(M.trace()-Math.sqrt(sqr(M.trace())-4.0*M.det()));
double lambda2=0.5*(M.trace()+Math.sqrt(sqr(M.trace())-4.0*M.det()));

result=sqr(Math.log(lambda1))+sqr(Math.log(lambda2));

return Math.sqrt(result);
}



public  static  Matrix randomSPDCholesky(int d)
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

public  static  Matrix randomSSPD(int d,double det)
{
 Matrix R= randomSPDCholesky(d);
 R=R.times(Math.pow(det/R.det(),1.0/(double)d));
 
 return R;
}



public static double sqr(double x){return x*x;}

public static double arccosh(double x)
{return Math.log(x+Math.sqrt(x*x-1.0));}

public static double arctanh(double x)
{return 0.5*Math.log((1.0+x)/(1.0-x));}


public static double KleinDistance(Complex k1, Complex k2)
{ 
 return arccosh((1-(k1.re()*k2.re()+k1.im()*k2.im())) /Math.sqrt( (1-sqr(k1.abs())) * (1-sqr(k2.abs())) )); 
}

public static Complex randomComplexDisk()
{
Complex z=new Complex(Math.random(),Math.random());
double r=Math.random();
return z.mul(r*z.abs());
}

public static Complex Poincare2Klein(Complex p)
{
 return new Complex(2*p.re()/(1+sqr(p.abs())), 2*p.im()/(1+sqr(p.abs()))); 
}

public static double KleinDistanceReal(Complex p, Complex q)
{
  double px=p.re(); 
  double py=p.im();
  double qx=q.re(); 
  double qy=q.im();
  
  return arccosh( (1-(px*qx+py*qy) )/Math.sqrt( (1-(px*px+py+py)) * (1-(qx*qx+qy*qy)) ) );
}


public static double PoincareDistance(Complex a, Complex b)
{ 
Complex c1=new Complex(1,0);
double ratio=( (a.subtract(b)).abs() )/( (c1.subtract(a.conjugate().mul(b))).abs() );

  
  return 2.0*arctanh(ratio);
}  

// Tenseurs de structure spatio-temporels
public static double [] SSPD2Hyperboloid(Matrix P)
{
double [] res=new double [3];

res[0]=(P.get(0,0)+P.get(1,1))*0.5;
res[1]=(P.get(0,0)-P.get(1,1))*0.5;
res[2]=P.get(0,1);

return res;
}

public static double HyperboloidDistance(double [] p, double [] q)
{
return arccosh(-(-p[0]*q[0]+p[1]*q[1]+p[2]*q[2]));  
}
