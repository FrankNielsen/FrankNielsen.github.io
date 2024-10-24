class Line
{
  double a,b;
  
 Line(double x1, double y1, double x2, double y2)
 {
  a=(y2-y1)/(x2-x1);
  b=y1-a*x1;
 }
 
 double x2y(double x){return a*x+b;}
 
 
 Line(double aa, double bb){a=aa;b=bb;}
 
 Line translate(double delta)
 {return new Line(a,b+delta);}
}
