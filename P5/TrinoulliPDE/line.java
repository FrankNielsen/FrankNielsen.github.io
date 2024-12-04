class Line
{
  double a,b,c;
  
  Line(double aa,double bb, double cc){a=aa;b=bb;c=cc;}
  
 double xtoy(double x)
  {
   return (-c-a*x)/b; 
  }
}
