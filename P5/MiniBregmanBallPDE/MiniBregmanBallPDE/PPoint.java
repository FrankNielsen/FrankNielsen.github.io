//
// Begin projective point
//
class PPoint {

public double x,y,w;

PPoint(Point p)
{
x=p.x;
y=p.y;
w=1.0;
}

PPoint(double xx, double yy)
{
x=xx;
y=yy;
w=1.0;
}

PPoint()
{x=y=0.0; w=1.0;}


// Dehomogenization (perspective division)
void Normalize()
{
if (w!=0) {x/=w; y/=w; w=1.0;}
}




// Return the ycoord corresponding to xcoord
double XtoY(double xcoord)
{
return (-w-x*xcoord)/y;
}


void SetInfinite()
{
w=0.0;
}

};