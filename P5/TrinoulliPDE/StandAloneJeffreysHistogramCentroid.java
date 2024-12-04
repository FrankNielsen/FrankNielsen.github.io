// (C) 2024 Frank NIELSEN
// Frank.Nielsen@acm.org
//
// implements
//  "Jeffreys centroids: A closed-form expression for positive histograms and a guaranteed tight approximation for frequency histograms."
//  IEEE Signal Processing Letters 20.7voi (2013): 657-660.
//
// We use external library  specfunc/lambert.c  by  G. Jungman (converted in Java)

class StandAloneJeffreysHistogramCentroid
{

// mixture geodesic, -1 geodesic
static double [] mGeodesic(double[] p, double [] q,double lambda)
{
 int i,dd=p.length;
 double [] res=new double [dd];
 
 for(i=0;i<dd;i++) {res[i]=(1.0-lambda)*p[i]+lambda*q[i];}
 
 
  return res;
}

// Exponential geodesic, +1 geodesic
static double [] eGeodesic(double[] p, double [] q,double lambda)
{
 int i,dd=p.length;
 double [] res=new double [dd];
 
 for(i=0;i<dd;i++) {res[i]=Math.pow(p[i],(1-lambda))*Math.pow(q[i],lambda);}
 
 
  return Normalize(res);
}


  static double scalarKLD(double p, double q)
  {
    return p*Math.log(p/q);
  }

  static double KLD(double [] array1, double[] array2)
  {
    int d=array1.length;
    double  res=0;
    int i;
    for (i=0; i<d; i++)  res+=scalarKLD(array1[i], array2[i]);
    return res;
  }


  static double rightKLInfo(double [][]set, double[] p)
  {
    int n=set.length;
    double   res=0;
    int i;
    for (i=0; i<n; i++) res+=KLD(set[i], p); // right
    return res;
  }

  static double leftKLInfo(double [][]set, double[] p)
  {
    int n=set.length;
    double   res=0;
    int i;
    for (i=0; i<n; i++) res+=KLD(p, set[i]); // left
    return res;
  }



  static  double [] FisherRaoMidpoint(double[] p, double[] q)
  {
    int d=p.length, i;
    double [] res=new double[d];


    for (i=0; i<d; i++)
    {
      res[i]=p[i]+q[i]+2.0*Math.sqrt(p[i]*q[i]);
    }


    return Normalize(res);
  }

  static double W(double x)
  {
    return LambertW.branch0(x);
  }


  static double sum(double [] array)
  {
    double res=0;
    for (int i=0; i<array.length; i++) res+=array[i];
    return res;
  }

  static double scalarJeffreysDiv(double p, double q)
  {
    return (p-q)*Math.log(p/q);
  }

  static double JeffreysDiv(double [] array1, double[] array2)
  {
    int d=array1.length;
    double  res=0;
    int i;
    for (i=0; i<d; i++)  res+=scalarJeffreysDiv(array1[i], array2[i]);
    return res;
  }
  
    static double TotalVariation(double [] array1, double[] array2)
  {
    int d=array1.length;
    double  res=0;
    int i;
    for (i=0; i<d; i++)  res+=Math.abs(array1[i]- array2[i]);
    return 0.5*res;
  }

  // Average Jeffreys divergence from  a histogram p to a set of histograms
  static double JeffreysInformation(double [][]set, double[] p)
  {
    int n=set.length;
    double   res=0;
    int i;
    for (i=0; i<n; i++) res+=JeffreysDiv(set[i], p);
    return res;
  }


  // a is arithmetic mean of the centroids, g is normalized geometric mean
  static double Jeffreys1D(double a, double g, double lambda)
  {
    return a/W(Math.exp(1+lambda)*a/g);
  }


  static double [] Normalize(double [] array)
  {
    int d=array.length;
    double [] res=new double [d];
    int i;
    double norm=sum(array);
    for (i=0; i<d; i++) res[i]=array[i]/norm;
    return res;
  }

  // Arithmetic mean is always normalized
  static double [] ArithmeticMean(double [][] set)
  {
    int n=set.length, d=set[0].length;
    double [] res=new double [d];
    int i, j;
    for (i=0; i<d; i++)
    {
      res[i]=0;
      for (j=0; j<n; j++) res[i]+=set[j][i];
      res[i]/=(double) n;
    }
    return res;
  }

  // Geometric mean needs to be normalized
  static double [] NormalizedGeometricMean(double [][] set)
  {
    int n=set.length, d=set[0].length;
    double [] res=new double [d];
    int i, j;
    for (i=0; i<d; i++)
    {
      res[i]=1;
      for (j=0; j<n; j++) res[i]*=set[j][i];
      res[i]=Math.pow(res[i], 1.0/(double)n); // unstable use exp log
    }
    return Normalize(res);
  }


  static double [] UnnormalizedJeffreysCentroid(double [] array1, double[] array2)
  {

    return UnnormalizedJeffreysCentroid(array1, array2, 0.0);
  }




  static double [] UnnormalizedJeffreysCentroid(double [] array1, double[] array2, double lambda)
  {
    int d=array1.length;
    double [] res=new double [d];
    int i;
    for (i=0; i<d; i++) res[i]= Jeffreys1D(array1[i], array2[i], lambda);
    return res;
  }


  static double [] JeffreysFisherRaoCentroid(double [][] set)
  {
    double [] a, g;

    a=ArithmeticMean(set);
    g=NormalizedGeometricMean(set);
    return FisherRaoMidpoint(a, g);
  }

  static double [] UnnormalizedJeffreysCentroid(double [][] set)
  {

    return UnnormalizedJeffreysCentroid(ArithmeticMean(set), NormalizedGeometricMean(set));
  }

static double max(double x, double y){if (x>y) return x; else return y;}

static void Test2()
{
int d=256;
int i; int j;
double almost1=0.99999,eps;

for(d=16;d<=1024;d*=2)
{

double [][] set=new double[2][d];  
for(i=0;i<d;i++) set[0][i]=1.0/(double)d;
set[1][0]=almost1;eps=(1-almost1)/(d-1.0);
for(i=1;i<d;i++) set[1][i]=eps;

double [] J=NumericalJeffreysCentroid(set);
double [] FR=JeffreysFisherRaoCentroid(set);

double TV=TotalVariation(J,FR);
System.out.println("Total variation between FR and J in dim d="+d+" :"+TV);
}

}

// Frank
  static double [] JeffreysCentroidInfoGeo(double [][] set)
  {
    double lm=0,lM=1,l,eps=1.e-5;
    double [] res=null;
    double [] A, G;
    
    A=ArithmeticMean(set);
    G=NormalizedGeometricMean(set);
    
    while(Math.abs(lM-lm)>eps)
    {
      l=(lm+lM)/2.0;
      res=mGeodesic(A,G,l);
      if (KLD(res,A)>KLD(G,res)){lM=l;}  
      else {lm=l;}
    }
    
    double delta=Math.abs(KLD(res,A)-KLD(G,res));
    System.out.println("info geo quality:"+delta);
    
    return res;
  }
  
    static double [] inductiveJeffreysCentroid(double [][] set, double eps)
    {
       double [] A, G;
    
    A=ArithmeticMean(set);
    G=NormalizedGeometricMean(set);
    return inductiveJeffreysCentroid(A,G,eps);
    }
  
  // Nice recursive code
   static double [] inductiveJeffreysCentroid(double [] p, double [] q, double eps)
   {double [][] set=new double[2][];
   set[0]=p;
   set[1]=q;
   
      double [] A, G;
    double error;

    A=ArithmeticMean(set);
    G=NormalizedGeometricMean(set);
    
    error=TotalVariation(A,G);
    
    if (error<eps) return A; else return  inductiveJeffreysCentroid(A,G,eps);
    
   }

  static double [] NumericalJeffreysCentroid(double [][] set,double eps)
  {
    double [] A, G;
    double error;

    A=ArithmeticMean(set);
    G=NormalizedGeometricMean(set);


    double  lmin=-Double.MAX_VALUE, lmax=0, l, csum=0;
int i,d=A.length;
for(i=0;i<d;i++) lmin=max(lmin,A[i]+Math.log(G[i])-1);

l=0.5*(lmax+lmin);
      csum=sum(UnnormalizedJeffreysCentroid(A, G, l));
      error=(1.0/csum);
 
    while (error-1>eps)
    {
      l=0.5*(lmax+lmin);
      csum=sum(UnnormalizedJeffreysCentroid(A, G, l));
      if (csum>1) lmin=l;
      else lmax=l;
    
 error=(1.0/csum);  
}
    
    
    l=0.5*(lmax+lmin);
    
    error=(1.0/csum)-1;
 //   System.out.println("guaranteed approximation with eps="+eps);
    
    double kl=KLD(UnnormalizedJeffreysCentroid(A, G, l),G);
    
    double delta=Math.abs(-kl-l);
    
  //  System.out.println("\t\tnumerical lambda:"+l+" KL(c:g)="+kl+ "  delta="+delta);
    double klac=KLD(A,UnnormalizedJeffreysCentroid(A, G, l));
    
    delta=Math.abs(-klac-l);
    System.out.println("\t KL(a:c)="+klac+ "  delta="+delta);
    
    
    return UnnormalizedJeffreysCentroid(A, G, l);
  }


  static double [] NumericalJeffreysCentroid(double [][] set)
  {
    
    
    
    double [] A, G;
    

    A=ArithmeticMean(set);
    G=NormalizedGeometricMean(set);


    double  lmin=-Double.MAX_VALUE, lmax=0, l, csum=0;
int i,d=A.length;
for(i=0;i<d;i++) lmin=max(lmin,A[i]+Math.log(G[i])-1);

//System.out.println("lmin:"+lmin);

    double eps=1.0e-12;
    while (Math.abs(lmax-lmin)>eps)
    {
      l=0.5*(lmax+lmin);
      csum=sum(UnnormalizedJeffreysCentroid(A, G, l));
      if (csum>1) lmin=l;
      else lmax=l;
    }
    l=0.5*(lmax+lmin);
    double kl=KLD(UnnormalizedJeffreysCentroid(A, G, l),G);
    double delta=Math.abs(-kl-l);
    
   // System.out.println("\t\tnumerical lambda:"+l+" KL(c:g)="+kl+ "  delta="+delta);
    
        double klac=KLD(A,UnnormalizedJeffreysCentroid(A, G, l));
    
    delta=Math.abs(-klac-l);
   // System.out.println("\t KL(a:c)="+klac+ "  delta="+delta);
    
    
    return UnnormalizedJeffreysCentroid(A, G, l);
  }



static double [] randomHistogram(int dim)
{double [] res=new double[dim];
  for (int j=0; j<dim; j++)
      {
        res[j]=Math.random();
      }
      return Normalize(res);
}


  // test procedure
  static void testJeffreysCentroid()
  {
    int  n=5;
    int d=3; //int  d=256;
    int i, j;
    double [][] set=new double[n][d];

    for (i=0; i<n; i++) {
      for (j=0; j<d; j++)
      {
        set[i][j]=Math.random();
      }
      set[i]=Normalize(set[i]);
    }

    // provide a lower bound
    double [] unnormalizedJeffreys=UnnormalizedJeffreysCentroid(set);
    double unnormalizedJinfo=JeffreysInformation(set, unnormalizedJeffreys);

    double [] normalizedJeffreys=Normalize(unnormalizedJeffreys);
    double normalizedJinfo=JeffreysInformation(set, normalizedJeffreys);

    double [] numericalJeffreys=  NumericalJeffreysCentroid(set);
    double Jinfo=JeffreysInformation(set, numericalJeffreys);

    System.out.println("Jeffreys unnormalized info (closed form, lower bound):\t"+unnormalizedJinfo);
    System.out.println("Jeffreys unnormalized info (closed form, upper bound):\t"+normalizedJinfo);
    System.out.println("Jeffreys normalized info (numerical):\t\t\t"+Jinfo);

    //
    double [] A=ArithmeticMean(set);
    double [] G=NormalizedGeometricMean(set);

    // Same Jeffreys information
    System.out.println("Remarkable property:"+JeffreysInformation(set, A)+"\t"+JeffreysInformation(set, G));
    
    double [][] nset=new double [2][d];
    nset[0]=A;nset[1]=G;
    double [] nJeffreys=  NumericalJeffreysCentroid(nset);
    double tv=TotalVariation(nJeffreys, numericalJeffreys);
    System.out.println("Test centroid of full set vs centroid of sided centroids: tv distance="+tv);
    
    double [] simpleJ=inductiveJeffreysCentroid(A,G, 1.e-5);
    double tv2=TotalVariation(simpleJ, numericalJeffreys);
    
     System.out.println("simpleJ vs usual J: tv distance="+tv2);
    
 
    
  }
}
