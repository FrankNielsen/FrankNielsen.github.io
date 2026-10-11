//
// Class Bregman disk
//
class BregmanDisk
{
// Center and radius of the disk
public Point center;
public double rad;

// Combinatorial basis
public PointSet basis;

BregmanDisk()
{
center=new Point();

center.x=0.0;
center.y=0.0;
rad=0.0;

basis=new PointSet(1);
basis.array[0].x=center.x;
basis.array[0].y=center.y;
}
		
	};