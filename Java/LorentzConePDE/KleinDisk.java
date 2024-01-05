// Klein disk model of hyperbolic geometry

class KleinDisk {

  // Euclidean inner product
  public static double EInnerProduct(double [] p, double [] q)
  {
    int d=p.length;
    int i;
    double res=0;

    for (i=0; i<d; i++) res+=p[i]*q[i];

    return res;
  }

// Convert Klein point to Poincare point

public static  double [] Klein2Poincare(double [] k)
{
 double r2=EInnerProduct(k,k);
 double s=(1.0-Math.sqrt(1.0-r2))/(r2);
  //System.out.println("scaling factor:"+s);

 
 int d=k.length;
 double [] res=new double [d];
 int i;
 
 for(i=0;i<d;i++) res[i]=k[i]*s;
 
// double rp=EInnerProduct(res,res);
// System.out.println("Poincare disk:"+rp);
 
 return res;
}

  public static double arccosh(double x)
  {
    return Math.log(x+Math.sqrt(x*x-1.0));
  }


  public static double KleinDistance(double [] p, double [] q)
  {
 /*   System.out.println(EInnerProduct(p, q)); 
    System.out.println(EInnerProduct(p, p));
    System.out.println(EInnerProduct(q, q)); 
    double ratio= (1.0-EInnerProduct(p, q)) / Math.sqrt( (1.0-EInnerProduct(p, p))*(1.0-EInnerProduct(q, q))) ;
    System.out.println("ratio:"+ratio);
   */
   
    return arccosh( (1.0-EInnerProduct(p, q)) / Math.sqrt( (1.0-EInnerProduct(p, p))*(1.0-EInnerProduct(q, q)) ) );
  }
  
  
  public static double KleinDistance(double R, double [] p, double [] q)
  {
 /*   System.out.println(EInnerProduct(p, q)); 
    System.out.println(EInnerProduct(p, p));
    System.out.println(EInnerProduct(q, q)); 
    double ratio= (1.0-EInnerProduct(p, q)) / Math.sqrt( (1.0-EInnerProduct(p, p))*(1.0-EInnerProduct(q, q))) ;
    System.out.println("ratio:"+ratio);
   */
   
    return arccosh( (R*R-EInnerProduct(p, q)) / Math.sqrt( (R*R-EInnerProduct(p, p))*(R*R-EInnerProduct(q, q)) ) );
  }
  
  
   public static double [] randomPointKlein(int d, double R)
  {
   double [] res=new double [d];
   double csum=0;
   int i;
   
   for(i=1;i<d;i++) {res[i]=Math.random();csum+=res[i];}
   csum=Math.sqrt(csum);
   
   double u=Math.random();
   for(i=1;i<d;i++)  res[i]=(R*u/csum)*res[i];
   
   
   
   return res;
  }
    public static double [] scale(double lambda, double [] p)
  { int d=p.length; 
   int i;
   double [] res=new double[d];
   
   for(i=0;i<d;i++) res[i]=lambda*p[i];
   return res;
    
  }
  
  public static void Test()
  {int d=10;
   double R1=Math.random()*5;
   double R2=Math.random()*5;
   double factor=R2/R1;
   double [] p=randomPointKlein(d,R1), q=randomPointKlein(d,R1);
   
   double KR1= KleinDistance(R1,p,q);
   double KR2= 
   KleinDistance(R2,scale(factor,p),scale(factor,q));
   
   System.out.println(KR1+" vs "+KR2);
   
  }
  
}
