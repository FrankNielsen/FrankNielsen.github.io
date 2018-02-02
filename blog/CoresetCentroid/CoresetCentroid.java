// Frank.Nielsen@acm.org
/*
Improved Coresets for Kernel Density Estimates (to appear). 
     WaiMing Tai and Jeff M. Phillips. 29th Annual ACM-SIAM Symposium on Discrete Algorithms (SoDA). January 2018. 
    arxiv:1710.04325. October 2017. 
    https://arxiv.org/abs/1710.04325
*/

class CoresetCentroid
{
	
// center of mass of a point set
public static double[] centroidSet(double[][] set)
{
int n=set.length;
int d=set[0].length;
int i,j;
double [] res=new double[d];

for(i=0;i<n;i++){
for(j=0;j<d;j++)
{res[j]+=set[i][j];}}

for(j=0;j<d;j++)
{res[j]/=(double)n;}

return res;
}	

// center of mass of the coreset
public static double[] centroidSet(double[][] set, boolean [] core)
{int n=set.length;
int d=set[0].length;
int i,j;
double [] res=new double[d];
int sizec=0;

for(i=0;i<n;i++)
{
	if (core[i])
		{sizec++;
		
		for(j=0;j<d;j++)
		{res[j]+=set[i][j];}
		
		}

}

for(j=0;j<d;j++)
{res[j]/=(double)sizec;}

return res;
}

// inner product
static double   inner(double[] a, double [] b)
{double res=0;
int d=a.length;
int i;

for(i=0;i<d;i++)
 {res+=a[i]*b[i];}

return res;
}


static int size(boolean [] core)
{int s=0;
for(int i=0;i<core.length;i++) if (core[i]) s++;
return s;}

// Euclidean distance
static double   distance(double[] a, double [] b)
{return Math.sqrt(inner(a,a)+inner(b,b)-2.0*inner(a,b));}


// subtract two vectors
static double []  minus(double[] a, double [] b)
{int d=a.length; 
double [] res=new double [d];

int i;

for(i=0;i<d;i++)
	{res[i]=a[i]-b[i];}

return res;
}

// Linear interpolation
static double [] LERP(double[] a, double [] b, double alpha)
{
int d=a.length;
double [] res=new double[d];
int i;

for(i=0;i<d;i++) 
{res[i]=(1-alpha)*a[i]+alpha*b[i];}

return res;	
}

// Main procedure for computing the centroid
static boolean []  coresetCentroid(double [][] set, double eps)
{
int n=set.length;
int d=set[0].length;
int i,j;
boolean [] res=new boolean[n];	
int nbiter=(int)(2.0/(eps*eps));
double [] c=new double [d];

// initialization
c=LERP(set[0],set[0],1.0);
double [] centroid=centroidSet(set);

for(i=1;i<=nbiter;i++)
{
	
int index=-1;
double minq,bestminq= Double.POSITIVE_INFINITY;

for(j=0;j<n;j++)
{
minq= inner( minus(c,centroid), minus(set[j],centroid));	
//minq= inner( minus(c,centroid),  set[j] );

if (minq<bestminq) {index=j;bestminq=minq;}
}

//System.out.println(index);

res[index]=true; // add to coreset
c=LERP(c,set[index],1.0/(double)i);
}

return res;
}



public static void main(String[] args)
{
int d=50;
int n=1000;
double [][] set=new double [n][d];
int i,j;

System.out.println("Coreset construction for the centroid");

for(i=0;i<n;i++){
for(j=0;j<d;j++)	
{
	set[i][j]=Math.random();
}
}
double [] centroid=centroidSet(set);
double epsilon;

for(epsilon=0.1;epsilon>0.0001;epsilon/=10.0)
{



boolean [] coreset=coresetCentroid(set,epsilon);

double [] coreCentroid=centroidSet(set,coreset);

System.out.println("Size of coreset="+size(coreset));


System.out.println("distance="+distance(centroid,coreCentroid)+   " eps="+epsilon);
}


System.out.println("completed");
}
	
}
