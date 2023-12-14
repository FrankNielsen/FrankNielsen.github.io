// frank.nielsen@acm.org

//Recovering Klein and Minkowski metrics from Hilbert's projective metric on Lorentz cone  

// https://math.stackexchange.com/questions/3279762/emulating-distance-on-poincar%C3%A9-disk-for-different-curvatures

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
  
  public static double [] scale(double lambda, double [] p)
  { int d=p.length; 
   int i;
   double [] res=new double[d];
   
   for(i=0;i<d;i++) res[i]=lambda*p[i];
   return res;
    
  }
  
   public static double min(double a, double b)
   {if (a<b) return a; else return b;}
  
     public static double diff(double [] p ,double [] q)
  {
     int d=p.length; 
   int i;
   double res=Double.MAX_VALUE;
   
   for(i=0;i<d;i++) 
      min(p[i]-q[i],res);
 
   return res;
  }
  
  
   public static boolean lessthanorequal(double [] p ,double [] q)
  {
     int d=p.length; 
   int i;
   
   for(i=0;i<d;i++) 
   if (p[i]>q[i]) {System.out.println("less or equal: false diff="+(p[i]-q[i])); return false;}
   
   return true;
  }
  
  
  public static double [] normalizeKleinDisk(double [] p)
  {
    int d=p.length; 
   int i;
   double []res=new double [d-1];
   
   for(i=0;i<d-1;i++) res[i]=p[i+1]/p[0];
   
   return res;
  }
  
  
    public static double [] normalizeKleinDisk(double R,double [] p)
  {
    int d=p.length; 
   int i;
   double []res=new double [d-1];
   
   for(i=0;i<d-1;i++) res[i]=R*p[i+1]/p[0];
   
   return res;
  }
  
  
      public static double [] normalizeHyperboloid(double [] p)
  {
    int d=p.length; 
   int i;
   double [] res=new double [d];
   double det=MInnerProduct(p,p);
   
   for(i=0;i<d;i++) res[i]=p[i]/Math.sqrt(det);
   
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
  return 0.5*Math.log(alpha(p,q)/beta(p,q));
  }
  
  
}
