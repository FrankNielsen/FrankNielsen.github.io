import Jama.*;

class SPDMean
{

  // see
  // Recursive computation of the Fr´echet mean on non-positively curved Riemannian manifolds with applications.
  // Nielsen, Frank. "What is... an inductive mean?" Notices of the American Mathematical Society 70.11 (2023): 1851-1855.
  static Matrix AIRecursiveMean(Matrix [] X, int nbiter)
  {
    int i, t, N=X.length;
    Matrix res;

    t=1;
    res=X[0];

    for (i=0; i<nbiter; i++)
    {
      res=SPD.AIRiemannianGeodesic(res, X[t%N], 1.0/(t+1));
      t++;
    }


    return res;
  }


  static Matrix AIRMean(Matrix [] X, int nbiter)
  {
    int i, j, N=X.length;
    Matrix res, S=X[0], newS;
    Matrix [] L=new Matrix[N];
    Matrix avgL;


// Initialize to arithmetic mean of SPD
    for (i=1; i<N; i++) {S=S.plus(X[i]);}
    S=S.times(1.0/(double)N); // arithmetic mean


    for (i=0; i<nbiter; i++)
    {

      for (j=0; j<N; j++)
      {
        L[j]=SPD.log( SPD.power(S, -0.5).times(X[j]).times(SPD.power(S, -0.5)) );
      }

      avgL=L[0];
      for (j=1; j<N; j++) {avgL=avgL.plus(L[j]);}
      avgL=avgL.times(1.0/(double)N); // arithmetic mean

// update scheme
      newS=SPD.power(S, 0.5).times(SPD.exp(avgL)).times(SPD.power(S, 0.5));

      S=newS;
    }


    return S;
  }

  // Arsigny, Vincent, et al. "Log‐Euclidean metrics for fast and simple calculus on diffusion tensors."
  // Magnetic Resonance in Medicine: An Official Journal of the International Society for Magnetic Resonance in Medicine 56.2 (2006): 411-421.

  static Matrix LogEuclideanMean(Matrix [] X)
  {
    int i, N=X.length;
    Matrix res;

    res=SPD.log(X[0]);

    for (i=1; i<N; i++)
      res=res.plus(SPD.log(X[1]));

    return SPD.exp(res.times(1.0/(double)N));
  }

  static double  GeometricMean(double [] x)
  {
    int i, N=x.length;
    double res=Math.log(x[0]);

    for (i=1; i<N; i++) res+=Math.log(x[i]);

    return Math.exp(res/(double)N);
  }

  // see Trindade, Gabriel, et al. "Fast Equivariant K-Means on SPD Matrices Using Log-Extrinsic Means."
  // International Conference on Geometric Science of Information. Cham: Springer Nature Switzerland, 2025.
  static Matrix LogExtrinsicMean(Matrix [] X)
  {
    int i, N=X.length, n=X[0].getRowDimension();
    Matrix res;
    double geomean;
    double[] scaleddet=new double[N];

    for (i=0; i<N; i++) scaleddet[i]=Math.pow(X[i].det(), 1.0/(double)n);

    geomean=GeometricMean(scaleddet);

    // System.out.println("Scalar geometric mean factor:"+geomean);

    res=new Matrix(n, n);

    for (i=0; i<N; i++)
      res=res.plus(X[i].times(1.0/(Math.pow(X[i].det(), 1.0/(double)n))));

    res=(res.times(1.0/Math.pow(res.det(), 1.0/(double)n))).times(geomean);

    return res;
  }
}
