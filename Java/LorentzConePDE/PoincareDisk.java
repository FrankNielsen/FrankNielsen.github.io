class PoincareDisk{
  
    public static double arccosh(double x)
  {
    return Math.log(x+Math.sqrt(x*x-1.0));
  }
  
  public static double EInnerProduct(double [] p, double [] q)
  {
    int d=p.length;
    int i;
    double res=0;

    for (i=0; i<d; i++) res+=p[i]*q[i];

    return res;
  }

// Squared Euclidean distance
  public static double EDistanceSqr(double [] p, double [] q)
  {
     
    return  EInnerProduct(p,p)+EInnerProduct(q,q)-2.0*EInnerProduct(p,q);
  }

// Distance in the Poincare disk
  public static double PoincareDistance(double [] p, double [] q)
  {
    return arccosh( 1+ ( 2.0 *EDistanceSqr(p, q) / ( (1.0-EInnerProduct(p, p))*(1.0-EInnerProduct(q, q)) ) ) );
  } 
}
