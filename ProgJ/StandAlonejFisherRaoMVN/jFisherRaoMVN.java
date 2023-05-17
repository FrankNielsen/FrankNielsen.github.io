// Install the Jama directory in the current directory:
// https://math.nist.gov/javanumerics/jama/

import Jama.*;

class vM
{
  Matrix v, M;

  vM(Matrix vv, Matrix MM)
  {
    v=vv.copy();
    M=MM.copy();
  }
}

class jFisherRaoMVN
{

  public static Matrix EmbedBlockCholesky(vM N)
  {
    int i, j, d=N.M.getRowDimension();
    Matrix Sigma=N.M;
    Matrix SigmaInv=N.M.inverse();
    Matrix mut=N.v.transpose();
    Matrix minusmu=N.v.times(-1.0);

    Matrix M, D, L; // Block Cholesky
    M=new Matrix(2*d+1, 2*d+1);
    D=new Matrix(2*d+1, 2*d+1);

    D.set(d, d, 1.0);

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        D.set(i, j, SigmaInv.get(i, j));
        D.set(d+1+i, d+1+j, Sigma.get(i, j));
      }

    M.set(d, d, 1.0);

    for (j=0; j<d; j++)
    {
      M.set(d, j, mut.get(0, j)); // row vector
      M.set(d+1+j, d, minusmu.get(j, 0)); // column vector
    }

    // add identity matrices
    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        M.set(i, i, 1.0);
        M.set(i+d+1, i+d+1, 1.0);
      }

    // Block Cholesky decomposition
    L=M.times(D).times(M.transpose());

    return L;
  }

  public static vM MVNGeodesic(vM N0, vM N1, double t)
  {
    vM result;
    Matrix G0, G1, Gt;

    G0=EmbedBlockCholesky(N0);
    G1=EmbedBlockCholesky(N1);
    Gt=RiemannianGeodesic(G0, G1, t); // Rie geodesic in SPD(2d+1)
    result=L2MVN(Gt);

    return result;
  }

  static vM L2MVN(Matrix L)
  {
    int i, j, d;
    d= (L.getRowDimension()-1)/2;
    Matrix Delta=new Matrix(d, d), delta=new Matrix(d, 1);
    
    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        Delta.set(i, j, L.get(i, j));
      }

    for (j=0; j<d; j++)
    {
      delta.set(j, 0, L.get(d, j));
    }

    Matrix mu, Sigma;

    // convert natural parameters to ordinary parameterization
    Sigma=Delta.inverse();
    mu=Sigma.times(delta);

    return new vM(mu, Sigma);
  }
  
  public static Matrix power(Matrix M, double p)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();
    
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.pow(D.get(i, i), p));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }
  
  public static Matrix RiemannianGeodesic(Matrix P, Matrix Q, double lambda)
  {
    if (lambda==0.0) return P;
    if (lambda==1.0) return Q;

    Matrix result;
    Matrix Phalf=power(P, 0.5);
    Matrix Phalfinv=power(P, -0.5);
    result=Phalfinv.times(Q).times(Phalfinv);
    result=power(result, lambda);
    
    return (Phalf.times(result)).times(Phalf);
  }

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
  
  public static double JeffreysMVN(vM N1, vM N2)
  {
    return KLMVN(N1.v, N1.M, N2.v, N2.M)+KLMVN(N2.v, N2.M, N1.v, N1.M);
  }

  public static double FisherRaoMVN(vM N1, vM N2, int T)
  {
    double rd=0.0;
    int i;
    double t, tn;
    vM X, Xn; // Xn for X next

    // cut geodesics into T geodesic segments using T+1
    for (i=0; i<T; i++)
    {
      t=(double)i/(double)T;
      tn=(i+1.0)/(double)T;
      X=MVNGeodesic(N1, N2, t);
      Xn=MVNGeodesic(N1, N2, tn);
      rd+=Math.sqrt(JeffreysMVN(X, Xn));
    }
    return rd;
  }

/* Running the code yields output:
Fisher-Rao distance for T=100:3.1996529412357417

Fisher-Rao distance for T=1000:3.199501696739761
*/

  public static void main(String [] args)
  {
    System.out.println("Fisher-Rao distance between two multivariate normal distributions.");

    Matrix m1, S1, m2, S2;

    m1=new Matrix(2, 1);
    m1.set(0, 0, 0);
    m1.set(1, 0, 0);
    S1=new Matrix(2, 2);
    S1.set(0, 0, 1.0);
    S1.set(0, 1, 0);
    S1.set(1, 0, 0);
    S1.set(1, 1, 0.1);

    m2=new Matrix(2, 1);
    m2.set(0, 0, 1);
    m2.set(1, 0, 1);
    S2=new Matrix(2, 2);
    S2.set(0, 0, 0.1);
    S2.set(0, 1, 0);
    S2.set(1, 0, 0);
    S2.set(1, 1, 1);

    vM N1, N2;
    N1=new vM(m1, S1);
    N2=new vM(m2, S2);


    int T;
    double raoDistance;

    T=100;
    raoDistance=FisherRaoMVN(N1, N2, T);
    System.out.println("\nFisher-Rao distance for T="+T+":"+raoDistance);

    T=1000;
    raoDistance=FisherRaoMVN(N1, N2, T);
    System.out.println("\nFisher-Rao distance for T="+T+":"+raoDistance);
  }
}
