// Frank.Nielsen@acm.org
//
// May-July 2023
// EmbedMVNSPD.java

// Fisher-Rao and CO via SPD are good

// Test MC estimation of determinant as log-sum-inexpi

// public static vM EriksenGeodesicStd(vM IVP, double t)

import Jama.*;

class Clock
{
 long start, finish, timeElapsed;
 
void Start(){ start = System.nanoTime();}
double Stop(){ finish = System.nanoTime();
timeElapsed = finish - start; 
return timeElapsed*1.0e-9;}

}

class Interval
{
double a, b;

Interval(double aa,double bb){a=aa;b=bb;}

public String toString() {String res; res="("+a+" "+b+")";return res;}
}

// compound (vector,Matrix) type for encoding multivariate normal distributions
class vM
{
  Matrix v, M;

  vM(Matrix vv, Matrix MM)
  {
    v=vv.copy();
    M=MM.copy();
  }

  // case of 1D constructor, say univariate normals
  vM(double mm, double vv)
  {
    v=new Matrix(1, 1);
    v.set(0, 0, mm);
    M=new Matrix(1, 1);
    M.set(0, 0, vv);
  }
  // compound inner product
  public static double inner(vM p1, vM p2)
  {
    return ((p1.v.transpose()).times(p2.v)).trace() + ((p1.M).times(p2.M)).trace();
  }


  public vM times(double l)
  {
    return new vM(v.times(l), M.times(l));
  }

  // compound subtraction
  public vM minus(vM p)
  {
    Matrix vv, MM;

    vv=v.minus(p.v);
    MM=M.minus(p.M);

    return new vM(vv, MM);
  }
  
  
    public vM plus(vM p)
  {
    Matrix vv, MM;

    vv=v.plus(p.v);
    MM=M.plus(p.M);

    return new vM(vv, MM);
  }

  public static String ToString(Matrix M)
  {
    int c=M.getColumnDimension();
    int l=M.getRowDimension();
    int i, j;
    String res="";

    for (i=0; i<l; i++)
    {
      for (j=0; j<c; j++)
      {
        res+=M.get(i, j)+" ";
      }
      res=res+"\n";
    }

    return res;
  }

  public String toString()
  {
    String res="";
    res+="v=\n"+ToString(v)+"\nM=\n"+ToString(M);
    return res;
  }
  
  public void print()
  {v.print(6,6); M.print(6,6);}
  
  // N(A\mu_1+a,A\Sigma_1A^\top)
  public vM affineLeftAction(vM g)
  {
  Matrix gMu=g.M.times(v).plus(g.v);
  Matrix gSigma=g.M.times(M).times(g.M.transpose());
  return new vM(gMu,gSigma);
  }
  
}



class EmbedMVNSPD
{
  public static double sqr(double x) {
    return x*x;
  }
  
  public static double  cosh(double x)
  {
    return  0.5*(Math.exp(x)+Math.exp(-x));
  }
  
   public static double  sinh(double x)
  {
    return  0.5*(Math.exp(x)-Math.exp(-x));
  }

  public static double arccosh(double x)
  {
    return Math.log(x+Math.sqrt(x*x-1));
  }
  
  
    public static double arctanh(double x)
  {
    return 0.5*Math.log((1+x)/(1-x));
  }
  
  
    public static double arcsinh(double x)
  {
    return Math.log(x+Math.sqrt(x*x+1));
  }

/*
// additive error
public static Interval GuaranteedFisherRaoMVN(vM N1, vM N2, double err)
{
Interval res;  
int T=1; 
double error;

res=GuaranteedFisherRaoMVN(N1,N2,T);
error=res.b-res.a;

while(error>err)
{
  
}

}
*/

public static void TestKobayashiMethod(vM N1, vM N2)
{
 double t=Math.random();
 double FR12;
 double FR1t;
 int nbiter=1000;
 
  vM N1t=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,t);
  
  FR12=GuaranteedFisherRaoMVN(N1,N2,nbiter).b;
  FR1t=GuaranteedFisherRaoMVN(N1,N1t,nbiter).b;
  
  double mp=t*FR12;
  
  System.out.println("[Test Kobayashi method] t="+t+" t FR12="+mp+" versus Kobayashi geodesic:"+FR1t );
  
}

public static double FisherRaoMVN(vM N1, vM N2, double alpha, double beta, int T)
{
 double lb=0, ub=0;
 int i;
 double t, tn;
 vM X, Xn; // Xn for X next
 
 // cut geodesics into geodesic segments
 for(i=0;i<T;i++)
 {// range between alpha and beta
   t=alpha+(beta-alpha)*i/(double)T; 
   tn=alpha+(beta-alpha)*(i+1.0)/(double)T;
   
   X=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,t);
   Xn=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,tn);
   
    
   ub+=Math.sqrt(JeffreysMVN(X,Xn));
 }
  
 return ub;
}


public static double Arithmetic(double x, double y, double t)
{
return (1-t)*x+t*y; 
}

public static double Harmonic(double x, double y, double t)
{
return  1.0/((1-t)*(1.0/x)+t*(1.0/y));
}


public static double Geometric(double x, double y, double t)
{
return  Math.pow(x,1-t)*Math.pow(y,t);
}

public static double InductiveAHM(double x, double y, double t, int nbiter)
{
double xx,yy;
 int i;
 
 for(i=0;i<nbiter;i++)
 {
   xx=Arithmetic(x,y,t);
   yy=Harmonic(x,y,t);
x=xx;y=yy;
 }
 return x;
}


static void TestAHM1D()
{
 double g,x,y,ahm;
 x=100*Math.random();y=100*Math.random();
 double t=Math.random();
 
 t=0.5;
 
 g=Geometric(x,y,t);
 ahm=InductiveAHM(x,y,t,100);
 double error=Math.abs(g-ahm);
 System.out.println("AHM 1D:"+ahm+" geometric="+g+" x="+x+" y="+y);
  System.out.println("t="+t+" error:"+error);
}

public static Matrix Arithmetic(Matrix X, Matrix Y, double t)
{
return (X.times(1-t)).plus(Y.times(t));
}

public static Matrix Harmonic(Matrix X, Matrix Y, double t)
{
return (X.inverse().times(1-t)).plus(Y.inverse().times(t)).inverse();
}

public static Matrix InductiveAHM(Matrix X, Matrix Y, double t, int nbiter)
{
 Matrix XX,YY;
 int i;
 
 for(i=0;i<nbiter;i++)
 {
   XX=Arithmetic(X,Y,t);
   YY=Harmonic(X,Y,t);
   X=XX;Y=YY;
 }
 return X;
}

public static vM MVNRieMean(vM N1, vM N2)
{
  vM res=KobayashiMVNGeodesic(N1,N2,0.5);
  
  return res;
}


public static void Mean1D(vM N1, vM N2)
{
 int nbiter=10000;
 
 vM Nmean1=MVNRieMean(N1,N2); // Riemannian mean
 vM Nmean2=DualInductiveMean(N1,N2,nbiter); // Inductive mean
  
  double rho1,rho2, rho12, delta2, delta3;
  
   rho12=FisherRao(N1.v.get(0,0),Math.sqrt(N1.M.get(0,0)),N2.v.get(0,0),Math.sqrt(N2.M.get(0,0)));
    rho1=FisherRao(N1.v.get(0,0),Math.sqrt(N1.M.get(0,0)),Nmean1.v.get(0,0),Math.sqrt(Nmean1.M.get(0,0)));// GuaranteedFisherRaoMVN(N1,Nmean1,nbiter).b;
   rho2= FisherRao(Nmean1.v.get(0,0),Math.sqrt(Nmean1.M.get(0,0)),N2.v.get(0,0),Math.sqrt(N2.M.get(0,0))) ; //GuaranteedFisherRaoMVN(Nmean1,N2,nbiter).b;

  delta2=Math.abs(rho1-rho2); // difference
  delta3=rho12-(rho1+rho2); // 
 System.out.println("1D. Rie mean' rho1="+ rho1+" rho2="+rho2+" "+ "|rho1-rho2|="+delta2+" delta triangle ineq geodesic:"+delta3);
  
    rho12=FisherRao(N1.v.get(0,0),Math.sqrt(N1.M.get(0,0)),N2.v.get(0,0),Math.sqrt(N2.M.get(0,0)));
   rho1=FisherRao(N1.v.get(0,0),Math.sqrt(N1.M.get(0,0)),Nmean2.v.get(0,0),Math.sqrt(Nmean2.M.get(0,0)));// GuaranteedFisherRaoMVN(N1,Nmean1,nbiter).b;
   rho2= FisherRao(Nmean2.v.get(0,0),Math.sqrt(Nmean2.M.get(0,0)),N2.v.get(0,0),Math.sqrt(N2.M.get(0,0))) ; //GuaranteedFisherRaoMVN(Nmean1,N2,nbiter).b;

  delta2=Math.abs(rho1-rho2); // difference
   delta3=rho12-(rho1+rho2); // 
 System.out.println("1D. Inductive mean rho1="+ rho1+" rho2="+rho2+" "+ "|rho1-rho2|="+delta2+" delta triangle ineq geodesic:"+delta3);
  
 
 
}


public static void Mean(vM N1, vM N2)
{
 int nbiter=10000;
 vM Nmean1=MVNRieMean(N1,N2);
 vM Nmean2=DualInductiveMean(N1,N2,nbiter);
 
 System.out.println("Inductive mean for ");
 System.out.println(N1); System.out.println(N2);
 System.out.println(Nmean2);
 
 double div12=JeffreysMVN(Nmean1,Nmean2);
 double divm12=JeffreysMVN(N1,N2);
 double div1=JeffreysMVN(N1,Nmean2);
  double div2=JeffreysMVN(Nmean2,N2);
  double delta=Math.abs(div1-div2);
   System.out.println("Jeffreys "+ div1+" "+div2+" "+divm12+" delta div1,div2="+delta);
  
  double rho12,rho1,rho2,delta2,delta3;
 rho12=GuaranteedFisherRaoMVN(N1,N2,nbiter).b;
  rho1=GuaranteedFisherRaoMVN(N1,Nmean1,nbiter).b;
   rho2=GuaranteedFisherRaoMVN(Nmean1,N2,nbiter).b;

 delta2=Math.abs(rho1-rho2);
  delta3=rho12-(rho1+rho2);
 System.out.println("Riemannian Mean: rho1="+ rho1+" rho2="+rho2+" "+ "|rho1-rho2|="+delta2+" delta geodesic:"+delta3);
  
  
  rho12=GuaranteedFisherRaoMVN(N1,N2,nbiter).b;
  rho1=GuaranteedFisherRaoMVN(N1,Nmean2,nbiter).b;
   rho2=GuaranteedFisherRaoMVN(Nmean2,N2,nbiter).b;

 delta2=Math.abs(rho1-rho2);
  delta3=rho12-(rho1+rho2);
 System.out.println("Inductive Mean: rho1="+ rho1+" rho2="+rho2+" "+ "|rho1-rho2|="+delta2+" delta geodesic:"+delta3);
  
  
// System.out.println("Diff Rie Mean Jeffreys:"+div12);
  
}

// Returns lower and upper bounds
public static Interval GuaranteedFisherRaoMVN(vM N1, vM N2, int T)
{
 double lb=0.0, ub=0.0;
 int i;
 double t, tn;
 vM X, Xn; // Xn for X next
 
 // cut geodesics into T geodesic segments using T+1
 for(i=0;i<T;i++)
 {
   t=(double)i/(double)T; 
   tn=(i+1.0)/(double)T;
   
   X=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,t);
   Xn=EmbedMVNSPD.KobayashiMVNGeodesic(N1,N2,tn);
   
   lb+=rhoCOSPD(X,Xn);
   
   ub+=Math.sqrt(JeffreysMVN(X,Xn));
 }
 // Fisher-Rao distance is contained inside this interval
 return new Interval(lb,ub);
}


  public static double rhoCOSPD(double m1, double s1, double m2, double s2)
  {
    Matrix P1, P2;
    vM M1, M2;
    M1=new vM(m1, s1*s1);
    M2=new vM(m2, s2*s2);
    P1=EmbedSPD(M1.v, M1.M);
    P2=EmbedSPD(M2.v, M2.M);
    // use now 2D SPD distance on the cone
    return Math.sqrt(1.0/2.0)*RieSPDDistance(P1, P2);
  }



public static double rhoCOSPD(vM N1, vM N2)
{
  Matrix P1, P2;
    vM M1, M2;
    P1=EmbedSPD(N1.v, N1.M);
    P2=EmbedSPD(N2.v, N2.M);
     
    return Math.sqrt(1.0/2.0)*RieSPDDistance(P1, P2);
}

  public static double rhoCO(double m1, double s1, double m2, double s2)
  {
    double deltamus1=(m2-m1)/s1;
    double ratio2=s2/s1;
    double tmp=sqr( arccosh((sqr(deltamus1)+ratio2+1.0)/(2.0*Math.sqrt(ratio2)))
      +
      (1.0/4.0)*sqr(Math.log(ratio2))
      );

    return Math.sqrt(tmp);
  }

  public static double delta(double a, double b, double c, double d)
  {
    return Math.sqrt((sqr(c-a)+2.0*sqr(d-b))/(sqr(c-a)+2.0*sqr(d+b)));
  }

  // OK
  public static double FisherRao(double m1, double s1, double m2, double s2)
  {
    return Math.sqrt(2)*Math.log((1.0+delta(m1, s1, m2, s2))/(1.0-delta(m1, s1, m2, s2)));
  }

  public static double rhoCO2(double m1, double s1, double m2, double s2)
  {
    double tmp;
    tmp=0.5*(sqr(FisherRao(m1, Math.sqrt(2)*s1, m2, Math.sqrt(2)*s2))+
      sqr(FisherRao(m1, Math.sqrt(2)*s1, m1, Math.sqrt(2)*s2))
      );
    return Math.sqrt(tmp);
  }

  // p230
  public static double rhoCOSameVar(double m1, double m2, double s)
  {
    double deltamu=m2-m1;
    return arccosh(1+0.5*sqr(deltamu/s));
  }

  public static void experimentCosta()
  {
    System.out.println("Costa Fisher Rao 2D:");

    vM N1, N2;
    Matrix m1, S1, m2, S2;
    Matrix P1, P2;
    double mu;

    m1=new Matrix(2, 1);
    S1=new Matrix(2, 2);
    m2=new Matrix(2, 1);
    S2=new Matrix(2, 2);

    for (mu=0; mu<=10; mu+=1.0)
    {


      m1.set(0, 0, -mu);
      m1.set(1, 0, 0);
      S1.set(0, 0, 0.55);
      S1.set(0, 1, -0.45);
      S1.set(1, 0, -0.45);
      S1.set(1, 1, 0.55);

      m2.set(0, 0, mu);
      m2.set(1, 0, 0);
      S2.set(0, 0, 0.55);
      S2.set(0, 1, 0.45);
      S2.set(1, 0, 0.45);
      S2.set(1, 1, 0.55);

      //S1.print(6,6);S2.print(6,6);

      N1=new vM(m1, S1);
      N2=new vM(m2, S2);


      double fra=approximateFisherRaoMVN(N1, N2, 1000);


      P1=EmbedSPD(m1, S1);
      P2=EmbedSPD(m2, S2);
      double rhospd=RiemannianDistance(P1, P2);
      
      double UB=UB3(N1,N2);

      double factor=fra/rhospd;

      System.out.println("Costa Fisher Rao mu:"+mu+" FR approx="+fra+" embed SPD (LB):"+rhospd+" factor approx<="+factor);
    System.out.println("Upper bound 3:"+UB);
    
    double UBF=Math.sqrt(KLD(N1,N2)+KLD(N2,N1));
    System.out.println("Upper bound sqrt J:"+UBF);
    }
  }

  public static void experiments(int d)
  {
    double mu=10;
    vM N1, N2;
    Matrix m1, S1, m2, S2;
    Matrix P1, P2;
    int i, j;
    int l;
    double fra, rhospd, factor, avgfactor=0, minfactor=Double.POSITIVE_INFINITY, maxfactor=Double.NEGATIVE_INFINITY;
    m1=new Matrix(d, 1);
    S1=Matrix.identity(d, d);
    N1=new vM(m1, S1);
    int nbexps=1000;

    for (l=0; l<nbexps; l++)
    {
      m2=new Matrix(d, 1);
      S2=new Matrix(d, d);
      for (i=0; i<d; i++) m2.set(i, 0, 10*Math.random());
      for (i=0; i<d; i++) S2.set(i, i, 10*Math.random());
      N2=new vM(m2, S2);



      fra=approximateFisherRaoMVN(N1, N2, 1000);


      P1=EmbedSPD(m1, S1);
      P2=EmbedSPD(m2, S2);
      rhospd=RiemannianDistance(P1, P2);
      //System.out.println("embed SPD:"+rhospd);
      factor=fra/rhospd;
      //System.out.println("ratio="+factor);
      avgfactor+=factor;
      minfactor=min(minfactor, factor);
      maxfactor=max(maxfactor, factor);
    }
    avgfactor/=(double)nbexps;
    System.out.println(d+"\t &\t"+avgfactor+"\t &\t"+minfactor+"\t &\t"+maxfactor+"\t\\cr");
  }



  public static void test2D()
  {
    double mu=10;
    vM N1, N2;
    Matrix m1, S1, m2, S2;
    Matrix P1, P2;


    m1=new Matrix(2, 1);
    S1=new Matrix(2, 2);
    m2=new Matrix(2, 1);
    S2=new Matrix(2, 2);

    m1.set(0, 0, -mu);
    m1.set(1, 0, 0);
    S1.set(0, 0, 0.55);
    S1.set(0, 1, -0.45);
    S1.set(1, 0, -0.45);
    S1.set(1, 1, 0.55);

    m2.set(0, 0, mu);
    m2.set(1, 0, 0);
    S2.set(0, 0, 0.55);
    S2.set(0, 1, 0.45);
    S2.set(1, 0, 0.45);
    S2.set(1, 1, 0.55);

    //S1.print(6,6);S2.print(6,6);

    N1=new vM(m1, S1);
    N2=new vM(m2, S2);



    System.out.println("Fisher Rao 2D:");

    double fra=approximateFisherRaoMVN(N1, N2, 1000);
    System.out.println("2D Approximate Fisher Rao:"+fra);

    P1=EmbedSPD(m1, S1);
    P2=EmbedSPD(m2, S2);
    double rhospd=RiemannianDistance(P1, P2);
    System.out.println("embed SPD:"+rhospd);
    double factor=fra/rhospd;
    System.out.println("factor approx<="+factor);
  }

  public static double min(double a, double b) {
    if (a<b) return a;
    else return b;
  }
  public static double max(double a, double b) {
    if (a>b) return a;
    else return b;
  }

  public static void experiments1D()
  {
    double m1, s1, m2, s2;
    double nm1, ns1, nm2, ns2;
    vM N1, N2;
    int l;
    double factor, minfactor=Double.POSITIVE_INFINITY, avgfactor=0, maxfactor=Double.NEGATIVE_INFINITY;
    double fr, fra, error, rhospd;
    int nbtests=1000;

System.out.println("Experiments in 1D with nbtests="+nbtests);

    for (l=0; l<nbtests; l++)
    {
      m1=15*Math.random();
      s1=6*Math.random();
      m2=6*Math.random();
      s2=15*Math.random();
      //System.out.println("m1="+m1+" s1="+s1+" m2="+m2+" s2="+s2);


      fr=FisherRao(m1, s1, m2, s2);
      rhospd=rhoCOSPD(m1, s1, m2, s2);


      N1=new vM(m1, s1*s1);
      N2=new vM(m2, s2*s2);
      fra=approximateFisherRaoMVN(N1, N2, 1000);

      //factor=fra/rhospd;// kappa
      factor=fra/fr;// kappa

      error=Math.abs((fr-fra)/fr);


      //System.out.println("Approximate Fisher Rao:"+fra+ " factor approx SPD<="+factor+ " relative error:"+error);
      //System.out.println("Fisher Rao:"+fr+" Calvo Oller:"+rco+" CO2:"+rco2+ " via spd (LB):"+rhospd);


      minfactor=min(minfactor, factor);
      avgfactor+=factor;
      maxfactor=max(maxfactor, factor);
    }
    avgfactor/=(double)nbtests;
    
    System.out.println("min factor:"+minfactor+" avg factor"+avgfactor+" maxfactor:"+maxfactor);
  }


  public static void test1D()
  {
    double m1, s1, m2, s2;
    double nm1, ns1, nm2, ns2;
    m1=15*Math.random();
    s1=6*Math.random();
    m2=6*Math.random();
    s2=15*Math.random();

    //s2=s1;


    System.out.println("m1="+m1+" s1="+s1+" m2="+m2+" s2="+s2);

    double A=Math.random();
    double a=Math.random();

    nm1=A*m1+a;
    ns1=A*s1; // in 1d!
    nm2=A*m2+a;
    ns2=A*s2;


    double rco=  rhoCO(m1, s1, m2, s2);
    double rco2=  rhoCO2(m1, s1, m2, s2);
    double fr=FisherRao(m1, s1, m2, s2);
    double rhospd=rhoCOSPD(m1, s1, m2, s2);
    double rhocovar= rhoCOSameVar(m1, m2, s1);

    vM N1=new vM(m1, s1*s1);
    vM N2=new vM(m2, s2*s2);
    double fra=approximateFisherRaoMVN(N1, N2, 1000);
    double factor=fra/rhospd;
    double error=Math.abs((fr-fra)/fr);


    System.out.println("Approximate Fisher Rao:"+fra+ " factor approx SPD<="+factor+ " relative error:"+error);


    System.out.println("Fisher Rao:"+fr+" Calvo Oller:"+rco+" CO2:"+rco2+ " via spd (LB):"+rhospd);
    if (s1==s2) System.out.println("when same var:"+rhocovar);

    double nfr=FisherRao(nm1, ns1, nm2, ns2);
    System.out.println("Affine group action Fisher Rao:"+nfr);

    double nrco=  rhoCO(nm1, ns1, nm2, ns2);
    double nrco2=  rhoCO2(nm1, ns1, nm2, ns2);
    System.out.println("Affine group action CO:"+nrco);
    System.out.println("Affine group action CO2:"+nrco2);
  }


//
// Project a SPD matrix onto the embedded MVN submanifold
//
  public static vM SPD2MVN(Matrix P)
  {
    int d=P.getRowDimension(),i,j;
    double beta=P.get(d-1, d-1);
    Matrix mu=new Matrix(d-1, 1), Sigma=new Matrix(d-1, d-1);
  
    for (i=0; i<d-1; i++)
    { mu.set(i, 0, P.get(d-1, i)/beta); // last row is beta mu
   }
    for (i=0; i<d-1; i++)
      for (j=0; j<d-1; j++)
      {        Sigma.set(i, j, P.get(i, j));}
   
    Sigma=Sigma.minus(mu.times(mu.transpose()).times(beta)); // retrieve covariance matrix

    return new vM(mu, Sigma);
  }


public static void testDiffeoSPD2MVN(vM N)
{
  System.out.println("check diffeo "+N);
  
  double beta=Math.random();
  
  Matrix SPD=EmbedSPD(N,beta);
  
  vM NN=DiffeoSPD2MVN(SPD);
  
  System.out.println("versus "+ NN);
}


//
// Convert back a SPD to a MVN
//
public static vM DiffeoSPD2MVN(Matrix P)
  {
    int d=P.getRowDimension(),i,j;
    double beta=P.get(d-1, d-1);
    Matrix mu=new Matrix(d-1, 1), Sigma=new Matrix(d-1, d-1);
  
    for (i=0; i<d-1; i++)
    { mu.set(i, 0, P.get(d-1, i)/beta); // last row is beta mu
   }
    for (i=0; i<d-1; i++)
      for (j=0; j<d-1; j++)
      {        Sigma.set(i, j, P.get(i, j));}
   
    Sigma=Sigma.minus(mu.times(mu.transpose()).times(beta)); // retrieve covariance

    return new vM(mu, Sigma);
  }
  

  //
  // get beta, set beta to 1 // foliations
  //
  public static Matrix Project2EmbeddedMVN(Matrix P)
  {
    int d=P.getRowDimension();
    double beta=P.get(d-1, d-1);
    Matrix mu=new Matrix(d-1, 1);//column vector
    Matrix Sigma=new Matrix(d-1, d-1);
    int i, j;

    for (i=0; i<d-1; i++)
    {
      mu.set(i, 0, P.get(d-1, i)/beta); // last row is beta mu
    }

    for (i=0; i<d-1; i++)
      for (j=0; j<d-1; j++)
      {
        Sigma.set(i, j, P.get(i, j));
      }

    Sigma=Sigma.minus(mu.times(mu.transpose()).times(beta));

    return EmbedSPD(mu, Sigma);
  }

  // p 239 of C & O 1990
  public static double Distance2EmbeddedMVN(Matrix P)
  {
    int d=P.getRowDimension();
    double beta=P.get(d-1, d-1);

    return Math.sqrt(1.0/2.0)*Math.abs(Math.log(beta));

    //return Math.abs(Math.log(beta));
  }

//
// Multivariate normals N1 and N2 parameterized by vector-Matrix (vM), number of steps
//
  public static double approximateFisherRaoMVN(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=ProjectedSPDGeodesic2MVN(N1, N2, lambda);
      X2=ProjectedSPDGeodesic2MVN(N1, N2, lambda+dlambda);
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }
  

  
   public static vM[] PathFRUniN(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 
double mu=0,sigma=1;
    for (int i=0;i<=nbpts;i++)
    { double lambda=i/(double)nbpts;
    {
      X[i]=new vM(mu,sqr(sigma));
    } 
    }
    return X;
  }
    

  
        public static vM[] PathFisherRao(vM IVP, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { double lambda=i/(double)nbpts;
    X[i]=GeodesicStd(IVP,lambda);
      
      
    }
    return X;
  }
  
      public static vM[] PathProjectedMVN(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { double lambda=i/(double)nbpts;
      X[i]=ProjectedSPDGeodesic2MVN(N1,N2,lambda);
      
    }
    return X;
  }
  

// General routine for the approximation
 public static double approximateFisherRaoMVN(vM N1, vM N2, vM[] pts)
  {

    double res=0;
    vM X1, X2;
    int T=pts.length,i;

    for (i=0;i<T-1;i++)
    { 
       
     res+=Math.sqrt(JeffreysMVN(pts[i],pts[i+1]));
    }
    return res;
  }



public static vM[] PathHilbert(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 
    Matrix P1bar=EmbedSPD(N1);
    Matrix P2bar=EmbedSPD(N2);
    
    
  

    for (int i=0;i<=nbpts;i++)
    { // Hilbert geodesic is linear geodesic
      X[i]=SPD2MVN(LERP(P1bar, P2bar, (double)i/(double)nbpts));
      
    }
    return X;
  }
  
  // Let parameter beta varies
  public static vM[] PathHilbert(double beta, vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 
    Matrix P1bar=EmbedSPD(N1,beta);
    Matrix P2bar=EmbedSPD(N2,beta);
    
     

    for (int i=0;i<=nbpts;i++)
    { // Hilbert geodesic is linear geodesic
      X[i]=SPD2MVN(LERP(P1bar, P2bar, (double)i/(double)nbpts));
      
    }
    return X;
  }
  
public static vM[] PathLambda(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { 
      X[i]=LERP(N1, N2, (double)i/(double)nbpts);
      
    }
    return X;
  }
  


public static double approximateFisherRaoMVNLERPLambda(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=LERP(N1, N2, lambda);
      X2=LERP(N1, N2, lambda+dlambda);
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }



public static double approximateFisherRaoMVNLERPHilbert(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;
    Matrix P1bar=EmbedSPD(N1);
    Matrix P2bar=EmbedSPD(N2);

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=SPD2MVN(LERP(P1bar, P2bar, lambda));
      X2=SPD2MVN(LERP(P1bar, P2bar, lambda+dlambda));
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }
  
  
  
  public static double approximateFisherRaoMVNLERPHilbert(double beta, vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;
    Matrix P1bar=EmbedSPD(N1,beta);
    Matrix P2bar=EmbedSPD(N2,beta);
    
    //testDiffeoSPD2MVN(N2);

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=SPD2MVN(LERP(P1bar, P2bar, lambda));
      
    //if (lambda==0){System.out.println("Check"); P2bar.print(6,6); LERP(P1bar, P2bar, 1.0).print(6,6);}
      
      X2=SPD2MVN(LERP(P1bar, P2bar, lambda+dlambda));
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }

public static double approximateFisherRaoMVNLERPTheta(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=Theta2LERPl(N1, N2, lambda);
      X2=Theta2LERPl(N1, N2, lambda+dlambda);
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }
  
  public static vM[] PathTheta(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { 
      X[i]=Theta2LERPl(N1, N2, (double)i/(double)nbpts);
      
    }
    return X;
  }
  
  
    public static vM[] PathEta(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { 
      X[i]=Eta2LERPl(N1, N2, (double)i/(double)nbpts);
      
    }
    return X;
  }
  
  
  // blend mixture with exponential geodesics
  public static double approximateFisherRaoMVNLERPThetaEta(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=(Theta2LERPl(N1, N2, lambda).plus(Eta2LERPl(N1,N2,lambda))).times(0.5);
      X2=(Theta2LERPl(N1, N2, lambda+dlambda).plus(Eta2LERPl(N1, N2, lambda+dlambda))).times(0.5);
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }
  
  
      public static vM[] PathThetaEta(vM N1, vM N2, int nbpts)
  {
    vM [] X= new vM[nbpts+1]; 

    for (int i=0;i<=nbpts;i++)
    { double lambda=i/(double)nbpts;
      X[i]=(Theta2LERPl(N1, N2, lambda).plus(Eta2LERPl(N1,N2,lambda))).times(0.5);
      
    }
    return X;
  }
  
  
public static double approximateFisherRaoMVNLERPEta(vM N1, vM N2, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    vM X1, X2;

    for (lambda=0; lambda<1.0-dlambda; lambda+=dlambda)
    { 
      X1=Eta2LERPl(N1, N2, lambda);
      X2=Eta2LERPl(N1, N2, lambda+dlambda);
     // sum the \Delta s elements along the projected SPD geodesic onto the embedded MVN
     res+=Math.sqrt(JeffreysMVN(X1, X2));
    }
    return res;
  }

  public static double approximateSPDDist(Matrix P, Matrix Q, int nbsteps)
  {
    double lambda, dlambda=1.0/(double)nbsteps;
    double res=0;
    Matrix X1, X2;
    for (lambda=0; lambda<1-dlambda; lambda+=dlambda)
    {
      X1=RiemannianGeodesic(P, Q, lambda);
      X2=RiemannianGeodesic(P, Q, lambda+dlambda);
      res+=Math.sqrt(2*KLMVN(X1, X2));
    }

    return res;
  }

  public static vM ProjectedSPDGeodesic2MVN(vM N1, vM N2, double lambda)
  {
    Matrix P1=EmbedSPD(N1.v, N1.M);
    Matrix P2=EmbedSPD(N2.v, N2.M);
    Matrix P= RiemannianGeodesic(P1, P2, lambda);// SPD geodesic
    Matrix Pproj=Project2EmbeddedMVN(P);
    vM N=SPD2MVN(Pproj); // convert to MVN

    return N;
  }

// Generalize
// Algorithms associated with arithmetic, geometric and harmonic means and integrable systems
public static vM DualInductiveMean(vM N1, vM N2, int nbiter)
{
 vM theta,eta,theta1,theta2,eta1,eta2;
 int i;

 
 for(i=0;i<nbiter;i++)
 {
 theta1=L2T(N1);
 theta2=L2T(N2);
 eta1=T2E(theta1);
 eta2=T2E(theta2);
 
 theta=LERP(theta1,theta2,0.5);
 eta=LERP(eta1,eta2,0.5);
 
 N1=T2L(theta);
 N2=E2L(eta);
 }
  
  return N1;
}

public static Matrix GeometricMean(Matrix P, Matrix Q)
  {
    return RiemannianGeodesic(P,Q,0.5);
  }

    public static boolean isSPD(Matrix M)
{
boolean spd=true;
EigenvalueDecomposition evd=M.eig();
Matrix diag=evd.getD();

for(int i=0;i<diag.getColumnDimension();i++)
  if (diag.get(i,i)<=0)
      spd=false;  
      
return spd;
}

  public static Matrix RiemannianGeodesic(Matrix P, Matrix Q, double lambda)
  {
    
//lambda=0.5;

    if (lambda==0.0) return P;
    if (lambda==1.0) return Q;

    Matrix result;
    Matrix Phalf=power(P, 0.5);
    Matrix Phalfinv=power(P, -0.5);

    result=Phalfinv.times(Q).times(Phalfinv);
    result=power(result, lambda);
    
  
  
  result=(Phalf.times(result)).times(Phalf);
  
  /*
    boolean spd=isSPD((P.inverse()).times(Q));
    
    if (spd) {
      
      System.out.println("is SPD");
     Matrix result2=P.times( power((P.inverse()).times(Q),lambda) );
    
    System.out.println("Difference interpolation SPD:");
    result2.minus(result).print(6,6);System.exit(1);
}
*/

    return result;
  }


  // Print on the console the statistics
  public static Matrix MinMaxVerbose(Matrix[] set, int nbIter)
  {
    int i=0, j, f;
    double ratio, distance, radius;
    Matrix COpt=new Matrix(set[0].getArrayCopy());
    ;
    double ropt=Double.POSITIVE_INFINITY;

    Matrix C=new Matrix(set[0].getArrayCopy());
    distance=RiemannianDistance(C, COpt)/ropt;
    radius=RiemannianDistance(C, set[argMaxCenter(set, C)]);

    System.out.println(i+"\t"+distance+"\t"+radius);

    for (i=1; i<=nbIter; i++)
    {
      f=argMaxCenter(set, C);
      ratio=1.0/(i+1);
      C=CutGeodesic(C, set[f], ratio);

      distance=RiemannianDistance(C, COpt)/ropt;
      radius=RiemannianDistance(C, set[argMaxCenter(set, C)]);
      System.out.println(i+"\t"+distance+"\t"+radius);
    }

    return C;
  }

  // Cut the geodesic [PQ] into [PR] and [RQ] so that d(P,R)=cut*d(P,Q)
  // For SPD matrices, the geodesic lambda split is equal to cut so we do not need the while loop
  // see paper for explanation.
  public static Matrix CutGeodesic(Matrix P, Matrix Q, double cut)
  {
    double dist=RiemannianDistance(P, Q);
    double minl=0, maxl=1.0, maxm=0.5;
    Matrix M=null;
    double distc;

    while (maxl-minl>1.0e-5)
    {
      maxm=0.5*(minl+maxl);
      M=RiemannianGeodesic(P, Q, maxm);
      distc=RiemannianDistance(P, M);

      if (distc>dist*cut)
        maxl=maxm;
      else minl=maxm;
    }

    //System.out.println("wanted:"+cut+" obtained for lambda="+maxm);

    return M;
  }

  // Maximum distance from the current centerpoint C
  public static double MaxCenter(Matrix[] set, Matrix C)
  {
    double result=0.0;

    for (int i=0; i<set.length; i++)
    {
      if  (RiemannianDistance(set[i], C)>result)
        result=RiemannianDistance(set[i], C);
    }

    return result;
  }

  // Return the index of the farthest point
  public static int argMaxCenter(Matrix[] set, Matrix C)
  {
    int winner=-1;
    double result=0.0;

    for (int i=0; i<set.length; i++)
    {
      if  (RiemannianDistance(set[i], C)>result)
      {
        result=RiemannianDistance(set[i], C);
        winner=i;
      }
    }

    return winner;
  }

  // Performs the generalization of Badoiu-Clarkson algorithm:
  // see paper: Smaller core-sets for balls. SODA 2003: 801-802
  public static Matrix MinMax(Matrix[] set, int nbIter)
  {
    int i, j, f;
    double ratio;
    Matrix C=new Matrix(set[0].getArrayCopy());

    for (i=1; i<=nbIter; i++)
    {
      f=argMaxCenter(set, C);
      ratio=1.0/(i+1);
      C=CutGeodesic(C, set[f], ratio);
      //System.out.println(i+"\t"+MaxCenter(set,C));
    }

    return C;
  }

public static double HilbertMVNDistance(vM N1, vM N2)
{return HilbertMVNDistance(1,N1,N2);}

 public static double HilbertMVNDistance(double beta, vM N1, vM N2)
  {
    Matrix P1bar=EmbedSPD(N1,beta);
    Matrix P2bar=EmbedSPD(N2,beta);
    Matrix P1P2inv=P1bar.times(P2bar.inverse());
    double res=0;
    double lambdamax,lambdamin;
    
    EigenvalueDecomposition evd=P1P2inv.eig();
    Matrix D=evd.getD();
    lambdamax=lambdamin=D.get(0,0);
    
    for (int i=1; i<D.getColumnDimension(); i++)
    {
     lambdamax=max(lambdamax,D.get(i,i));
    lambdamin=min(lambdamin,D.get(i,i));
  }
     

    return Math.log(lambdamax/lambdamin);
  }
  
  

  // Non-integer power of a matrix
  public static Matrix power(Matrix M, double p)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();
    // power on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.pow(D.get(i, i), p));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }

public static double  FisherRaoDistanceFromI(vM IVP, double tfinal, int nbsteps)
{
  double res=0;
  vM X,Xn;
  int i;
  double tt, ttn, dtt=tfinal/(double)nbsteps;
  
  //for(tt=0;tt<=tfinal-dtt;tt+=dtt)
  for(i=0;i<nbsteps;i++)
  {tt=i*dtt;
    ttn=tt+dtt;
    X=GeodesicStd(IVP,tt);
    Xn=GeodesicStd(IVP,ttn);
    res+=Math.sqrt(JeffreysMVN(X,Xn));
  }
  
  return res;
}

/*
public static vM GeodesicIVP(vM N, vM IVP, double t)
{
Matrix P=power(N,0.5).inverse();
Matrix P
//Matrix vIV=P.times(IVP.v).times(-1);
//Matrix MIV=P.times(IVP.M).times
//vM tIVP=new vM();

return  GeodesicStd(tIVP,t).affineLeftAction();
}
*/

//

public static Matrix EmbedBlockCholesky(vM N)
{
  int i,j,d=N.M.getRowDimension();
  Matrix Sigma=N.M;
  Matrix SigmaInv=N.M.inverse();
  Matrix mut=N.v.transpose();
  Matrix minusmu=N.v.times(-1.0);
  
   
  Matrix M,D,L; // Block Cholesky
  M=new Matrix(2*d+1,2*d+1);
  D=new Matrix(2*d+1,2*d+1);
  
  D.set(d,d,1.0);
  
  for(i=0;i<d;i++)
  for(j=0;j<d;j++)
  {
    D.set(i,j,SigmaInv.get(i,j));
    D.set(d+1+i,d+1+j,Sigma.get(i,j));
  }
  
  
  
  M.set(d,d,1.0);
   
  for(j=0;j<d;j++)
  {
   M.set(d,j,mut.get(0,j)); // row vector
   M.set(d+1+j,d,minusmu.get(j,0)); // column vector 
  }
  
  // add identity matrices
  for(i=0;i<d;i++)
  for(j=0;j<d;j++)
  {
  M.set(i,i,1.0);
  M.set(i+d+1,i+d+1,1.0);
  }
  
  // Block Cholesky decomposition
   L=M.times(D).times(M.transpose());
   
  return L;

}

public static Matrix EmbedBlockCholeskyGood(vM N)
{
  int i,j,d=N.M.getRowDimension();
  Matrix xi, Xi; // natural coordinates
  
  Xi=N.M.inverse();// Sigma^{-1}
  xi=Xi.times(N.v);// Sigma^{-1} mu
  
  Matrix tmp1, tmp2;
  tmp1=(xi.transpose()).times(Xi.inverse());// row vector
  tmp2=((Xi.inverse()).times(xi)).times(-1.0);// column vector
  
  Matrix M,D,L; // Block Cholesky
  M=new Matrix(2*d+1,2*d+1);
  D=new Matrix(2*d+1,2*d+1);
  
  D.set(d,d,1.0);
  
  for(i=0;i<d;i++)
  for(j=0;j<d;j++)
  {
    D.set(i,j,Xi.get(i,j));
    D.set(d+1+i,d+1+j,N.M.get(i,j));
  }
  
  
  
  M.set(d,d,1.0);
   
  for(j=0;j<d;j++)
  {
   M.set(d,j,tmp1.get(0,j)); // row vector
   
   M.set(d+1+j,d,tmp2.get(j,0)); // column vector 
  }
  
  for(i=0;i<d;i++)
  for(j=0;j<d;j++)
  {
  
  M.set(i,i,1.0);
  
  M.set(i+d+1,i+d+1,1.0);
  
  }
  
   L=M.times(D).times(M.transpose());
   
  return L;

}

// From SPD(2d+1)
// https://arxiv.org/pdf/2304.12575.pdf
//

public static vM KobayashiMVNGeodesic(vM N0, vM N1, double t)
{
vM result;
Matrix G0, G1, Gt;

G0=EmbedBlockCholesky(N0);
G1=EmbedBlockCholesky(N1);

 
Gt=RiemannianGeodesic(G0,G1,t); // Rie geodesic in SPD(2d+1)
 
result=L2MVN(Gt);

return result;
}

static vM L2MVN(Matrix L)
{int i,j,d;
  d= (L.getRowDimension()-1)/2;
  
 // System.out.println("extract mvn d="+d);
  
  Matrix Delta=new Matrix(d,d), delta=new Matrix(d,1);
for(i=0;i<d;i++)
for(j=0;j<d;j++)
{Delta.set(i,j,L.get(i,j));}

for(j=0;j<d;j++)
{delta.set(j,0,L.get(d,j));}

Matrix mu, Sigma;

// convert natural parameters to ordinary parameterization
Sigma=Delta.inverse();
mu=Sigma.times(delta);

return new vM(mu,Sigma);

}



public static vM KobayashiMVNGeodesicGood(vM N0, vM N1, double t)
{
vM result;
Matrix G0, G1, Gt;

G0=EmbedBlockCholesky(N0);
G1=EmbedBlockCholesky(N1);

//System.out.println("Rie geo");
Gt=RiemannianGeodesic(G0,G1,t); // Rie geodesic in SPD(2d+1)
//System.out.println("done!");
// Extra MVN
result=L2MVN(Gt);

return result;
}

static vM L2MVNgood(Matrix L)
{int i,j,d;
  d= (L.getRowDimension()-1)/2;
  
 // System.out.println("extract mvn d="+d);
  
  Matrix Delta=new Matrix(d,d), delta=new Matrix(d,1);
for(i=0;i<d;i++)
for(j=0;j<d;j++)
{Delta.set(i,j,L.get(i,j));}

for(j=0;j<d;j++)
{delta.set(j,0,L.get(d,j));}

Matrix mu, Sigma;

// convert natural parameters to ordinary parameterization
Sigma=Delta.inverse();
mu=Sigma.times(delta);

return new vM(mu,Sigma);

}

// From the paper : Geodesics connected with the Fisher metric on the multivariate normal manifold
public static vM EriksenGeodesicStd(vM IVP, double t)
{
int i,j, d= IVP.M.getRowDimension();
Matrix A=new Matrix(2*d+1,2*d+1);

Matrix B,x;
B=IVP.M;
x=IVP.v;

for(i=0;i<d;i++)
for(j=0;j<d;j++)
{ 
A.set(i,j,-B.get(i,j));
A.set(d+1+i,d+1+j,B.get(i,j));
}

for(j=0;j<d;j++)
{
A.set(d,j,x.get(j,0));
A.set(d,d+j,-x.get(j,0));
A.set(d,d+j,-x.get(j,0));
}

// calculate the matrix exponential
Matrix Lambda=exp(A.times(t));

// Retrieve parameters
Matrix Delta=new Matrix(d,d), delta=new Matrix(d,1);
for(i=0;i<d;i++)
for(j=0;j<d;j++)
{Delta.set(i,j,Lambda.get(i,j));}

for(j=0;j<d;j++)
{delta.set(j,0,Lambda.get(d,j));}


return new vM(delta,Delta);
}

// Eriksen's method 1987 from Identity
public static vM ErikenGeodesicFromStdN(vM IVP, double t)
{
  
int d=IVP.M.getRowDimension();

System.out.println("Eriksen dim="+d);

Matrix A=new Matrix (2*d+1,2*d+1);
int i,j;

// B=IVP.M
for(i=0;i<d;i++)
for(j=0;j<d;j++)
{
A.set(i,j,-IVP.M.get(i,j));
A.set(d+1+i,d+1+j,IVP.M.get(i,j));
}

System.out.println("filled B");

for(j=0;j<d;j++)
{
A.set(j,d,IVP.v.get(j,0));

A.set(d,j,IVP.v.get(j,0));

A.set(d,d+1+j,-IVP.v.get(j,0));

A.set(2*d,d+j,-IVP.v.get(j,0));
}

System.out.println("filled A");

Matrix ExpA=exp(A.times(t));

// Extract solution in xi coordinate systems

Matrix Delta=new Matrix(d,d);
Matrix delta=new Matrix(d,1); 

//res=new vM(d,d);

// extract

for(i=0;i<d;i++)
for(j=0;j<d;j++)
{
Delta.set(i,j,ExpA.get(i,j));
}

for(j=0;j<d;j++)
{
delta.set(j,0,ExpA.get(0,j+d));
}

// convert to ordinary parameters from Xi

Matrix mu, Sigma;

// convert natural parameters to ordinary parameterization
Sigma=Delta.inverse();
mu=Sigma.times(delta);

return new vM(mu,Sigma);

  
}


// Calvo Oller 1991
public static vM GeodesicStd(vM IVP, double t)
{
Matrix G2=IVP.M.times(IVP.M).plus(IVP.v.times(IVP.v.transpose()).times(2.0));  
Matrix G=power(G2,0.5);
Matrix Gminus=G.inverse();
Matrix R=cosh(G.times(0.5*t)).minus(IVP.M.times(Gminus).times(sinh(G.times(0.5*t))));
Matrix resM=R.times(R.transpose());
Matrix resv=R.times(sinh(G.times(0.5*t))).times(Gminus).times(IVP.v.times(2.0));
return new vM(resv,resM);
}

public static Matrix sinh(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();
    // power on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, sinh(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }
  
  
  public static Matrix cosh(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();
    // power on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, cosh(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }




  // Exponential of a SPD matrix
  public static Matrix exp(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    // exponential on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.exp(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }

  // Logarithm of a SPD matrix
  public static Matrix log(Matrix M)
  {
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    // Logarithm on the positive eigen values
    for (int i=0; i<D.getColumnDimension(); i++)
      D.set(i, i, Math.log(D.get(i, i)));

    Matrix V=evd.getV();

    return V.times(D.times(V.transpose()));
  }


  public static Matrix LogEuclideanMean(Matrix [] set)
  {
    int i;
    int n=set.length;
    int d=set[0].getColumnDimension();
    Matrix R=new Matrix(d, d);

    for (i=0; i<n; i++)
    {
      R=R.plus(log(set[i]).times(1.0/n))  ;
    }

    return exp(R);
  }

  public static double RiemannianDistance(Matrix P, Matrix Q) {
    return RieSPDDistance(P, Q);
  }

  // Here we scale
  public static double scale=1.0/2.0; // parameter beta


  public static double RieSPDDistance(Matrix P, Matrix Q)
  {
    double result=0.0d;
    Matrix M=P.inverse().times(Q);
    EigenvalueDecomposition evd=M.eig();
    Matrix D=evd.getD();

    for (int i=0; i<D.getColumnDimension(); i++)
      result+=sqr(Math.log(D.get(i, i)));

    return Math.sqrt(scale* result);
  }

  public static vM L2T(vM l)
  {
    vM res;

    Matrix v=(l.M.inverse()).times(l.v);
    Matrix M=(l.M.inverse()).times(0.5);

    return new vM(v, M);
  }
  public static double QuadForm(Matrix x, Matrix Q)
  {
    return ((x.transpose().times(Q)).times(x)).trace();
  }
  // F(theta)
  public static double F(vM t)
  {
    int d=t.M.getColumnDimension();

    return 0.5*( d*Math.log(Math.PI)-Math.log((t.M).det())
      +0.5*QuadForm(t.v, t.M.inverse()));
  }
  public static double BhattacharyyaDistanceSigma(Matrix S1, Matrix S2, double alpha)
  {
    return 0.5*Math.log(Math.sqrt(S1.det()*S2.det())/
      (S1.inverse().times(alpha).plus(S2.inverse().times(1-alpha))).inverse().det());
  }


  // linear interpolation
  public static Matrix LERP(Matrix P1, Matrix P2, double a)
  {
    Matrix  Ma;
     
    Ma=P1.times(1-a).plus(P2.times(a));
    return Ma;
  }
  
  
  // linear interpolation
  public static vM LERP(vM t1, vM t2, double a)
  {
    Matrix va, Ma;
    va=t1.v.times(1-a).plus(t2.v.times(a));
    Ma=t1.M.times(1-a).plus(t2.M.times(a));
    return new vM(va, Ma);
  }

  // natural to expectation parameters
  public static vM T2E(vM t)
  {
    vM res;

    Matrix v=(((t.M).inverse()).times(t.v)).times(0.5);
    Matrix tmp=(t.M.inverse()).times(t.v);

    Matrix M=(((t.M).inverse()).times(-0.5)).minus((tmp).times(tmp.transpose()).times(0.25));

    res=new vM(v, M);
    return res;
  }
  //  expectation to lambda parameters
  public static vM E2L(vM e)
  {
    vM res;

    Matrix v=e.v;
    Matrix M=(e.M.times(-1)).minus(e.v.times(e.v.transpose()));

    res=new vM(v, M);
    return res;
  }
  public static vM L2E(vM l)
  {
    vM res;

    Matrix v=l.v;
    Matrix M=(l.M.times(-1)).minus(l.v.times(l.v.transpose()));
    res=new vM(v, M);
    return res;
  }
  public static vM T2L(vM t)
  {
    vM res;
    Matrix M=(t.M.inverse()).times(0.5);
    Matrix v= M.times(t.v);
    return new vM(v, M);
  }



//
// Return an array of discretized points along the LERP curve in 
// the ordinary parameterization lambda=(mu,Sigma)
//
public static vM [] DiscretizeOrdinaryLERPcurve(vM l1, vM l2, int T)
  {vM [] res=new vM[T];
     
    // Linear interpolation in natural parameter space
    for(int i=0;i<T;i++)
    {
    res[i]=LERP(l1, l2, (double)i/(T-1.0));
    }
    return res;
  }

//
// Return an array of discretized points along the exponential geodesic in 
// the ordinary parameterization lambda=(mu,Sigma)
//
public static vM [] DiscretizeExponentialGeodesic(vM l1, vM l2, int T)
  {vM [] res=new vM[T];
    vM t1=L2T(l1);
    vM t2=L2T(l2);
    // Linear interpolation in natural parameter space
    for(int i=0;i<T;i++)
    {
    res[i]=T2L(LERP(t1, t2, (double)i/(T-1.0)));
    }
    return res;
  }
  
  
  // prime geodesic interpolation
  public static vM Theta2LERPl(vM l1, vM l2, double alpha)
  {
    vM t1=L2T(l1);
    vM t2=L2T(l2);
    vM t12=LERP(t1, t2, alpha);

    return T2L(t12);
  }



//
// Return an array of discretized points along the mixture geodesic in 
// the ordinary parameterization lambda=(mu,Sigma)
//
public static vM [] DiscretizeMixtureGeodesic(vM l1, vM l2, int T)
  {vM [] res=new vM[T];
    vM e1=L2E(l1);
    vM e2=L2E(l2);
    // Linear interpolation in expectation parameter parameter space
    for(int i=0;i<T;i++)
    {
    res[i]=E2L(LERP(e1, e2,(double)i/(T-1.0)));
    }
    return res;
  }


public static vM [] DiscretizeProjectedSPDGeodesic(vM l1, vM l2, int T)
  {vM [] res=new vM[T];
  Matrix P1bar=EmbedSPD(l1);
  Matrix P2bar=EmbedSPD(l2);
  int d=l1.v.getRowDimension();
Matrix zeroMean=new Matrix(d+1,1);
  
    
    for(int i=0;i<T;i++)
    {
    Matrix P= RiemannianGeodesic(P1bar, P2bar, (double)i/(T-1.0));// SPD geodesic
    res[i]=new vM(zeroMean,Project2EmbeddedMVN(P)); // back to lambda parameterization
    }
    return res;
  }
  
  
  public static vM [] DiscretizeProjectedSPDGeodesic2MVN(vM l1, vM l2, int T)
  {vM [] res=new vM[T];
  Matrix P1bar=EmbedSPD(l1);
  Matrix P2bar=EmbedSPD(l2);

    for(int i=0;i<T;i++)
    {
    Matrix P= RiemannianGeodesic(P1bar, P2bar, (double)i/(T-1.0));// SPD geodesic
    res[i]=SPD2MVN(Project2EmbeddedMVN(P));
    }
    return res;
  }
  
  //
  // dual geodesic interpolation
  //
  public static vM Eta2LERPl(vM l1, vM l2, double alpha)
  {
    vM e1=L2E(l1);
    vM e2=L2E(l2);
    vM e12=LERP(e1, e2, alpha);
    return E2L(e12);
  }


  // primal geodesic interpolation
  public static vM NLERPl(vM l1, vM l2, double alpha)
  {

    Matrix malpha, Salpha, Deltam, tmp;
    Deltam=l1.v.minus(l2.v);
    Matrix S1inv=l1.M.inverse();
    Matrix S2inv=l2.M.inverse();

    Salpha=(((S1inv).times(1-alpha)).plus((S2inv.times(alpha)))).inverse();
    tmp=(((S1inv).times(l1.v)).times(1-alpha)).plus( ((S2inv).times(l2.v)).times(alpha) );

    malpha=Salpha.times(tmp);

    return new vM(malpha, Salpha);
  }

  public static double CD(vM t1, vM e2)
  {
    return F(t1)+Ge(e2)-vM.inner(t1, e2);
  }
  // convex conjugate eta
  public static double Ge(vM e)
  {
    int d=e.M.getColumnDimension();

    return -0.5*( Math.log(1+QuadForm(e.v, e.M.inverse()))
      +Math.log((e.M.times(-1)).det())+d*(1+Math.log(2*Math.PI))
      );
  }

  // verified: ok!
  public static double BhattacharyyaDistanceMuSigma(Matrix m1, Matrix S1, Matrix m2, Matrix S2, double alpha)
  {
    Matrix SigmaAlpha=((S1.inverse().times(alpha)).plus(S2.inverse().times(1-alpha))).inverse();
    Matrix muAlpha=SigmaAlpha.times(
      (S1.inverse().times(alpha).times(m1)).plus( S2.inverse().times(1-alpha).times(m2) )
      );
    double term1=(m1.transpose().times(S1.inverse()).times(m1).times(alpha)).trace();
    double term2=(m2.transpose().times(S2.inverse()).times(m2).times(1-alpha)).trace();
    double term3=(muAlpha.transpose().times(SigmaAlpha.inverse()).times(muAlpha)).trace();
    double term4=Math.log(Math.pow(S1.det(), alpha)*Math.pow(S2.det(), 1-alpha)/SigmaAlpha.det());

    return 0.5*(term1+term2-term3+term4);
  }

  // squared Hellinger between two multivariate normals
  public static double HellingerMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
  {
    int d=S1.getColumnDimension();
    Matrix Deltam=m1.minus(m2);
    Matrix M12=(S1.plus(S2)).times(0.5);
    double d1=S1.det();
    double d2=S2.det();

    double term=(Deltam.transpose().times(M12).times(Deltam)).trace();
    return  1.0- (Math.pow(d1, 0.25)*Math.pow(d2, 0.25)/Math.sqrt(M12.det()))*
      Math.exp(-(1/8.0)*term);
  }

  public static double HellingerCenteredMVN( Matrix S1, Matrix S2)
  {
    int d=S1.getColumnDimension();
    Matrix M12=(S1.plus(S2)).times(0.5);
    double d1=S1.det();
    double d2=S2.det();

    return  1.0- (Math.pow(d1, 0.25)*Math.pow(d2, 0.25)/Math.sqrt(M12.det()));
  }



  // Jeffreys between two multivariate normals
 public static double KLD(vM N1, vM N2)
  {
    return KLMVN(N1, N2);
  }
  
  public static double KLMVN(vM N1, vM N2)
  {
    return KLMVN(N1.v, N1.M, N2.v, N2.M);
  }
  
    public static double JeffreysMVN(vM N1, vM N2)
  {
    return KLMVN(N1.v, N1.M, N2.v, N2.M)+KLMVN(N2.v, N2.M, N1.v, N1.M);
  }

  public static double KLMVN(Matrix m1, Matrix S1, Matrix m2, Matrix S2)
  {
    int d=S1.getColumnDimension();
    Matrix Deltam=m1.minus(m2);

    return 0.5*(
      ((S2.inverse()).times(S1)).trace()-d+
      ((Deltam.transpose().times(S2.inverse())).times(Deltam)).trace()
      +Math.log(S2.det()/S1.det())
      );
  }

  public static double KLMVN(Matrix S1, Matrix S2)
  {
    int d=S1.getColumnDimension();

    return 0.5*(
      ((S2.inverse()).times(S1)).trace()-d+
      +Math.log(S2.det()/S1.det())
      );
  }



 public static  Matrix randomMatrix(int d)
 {
 int i,j;
  double [][] array=new double[d][d];
  
 for(i=0;i<d;i++)
 for(j=0;j<=d;j++)
 {
 double coeff=-1+2*Math.random();
 array[i][j]=coeff;
 }
 
  return new Matrix(array);
 }


 public static  Matrix randomSymmetricMatrix(int d)
 {
 int i,j;
  double [][] array=new double[d][d];
  
 for(i=0;i<d;i++)
 for(j=0;j<=i;j++)
 {
 double coeff=-1+2*Math.random();
 array[i][j]=array[j][i]=coeff;
 }
 
  return new Matrix(array);
 }

  public static  Matrix randomMu(int d)
  {
    int i;
    double [][] array=new double[d][1];


    for (i=0; i<d; i++)
    {
      array[i][0]=Math.random();
    }

    return new Matrix(array);
  }

  public static  Matrix randomSPDCholesky(int d)
  {
    int i, j;
    double [][] array=new double[d][d];
    Matrix L;

    for (i=0; i<d; i++)
      for (j=0; j<=i; j++)
      {
        array[i][j]=Math.random();
      }

    L=new Matrix(array);
    // Cholesky
    return L.times(L.transpose());
  }

  // Calvo Oller mapping 1
  
    public static  Matrix EmbedSPD(vM l)
    {return EmbedSPD(l.v,l.M);}
    	
  public static  Matrix EmbedSPD(Matrix mu, Matrix Sigma)
  {
    //  mu.print(5,5); Sigma.print(5,5);

    int d=mu.getRowDimension();
    //System.out.println("embed in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;

    tmp=Sigma.plus(mu.times(mu.transpose()));

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, mu.get(i, 0));

    res.set(d, d, 1);

    //res.print(5, 5);
    // check that they have the same determinant
    //   System.out.println("embedding/ det :"+detS+" embedded det "+res.det());

    return res;

    //  scalar times matrix = matrix coeff * scalar
    //  return res.times(Math.pow(detS,-2.0/(d+1)));
    //return res.times(Math.pow(detS,1.0/(d*(d+1))));
  }

    public static  Matrix EmbedSPD(vM l, double beta)
    {return EmbedSPD(l.v,l.M,beta);}

//
// Diffeomorphism
//
  public static  Matrix EmbedSPD(Matrix mu, Matrix Sigma, double beta)
  {
    //  mu.print(5,5); Sigma.print(5,5);

    int d=mu.getRowDimension();
    //System.out.println("embed in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;

    tmp=Sigma.plus(mu.times(mu.transpose()).times(beta));

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, beta*mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, beta*mu.get(i, 0));

    res.set(d, d, beta);

    //res.print(5, 5);
    // check that they have the same determinant
    //   System.out.println("embedding/ det :"+detS+" embedded det "+res.det());

    return res;

    //  scalar times matrix = matrix coeff * scalar
    //  return res.times(Math.pow(detS,-2.0/(d+1)));
    //return res.times(Math.pow(detS,1.0/(d*(d+1))));
  }
  


  // Calvo Oller mapping 1
  public static  Matrix EmbedIsoSPD1(Matrix mu, Matrix Sigma)
  {
    //  mu.print(5,5); Sigma.print(5,5);

    int d=mu.getRowDimension();
    System.out.println("embed in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;

    tmp=Sigma.plus(mu.times(mu.transpose()));

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, mu.get(i, 0));

    res.set(d, d, 1);

    res.print(5, 5);

    System.out.println("det :"+detS+" embedded det "+res.det());

    return res;

    //  scalar times matrix = matrix coeff * scalar
    //  return res.times(Math.pow(detS,-2.0/(d+1)));
    //return res.times(Math.pow(detS,1.0/(d*(d+1))));
  }


  // [checked] matrix inverse in closed-form
  public static  Matrix MatInvIsoSPD1(Matrix mu, Matrix Sigma)
  {
    //  mu.print(5,5); Sigma.print(5,5);

    int d=mu.getRowDimension();
    System.out.println("embed in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    Matrix SigmaInv=Sigma.inverse();
    Matrix MinusSigmaInvMu=SigmaInv.times(mu).times(-1);
    Matrix muTSigmaInvmu=(mu.transpose()).times(SigmaInv).times(mu);

    int i, j;

    tmp=Sigma.plus(mu.times(mu.transpose()));

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, SigmaInv.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, MinusSigmaInvMu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, MinusSigmaInvMu.get(i, 0));

    res.set(d, d, 1+muTSigmaInvmu.trace());


    return res;
  }

  // Calvo Oller mapping 1
  public static  Matrix EmbedIsoSPD2(Matrix mu, Matrix Sigma, double beta)
  {
    //  mu.print(5,5); Sigma.print(5,5);

    int d=mu.getRowDimension();
    System.out.println("iso embed 2 in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;

    tmp=Sigma.plus(  (mu.times(mu.transpose())).times(beta*beta)  );

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, beta*mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, beta*mu.get(i, 0));

    res.set(d, d, 1);

    res.times(Math.pow(detS, -2.0/(1.0+d)));

    System.out.println("det :"+detS+" embedded det "+res.det());

    return res;

    //  scalar times matrix = matrix coeff * scalar
    //  return res.times(Math.pow(detS,-2.0/(d+1)));
    //return res.times(Math.pow(detS,1.0/(d*(d+1))));
  }



  public static  Matrix EmbedDiffeoSPD(Matrix mu, Matrix Sigma, double alpha, double beta, double gamma)
  {

    int d=mu.getRowDimension();
    System.out.println("embed diffeo in SPD "+(d+1)+" dimensions:"+alpha+" "+beta+" "+gamma);
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;
    Matrix mumuT=mu.times(mu.transpose());
    tmp=Sigma.plus( (mumuT.times(beta*gamma*gamma)) ) ;

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, beta*gamma*mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, beta*gamma*mu.get(i, 0));

    res.set(d, d, beta);

    res.times(Math.pow(detS, alpha));

    //  System.out.println("det :"+detS+" embedded det "+res.det());

    return res;
  }

  // special SPD, det 1 embedding: same unit determinant
  public static  Matrix EmbedSSPD(Matrix mu, Matrix Sigma)
  {
    mu.print(5, 5);
    Sigma.print(5, 5);

    int d=mu.getRowDimension();
    System.out.println("embed in SPD "+(d+1)+" dimensions");
    Matrix res=new Matrix(d+1, d+1);
    Matrix tmp=new Matrix(d, d);
    double detS=Sigma.det();
    int i, j;

    tmp=Sigma.plus(mu.times(mu.transpose()));

    for (i=0; i<d; i++)
      for (j=0; j<d; j++)
      {
        res.set(i, j, tmp.get(i, j));
      }

    for (i=0; i<d; i++)
      res.set(d, i, mu.get(i, 0));

    for (i=0; i<d; i++)
      res.set(i, d, mu.get(i, 0));

    res.set(d, d, 1);

    res.print(5, 5);

    return res.times(Math.pow(detS, -1.0/(d+1)));
  }

  public static void testApproxDist()
  {
    int d=5;
    Matrix m, S, P1, P2;


    P1=randomSPDCholesky(d);
    P2=randomSPDCholesky(d);

    double dist=RiemannianDistance(P1, P2);
    double dista=approximateSPDDist(P1, P2, 10000);

    System.out.println(dist+" dist approx="+dista);
  }

  public static void testProjection()
  {
    int d=5;
    Matrix m, S, P;

    for (int l=0; l<3; l++)
    {

      m=randomMu(d);
      S=randomSPDCholesky(d);
      P=randomSPDCholesky(d);
      //Matrix P=EmbedSPD(m, S);

      double dist=Distance2EmbeddedMVN(P);

      Matrix Pbar=Project2EmbeddedMVN(P);

      double dist2=RiemannianDistance(Pbar, P);
      double ratio=dist2/dist;
      System.out.println("dist(P,Nbar)="+ dist+ " dist(pbar,p)="+dist2+ " ratio:"+ratio);
    }
  }

  public static void testHellinger()
  {
    int d=2;
    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);

    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);

    double hellinger=HellingerMVN(m1, S1, m2, S2);

    Matrix P1= EmbedSPD(m1, S1);
    Matrix P2= EmbedSPD(m2, S2);

    double chellinger=HellingerCenteredMVN(P1, P2);

    System.out.println("Hellinger MVN SPD distance:"+hellinger+" "+chellinger);
    double ratio=hellinger/chellinger;
    System.out.println("ratio:"+ratio);
  }


  public static void testKLD()
  {

    int d=5;
    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);

    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);

    double kl=KLMVN(m1, S1, m2, S2);

    System.out.println("Test KLD MVN versus KLD Centered MVN\ndim="+d);

    Matrix P1= EmbedSPD(m1, S1);
    Matrix P2= EmbedSPD(m2, S2);

    double kle=KLMVN(P1, P2);

    System.out.println("KLD MVN "+kl+ " vs KL zero MVN distance:"+kle);
  }



  public static void test2()
  {
    int d=7;
    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);

    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);

    double kl=KLMVN(m1, S1, m2, S2);

    Matrix P1= EmbedSPD(m1, S1);
    Matrix P2= EmbedSPD(m2, S2);

    Matrix P1inv=P1.inverse();
    Matrix P1invcf=MatInvIsoSPD1(m1, S1);
    P1inv.minus(P1invcf).print(5, 5); // null matrix!

    double embedkl=KLMVN(P1, P2);
    double diff=Math.abs(embedkl-kl);
    System.out.println("\t->1] kl:"+kl+" vs embedded kl "+embedkl+ " diff="+diff);

    //double beta=1+Math.random();
    double beta=1;
    Matrix PP1= EmbedIsoSPD2(m1, S1, beta);
    Matrix PP2= EmbedIsoSPD2(m2, S2, beta);
    double embedkl2=KLMVN(PP1, PP2);
    double diff2=Math.abs(embedkl2-kl);
    System.out.println("\t->2] kl :"+kl+" vs embedded iso method 2 kl "+embedkl2+ " diff="+diff2);

    double alpha=0.2;
    double bhat=BhattacharyyaDistanceMuSigma(m1, S1, m2, S2, alpha);
    double embedbhat=BhattacharyyaDistanceSigma(P1, P2, alpha);
    System.out.println("Bhat:"+bhat+" vs embedded bhat "+embedbhat);
  }

public static void testUBFR(int d)
  {Matrix m1;
    Matrix S1;

    Matrix m2;
    Matrix S2;
    vM   N1, N2; 
    Matrix P1bar, P2bar;
  	   double distCO, distFRp,U, UBF;
   int nbtests=1000;
   
   distCO=distFRp=U=UBF=0;
   
   for(int t=0;t<=nbtests;t++)
   {
   
    m1=randomMu(d);
   S1=randomSPDCholesky(d);

     m2=randomMu(d);
    S2=randomSPDCholesky(d);
   N1=new vM(m1, S1);
   N2=new vM(m2,S2); 
 
  P1bar = EmbedSPD(m1, S1);
     P2bar = EmbedSPD(m2, S2);
    
  distCO+=RieSPDDistance(P1bar,P2bar);
    distFRp+=approximateFisherRaoMVN(N1, N2, 1000);
    U+=UB3(N1,N2);
    
       
     UBF+=Math.sqrt(KLD(N1,N2)+KLD(N2,N1));
   // if (System.out.println("Upper bound sqrt J:"+UBF);
    
   }
     distCO/=(double)nbtests;
    distFRp/=(double)nbtests;
    U/=(double)nbtests;
   UBF/=(double)nbtests;
    
  //  System.out.println(distCO+" <= FR approx "+distFRp+ " <= "+U);
        System.out.println(d+" & "+ distCO+"& "+distFRp+ " & "+U+" & ubf "+UBF+" \\cr");
  }
  
  public static void test3()
  {
    double alpha=0.2+Math.random();
    double beta=1+Math.random();
    double gamma=2+Math.random();
    int d=7;
    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);

    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);

    double kl=KLMVN(m1, S1, m2, S2);

    /*
 Matrix P1= EmbedDiffeoSPD(m1,S1,alpha,beta,gamma);
     Matrix P2=  EmbedDiffeoSPD(m2,S2,alpha,beta,gamma);
     */
    Matrix P1= EmbedDiffeoSPD(m1, S1, 0, 1, 1);
    Matrix P2=  EmbedDiffeoSPD(m2, S2, 0, 1, 1);

    double embedkl=KLMVN(P1, P2);

    System.out.println("kl:"+kl+" vs embedded kl "+embedkl);
  }

  public static void test()
  {
    int d=3;
    Matrix m=randomMu(d);
    Matrix S=randomSPDCholesky(d);

    Matrix P1= EmbedSSPD(m, S);
    Matrix P2= EmbedSPD(m, S);

    double detS=S.det();
    double detP1=P1.det();
    double detP2=P2.det();
    System.out.println("determinant covar:"+detS+" determinant embedded SSPD:"+detP1+ " det mapping 1:"+detP2);

    /*
P= EmbedSPD(m,S);
     detS=S.det();
     detP=P.det();
     System.out.println("determinant covar:"+detS+" determinant embedded SPD:"+detP);
     System.out.println("coincide with ? " + Math.sqrt(S.det()));
     */
  }

  // They are not embedded connections! Different connections
  public static void testIG2()
  {
    int d=3;
    Matrix zero=new Matrix(d+1, 1);

    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);


    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);

    // S2=S1;
    // m1=m2; // same mean,

    Matrix P1 = EmbedSPD(m1, S1);
    Matrix P2 = EmbedSPD(m2, S2);

    vM ms1=new vM(m1, S1);
    vM ms2=new vM(m2, S2);
    vM mse1=new vM(zero, P1);
    vM mse2=new vM(zero, P2);

    double lambda=Math.random();

    System.out.println("lambda interpol "+lambda);

    //  vM lambdacN=Theta2LERPl(mse1,mse2,lambda); // nabla-geodesic
    vM lambdacN=Eta2LERPl(mse1, mse2, lambda);// nablastar-geodesic



    double err=1.e8;
    double stepl=0.0001;
    double l, alpha=-1;

    for (l=0; l<=1.0; l+=stepl)
    {
      //  vM lMVN=Theta2LERPl(ms1,ms2,l); // nabla-geodesic

      vM lMVN=Eta2LERPl(ms1, ms2, l);// nablastar-geodesic

      Matrix maplMVN=EmbedSPD(lMVN.v, lMVN.M);

      double delta=maplMVN.minus(lambdacN.M).norm2();
      if (delta<err) {
        err=delta;
        alpha=l;
      }
    }

    System.out.println("min error:"+err+" alpha MVN="+alpha);
  }

public static void DistanceCO(vM N1, vM N2)
{Matrix  P1bar = EmbedSPD(N1.v, N1.M);
Matrix  P2bar = EmbedSPD(N2.v, N2.M);
  int i,minsteps=3,maxsteps=100,stepinc=10;
   double distFRp;
   // i+=stepinc
  for(i=minsteps;i<=maxsteps;i++)
  {
    distFRp=approximateFisherRaoMVN(N1, N2, i);
     System.out.println(i+"\t"+distFRp);
  }
}
  
  //
  // Test several distances
  //
public static void Distances(vM N1, vM N2)
{int nbsteps=1000;
Matrix  P1bar = EmbedSPD(N1.v, N1.M);
Matrix  P2bar = EmbedSPD(N2.v, N2.M);
     
double    distLB=RieSPDDistance(P1bar,P2bar);
  double    distUB=UB3(N1,N2);
   double distUBJ=Math.sqrt(KLD(N1,N2)+KLD(N2,N1));
  
  System.out.println("Lower bound (Calvo and Oller):"+distLB);
  System.out.println("Upper bound (S):"+distUB);
     System.out.println("Upper bound (sqrt Jeffreys):"+distUBJ);
     
  double distFRl=approximateFisherRaoMVNLERPLambda(N1,N2,nbsteps);
    System.out.println("LERP lambda:"+distFRl);
    
   double  distFRe=approximateFisherRaoMVNLERPEta(N1,N2,nbsteps);
    System.out.println("LERP eta:"+distFRe);
   
    double   distFRt=approximateFisherRaoMVNLERPTheta(N1,N2,nbsteps);
     System.out.println("LERP theta:"+distFRt);
     
     
     double  distFRte=approximateFisherRaoMVNLERPThetaEta(N1,N2,nbsteps);
      System.out.println("mid LERP theta-eta:"+distFRte);
 
     double   distFRp=approximateFisherRaoMVN(N1, N2, nbsteps);
     System.out.println("projected SPD geodesic:"+distFRp);
     
     
     double   distHilbert=approximateFisherRaoMVNLERPHilbert(N1, N2, nbsteps);
     double distSPDHilbert=HilbertMVNDistance(N1, N2);
     
     System.out.println("Hilbert FR:"+distHilbert+" Hilbert SPD:"+distSPDHilbert);
     
     double   distHilbert2=approximateFisherRaoMVNLERPHilbert(1.5,N1, N2, nbsteps);
      double distSPDHilbert2=HilbertMVNDistance(1.5,N1, N2);
     System.out.println("Hilbert beta=1.5 :"+distHilbert2+" Hilbert SPD:"+distSPDHilbert2);
     
     double   distHilbert3=approximateFisherRaoMVNLERPHilbert(2.0,N1, N2, nbsteps);
      double distSPDHilbert3=HilbertMVNDistance(2.0, N1, N2);
     System.out.println("Hilbert beta=2:"+distHilbert3+" Hilbert SPD:"+distSPDHilbert3);
     
     
}


public static void testUB(int d)
{
 double kappal, kappat,kappae,kappap,kappate;
 double avgkappal, avgkappat,avgkappae,avgkappap,avgkappate;
  double  minkappal, minkappat,minkappae,minkappap,minkappate;
  double  maxkappal, maxkappat,maxkappae,maxkappap,maxkappate;
  
  
    double distCO,distFRl,distFRe,distFRt,distFRp, distFRte;
       
  avgkappal= avgkappat=avgkappae=avgkappap=avgkappate=0;
  minkappal= minkappat=minkappae=minkappap=minkappate=Double.MAX_VALUE;
  maxkappal= maxkappat=maxkappae=maxkappap=maxkappate=Double.MIN_VALUE;
  
  vM N1,N2;
  
      Matrix m1,S1,P1bar,m2,S2,P2bar;
    
  
 int i,ii;   int nbsteps=1000,nbtests=1000;
    m1=new Matrix(d, 1);
    S1=Matrix.identity(d, d);
     
           
      m2=new Matrix(d, 1);
      S2=new Matrix(d, d);
      
      
 for(ii=0;ii<nbtests;ii++)
 {
  
     // for (i=0; i<d; i++) m2.set(i, 0, 10*Math.random());
     // for (i=0; i<d; i++) S2.set(i, i, 10*Math.random());
      
      m1=randomMu(d);
      S1=randomSPDCholesky(d);
       m2=randomMu(d);
      S2=randomSPDCholesky(d);
      
         N1=new vM(m1, S1);
       N2=new vM(m2,S2); 
 
 
    P1bar = EmbedSPD(m1, S1);
     P2bar = EmbedSPD(m2, S2);
    
  
 
    
 
    
  distCO=RieSPDDistance(P1bar,P2bar);
   distFRl=approximateFisherRaoMVNLERPLambda(N1,N2,nbsteps);
    distFRe=approximateFisherRaoMVNLERPEta(N1,N2,nbsteps);
      distFRt=approximateFisherRaoMVNLERPTheta(N1,N2,nbsteps);
      distFRte=approximateFisherRaoMVNLERPThetaEta(N1,N2,nbsteps);
      
       distFRp=approximateFisherRaoMVN(N1, N2, nbsteps);
       
       kappal=distFRl/distCO;avgkappal+=kappal ;minkappal=min(minkappal,kappal);maxkappal=max(minkappal,kappal);
    
     kappae=distFRe/distCO;avgkappae+=kappae ;minkappae=min(minkappae,kappae);maxkappae=max(minkappae,kappae);
      
      
       kappat=distFRt/distCO;avgkappat+=kappat ;minkappat=min(minkappat,kappat);maxkappat=max(minkappat,kappat);
      
            kappate=distFRte/distCO;avgkappate+=kappate ;minkappate=min(minkappate,kappate);
            maxkappate=max(minkappate,kappate);
       
       kappap=distFRp/distCO;
       avgkappap+=kappap ;
       minkappap=min(minkappap,kappap);
       maxkappap=max(minkappap,kappap);
         
 }
   avgkappal/=(double)nbtests;
    avgkappae/=(double)nbtests;
     avgkappat/=(double)nbtests;
      avgkappap/=(double)nbtests;
   avgkappate/=(double)nbtests;
   
 System.out.println(d+"\tProjected="+avgkappap+"\tLambda="+avgkappal+"\tTheta="+avgkappat+"\teta="+avgkappae+"\tThetaEta="+avgkappate); 
 
// System.out.println(d+"\t&\t"+avgkappap+"\t&\t"+minkappap+"\t&\t"+maxkappap+"\t&\t"
// +avgkappal+"\t&\t"+minkappal+"\t&\t"+maxkappal+"\t&\t"+
 //	avgkappat+"\t&\t"+minkappat+"\t&\t"+maxkappat+"\t&\t"
//+avgkappae+"\t&\t"+minkappae+"\t&\t"+maxkappae);  
/*
System.out.println("LB CO:"+distCO);
 System.out.println("UB lambda:"+distFRl);
  System.out.println("UB theta:"+distFRt);
   System.out.println("UB eta:"+distFRe);
    System.out.println("UB projected CO:"+distFRproj);
  */  
}


public static double UB3(vM N1, vM N2)
{double res=0; int i,dim;
dim=N1.v.getRowDimension();
Matrix Sigma=power(N1.M,-0.5).times(N2.M).times(power(N1.M,-0.5));
double rho2,rho1;
  EigenvalueDecomposition evd=Sigma.eig();
  
Matrix diag=evd.getD();
Matrix Omega=evd.getV();
Matrix mu=(Omega.transpose()).times(power(N1.M,-0.5)).times(N2.v.minus(N1.v));
for(i=0;i<dim;i++)
{
	rho1=Math.sqrt(sqr(1-diag.get(i,i))+sqr(mu.get(i,0)));
	rho2=Math.sqrt(sqr(1+diag.get(i,i))+sqr(mu.get(i,0)));
	
res+=sqr(Math.log((rho2+rho1)/(rho2-rho1)));	
}

return Math.sqrt(2.0*res);
}



// uniform with maxt entries
public static void testUBDiag(int d)
{
 double kappal, kappat,kappae,kappap;
 double avgkappal, avgkappat,avgkappae,avgkappap;
  double  minkappal, minkappat,minkappae,minkappap;
  double  maxkappal, maxkappat,maxkappae,maxkappap;
  
  
    double distCO,distFRl,distFRe,distFRt,distFRp;
       
  avgkappal= avgkappat=avgkappae=avgkappap=0;
  minkappal= minkappat=minkappae=minkappap=Double.MAX_VALUE;
  maxkappal= maxkappat=maxkappae=maxkappap=Double.MIN_VALUE;
  
  vM N1,N2;
  
      Matrix m1,S1,P1bar,m2,S2,P2bar;
    
  
 int i,ii;   int nbsteps=1000,nbtests=1000;
    m1=new Matrix(d, 1);
    S1=Matrix.identity(d, d);
       
           
      m2=new Matrix(d, 1);
      S2=new Matrix(d, d);
      
      double maxt=5;
      
      
 for(ii=0;ii<nbtests;ii++)
 {
  
    for(i=0;i<d;i++) m2.set(i,0,maxt*Math.random());
     for(i=0;i<d;i++) S2.set(i,i,maxt*Math.random());
       N2=new vM(m2,S2); 
       	 N1=new vM(m1, S1);
 
 
    P1bar = EmbedSPD(m1, S1);
     P2bar = EmbedSPD(m2, S2);
    
  
 
    
 
    
  distCO=RieSPDDistance(P1bar,P2bar);
   distFRl=approximateFisherRaoMVNLERPLambda(N1,N2,nbsteps);
    distFRe=approximateFisherRaoMVNLERPEta(N1,N2,nbsteps);
      distFRt=approximateFisherRaoMVNLERPTheta(N1,N2,nbsteps);
       distFRp=approximateFisherRaoMVN(N1, N2, nbsteps);
       
       kappal=distFRl/distCO;avgkappal+=kappal ;minkappal=min(minkappal,kappal);maxkappal=max(minkappal,kappal);
    
     kappae=distFRe/distCO;avgkappae+=kappae ;minkappae=min(minkappae,kappae);maxkappae=max(minkappae,kappae);
      
      
       kappat=distFRt/distCO;avgkappat+=kappat ;minkappat=min(minkappat,kappat);maxkappat=max(minkappat,kappat);
      
      
       kappap=distFRp/distCO;avgkappap+=kappap ;minkappap=min(minkappap,kappap);maxkappap=max(minkappap,kappap);
         
 }
   avgkappal/=(double)nbtests;
    avgkappae/=(double)nbtests;
     avgkappat/=(double)nbtests;
      avgkappap/=(double)nbtests;
   
 System.out.println(d+"\t"+avgkappap+"\t"+avgkappal+"\t"+avgkappat+"\t"+avgkappae); 
 
// System.out.println(d+"\t&\t"+avgkappap+"\t&\t"+minkappap+"\t&\t"+maxkappap+"\t&\t"
// +avgkappal+"\t&\t"+minkappal+"\t&\t"+maxkappal+"\t&\t"+
 //	avgkappat+"\t&\t"+minkappat+"\t&\t"+maxkappat+"\t&\t"
//+avgkappae+"\t&\t"+minkappae+"\t&\t"+maxkappae);  
/*
System.out.println("LB CO:"+distCO);
 System.out.println("UB lambda:"+distFRl);
  System.out.println("UB theta:"+distFRt);
   System.out.println("UB eta:"+distFRe);
    System.out.println("UB projected CO:"+distFRproj);
  */  
}

// Check canonical divergences match
  public static void testIG()
  {
    int d=1;
    Matrix zero=new Matrix(d+1, 1);

    Matrix m1=randomMu(d);
    Matrix S1=randomSPDCholesky(d);
    
    Matrix P1 = EmbedSPD(m1, S1);

    Matrix m2=randomMu(d);
    Matrix S2=randomSPDCholesky(d);
    
    Matrix P2 = EmbedSPD(m2, S2);

    vM ms1=new vM(m1, S1);
    vM theta1=L2T(ms1);
    vM eta1=T2E(theta1);

    vM ms2=new vM(m2, S2);
    vM theta2=L2T(ms2);
    vM eta2=T2E(theta2);

    double Ftheta1=F(theta1);
    double Geta1=Ge(eta1);

    vM mse1=new vM(zero, P1);
    vM thetae1=L2T(mse1);
    
    vM etae1=T2E(thetae1);
    vM mse2=new vM(zero, P2);
    vM thetae2=L2T(mse2);
    vM etae2=T2E(thetae2);

    double Fthetae1=F(thetae1);
    double Getae1=Ge(etae1);

    System.out.println("test IG Ftheta:"+Ftheta1+" "+Fthetae1);
    System.out.println("test IG Geta:"+Geta1+" "+Getae1);

    double inner12=vM.inner(theta1, eta2);
    double innere12=vM.inner(thetae1, etae2);

// canonical divergence
    double cd12=F(theta1)+Ge(eta2)-inner12;
    double cde12=F(thetae1)+Ge(etae2)-innere12;
    System.out.println("test IG Canonical divergences: Normal mfd"+cd12+" embedded manifold"+cde12);
    // System.out.println("inner products "+inner12+" "+innere12);

    double lambda=Math.random();
    lambda=0.5;
    System.out.println("lambda interpol "+lambda);

    vM interpolMVN=NLERPl(ms1, ms2, lambda);
    vM interpolcN=NLERPl(mse1, mse2, lambda);

    Matrix mapinter=EmbedSPD(interpolMVN.v, interpolMVN.M);
    mapinter.print(6, 6);
    interpolcN.M.print(6, 6);
    double delta=mapinter.minus(interpolcN.M).norm2();
    System.out.println("delta "+delta);

    double tplus=(interpolcN.M.get(0, d)-mse2.M.get(0, d))/(mse1.M.get(0, d)-mse2.M.get(0, d));
    System.out.println("t+:" +tplus);
    /*
 double tmp=F(thetae1)-F(theta1);
     double c=0.5*Math.log(Math.PI);
     System.out.println(tmp+" "+c);
     */
  }

  public static void main(String [] args)
  {  //testIG();
  	int dim;
  	for(dim=1;dim<=10;dim++) testUBFR(dim);
  //	for( dim=1;dim<=30;dim++) testUBDiag(dim);
  	//for( dim=1;dim<=5;dim++)
  		// testUB(dim);
  	//	testUB(5);
//experiments1D();
   
    //experimentCosta();

    //testApproxDist();
    //testProjection();
    
    //for(int dim=11;dim<=30;dim++) experiments(dim);

    //test1D();
    //test2D();

    // System.out.println("Calvo Oller MVN SPD embedding");
   
    //testIG2();

    //   testHellinger();

    //  testKLD();  // works: checked!

    //test();
    //test2();
    //test3();
  }
}
