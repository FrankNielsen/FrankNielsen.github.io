// Frank.Nielsen@acm.org  February 2023
/*
 Implement and numerically check
 Collet, Jean-Francois. "An Exact Expression for the Gap in the Data Processing Inequality for $f$-Divergences." IEEE Transactions on Information Theory 65.7 (2019): 4387-4391.
 */

class ExactGapDPI
{
  public static double f(double u) {
    return u*Math.log(u);
  }


  public static double gradf(double u) {
    return Math.log(u)+1.0;
  }


/*
// Chi2
public static double f(double u) {
    return (u-1)*(u-1);
  }


  public static double gradf(double u) {
    return 2*(u-1);
  }
*/

  public static double KL(double [] p, double [] q)
  {
    int i;
    int d=p.length;
    double res=0;
    for (i=0; i<d; i++) res+=p[i]*Math.log(p[i]/q[i])+q[i]-p[i];
    return res;
  }
  
    public static double TV(double [] p, double [] q)
  {
    int i;
    int d=p.length;
    double res=0;
    for (i=0; i<d; i++) res+=Math.abs(p[i]-q[i]);
    return 0.5*res;
  }


  public static double If(double [] p, double [] q)
  {
    int i;
    int d=p.length;
    double res=0;
    for (i=0; i<d; i++) res+=q[i]*f(p[i]/q[i]); // Csiszar convention here
    return res;
  }



  // Scalar Bregman divergence (extended KL when f(x\log x)
  public static double Bf(double x, double y)
  {
    return  f(x)-f(y)-(x-y)*gradf(y);
  }
  
  
public static double g(double u){return u*u;}
//public static double g(double u){return 0;}

  public static double Dfg(double x, double y)
  {
    return  f(x)-f(y)-(x-y)*g(y);
  }

  // column stochastic dbar x d
  public static double [][] randomSto(int d, int dbar)
  {
    double [][] res = new double [dbar][d];
    int i, j;
    double [] csum=new double [d];

    for (i=0; i<dbar; i++)   for (j=0; j<d; j++) {
      res[i][j]=Math.random();
      csum[j]+=res[i][j];
    }

    for (i=0; i<dbar; i++)   for (j=0; j<d; j++) {
      res[i][j]/=csum[j];
    }

    return res;
  }


  static void print(double [] v)
  {
    int d=v.length, i;
    for (i=0; i<d; i++) System.out.print(v[i]+" ");
    System.out.println("");
  }

  static void print(double [][] M)
  {
    int d=M[0].length, i, j;
    int  dbar=M.length;

    for (i=0; i<dbar; i++)
    {

      for (j=0; j<d; j++) System.out.print(M[i][j]+" ");
      System.out.println("");
    }
  }


  public static double [] randHisto(int d)
  {
    double [] p=new double [d];
    double ps=0;
    int i;

    for (i=0; i<d; i++)
    {
      p[i]=Math.random();
      ps+=p[i];
    }

    // normalize to unit probability
    for (i=0; i<d; i++)
    {
      p[i]/=ps;
    }

    return p;
  }
  public static double max (double x, double y){if (x>y) return x; else return y;}
  
  public static double max (double [][] A)
  {    int d=A[0].length, i, j;
    int  dbar=A.length;
     
    double   res=0;
    
    
     for (i=0; i<dbar; i++)
    {
   

      for (j=0; j<d; j++)
      {
       res=max(res,A[i][j]);
      }
  }
  
  return res;
  }
  
  
    public static double   kappa (double [][] A)
    {
    	int dX=A[0].length, i, j,k;
    int  dY=A.length;
    double res=0,rest;
    
    for(j=0;j<dX;j++)
    	for(k=0;k<dX;k++)
    	{rest=0;
    	
    		for(i=0;i<dY;i++) res+= Math.abs(A[i][j]-A[i][k]);
    	
    	res=max(res,rest);
    	}
    	
    return 0.5*res;
    }
    

  public static double [] coarsegrainingdouble (double [][] A, double [] h)
  {
    int d=h.length, i, j;
    int  dbar=A.length;
    double tmp;
    double [] res=new double[dbar];

    // System.out.println("dimX="+d+" dimY="+dbar);

    for (i=0; i<dbar; i++)
    {
      tmp=0.0d;

      for (j=0; j<d; j++)
      {
        tmp+=A[i][j]*h[j];
      }

      res[i]=tmp;
    }

    return res;
  }

// dprime x d matrix
public static double alphabar(double [][] A)
{int d=A[0].length, i, j,k;
    int  dbar=A.length;
    double tmp,res=0;
    for(j=0;j<d;j++) 
    	for(k=0;k<d;k++)
    {
    	tmp=0;
    	for(i=0;i<dbar;i++) tmp+=Math.abs(A[i][j]-A[i][k]);
    	res=max(res,tmp);
    	}
    
    return 0.5*res;
}

// p 216
public static void expTVContractionCoeff(int dimX, int dimY, int nbtests)
  {
  	int i;
    double [] pX; 
    double [] qX; 
    double [] pY; 
    double [] qY;
    double [][] A=randomSto(dimX, dimY);
    double kappa=0,kappat;
    
    for(i=0;i<nbtests;i++)
    {
    	pX= randHisto(dimX);
    	qX= randHisto(dimX);
    	pY=coarsegrainingdouble(A, pX);
        qY=coarsegrainingdouble(A, qX);
    	
    	kappat=TV(pY,qY)/TV(pX, qX);
    	kappa=max(kappa,kappat);
    }
    
    double ubkappa=alphabar(A);
    System.out.println("Experimental contraction coefficient:"+kappa+" exact bound:"+ubkappa);
  }
  
  
public static void expContractionCoeff(int dimX, int dimY, int nbtests)
  {
  	int i;
    double [] pX; 
    double [] qX; 
    double [] pY; 
    double [] qY;
    double [][] A=randomSto(dimX, dimY);
    double kappa=0,kappat;
    
    for(i=0;i<nbtests;i++)
    {
    	pX= randHisto(dimX);
    	qX= randHisto(dimX);
    	pY=coarsegrainingdouble(A, pX);
        qY=coarsegrainingdouble(A, qX);
    	
    	kappat=If(pY,qY)/If(pX, qX);
    	kappa=max(kappa,kappat);
    }
    
    double ubkappa=kappa(A);
    System.out.println("Experimental contraction coefficient:"+kappa+" upper bound:"+ubkappa);
  }

  public static void Test()
  {
 
    int i, j;

    int dimX=10, dimY=dimX/2;
    double [] pX= randHisto(dimX);
    double [] qX=randHisto(dimX);
    double [][] A=randomSto(dimX, dimY);


    //System.out.println("Exact DPI gap (Chollet's paper): Dim X="+dimX+" reduced Dim Y="+dimY);

    // print(A);

    double [] pY=coarsegrainingdouble(A, pX);
    double [] qY=coarsegrainingdouble(A, qX);

    double IfX=If(pX, qX);
    double  IfY=If(pY, qY);

    double Delta=IfX-IfY;
   

    System.out.println("Direct: [non-negative] gap="+Delta);// should always be positive

    double res=0.0d;

    for (i=0; i<dimX; i++) {

      for (j=0; j<dimY; j++)
      {
       res+=A[j][i]*qX[i]*Bf(pX[i]/qX[i], pY[j]/qY[j]);
      
      // This works too (see Remark 1):
      //res+=A[j][i]*qX[i]*Dfg(pX[i]/qX[i], pY[j]/qY[j]);
      
      // This works too!
      //res+=A[j][i]*qX[i]* (Bf(pX[i]/qX[i],1)-Bf(pY[j]/qY[j],1));
      }
    }

    System.out.println("check with Collet's formula ="+res);
    
    double TVy=TV(pY,qY);
    double TVx=TV(pX,qX);
    
    double kappa=dimY*dimX*TVx;
   // System.out.println("should be less than  dimY*TV(pX,qX)="+kappa);
    
    if (kappa<res) {System.out.println("Error!"+res+" "+kappa);System.exit(-1);}
  }
  
   public static void main(String [] args)
  {int i=0;
  	//while(true)  {if ((i%100)==0) System.err.print(".");
  	expTVContractionCoeff(6,3,1000000);
  //	expContractionCoeff(6,4,1000); 
  		
  	// Test();
  	 //i++;}
  }
  
}
