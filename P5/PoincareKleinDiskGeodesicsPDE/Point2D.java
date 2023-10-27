class Point2D
{
  double x, y;

  Point2D() {
  }

  Point2D(double xx, double yy) {
    x=xx; 
    y=yy;
  }


  void rand() {
    double theta=2*Math.PI*Math.random(); 
    double r=Math.random();
    x=r*Math.cos(theta);
    y=r*Math.sin(theta);
  }

  void rand(double R) {
    double theta=2*Math.PI*Math.random(); 
    double r=R*Math.random();
    x=r*Math.cos(theta);
    y=r*Math.sin(theta);
  }


  double norm() {
    return Math.sqrt(sqrnorm());
  }

  double inner(Point2D q) {
    return x*q.x+y*q.y;
  }

  Point2D minus(Point2D q)
  {
    return new Point2D(x-q.x, y-q.y);
  }

  double sqrnorm() {
    return (x*x+y*y);
  }
}
