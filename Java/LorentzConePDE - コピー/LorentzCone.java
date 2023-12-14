// frank.nielsen@acm.org

//Recovering Klein and Minkowski metrics from Hilbert's projective metric on Lorentz cone  

class LorentzCone
{
  
  public static double [] randomPointLorentzCone(int d)
  {
   double [] res=new double [d];
   double csum=0;
   int i;
   
   for(i=1;i<d;i++) {res[i]=Math.random();csum+=res[i];}
   csum=Math.sqrt(csum);
   
   res[0]=csum+Math.random();
   
   return res;
  }
  
  public static double [] normalizeKleinDisk(double [] p)
  {
    int d=p.length; 
   int i;
   double []res=new double [d-1];
   
   for(i=0;i<d-1;i++) res[i]=p[i+1]/p[0];
   
   return res;
  }
  
  // Minkowski innner product
  public static double MInnerProduct(double [] p , double [] q)
  {
   int d=p.length; 
   int i;
   double res=0;
   
   for(i=1;i<d;i++) res+=p[i]*q[i];
   
   return p[0]*q[0]-res;
    
  }
  
  
   public static double det(double [] p)
   {
   return MInnerProduct(p,p);
   }
   
   
   public static double alpha(double [] p , double [] q)
  {
   double ip=MInnerProduct(p,q);
   
  return ip+Math.sqrt(ip*ip-det(p)*det(q));
  }
  
  
     public static double beta(double [] p , double [] q)
  {
   double ip=MInnerProduct(p,q);
   
  return ip-Math.sqrt(ip*ip-det(p)*det(q));
  }
  
  
  // Projective Hilbert
  public static double BirkhoffDistance(double [] p , double [] q)
  {
  return Math.log(alpha(p,q)/beta(p,q));
  }
  
  
}
