// Frank Nielsen, June 2025

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


  // Exponential of a SPD matrix
  public static Matrix exp(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    // exponential on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.exp(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }

  // Logarithm of a SPD matrix
  public static Matrix log(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    // Logarithm on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.log(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }


  // Non-integer power of a matrix
  public static Matrix power(Matrix M, double p)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();
    // power on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.pow(D.get(i, i), p));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }


  public static Matrix AIRGeodesicMidPoint(Matrix P0, Matrix P1)
  {
    return AIRiemannianGeodesic(P0, P1, 0.5);
  }


  public static Matrix AIRiemannianGeodesic(Matrix P, Matrix Q, double lambda)
  {
    if (lambda==0.0) return P;
    if (lambda==1.0) return Q;

    Matrix result;
    Matrix Phalf=power(P, 0.5);
    Matrix Phalfinv=power(P, -0.5);

    result=Phalfinv.times(Q).times(Phalfinv);
    result=power(result, lambda);



    result=(Phalf.times(result)).times(Phalf);



    return result;
  }

  public static  Matrix randomSPDCholesky(int d)
  {
    int i, j;
    double [][] array=new double[d][d];
    Matrix L;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=0.3+0.7*Math.random();
      }

    L=new Matrix(array);
    // Cholesky
    return L.times(L.transpose());
  }
}
