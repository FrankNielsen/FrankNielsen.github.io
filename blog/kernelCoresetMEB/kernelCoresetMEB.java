// Frank.Nielsen@acm.org
// core-set for MEB, kernel
// implicit parameterization
// September 2017


abstract class kernel {
abstract double k(double[] x, double [] y);

double sqrDistance(double[] x, double [] y)
{return k(x,x)+k(y,y)-2.0*k(x,y);}

	} 


class euclideanKernel extends kernel
{
static double sigma=1.0;
//static double sigma=20.0;

double k(double[] x, double [] y)
{
double res=0.0;
int n=x.length,i;

for(i=0;i<n;i++)
{res+=x[i]*y[i];}
return res;
}

}


class gaussianKernel extends kernel
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
 double k(double[] x, double [] y)
{
return Math.exp(-sqrEucDistance(x,y)/(2.0*sigma*sigma));
}
	
}

class ball{
double [] centerw;
double rad2;

ball(){rad2=0.0; centerw=null;}
};




// should add a support vector boolean array
public class kernelCoresetMEB
{
	
static int w=512,h=w;
static double bb=0.5;
static double minx=-0.5-bb;
static double miny=-0.5-bb;
static double maxx=0.5+bb;
static double maxy=0.5+bb;

public static double xToX(int x)
{
return (minx+(maxx-minx)*x/(double)w);	
}

public static int Xtox(double X)
{
return 	(int)(((X-minx)/(maxx-minx))*(w-1));
}

public static int Ytoy(double Y)
{
return 	(int)(((Y-miny)/(maxy-miny))*(h-1));
}


public static double yToY(int y)
{
return (miny+(maxy-miny)*y/(double)h);	
}

static int maxiter=1000;	
static int d=2;
static int n=100;
static double [][] data=new double [n][d];
static int [] listSV=new int[maxiter];

static kernel myKernel=new gaussianKernel();
//static kernel myKernel=new euclideanKernel();


// to speed up computation

static double kernelDistance(double [] centerw, double[][] data, double [] pt)
{
double res=0;
int i,j,n=centerw.length;

for(i=0;i<n;i++)
for(j=0;j<n;j++)
{res+=centerw[i]*centerw[j]*myKernel.k(data[i],data[j]);}

res+=myKernel.k(pt,pt);

for(i=0;i<n;i++)
{
res-=2.0*	centerw[i]*myKernel.k(data[i],pt);
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
//System.out.println("maxd="+maxkd);	
return winner;	
}

public static ball kernelCoreMEB(double [][] data,int nbiter)
{
int  	n=data.length;
double [] centerw=new double [n];
centerw[0]=1; //initialization of center
int i, j;

for(i=0;i<nbiter;i++)
{
int index=Farthest(centerw,data);

//System.out.println(i+"\t"+index);

// update weights
for(j=0;j<n;j++)
{
centerw[j]*=(double)nbiter/(double)(nbiter+1.0);
if (j==index) centerw[j]+=(1.0/(double)(nbiter+1.0));	
}

}

ball sol=new ball();

sol.centerw=centerw;
sol.rad2=kernelDistance(centerw,data,data[Farthest(centerw,data)]);

return sol;	
}


public static int nbSV(double [] w)
{int n=w.length; int i;
int nb=0;
for(i=0;i<n;i++)
{
if (w[i]!=0.0) nb++;
}
return nb;
}


public static void print(double [] w)
{int n=w.length; int i;

for(i=0;i<n;i++)
{
System.out.print(w[i]+" ");
}
System.out.print("\n");
}
// end print


static ball approxBall;

public static void exportBall(String filename)
{int i,j;
double xx,yy;
PPM img=new PPM(w,h);

for(i=0;i<w;i++)
	for(j=0;j<h;j++)
	{double pt []=new double[2]; 
		pt[0]=xToX(i);	
		pt[1]=yToY(j);
	
	if (kernelDistance(approxBall.centerw,data,pt)<approxBall.rad2)
	{img.r[i][j]=img.g[i][j]=img.b[i][j]=128;}
	
	
}

for(i=0;i<n;i++)
{
int ii,jj; 
ii=(int)Xtox(data[i][0]);
jj=(int)Ytoy(data[i][1]);

int kk, ll;
for(kk=-2;kk<=2;kk++)
for(ll=-2;ll<=2;ll++)
{
img.r[ii+kk][jj+ll]=255;
img.g[ii+kk][jj+ll]=img.b[ii+kk][jj+ll]=0;
}
	
}

img.write(filename);
}


public static void main(String [] a)
{int i,j;
int nbiter=1000;

System.out.println("kernel MEB");

for(i=0;i<n;i++)
for(j=0;j<d;j++)
	{data[i][j]=-0.5+Math.random();
}

approxBall=kernelCoreMEB(data,nbiter);

print(approxBall.centerw);
System.out.println(" sqrradius="+approxBall.rad2);
	
System.out.println(" #SVs="+nbSV(approxBall.centerw));	

	
System.out.println("exporting ball in ppm");	
//exportBall("eball.ppm");
exportBall("gball.ppm");
	
System.out.println("done!");	
}

}