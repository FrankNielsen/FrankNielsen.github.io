//
// A Point set class
//

import java.util.Random;

class PointSet
{
public int n;
public Point array[];


public void PrintSet()
{
	int i;
	
	for(i=0;i<n;i++)
	System.out.println(i+" "+array[i].x+" "+array[i].y);
	
}

// Constructor
PointSet(int card)
{
	int i;
	Random rand =new Random();

	n=card;
	
	if (n>0)
	{
	array=new Point[card];

	// Uniform point set on the unit square
	for(i=0;i<n;i++)
		{
		array[i]=new Point();
		array[i].x=0.1+0.9*rand.nextDouble();
		array[i].y=0.1+0.9*rand.nextDouble();
		}
		}
}

//
// Truncated copy of the point set
//
PointSet(PointSet another, int start)
{
int i;

n=another.n-start;
array=new Point[n];

for(i=0;i<n;i++)
	{
	array[i]=new Point();
	array[i]=another.array[i+start];
	}
	
}


//
// Copy of the point set+ an extra point
//
PointSet(PointSet another, Point p)
{
int i;

n=another.n+1;
array=new Point[n];

for(i=0;i<another.n;i++)
	{
	array[i]=new Point();
	array[i]=another.array[i];
	}
	
	array[n-1]=new Point();
	array[n-1]=p;
}
	
	

//
// Constructor with a divergence for sampling inside a ball
//
PointSet(int card, BregmanDivergence BD)
{
	int i;
	double xx,yy;
	Random rand =new Random();
	Point centerball=new Point(rand.nextDouble(),rand.nextDouble());
	double radiusball=0.5+rand.nextDouble();
	double rad;
	Point drawpoint=new Point();

	n=card;

	centerball.x=0.5;
	centerball.y=0.5;

radiusball=BD.divergence(centerball, new Point(0.1,0.1));

	System.out.println("I have choosen theoretical center "+centerball.x+" "+centerball.y+" and divergence radius:"+radiusball);
	

	
	array=new Point[card];

	// Uniform point set on the unit square
	for(i=0;i<n;i++)
		{
		array[i]=new Point();

		drawpoint.x=rand.nextDouble();
		drawpoint.y=rand.nextDouble();
		
		while ( BD.divergence( centerball, drawpoint ) > radiusball )
		{
		drawpoint.x=rand.nextDouble();
		drawpoint.y=rand.nextDouble();
		}

		array[i].x=drawpoint.x;
		array[i].y=drawpoint.y;
		}
		
		System.out.println("Point set drawn.");
}


} // End of  point set class
