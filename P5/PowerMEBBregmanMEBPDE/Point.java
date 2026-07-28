import java.util.Random;

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

//
// A Point set class
//
class PointSet
{
public int n;
public Point array[];

// Constructor
PointSet(int card)
{
  int i;
  Random rand =new Random();

  n=card;
  array=new Point[card];

  // Uniform point set on the unit square
  for(i=0;i<n;i++)
    {
    array[i]=new Point();
    array[i].x=0.1+0.9*rand.nextDouble();
    array[i].y=0.1+0.9*rand.nextDouble();
    }
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

  // We need to get an idea of a Bregman ball
//  PointSet ptst=new PointSet(card);

  centerball.x=0.5;
  centerball.y=0.5;

/*  for(i=0;i<n;i++)
    {
    centerball.x+=ptst.array[i].x;
    centerball.y+=ptst.array[i].y;
    }

  centerball.x=(1.0/n)*centerball.x;
  centerball.y=(1.0/n)*centerball.y;

  radiusball=0.0;
  for(i=0;i<n;i++)
    {
    rad=BD.divergence(centerball, ptst.array[i]);
    if (rad>radiusball) radiusball=rad;
    }
*/

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
