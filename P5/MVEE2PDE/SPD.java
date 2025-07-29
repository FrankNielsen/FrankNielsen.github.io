// Frank Nielsen, June+July 2025

 
import Jama.*;


class SPD
{

  public static double min(double a, double b) {
    if (a<b) return a;
    else return b;
  }
  public static double max(double a, double b) {
    if (a>b) return a;
    else return b;
  }
  public static double sqr(double x) {
    return x*x;
  }
  
  
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

 public static Matrix sqrt(Matrix M)
 {return power(M,0.5);}
 
 
 //  Burgeth, Bernhard, et al. "Morphology for matrix data: Ordering versus pde-based approach." Image and Vision Computing 25.4 (2007): 496-511.

  public static Matrix  Max(Matrix A, Matrix B)
  {
    
  return ( ((A.plus(B)).plus(sqrt( (A.minus(B)).times(A.minus(B)).transpose() ))) ).times(0.5); 
  }

// Allamigeon, Xavier, et al. "A scalable algebraic method to infer quadratic invariants of switched systems." ACM Transactions on Embedded Computing Systems (TECS) 15.4 (2016): 1-20.
public static Matrix MVEE(Matrix A, Matrix B)
{
 Matrix X=power(A,0.5);
 Matrix Id=Matrix.identity(2,2);
 
 //Matrix tmp=
 
 return X.times( Max(Id, (X.inverse()).times(B).times( X.inverse().transpose() )).times(X.transpose() ));
  
}



  // projective distance
  public static double HilbertConeDistance(Matrix P1, Matrix P2)
  {
    int i;
    Matrix P1invP2=(P1.inverse()).times(P2);
    EigenvalueDecomposition evd=P1invP2.eig();
    Matrix D=evd.getD();
    int d=P1.getRowDimension();
    double lambdamax, lambdamin;
    lambdamax=lambdamin=D.get(0, 0);
    for (i=1; i<d; i++) {
      lambdamin=min(lambdamin, D.get(i, i));
      lambdamax=max(lambdamax, D.get(i, i));
    }
    return Math.log(lambdamax/lambdamin);
  }



 
  public static  Matrix IsometricSPDEmbeddingCalvoOller(Matrix mu, Matrix Sigma)
  {
 
    int d=mu.getRowDimension();
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);

    int i, j;

    tmp=Sigma.plus(  (mu.times(mu.transpose()))  );

    // Left top corner
    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    // Left column
    for (i=0; i<d; i++)
    {
      res.set(d, i, mu.get(i, 0));
    }

    // Bottom row
    for (i=0; i<d; i++)
    {
      res.set(i, d, mu.get(i, 0));
    }

    // Last element is one
    res.set(d, d, 1);

    return res;
  }


//
  public static double oldCPHilbertDistance(Matrix A, Matrix B)
  {
    int dim=A.getRowDimension();
    Matrix I=Matrix.identity(dim, dim);
    //Matrix A=P.times((P.plus(I)).inverse());
    //Matrix B=P.times((Q.plus(I)).inverse());

    Matrix AinvB=A.inverse().times(B);
    Matrix ImAinvImB=((I.minus(A)).inverse()).times(I.minus(B));

    int i;
    //  d_H(A, B) = log (lambda_max(A^-1 B) / lambda_min( (I - A)^-1 (I - B) )


    EigenvalueDecomposition evd=AinvB.eig();
    Matrix D=evd.getD();
    int d=D.getRowDimension();
    double lambdamax;
    lambdamax=D.get(0, 0);
    for (i=1; i<d; i++) {
      // lambdamin=min(lambdamin, D.get(i, i));
      lambdamax=max(lambdamax, D.get(i, i));
    }

    evd=ImAinvImB.eig();
    D=evd.getD();
    d=D.getRowDimension();
    double   lambdamin;
    lambdamin=D.get(0, 0);
    for (i=1; i<d; i++) {
      lambdamin=min(lambdamin, D.get(i, i));
      // lambdamax=max(lambdamax, D.get(i, i));
    }


    return Math.log(lambdamax/lambdamin);
  }
  
  // new July 16
  public static double CPHilbertDistance(Matrix A, Matrix B)
  {  int i;
    int dim=A.getRowDimension();
    Matrix I=Matrix.identity(dim, dim);
    
    //double lambdamin,lambdamax,mumin,mumax;

    Matrix AinvB=A.inverse().times(B);
    Matrix ImAinvImB=((I.minus(A)).inverse()).times(I.minus(B));

  

    EigenvalueDecomposition evd=AinvB.eig();
    Matrix D=evd.getD();
    int d=D.getRowDimension();
    double lambdamax,lambdamin;
    lambdamin=lambdamax=D.get(0, 0);
    for (i=1; i<d; i++) {
      lambdamin=min(lambdamin, D.get(i, i));
      lambdamax=max(lambdamax, D.get(i, i));
    }

    evd=ImAinvImB.eig();
    D=evd.getD();
    d=D.getRowDimension();
    double   mumin,mumax;
    mumin=mumax=D.get(0, 0);
    for (i=1; i<d; i++) {
      mumin=min(mumin, D.get(i, i));
      mumax=max(mumax, D.get(i, i));
    }


    return Math.log(max(lambdamax,mumax)/min(lambdamin,mumin));
  }



  public static double CPHilbertDistanceold(Matrix P, Matrix Q)
  {
    int dim=P.getRowDimension();
    Matrix I=Matrix.identity(dim, dim);
    Matrix A=P.times((P.plus(I)).inverse());
    Matrix B=P.times((Q.plus(I)).inverse());

    //  d_H(A, B) = log (lambda_max(A^-1 B) / lambda_min( (I - A)^-1 (I - B) )

    return HilbertConeDistance(A, B);
  }

  // Riemannian distance, affine-invariant AIRM, trace metric

  public static double AIRMDistance(Matrix P, Matrix Q)
  {
    double result=0.0d;
    Matrix M=P.inverse().times(Q);
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    for (int i=0; i<D.getColumnDimension(); i++)
      result+=sqr(Math.log(D.get(i, i)));

    return Math.sqrt(result);
  }


public static Matrix SPD2VPM(Matrix M)
{int d=M.getRowDimension();
Matrix Id=Matrix.identity(d,d);
  return M.times((M.plus(Id)).inverse());
}


  public static  Matrix randomGL(int d)
  {
    //System.out.println("random PSD matrix of dimension "+d+" and rank "+r);
    int i, j;
    double [][] array=new double[d][d];
    Matrix L,M,D,V;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=-1+2*Math.random();
      }
      
      return new Matrix(array);
  }
      

// rank r<=d
  public static  Matrix randomSPDCholesky(int d, int r)
  {
    System.out.println("random PSD matrix of dimension "+d+" and rank "+r);
    int i, j;
    double [][] array=new double[d][d];
    Matrix L,M,D,V;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=0.3+2*Math.random();
      }

//for(j=r+1;j<d;j++) array[j][j]=0;

    L=new Matrix(array);
    // Cholesky
      M = L.times(L.transpose()); // SPD matrix
    
    EigenvalueDecomposition evd=M.eig();
    D=evd.getD();
    V=evd.getV();
     
     for(j=r;j<d;j++) D.set(j,j,0);
     
     return V.times(D.times(V.transpose()));
     
    
  }
  


  public static  Matrix randomSPDCholesky(int d)
  {
    int i, j;
    double [][] array=new double[d][d];
    Matrix L;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=0.3+2*Math.random();
      }

    L=new Matrix(array);
    // Cholesky
    return L.times(L.transpose());
  }
  
  
}
