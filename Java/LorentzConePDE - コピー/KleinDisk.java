class KleinDisk{
  
  // Euclidean inner product
  public static double EInnerProduct(double [] p , double [] q)
  {
   int d=p.length; 
   int i;
   double res=0;
   
   for(i=0;i<d;i++) res+=p[i]*q[i];
   
   return res;
    
  }
  
  
  public static double arccosh(double x){return Math.log(x+Math.sqrt(x*x-1));}
  
  
  public static double KleinDistance(double [] p, double [] q)
{return arccosh( (1-EInnerProduct(p,q))/Math.sqrt((1-EInnerProduct(p,p)))*(1-EInnerProduct(q,q)) );
}
  
}
