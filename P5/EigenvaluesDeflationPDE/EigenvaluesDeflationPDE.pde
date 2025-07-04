//
// https://en.wikipedia.org/wiki/Power_iteration
// Frank.Nielsen@acm.org
//
// Compute the maximal eigenvalue, then remove  lambda x x^\top from current matrix and reiterate
// assume symmetric matrices so that we get real-valued eigenvalues
//
// the eigenvectors form an orthonormal basis for symmetric matrices
// symmetric matrices can have repeated eigenvalues

// Run several times to see when we get an orthonormal basis or not
// (need to set the number of iterations)
// the eigenvectors are normalized but may not be orthonormal if the number of iterations is too low
//
//  algebraic multiplicity,  geometric multiplicity of eigenvalues  (algebraic multiplicity >=geometric multiplicity)

import Jama.*;
import java.util.Arrays; 

int nbiterPower=1000; // depends on many factors
int d=10;

public  double [] Eigenvalues(Matrix M)
{
  int d=M.getRowDimension();
  double [] res=new double[d];
  EigenvalueDecomposition evd=M.eig();
  Matrix D=evd.getD();
  // power on the positive eigen values
  for (int i=0; i<D.getColumnDimension(); i++)
  {
    res[i]=D.get(i, i);
  }


  return res;
}



EigenPair PowerMethod(Matrix M, int nbiter)
{
  EigenPair ep=new EigenPair();
  int i, d=M.getRowDimension();
  Matrix x=new Matrix(d, 1);
  for (i=0; i<d; i++) x.set(i, 0, Math.random());
  double norm;

  for (i=0; i<nbiter; i++)
  {
    norm=(M.times(x)).norm2();  
    x=(M.times(x)).times(1.0/norm);
  }
  double smax=(x.transpose().times(M).times(x).trace())/(x.transpose().times(x).trace());

  //x.print(6,3);
  //println("smax="+smax);

  ep.eigenvalue=smax;
  ep.eigenvector=(Matrix)x.clone();

  return ep;
}

void Test()
{
  int i, j;
  
 // int d=3;
  
  println("dimension="+d+" #iterations per power method:"+nbiterPower);
  
  Matrix M=new Matrix(d, d);
  
  /* repeated eigenvalues
  // this works
  M.set(0,0,1);M.set(0,1,0);M.set(0,2,Math.sqrt(2));
  M.set(1,0,0);M.set(1,1,2);M.set(1,2,0);
  M.set(2,0,Math.sqrt(2));M.set(2,1,0);M.set(2,2,0);
  */
  
  
  //random symmetric matrix
  for (i=0; i<d; i++)
    for (j=0; j<=i; j++) {
      double a=-3+6*Math.random();
      M.set(i, j, a);
      M.set(j, i, a);
    }
    
    
    
  //M.print(6,3);
  println("eigenvalues by Jama:");
  double [] ev=Eigenvalues(M);
  for (i=0; i<d; i++) print(ev[i]+" ");
  println("");

  EigenPair[] ep=new EigenPair[d];

  // Iterative power method here (assume distinct eigenvalues)
  for (i=0; i<d; i++)
  {
    ep[i]=PowerMethod(M, nbiterPower);
    M=M.minus((ep[i].eigenvector.times(ep[i].eigenvector.transpose())).times(ep[i].eigenvalue));
  }

  Arrays.sort(ep);

  double res=0.0;

  println("eigenvalues by power method:");
  for (i=0; i<d; i++) 
  {
    res=res+Math.abs(ev[i]-ep[i].eigenvalue);
    print(ep[i].eigenvalue+" ");
    
  }
  println("");

  println("Difference between the eigenvalues (JAMA vs iterative power methods):"+res);


println("Checking for orthonormal basis (print exceptions for pairs of eigenvectors)");
  double eps=1.e-5;
  // check orthonormal basis
  for (i=0; i<d; i++) 
    for (j=0; j<=i; j++)
    {
      double ip=ep[i].InnerProduct(ep[j]);
      if ((i==j)&&(Math.abs(ip-1)>eps)) 
          println("not orthonormal:"+i+" "+j+" "+ip);
      if ((i!=j)&&(Math.abs(ip)>eps)) 
          println("not orthonormal:"+i+" "+j+" "+ip);
    }
    
    println("Checking normalized eigenvectors");
    for (i=0; i<d; i++)
    {
    double nor=ep[i].norm();
    if (Math.abs(nor-1)>eps) 
     println("not normalized:"+i+" "+nor);
    }
    
    
    println("completed!");
}

void setup()
{
  Test();
}
