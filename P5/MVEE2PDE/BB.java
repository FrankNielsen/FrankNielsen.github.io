// Boundary box for converting coordinates to canvas coordinates.
// tx ty is the offset in the canvas



class BB
{
  double minx, maxx;
  double miny, maxy;
  int w, h;
  int tx, ty;

  // by default tx, ty=0;
  BB(double mx, double Mx, double my, double My, int ww, int hh, int ttx, int tty)
  {
    minx=mx;
    maxx=Mx;
    miny=my;
    maxy=My;
    w=ww;
    h=hh;
    tx=ttx;
    ty=tty;
  }

  BB(double mx, double Mx, double my, double My, int ww, int hh)
  {
    minx=mx;
    maxx=Mx;
    miny=my;
    maxy=My;
    w=ww;
    h=hh;
    tx=ty=0;
  }

  public void info()
  {// if you want this, rename .java into .pde
    // println("Bounding box:"+minx+" "+maxy+" "+miny+" "+maxy+" "+w+" "+h+" "+tx+" "+ty);
  }

  public  float x2X(double x)
  {
    return (float)(tx+((x-minx)*w/(maxx-minx)));
  }


  public  float y2Y(double y)
  {
    return (float)(h-(ty+((y-miny)*h/(maxy-miny))));
  }

  public  float X2x(double X)
  {
    return (float)(minx+(maxx-minx)*(X/(float)w));
  }

  public  float Y2y(double Y)
  {
    return (float)(miny+(maxy-miny)*((h-Y)/(float)h));
  }
}
