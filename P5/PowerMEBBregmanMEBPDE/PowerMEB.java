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
    
    for (i=0; i<d; i++) {x[i]=xx[i];}
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

    return new WeightedPoint(xx,0.2*Math.random());
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


  static double MaxPowerDistance(double [] x, WeightedPoint [] s)
  {
    int d=x.length, i, n=s.length;
    ;
    double res=PowerDistance(x, s[0]);

    for (i=1; i<n; i++) res=max(res, PowerDistance(x, s[i]));

    return res;
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

  // the weights is min
  static WeightedPoint PowerMEB(WeightedPoint [] set, int T)
  {
    double [] center=set[0].x;
    int f, i;

    for (i=0; i<T; i++)
    {
      f=ArgMaxPowerDistance(center, set);
      center=LERP(center, set[f].x, 1.0/(1.0+i));
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
