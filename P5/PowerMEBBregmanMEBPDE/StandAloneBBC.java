// Frank Nielsen, September 2024
// Frank.Nielsen@acm.org


import java.util.Random;

class StandAloneBregmanBall
{
BregmanDivergence DF; //=new L22();

public int n;
public PointSet dataset;

static int maxhistory=10000; // keep at most x points


Point circumcenter;

//
// Points for BBC
//
Point center, furthestpoint;
Point initialPoint;
int iter;
double radius;


int [] weight;

//
// History
//

int [] historyFurthestIndex=new int[maxhistory];
PointSet historycenter=new PointSet(maxhistory);
double[] historyradius=new double[maxhistory];
int history=0;

int card(int [] ww)
{
  int i, res=0;
  
 for(i=0;i<n;i++)
{if (ww[i]>0) res++;}


  return res;
}

int  [] TruncateWeight(double eps)
{
int i;
int s=sum(weight);
int [] nweight=new int[n];
for(i=0;i<n;i++)
{if (weight[i]<s*eps) nweight[i]=0; else nweight[i]=weight[i];}

return nweight;
}


int [] ExportBasis(int [] w)
{int i;
 int nbbasis= card(w); int nbr=0;
 
 int [] res=new int[nbbasis];
 for(i=0;i<w.length;i++)
 if (w[i]>0) {res[nbr]=i;nbr++;}
 
 return res;
}

int sum(int [] w)
{
 int i, res=0;
 
 for(i=0;i<w.length;i++) res+=w[i];
 
 return res;
}


double symmetrizedBregmanInformation(Point P)
{
  
 return rightBregmanInformation(P)+leftBregmanInformation(P);
}


double rightBregmanInformation(Point P)
{
 int i;
 double res=0;
 
 for(i=0;i<n;i++)
 {
  res+=DF.divergence(dataset.array[i],P); // right
 }
 
 return res;
}


double leftBregmanInformation(Point P)
{
 int i;
 double res=0;
 
 for(i=0;i<n;i++)
 {
  res+=DF.divergence(P,dataset.array[i]); // P is on left side
 }
 
 return res;
}

// does not work
void testProp()
{int i;
int [] ww=new int[n];
  for(i=0;i<n;i++) ww[i]=1;
  
 Point A=primalCentroid(ww);
 Point QAM=dualCentroid(ww);
 
 double IA,IQAM;
 
 IA=symmetrizedBregmanInformation(A); 
 IQAM=symmetrizedBregmanInformation(QAM);
 
 System.out.println("Is there a remarkable property:"+IA+" \t"+IQAM);
}


Point primalCentroid()
{
return primalCentroid(weight);  
}

// Arithmetic barycenter
Point primalCentroid(int [] w)
{int i;
double alpha;
double cx=0,cy=0;
int nb=sum(weight);

for(i=0;i<n;i++)
{
  cx+=(w[i]/(double)nb)*dataset.array[i].x;
  cy+=(w[i]/(double)nb)*dataset.array[i].y;
}

  return new Point(cx,cy);
}


 
Point dualCentroid()
{return dualCentroid(weight);}

// quasi-arithmetic centroid
Point dualCentroid(int [] w)
{int i;
double alpha;
double cx=0,cy=0;
int nb=sum(weight);
Point q;

for(i=0;i<n;i++)
{ q=DF.gradF(dataset.array[i]);
  cx+=(w[i]/(double)nb)*q.x;
  cy+=(w[i]/(double)nb)*q.y;
}

  return   DF.gradFinv(new Point(cx,cy));
  
}

// Frank: not correct
double JensenDiversity()
{
  int i;
  int nb=sum(weight);
  double alphaF=0,alphai;
  
  for(i=0;i<n;i++)
  {
  alphai=weight[i]/(double)nb;  
  alphaF+=alphai*DF.F(dataset.array[i]);
  }
  
  // should be centroid here
  return alphaF-DF.F(dualCentroid());
}

double DualJensenDiversity()
{
  return 0;
}

//
// Compute the furthest point to a point set
//
int argFurthestPoint(Point p)
{
int i,winner;
double div,maxdiv=0.0;

winner=0;

for(i=0;i<dataset.n;i++)
  {
    div=DF.divergence(p,dataset.array[i]);
    if (div>maxdiv) {maxdiv=div; winner=i;}
  }
return winner;
}


//
// Compute the furthest point to a point set
//
Point FurthestPoint(Point p)
{
int winner;
 
winner=argFurthestPoint(p);
return dataset.array[winner];
}


//
// Compute the maximal divergence to a point set
//
double MaxDivergence(Point p)
{
int i;
double div,maxdiv=0.0;

for(i=0;i<dataset.n;i++)
  {
    div=DF.divergence(p,dataset.array[i]);
    if (div>maxdiv) {maxdiv=div;}
  }

return maxdiv;
}

public void InitializeBBC()
{
Random rand =new Random();
int pos;

weight=new int[n];

 historyFurthestIndex=new int[maxhistory];
 historycenter=new PointSet(maxhistory);
  historyradius=new double[maxhistory];

pos=Math.abs(rand.nextInt())%dataset.n;
//System.out.println("Choosing at random the seed point: Index "+pos+" of "+dataset.n);


initialPoint=dataset.array[pos];

center=dataset.array[pos];
weight[pos]++;

historycenter.array[0]=center;


furthestpoint=FurthestPoint(center);

historyFurthestIndex[0]=argFurthestPoint(center);


radius=MaxDivergence(center);


iter=1;
history=1;


}

//
// Interpolation for the geodesic
//
public Point BBCPoint(double alpha, Point p, Point q)
{
Point gradfp,gradc;
Point cc=new Point();

gradfp=DF.gradF(q);
gradfp.MultCste(1.0-alpha);

gradc=DF.gradF(p);
gradc.MultCste(alpha);

gradc.AddPoint(gradfp);

cc=DF.gradFinv(gradc);

return cc;
}




//
// One iteration of the BBC algorithm
//
public void OneIterationBBC()
{
Point gradfp,gradc, cc;
double alpha;
int indexfp;

// Move the center
alpha=(double)iter/(double)(iter+1.0);


gradfp=DF.gradF(furthestpoint);
gradfp.MultCste(1.0-alpha);
gradc=DF.gradF(center);
gradc.MultCste(alpha);

gradc.AddPoint(gradfp);

center=DF.gradFinv(gradc);

iter=iter+1;

radius=MaxDivergence(center);
furthestpoint=FurthestPoint(center);
indexfp=argFurthestPoint(center);

weight[indexfp]++;


if (history<maxhistory) {
//
// Update (center,radius) history here
//
historycenter.array[history]=center;
historyFurthestIndex[history]=indexfp;
historyradius[history]=radius;
  history++;
  }
  else {history=0;// System.out.println("Beware: Exceeded max history!"); //System.exit(-1);
}
}



//
// Many iterations
//
public void IterateBBC(int nbiter)
{int i;
for(i=0;i<nbiter;i++) 
{
OneIterationBBC();
}
}

  
}
