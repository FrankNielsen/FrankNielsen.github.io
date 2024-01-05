// https://en.wikipedia.org/wiki/Beltrami%E2%80%93Klein_model
// https://eprints.soton.ac.uk/415515/1/Amal_Alabdullatif.pdf

class MinkowskiHyperboloid
{
   // Minkowski innner product
  public static double MInnerProduct(double [] p , double [] q)
  {
   int d=p.length; 
   int i;
   double res=0;
   
   for(i=1;i<d;i++) res+=p[i]*q[i];
   
   return p[0]*q[0]-res;
    
  }
  
  
    public static double arccosh(double x)
  {
    return Math.log(x+Math.sqrt(x*x-1.0));
  }
  
   public static double HyperboloidDistance( double [] p, double [] q)
  {
  
  return arccosh( MInnerProduct( p, q)/Math.sqrt(MInnerProduct(p,p)*MInnerProduct(q,q)) );
}

}
