//
// Class for manipulating a 2D point
// 

class Point
{
public double x,y;

// Constructor
Point()
	{
	x=0.0;
	y=0.0;
	}
	
Point (double xx, double yy)
{x=xx; y=yy;}	


double distSqr(Point q)
{
	return (q.x-x)*(q.x-x)+(q.y-y)*(q.y-y);
}
//
// Java does not allow operator overloading
// Thus, we need to do it coordinatewise
//
public void AddPoint(Point p)
{
x=x+p.x;
y=y+p.y;
}

public void MultCste(double cste)
{
x=cste*x;
y=cste*y;
}

}