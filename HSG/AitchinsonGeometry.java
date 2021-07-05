// Frank Nielsen   contact: Frank.Nielsen@acm.org
// November 2018

// Show experimentally that the Hilbert simplex metric is information monotone

/*
- "Clustering in Hilbert simplex geometry"
https://arxiv.org/abs/1704.00454

- "Clustering in Hilbert Projective Geometry:
The Case Studies of the Probability Simplex and
the Elliptope of Correlation Matrices."

https://franknielsen.github.io/HSG/
*/

class HilbertSimplexGeometry
{
	public static double max(double a, double b)
	{if (a<b) return b; else return a;}
	
	public static double min(double a, double b)
	{if (a<b) return a; else return b;}
	
// Birkhoff cone distance (between rays)
public static double orthantDistance(double [] p, double [] q)
{
  int i, d=p.length;
  double M=0;
  double m=Double.POSITIVE_INFINITY;
  
  for(i=0;i<d;i++)
  {
  M=max(M,p[i]/q[i]);
  m=min(m,p[i]/q[i]);
  }
  
  return Math.log(M/m);
  }
  
  
  
public static double variationNormDistance(double [] p, double [] q)
{
  int i, d=p.length;
  double M=0;
  double m=Double.POSITIVE_INFINITY;
  
  for(i=0;i<d;i++)
  {
  M=max(M,Math.log(p[i])-Math.log(q[i]));
  m=min(m,Math.log(p[i])-Math.log(q[i]));
  }
  
  return M-m;
  }
    
/* implements "Algorithm 4: Computing the Hilbert distance" in
 * arxiv v3 https://arxiv.org/pdf/1704.00454.pdf
 */ 	
public static double simplexDistance(double [] p, double [] q)
{
  int i, d=p.length;
  boolean samePoint=true;
  for (i=0; i<d; i++)
  {
    if (p[i]!=q[i]) samePoint=false;
  }

  if (samePoint) 
    return 0.0;
  else
  {
    double  t, t0=Double.NEGATIVE_INFINITY, t1=Double.POSITIVE_INFINITY;

    for (i=0; i<d; i++)
    {
      if (p[i]!=q[i])
      {
        t=p[i]/(p[i]-q[i]);
        if ((t0<t)&&(t<=0)) t0=t;
        if ((1<=t)&&(t<t1)) t1=t;
      }
    }  

    return Math.abs(Math.log(1.0-1.0/t0)-Math.log(1.0-1.0/t1));
  }
}

public static String  toStringMatrix(double [][] M)
{
String res="";	
int i,j, d1=M.length, d2=M[0].length;
for(i=0;i<d1;i++)
{for(j=0;j<d2;j++)
{res=res+M[i][j]+"\t";}
res=res+"\n";
}

return res;	
}

public static  double [][] randomPositiveColumnStochastic(int d1, int d2)
{
int i,j,k;
double cumul;
double [][] res=new double [d1][d2];
for(i=0;i<d1;i++)
for(j=0;j<d2;j++)
res[i][j]=Math.random();

for(j=0;j<d2;j++)
{
cumul=0.0;
for(i=0;i<d1;i++)
cumul+=res[i][j];
for(i=0;i<d1;i++)
res[i][j]/=cumul;

}

return res;	
}

 
 // Coarse-binning the d-simplex into d'-simplex
 // See Sec 3.3 of arxiv
 // M is (d',d) column stochastic
public static  double [] matrixReduce(double [][] M, double [] x) 
{
int i,j;
int d=x.length;
int dprime=M.length;

double [] res=new double[dprime];
 
 
for(i=0;i<dprime;i++)
{
double coeff=0;
for(j=0;j<d;j++)
	{coeff+=M[i][j]*x[j];}
res[i]=coeff;	
}

return res;	
} 
 
 
public static void normalize(double [] x)
{int d=x.length;
double cumul=0.0;
int i;

for(i=0;i<d;i++)
{cumul+=x[i];}
for(i=0;i<d;i++)
{x[i]/=cumul;}
}

// Draw a random point in the simplex
public static double [] randSimplex(int d)
{double [] res =new double[d];
for(int i=0;i<d;i++) 
	{res[i]=Math.random();}
normalize(res);
return res;
}


public static double [] randOrthant(int d)
{double [] res =new double[d];
for(int i=0;i<d;i++) 
{res[i]=Math.random();}
 
return res;
}


public static double [] LERP(double [] p, double [] q, double lambda)
{int d=p.length;
double [] res =new double[d];
for(int i=0;i<d;i++) res[i]=(1-lambda)*p[i]+lambda*q[i];	
return res;
}

public static void test1()
{
int d=256;
double [] p=randSimplex(d);
double [] q=randSimplex(d);

System.out.println("Computing Hilbert's simplex metric using three equivalent methods");

double d1,d2,d3;

d1=variationNormDistance(p,q);
d2=orthantDistance(p,q);
d3=simplexDistance(p,q);

System.out.println("Method variation norm (fast):\t "+d1);
System.out.println("Method Birkhoff (projective):\t "+d2);
System.out.println("Algorithmic method (slow):\t "+d3);
}


public static void test2()
{


int d=5, dprime=3;
double [][] M=randomPositiveColumnStochastic(dprime,d);

System.out.println("Checking information monotonicity: From dim "+d+" to dim "+dprime+"\n\n");

System.out.println("Matrix M (fat column-stochastic):\n"+toStringMatrix(M));

double [] p=randSimplex(d);
double [] q=randSimplex(d);

double dpq=variationNormDistance(p,q);

double [] pRed=matrixReduce(M,p);
double [] qRed=matrixReduce(M,q);
double dpqprime=variationNormDistance(pRed,qRed);

System.out.println("[Hilbert] Check information monotonicity:"+dpqprime+" <=  "+dpq);	

 p=randOrthant(d);
 q=randOrthant(d);
 dpq=orthantDistance(p,q);
 pRed=matrixReduce(M,p);
 qRed=matrixReduce(M,q);
 dpqprime=orthantDistance(pRed,qRed);
System.out.println("[Birkhoff] Check information monotonicity:"+dpqprime+" <= "+dpq);




		
}

public static void main(String[] args)
{
	System.out.println("Hilbert simplex metric\n[2018] Frank Nielsen and Ke Sun\n\n");
	
	test1();
	test2();
}	
	
	
	
public  static void test3()
{
System.out.println("Test triangle equality for intermediate point on the line segment [pq]");

int dim=256;
double [] p=randSimplex(dim);
double [] q=randSimplex(dim);
double [] r=LERP(p,q,Math.random());
double Dpq=simplexDistance(p,q);
double Dpr=simplexDistance(p,r);
double Drq=simplexDistance(r,q);

System.out.println("D(p,q)="+Dpq);
double err=Dpq-(Dpr+Drq);
System.out.println("D(p,r)="+Dpr+" D(r,q)="+Drq+" Error="+err);
}	
}