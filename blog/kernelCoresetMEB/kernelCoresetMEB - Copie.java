// Frank.Nielsen@acm.org
// core-set for MEB, kernel
// implicit parameterization


class euclideanKernel
{
static double sigma=1.0;

static double k(double[] x, double [] y)
{
double res=0.0;
int n=x.length,i;

for(i=0;i<n;i++)
{res+=x[i]*y[i];}
return res;
}

}


class gaussianKernel
{
static double sigma=1.0;

static double sqrEucDistance(double[] x, double [] y)
{
double res=0.0;
int n=x.length,i;

for(i=0;i<n;i++)
{res+=(x[i]-y[i])*(x[i]-y[i]);}
return res;
}

// inner product kernel trick
static double k(double[] x, double [] y)
{
return Math.exp(-sqrEucDistance(x,y)/(2.0*sigma*sigma));
}
	
static double sqrDistance(double[] x, double [] y)
{return k(x,x)+k(y,y)-2.0*k(x,y);
}
}

// should add a support vector boolean array
public class kernelCoresetMEB
{
static int maxiter=10000;	
static int d=2;
static int n=100;
static double [][] data=new double [n][d];
static int [] listSV=new int[maxiter];
// to speed up computation

static double kernelDistance(double [] centerw, double[][] data, double [] pt)
{
double res=0;
int i,j,n=centerw.length;

for(i=0;i<n;i++)
for(j=0;j<n;j++)
{res+=centerw[i]*centerw[j]*gaussianKernel.k(data[i],data[j]);}

res+=gaussianKernel.k(pt,pt);

for(i=0;i<n;i++)
{
res-=2.0*	centerw[i]*gaussianKernel.k(data[i],pt);
	}

return res;	
}


static int Farthest(double[] center, double [][] data)
{
int winner=0, n=center.length,i;
double maxkd=kernelDistance(center, data, data[winner]);

for(i=1;i<n;i++)
{
double cd=kernelDistance(center, data, data[i]);
if (cd>maxkd) {maxkd=cd; winner=i;}	
}
System.out.println("maxd="+maxkd);	
return winner;	
}

public static double [] kernelCoreMEB(double [][] data,int nbiter)
{
int  	n=data.length;
double [] centerw=new double [n];
centerw[0]=1; //initialization of center
int i, j;

for(i=0;i<nbiter;i++)
{
int index=Farthest(centerw,data);
System.out.println(i+"\t"+index);

// update weights
for(j=0;j<n;j++)
{
centerw[j]*=(double)nbiter/(double)(nbiter+1.0);
if (j==index) centerw[j]+=(1.0/(double)(nbiter+1.0));	
}

}


return centerw;	
}

public static void print(double [] w)
{int n=w.length; int i;

for(i=0;i<n;i++)
{
System.out.print(w[i]+" ");
}
System.out.print("\n");
}


public static void main(String [] a)
{int i,j;
int nbiter=1000;

System.out.println("kernel MEB");

for(i=0;i<n;i++)
for(j=0;j<d;j++)
	data[i][j]=Math.random();

double [] centerw=kernelCoreMEB(data,nbiter);

print(centerw);
	
System.out.println("done!");	
}

}