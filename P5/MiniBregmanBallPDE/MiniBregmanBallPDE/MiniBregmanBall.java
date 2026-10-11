//
// The Bregman MiniBall class
//

import java.util.Random;

class MiniBregmanBall
{
	/* intersection point is normalized */
public PPoint b12, b13, b23,intersection;  
PointSet set;
BregmanDivergence DF;

// Solution
BregmanDisk bdisk;
PointSet basis;

// Random generator for choosing the pivot
Random random;

MiniBregmanBall(PointSet ps, BregmanDivergence div)
{
set=new PointSet(ps,0);
DF=div;

// At most 3 points in a basis

basis=new PointSet(0); 




random=new Random();

//bdisk=SolveDisc3(set.array[0],set.array[1],set.array[2]);
//bdisk=SolveDisc2(set.array[0],set.array[1]);

bdisk=MiniDisc(set,basis);

//System.out.println("Solution to Miniball: "+bdisk.center.x+" "+bdisk.center.y+" radius="+bdisk.rad+" basis size="+bdisk.basis.n);
}


PPoint CrossProduct(PPoint p1, PPoint p2)
{
PPoint result=new PPoint();

result.x=p1.y*p2.w-p1.w*p2.y;
result.y=p1.w*p2.x-p1.x*p2.w;
result.w=p1.x*p2.y-p1.y*p2.x;

return result;
}

double DotProduct(Point p,Point q)
{
return p.x*q.x+p.y*q.y;
}

//
// Compute the linear equation of a Bregman Bisector (type 1)
//
PPoint BregmanBisector(Point p, Point q)
{
Point  gradp,gradq;
PPoint result=new PPoint();

//System.out.println("Bregman bisector of "+p.x+" "+p.y+" with "+q.x+" "+q.y);

gradp=DF.gradF(p);
gradq=DF.gradF(q);

//
// Equation of the bisector stored as a projective point
//
result.x=gradp.x-gradq.x;
result.y=gradp.y-gradq.y;

result.w=DF.F(p)-DF.F(q)+DotProduct(q,gradq)-DotProduct(p,gradp);

return result;
}

//
// Solve the basic problem for three points:
// Note that not all disks can pass by three points
//
BregmanDisk SolveDisc3(Point d1, Point d2, Point d3)
{
BregmanDisk result=new BregmanDisk();


b12=BregmanBisector(d1,d2);
b13=BregmanBisector(d1,d3);
b23=BregmanBisector(d2,d3);

intersection=CrossProduct(b12,b13);
intersection.Normalize();

result.center.x=intersection.x;
result.center.y=intersection.y;

result.rad=DF.divergence(result.center, d1); // trisector

result.basis=new PointSet(3);
result.basis.array[0]=d1;
result.basis.array[1]=d2;
result.basis.array[2]=d3;

return result;
}


//
// Solve minimum divergence for two points 
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

BregmanDisk SolveDisc2(Point d1, Point d2)
{
BregmanDisk result=new BregmanDisk();
double mindiv,div;
int i,nbsteps=1000;
double alpha;
double increment=1.0/(double)nbsteps;

/*
Point p=new Point();
b12=BregmanBisector(d1,d2);

mindiv=Double.MAX_VALUE;

for(i=0;i<nbsteps;i++)
	{
	alpha=(double)i/(double)nbsteps;
	p=BBCPoint(alpha, d1,d2);
	
	div=Math.abs(DF.divergence(p,d1)-DF.divergence(p,d2));
		if (div<mindiv) 
			{mindiv=div;
			result.center=p;
			}
}
*/


Point pq2=new Point();
double lambda, lambdamin, lambdamax;

lambdamin=0.0;
lambdamax=1.0;

while(Math.abs(lambdamax-lambdamin)>1.0e-5)
{
lambda=0.5*(lambdamin+lambdamax);
pq2=BBCPoint(lambda, d1,d2);


if (DF.divergence(pq2,d1)>DF.divergence(pq2,d2))
	lambdamin=lambda;
	else
	lambdamax=lambda;
}

result.center=pq2;

result.rad=DF.divergence(result.center, d1); // should be mindiv
result.basis=new PointSet(2);
result.basis.array[0]=d1;
result.basis.array[1]=d2;

return result;
}


BregmanDisk SolveDisc1(Point c)
{
BregmanDisk result=new BregmanDisk();
		result.rad=0.0; 
								result.center=c;
								result.basis=new PointSet(1); 
								result.basis.array[0]=result.center;
								
								return result;
}

//
// FallOutside bypasses the computation of the exact casis
//
boolean FallOutside(BregmanDisk b, Point p)
{
	/*
if (b.basis.n==2)
	{
		// Exact computation
		BregmanDisk d3=SolveDisc3(p,b.basis.array[0],b.basis.array[1]);
	
	   // Can the SEB of the basis be below d3.rad ?
		return SolveDisc2DP(b.basis.array[0],b.basis.array[1],d3.rad);
	}
	else
	*/ 
	if 	(DF.divergence(b.center,p)>b.rad) return true;
	else return false;
}

//
// Miniball recursive algorithm "as is"
// See Welzl's paper 
//
BregmanDisk MiniDisc(PointSet set, PointSet basis)
{
int k,b,n;


b=basis.n;
n=set.n;

//System.out.println("Set size:"+set.n+" Basis size:"+basis.n);
//set.PrintSet(); 
//basis.PrintSet();

//
// Terminal cases
//
if (b==3)  
	{   BregmanDisk result;
	//	System.out.println("Solve terminal case with basis=3");
		result=SolveDisc3(basis.array[0], basis.array[1], basis.array[2]);
		return result;
	}
	// divergence is zero by definition
if ((n==1)&&(b==0))
	 {
	 	BregmanDisk result;
	 	result=SolveDisc1(set.array[0]);
	 	return result;}

if ((n==2)&&(b==0))  
	{
		BregmanDisk result; 
		result=SolveDisc2(set.array[0],set.array[1]);
		return result;}
	 
if ((n==0)&&(b==2))  
						{BregmanDisk result;
							result=SolveDisc2(basis.array[0],basis.array[1]); 
						//	System.out.println("Terminal case b=2 n=0 "+result.rad);
							return result;
						}
	
if ((n==1)&&(b==1))
		  {BregmanDisk result;
		  result=SolveDisc2(basis.array[0], set.array[0]);
		  return result;} 
	
	//
	// General case
	//
	if (n+b>2)
	{
		BregmanDisk result;
		// Randomization: choosing a pivot
		k=Math.abs(random.nextInt())%n; // between 0 and n-1

		if (k!=0) { 
				// Swap two points for a randomized miniball
				Point tmp=new Point();
				
				tmp=set.array[0];
				set.array[0]=set.array[k];
				set.array[k]=tmp;
				}
	
	//	System.out.println("Pivot "+k);
	
	// Copy the point set except the first element	
	PointSet remainset=new PointSet(set,1); 
	// Remove the first element
	result=MiniDisc(remainset,basis);

	// If the point falls outside the Bregman disk, this means that
	// it should belong to the basis
//	if (DF.divergence(result.center,set.array[0])>result.rad)
if (FallOutside(result,set.array[0]))
		{
		// Then point stored at set[0] necessarily belongs to the basis.
		//	basis.array[basis.n]=new Point();
		
	//	System.out.println("Upgrade basis "+basis.n);
			
			PointSet newbasis=new PointSet(basis,set.array[0]);
			
		//		System.out.println("... new basis "+newbasis.n);
			result=MiniDisc(remainset,newbasis);
		}	
		return result;
}  // end of not terminal case

// we should not reach that stage but Java requires to return some value for all paths
return new BregmanDisk();  
}
}
