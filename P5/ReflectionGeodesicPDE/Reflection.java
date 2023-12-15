// Frank.Nielsen@acm.org
class Reflection
{
  double a0, b0, r0;

  public static double sqr(double x) {return x*x;}

// Reflect a point
  Point2D reflect(Point2D p)
  {
    double a=p.x; double b=p.y; double xx, yy;
    xx=      ((a-a0)*sqr(r0))/(sqr(b0-b)+sqr(a-a0))+a0;
    yy=      ((b-b0)*sqr(r0))/(sqr(b0-b)+sqr(a-a0))+b0;

    return new Point2D(xx, yy);
  }

  Reflection(double a, double b, double r)
  {
    a0=a; b0=b;r0=r;
  }

// Given three points on a Poincare geodesic (usually p3 is interior point on p1 p) calculates the coefficients of the circle inversion 
// which gives the hyperbolic reflection
  Reflection(Point2D p1, Point2D p2, Point2D p3)
  {
    double a1, b1, a2, b2, a3, b3;
    a1=p1.x;
    b1=p1.y;
    a2=p2.x;
    b2=p2.y;
    a3=p3.x;
    b3=p3.y;

    a0 = -((b2-b1)*Math.pow(b3, 2)+((-Math.pow(b2, 2))+Math.pow(b1, 2)-Math.pow(a2, 2)+Math.pow(a1, 2))*b3+b1*Math.pow(b2, 2)+((-Math.pow(b1, 2))+Math.pow(a3, 2)-Math.pow(a1, 2))*b2+(Math.pow(a2, 2)-Math.pow(a3, 2))*b1)/((2*a2-2*a1)*b3
      +(2*a1-2*a3)*b2+(2*a3-2*a2)*b1);

    b0 = ((a2-a1)*Math.pow(b3, 2)+(a1-a3)*Math.pow(b2, 2)+(a3-a2)*Math.pow(b1, 2)+(a2-a1)*Math.pow(a3, 2)+(Math.pow(a1, 2)
      -Math.pow(a2, 2))*a3+a1*Math.pow(a2, 2)-Math.pow(a1, 2)*a2)/((2*a2-2*a1)*b3+(2*a1-2*a3)*b2+(2*a3-2*a2)*b1);

    r0 = Math.sqrt((Math.pow(b2, 2)-2*b1*b2+Math.pow(b1, 2)+Math.pow(a2, 2)-2*a1*a2+Math.pow(a1, 2))*Math.pow(b3, 4)+
      ((-2*Math.pow(b2, 3))+2*b1*Math.pow(b2, 2)+(2*Math.pow(b1, 2)-2*Math.pow(a2, 2)+4*a1*a2-2*Math.pow(a1, 2))*b2
      -2*Math.pow(b1, 3)+((-2*Math.pow(a2, 2))+4*a1*a2-2*Math.pow(a1, 2))*b1)*Math.pow(b3, 3)+(Math.pow(b2, 4)+2*b1*Math.pow(b2, 3)
      +((-6*Math.pow(b1, 2))+2*Math.pow(a3, 2)+((-2*a2)-2*a1)*a3+2*Math.pow(a2, 2)-2*a1*a2+2*Math.pow(a1, 2))*Math.pow(b2, 2)
      +(2*Math.pow(b1, 3)+((-4*Math.pow(a3, 2))+(4*a2+4*a1)*a3+2*Math.pow(a2, 2)-8*a1*a2+2*Math.pow(a1, 2))*b1)*b2+Math.pow(b1, 4)
      +(2*Math.pow(a3, 2)+((-2*a2)-2*a1)*a3+2*Math.pow(a2, 2)-2*a1*a2+2*Math.pow(a1, 2))*Math.pow(b1, 2)+(2*Math.pow(a2, 2)-4*a1*a2+2*Math.pow(a1, 2))*Math.pow(a3, 2)
      +((-2*Math.pow(a2, 3))+2*a1*Math.pow(a2, 2)+2*Math.pow(a1, 2)*a2-2*Math.pow(a1, 3))*a3
      +Math.pow(a2, 4)-2*a1*Math.pow(a2, 3)+2*Math.pow(a1, 2)*Math.pow(a2, 2)-2*Math.pow(a1, 3)*a2+Math.pow(a1, 4))*Math.pow(b3, 2)+
      ((-2*b1*Math.pow(b2, 4))+(2*Math.pow(b1, 2)-2*Math.pow(a3, 2)+4*a1*a3-2*Math.pow(a1, 2))*Math.pow(b2, 3)+(2*Math.pow(b1, 3)
      +(2*Math.pow(a3, 2)+(4*a2-8*a1)*a3-4*Math.pow(a2, 2)+4*a1*a2+2*Math.pow(a1, 2))*b1)*Math.pow(b2, 2)
      +((-2*Math.pow(b1, 4))+(2*Math.pow(a3, 2)+(4*a1-8*a2)*a3+2*Math.pow(a2, 2)+4*a1*a2-4*Math.pow(a1, 2))*Math.pow(b1, 2)+((-2*Math.pow(a2, 2))+4*a1*a2-2*Math.pow(a1, 2))*Math.pow(a3, 2)
      +(4*a1*Math.pow(a2, 2)-8*Math.pow(a1, 2)*a2+4*Math.pow(a1, 3))*a3-2*Math.pow(a1, 2)*Math.pow(a2, 2)+4*Math.pow(a1, 3)*a2-2*Math.pow(a1, 4))*b2
      +((-2*Math.pow(a3, 2))+4*a2*a3-2*Math.pow(a2, 2))*Math.pow(b1, 3)+(((-2*Math.pow(a2, 2))+4*a1*a2-2*Math.pow(a1, 2))*Math.pow(a3, 2)+(4*Math.pow(a2, 3)-8*a1*Math.pow(a2, 2)+4*Math.pow(a1, 2)*a2)*a3-2*Math.pow(a2, 4)
      +4*a1*Math.pow(a2, 3)-2*Math.pow(a1, 2)*Math.pow(a2, 2))*b1)*b3+(Math.pow(b1, 2)+Math.pow(a3, 2)-2*a1*a3+Math.pow(a1, 2))*Math.pow(b2, 4)+
      (((-2*Math.pow(a3, 2))+4*a1*a3-2*Math.pow(a1, 2))*b1-2*Math.pow(b1, 3))*Math.pow(b2, 3)+(Math.pow(b1, 4)+(2*Math.pow(a3, 2)
      +((-2*a2)-2*a1)*a3+2*Math.pow(a2, 2)-2*a1*a2+2*Math.pow(a1, 2))*Math.pow(b1, 2)+Math.pow(a3, 4)+((-2*a2)-2*a1)*Math.pow(a3, 3)
      +(2*Math.pow(a2, 2)+2*a1*a2+2*Math.pow(a1, 2))*Math.pow(a3, 2)+((-4*a1*Math.pow(a2, 2))+2*Math.pow(a1, 2)*a2-2*Math.pow(a1, 3))*a3+2*Math.pow(a1, 2)*Math.pow(a2, 2)-2*Math.pow(a1, 3)*a2+Math.pow(a1, 4))*Math.pow(b2, 2)
      +(((-2*Math.pow(a3, 2))+4*a2*a3-2*Math.pow(a2, 2))*Math.pow(b1, 3)+((-2*Math.pow(a3, 4))+(4*a2+4*a1)*Math.pow(a3, 3)+((-2*Math.pow(a2, 2))-8*a1*a2-2*Math.pow(a1, 2))*Math.pow(a3, 2)
      +(4*a1*Math.pow(a2, 2)+4*Math.pow(a1, 2)*a2)*a3-2*Math.pow(a1, 2)*Math.pow(a2, 2))*b1)*b2+(Math.pow(a3, 2)-2*a2*a3+Math.pow(a2, 2))*Math.pow(b1, 4)
      +(Math.pow(a3, 4)+((-2*a2)-2*a1)*Math.pow(a3, 3)+(2*Math.pow(a2, 2)+2*a1*a2+2*Math.pow(a1, 2))*Math.pow(a3, 2)+((-2*Math.pow(a2, 3))
      +2*a1*Math.pow(a2, 2)-4*Math.pow(a1, 2)*a2)*a3+Math.pow(a2, 4)-2*a1*Math.pow(a2, 3)+2*Math.pow(a1, 2)*Math.pow(a2, 2))*Math.pow(b1, 2)+(Math.pow(a2, 2)-2*a1*a2+Math.pow(a1, 2))*Math.pow(a3, 4)
      +((-2*Math.pow(a2, 3))+2*a1*Math.pow(a2, 2)+2*Math.pow(a1, 2)*a2-2*Math.pow(a1, 3))*Math.pow(a3, 3)
      +(Math.pow(a2, 4)+2*a1*Math.pow(a2, 3)-6*Math.pow(a1, 2)*Math.pow(a2, 2)+2*Math.pow(a1, 3)*a2+Math.pow(a1, 4))*Math.pow(a3, 2)
      +((-2*a1*Math.pow(a2, 4))+2*Math.pow(a1, 2)*Math.pow(a2, 3)+2*Math.pow(a1, 3)*Math.pow(a2, 2)-2*Math.pow(a1, 4)*a2)*a3+Math.pow(a1, 2)*Math.pow(a2, 4)
      -2*Math.pow(a1, 3)*Math.pow(a2, 3)+Math.pow(a1, 4)*Math.pow(a2, 2))/((2*a2-2*a1)*b3+(2*a1-2*a3)*b2+(2*a3-2*a2)*b1);
  } 
}
