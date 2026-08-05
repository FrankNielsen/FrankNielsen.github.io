// Frank.Nielsen@acm.org July 2026

 

class BregmanMEB
{
  static int d;

  static double sqr(double x) {
    return x*x;
  }

  static double max(double x, double y) {
    if (y>x) return y;
    else return x;
  }
  
  /*
   static double f(double x){return x*Math.log(x)-x;}
 static double fprime(double x){return Math.log(x);}
 static double gprime(double y){return Math.exp(y);}
*/


// squared Euclidean
/*
   static double f(double x){return x*x;}
 static double fprime(double x){return 2*x;}
 static double gprime(double y){return y/2.0;}
 static double g(double y) { return y*y/4.0;}
*/

   static double f(double x){return 0.5*x*x;}
 static double fprime(double x){return x;}
 static double gprime(double y){return y;}
 static double g(double y) { return 0.5*y*y;}

  static double BregmanDivergence(double [] p, double [] q)
  {
    int d=p.length, i;
    double res=0.0d;

    for (i=0; i<d; i++)
    {
      res+=f(p[i])-f(q[i])-(p[i]-q[i])*fprime(q[i]);
    }

    return res;
  }


  static double MaxBregmanDivergence(double [] x, double [] [] s)
  {
    int d=x.length, i, n=s.length;
    ;
    double res=BregmanDivergence(x, s[0]);

    for (i=1; i<n; i++) res=max(res, BregmanDivergence(x, s[i]));

    return res;
  }


  static int ArgMaxBregmanDivergence(double [] x,double [] [] s)
  {
    int d=x.length, i, n=s.length;
    ;
    double res=BregmanDivergence(x, s[0]);
    int winner=0;

    for (i=1; i<n; i++)
    {
      if (BregmanDivergence(x, s[i])>res) {
        winner=i;
        res=BregmanDivergence(x, s[i]);
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
  
  
    static double [] LERPEta(double [] p1, double [] p2, double alpha)
  {
    int i, d=p1.length;
    double [] res=new double[d];

    for (i=0; i<d; i++){
      res[i]=gprime((1-alpha)*fprime(p1[i])+alpha*fprime(p2[i]));
    }
    
    return res;
  }
  

  // the weights is min
  static WeightedPoint BregmanMEB(double [] [] set, int T)
  {
    double [] center=set[0];
    int f, i;

    for (i=0; i<T; i++)
    {
      f=ArgMaxBregmanDivergence(center, set);
      center=LERPEta(center, set[f], 1.0/(1.0+i));
    }

    return new WeightedPoint(center, MaxBregmanDivergence(center, set));
  }



 
}// end class
