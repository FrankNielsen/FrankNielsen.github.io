// Frank Nielsen, Frank.Nielsen@acm.org
// December 4, 2024
// implement BC miniball for the Fisher-Rao categorical distance
// computes an approximation of the smallest enclosing Fisher-Rao ball
// see https://arxiv.org/pdf/1101.4718


class TrinoulliMiniball
{
  static  double sqr(double x) {
    return x*x;
  }
  
  static double FisherRaoDistance(double[] p, double [] q)
  {
    double innerp=0;
    double dd=p.length;
    int i;
    for (i=0; i<dd; i++) innerp+=Math.sqrt(p[i]*q[i]);

    return 2.0*Math.acos(innerp);
  }

  // Dawid 1977
  static double [] FisherRaoGeodesicCategorical(double[] p, double [] q, double lambda)
  {
    int i, dd=p.length;
    double rho=FisherRaoDistance(p, q);
    double [] f=new double[dd];
    double [] res=new double[dd];
    for (i=0; i<dd; i++)
    {
      f[i]= (Math.sqrt(q[i])-Math.sqrt(p[i])*Math.cos(rho/2.0))/Math.sin(rho/2.0);
    }


    for (i=0; i<dd; i++)
    {
      res[i]=sqr(Math.sqrt(p[i])*Math.cos(lambda*rho/2.0)+f[i]*Math.sin(lambda*rho/2.0));
    }

    return res;
  }


// Report the index of the farthest point in set from p 
  static  int FarthestIndex(double [][] set, double [] p)
  {
    int i, n=set.length, win=0;
    double maxdist=FisherRaoDistance(set[0], p);

    for (i=1; i<n; i++)
    {
      if (FisherRaoDistance(set[i], p)>maxdist )
        {win=i;
      maxdist=FisherRaoDistance(set[i], p);}
    }
    
    
    return win;
  }


//  run in the moment eta coordinates
  static double [] TrinoulliFisherRaoBC(double [][] set, int nbiter)
  {
    int i, j, dim, n;
    n=set.length;
    dim=set[0].length;
    double [] sol=set[0];// initialize center
    int fp;

    for (i=1; i<nbiter; i++)
    {
      fp=FarthestIndex(set, sol);
      sol= FisherRaoGeodesicCategorical(sol, set[fp], (double)1/(double)(i+1));
    }

    return sol;
  }
}
