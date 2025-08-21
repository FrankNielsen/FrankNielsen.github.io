//
// Class for managing d-dimensional points
//
import java.util.Random;

class point
{
static final Random rand = new Random();
	
int d;
double coord[];	

//
// Initialize a point of dimension d to the origin
//
point(int dd)
{
d=dd;
coord=new double[d];

for(int i=0; i<d; i++)
			coord[i]=0.0;	
}

//
// Initialize to a random point in the unit square
//
void rand()
{
	for(int i=0;i<d;i++)
		coord[i]=rand.nextDouble();
}

//
// Compute the distance between this point and another
//
double Distance(point q)
{
double l=0.0;

for(int i=0;i<d;i++) l+=(coord[i]-q.coord[i])*(coord[i]-q.coord[i]);
return Math.sqrt(l);	
}

double Norm()
{
double l=0.0;

for(int i=0;i<d;i++) l+=(coord[i]*coord[i]);
return Math.sqrt(l);	
}

}
