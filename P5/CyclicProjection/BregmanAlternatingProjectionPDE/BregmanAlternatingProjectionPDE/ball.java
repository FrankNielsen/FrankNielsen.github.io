//
// Class for managing d-dimensional balls
//
class ball
{
int d;
point center; // center of the ball
double radius;	

ball(point p, double r)
{
	int i;
	d=p.d;
	center=p;
	
	
	radius=r;
}

//
// Is point p inside this ball ball ?
//
boolean Inside(point p)
{
int j;
double l=0.0;

// Compute the distance of p to the center
for(int i=0;i<d;i++) 
	l+=(center.coord[i]-p.coord[i])*(center.coord[i]-p.coord[i]);

l=Math.sqrt(l);

System.out.println("Inside test:"+l+" "+radius+( (l<radius) ? " Inside!": " Outside!") );

if (l<=radius) return true; 
				else return false;
}


}


