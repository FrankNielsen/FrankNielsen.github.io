/*
Implement the formula/expressions for the cumulant-free Kullback-Leibler divergences
 between multivariate Gaussian distributions.
 
 See 
 
 Cumulant-free closed-form formulas for some common (dis)similarities between densities of an exponential family
 https://arxiv.org/abs/2003.02469
 
 You need to install the JAMA matrix package Jar from
 https://math.nist.gov/javanumerics/jama/
 
 (C) 2020 Frank.Nielsen@acm.org
 */

import Jama.*; 

class CumulantFreeKullbackLeiblerMVGaussian {

  // There are better algorithms for calculating the matrix square root.  
  public static Matrix sqrt(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();


    for (int i=0; i<D.getColumnDimension(); i++)
    {
      //System.out.println("lambda"+i+" = "+D.get(i,i));
      D.set(i, i, Math.sqrt(D.get(i, i)));
    }

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }

  // Retrieve the col-th column from the matrix M
  public static Matrix column(Matrix M, int col)
  {
    int d=M.getRowDimension();  
    Matrix res=new Matrix(d, 1);
    int j;

    for (j=0; j<d; j++)
      res.set(j, 0, M.get(j, col));

    return res;
  }


  // KLD between two multivariate normal distributions
  public static double KLDMVGaussian(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
  {
    int d=S1.getColumnDimension();  
    Matrix Deltam=m1.minus(m2);

    return 0.5*(
      ((S2.inverse()).times(S1)).trace()-d+
      ((Deltam.transpose().times(S2.inverse())).times(Deltam)).trace()
      +Math.log(S2.det()/S1.det()) 
      );
  }


  public static Matrix randomVector(int d)
  {
    int i, j;
    double [][] array=new double[d][1];
    Matrix V;

    for (i=0; i<d; i++)
      array[i][0]=-1+2*Math.random();

    return new Matrix(array);
  }


  public static Matrix randomSPDCholesky(int d)
  {
    int i, j;
    double [][] array=new double[d][d];
    Matrix L;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=-30.0+60.0*Math.random();
      }

    L=new Matrix(array);
    // Cholesky
    return L.times(L.transpose());
  }  


  // usual density for the Gaussian with parameter   (mu,Sigma)
  public static double pdfGaussian(Matrix x, Matrix m, Matrix S)
  {
    int d=S.getRowDimension();  

    double result=Math.pow(Math.PI*2.0, (double)(d)/2.0)*Math.sqrt(S.det());

    double distSqrMah=  ( ( (x.minus(m)).transpose()).times( (S.inverse()).times(x.minus(m)))).trace();
    result=Math.exp(-0.5*distSqrMah)/result;
    return result;
  }

  public static void MVGaussianTest()
  {
    int d=2, i;  
    Matrix m1, m2, S1, S2;
    Matrix [] omega=new Matrix[d];

    m1=randomVector(d);
    m2=randomVector(d);
    S1=randomSPDCholesky(d);
    S2=randomSPDCholesky(d);

    Matrix SqrtDS1=sqrt(S1.times(d));

    for (i=0; i<d; i++) 
    {
      omega[i]=column(SqrtDS1, i);
    }

    double kl=0;

    for (i=0; i<d; i++)
    {

      kl+=((Math.log(pdfGaussian(m1.plus(omega[i]), m1, S1)/pdfGaussian(m1.plus(omega[i]), m2, S2))
        +Math.log(pdfGaussian(m1.minus(omega[i]), m1, S1)/pdfGaussian(m1.minus(omega[i]), m2, S2))));


      //kl+=Math.log((pdfGaussian(m1.plus(omega[i]),m1,S1)*pdfGaussian(m1.minus(omega[i]),m1,S1))/(pdfGaussian(m1.plus(omega[i]),m2,S2)*pdfGaussian(m1.minus(omega[i]),m2,S2)));
    }

    kl/=(2.0*d);  

    double klcf=KLDMVGaussian(m1, S1, m2, S2);

    System.out.println("dimension:"+d);
    System.out.println("Ordinary closed-form formula for the KLD:"+klcf);
    System.out.println("Cumulant-free formula for the KLD:"+kl);
  } 

  // Main entry of the program  
  public static void main(String [] args)
  {
    System.out.println("Cumulant-free closed-form formulas for some common (dis)similarities between densities of an exponential family");

    for (int l=0; l<6; l++)
      MVGaussianTest();
  }
}
