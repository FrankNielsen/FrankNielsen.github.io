class Line2D
{// ax+by+c=0
  public double a,b,c;
  
  Line2D(){}
  
  double y(double x)
  {return (-c-a*x)/b;}
  
  Line2D(Point2D p, Point2D q)
  {
    double deltax=p.x-q.x;
    double deltay=p.y-q.y;
    
    a=deltay;
    b=-deltax;
    c=p.y*deltax-deltay*p.x;
  }
  
}
