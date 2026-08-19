// Frank.Nielsen@acm.org July 2026

class WeightedPoint
{
  double [] x;
  double w;




  WeightedPoint(double [] xx, double ww)
  {
    w=ww;
    int i, d=xx.length;
    x=new double [d];

    for (i=0; i<d; i++) {
      x[i]=xx[i];
    }
  }


  WeightedPoint(int d)
  {
    x=new double [d];
  }



  static  WeightedPoint Random(int d)
  {
    int i;
    double [] xx=new double[d];

    for (i=0; i<d; i++) xx[i]=Math.random();

    return new WeightedPoint(xx, 0.2*Math.random());
    //  return new WeightedPoint(xx, 0);
    // return new WeightedPoint(xx, 0.1);
  }
}

class PowerMEB
{
  static int d;

  static double sqr(double x) {
    return x*x;
  }

  static double max(double x, double y) {
    if (y>x) return y;
    else return x;
  }

  static double PowerDistance(double [] x, WeightedPoint p)
  {
    int d=x.length, i;
    double res=0.0d;

    for (i=0; i<d; i++)
    {
      res+=sqr(x[i]-p.x[i]);
    }

    return res-p.w;
  }




  static double PowerDistance(  WeightedPoint p, WeightedPoint q)
  {
    int d=p.x.length, i;
    double res=0.0d;

    for (i=0; i<d; i++)
    {
      res+=sqr(p.x[i]-q.x[i]);
    }

    return res-p.w-q.w; // cf JDB
  }



  static double MaxPowerDistance(double [] x, WeightedPoint [] s)
  {
    int d=x.length, i, n=s.length;
    ;
    double res=PowerDistance(x, s[0]);

    for (i=1; i<n; i++) res=max(res, PowerDistance(x, s[i]));

    return res;
  }


  static double SqrDistance(double [] p, double [] q)
  {
    int i;
    double res=0;
    int dd=p.length;

    for (i=0; i<dd; i++) res+=sqr(p[i]-q[i]);

    return res;
  }



  public static double[] barycentric(double[][] vertices, double[] x) {

    int d = x.length;
    int n = d + 1;

    double[][] A = new double[n][n];
    double[] b = new double[n];

    // coordinate equations
    for (int i = 0; i < d; i++) {
      for (int j = 0; j < n; j++)
        A[i][j] = vertices[j][i];
      b[i] = x[i];
    }

    // sum lambda_i = 1
    for (int j = 0; j < n; j++)
      A[d][j] = 1.0;
    b[d] = 1.0;

    return gaussianSolve(A, b);
  }

  private static double[] gaussianSolve(double[][] A, double[] b) {

    int n = b.length;

    // Forward elimination
    for (int p = 0; p < n; p++) {

      int max = p;
      for (int i = p + 1; i < n; i++)
        if (Math.abs(A[i][p]) > Math.abs(A[max][p]))
          max = i;

      double[] temp = A[p];
      A[p] = A[max];
      A[max] = temp;

      double t = b[p];
      b[p] = b[max];
      b[max] = t;

      for (int i = p + 1; i < n; i++) {
        double alpha = A[i][p] / A[p][p];

        b[i] -= alpha * b[p];

        for (int j = p; j < n; j++)
          A[i][j] -= alpha * A[p][j];
      }
    }

    // Back substitution
    double[] x = new double[n];

    for (int i = n - 1; i >= 0; i--) {
      double sum = b[i];
      for (int j = i + 1; j < n; j++)
        sum -= A[i][j] * x[j];
      x[i] = sum / A[i][i];
    }

    return x;
  }


// support spheres of the power meb
  static    int [] SupportPoints(WeightedPoint [] s, double [] cc, double R)
  {
    int nn=s.length;
    double eps=1.0e-3;
    int i, nbsupport=0;

    for (i=0; i<nn; i++)
    {
      if (PowerDistance(cc, s[i])>R-eps ) nbsupport++;
    }

    int [] res=new int[nbsupport];
    nbsupport=0;

    for (i=0; i<nn; i++)
    {
      if (PowerDistance(cc, s[i])>R-eps ) res[nbsupport++]=i;
    }


    return res;
  }


  static void CheckBarycentricIdentity(WeightedPoint [] s, WeightedPoint cc)
  {
    int b[]= SupportPoints(s, cc.x, cc.w);
    int nbb=b.length;
    
        System.out.println("Power MEB # supporting points:"+nbb);
        
    if (nbb!=3) return;


    double [][] simplexv=new double[nbb][2];
    int i, j;

    for (i=0; i<nbb; i++)
      for (j=0; j<2; j++)
        simplexv[i][j]=s[b[i]].x[j];

    System.out.println("----------"+simplexv.length+" "+cc.x.length);
    double [] lambda=barycentric( simplexv, cc.x);
    
    double RR=0;

    for (i=0; i<nbb; i++)
      for (j=0; j<nbb; j++)
        RR+= lambda[i]*lambda[j]*PowerDistance(s[b[i]], s[b[j]]);


    RR/=2.0;


    System.out.println("pairwise reconstruction RR=" +RR+ " versus power meb radius:" +cc.w) ;
  }


  static int ArgMaxPowerDistance(double [] x, WeightedPoint [] s)
  {
    int d=x.length, i, n=s.length;
    ;
    double res=PowerDistance(x, s[0]);
    int winner=0;

    for (i=1; i<n; i++)
    {
      if (PowerDistance(x, s[i])>res) {
        winner=i;
        res=PowerDistance(x, s[i]);
      }
    }


    return winner;
  }


  static double [] LERP(double [] p1, double [] p2, double alpha)
  {
    int i, d=p1.length;
    double [] res=new double[d];

    for (i=0; i<d; i++)
      res[i]=(1-alpha)*p1[i]+alpha*p2[i];

    return res;
  }
  
  static double sqrNorm(WeightedPoint p)
{
  return sqr(p.x[0])+sqr(p.x[1]);
}



 
public static WeightedPoint GPTBadExactPowerMEB2(
       WeightedPoint [] set ) {
          
          double[] p1=set[0].x; double w1=set[0].w;
     double[] p2=set[1].x; double w2=set[0].w;
 

    double dx = p2[0] - p1[0];
    double dy = p2[1] - p1[1];

    double d2 = dx * dx + dy * dy;

    if (d2 == 0.0)
        return null;

    double t = (d2 + w1 - w2) / (2.0 * d2);

   WeightedPoint res=new WeightedPoint(2);
        res.x[0]=p1[0] + t * dx;
        res.x[1]=p1[1] + t * dy;
  res.w=PowerDistance(res.x,set[0]);
    return res;
}
//
// Power MEB of two weighted points
//
static WeightedPoint ExactPowerMEB2( WeightedPoint [] set)
{
double [] a=new double [2];
double b;

// <a,x>+b=0
a[0]=-2.0*(set[0].x[0]-set[1].x[0]);
a[1]=-2.0*(set[0].x[1]-set[1].x[1]);

b=set[1].w-set[0].w+sqrNorm(set[0])-sqrNorm(set[1]);


// x=lambda*(p1-p2)+p2
double lambda, lambdab;


lambda=(SqrDistance(set[0].x,set[1].x)-set[1].w+set[0].w)/(SqrDistance(set[0].x,set[1].x));

WeightedPoint res=new WeightedPoint(2);

lambdab=(-b-a[0]*set[1].x[0]-a[1]*set[1].x[1])/(a[0]*(set[0].x[0]-set[1].x[0]) + a[1]*(set[0].x[1]-set[1].x[1]));
System.out.println("Lambda="+lambda+ " lambdab="+lambdab); //  

lambda=lambdab;


res.x[0]=lambda*(set[0].x[0]-set[1].x[0])+set[1].x[0];
res.x[1]=lambda*(set[0].x[1]-set[1].x[1])+set[1].x[1];
res.w=0;

res.w=PowerDistance(res,set[0]);

return res;
}

static boolean [] coreset;


  // the weights is min
  static WeightedPoint PowerMEB(WeightedPoint [] set, int T)
  {
int f, i;
    int nn=set.length;
      coreset=new boolean[nn];
     for (i=0; i<nn; i++) coreset[i]=false;
    
    
  //  if (nn==2) return ExactPowerMEB2(set);
    
    double [] center=set[0].x;
    

    for (i=0; i<T; i++)
    {
      f=ArgMaxPowerDistance(center, set);
      coreset[f]=true;
      center=LERP(center, set[f].x, 1.0/(1.0+i));
    }

    return new WeightedPoint(center, MaxPowerDistance(center, set));
  }


 // the weights is min
  static WeightedPoint PowerMEBq(WeightedPoint [] set, int T)
  {
    double [] center=set[0].x;
    int f, i;

    for (i=0; i<T; i++)
    {
      f=ArgMaxPowerDistance(center, set);
      center=LERP(center, set[f].x, 2.0/(3.0+i));
    }

    return new WeightedPoint(center, MaxPowerDistance(center, set));
  }
  
  


  static WeightedPoint PowerMEBOneIteration(double [] center, WeightedPoint [] set, double alpha)
  {

    int f, i;


    f=ArgMaxPowerDistance(center, set);
    center=LERP(center, set[f].x, alpha);


    return new WeightedPoint(center, MaxPowerDistance(center, set));
  }
}// end class
