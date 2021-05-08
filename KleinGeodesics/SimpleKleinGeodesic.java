
/* (c) April 2021 Frank Nielsen Frank.Nielsen@acm.org  
 see
 Closed-form expression of geodesics in the Klein model of hyperbolic geometry
 or
 The hyperbolic Voronoi diagram in arbitrary dimension
 https://arxiv.org/abs/1210.8234
 */
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


public class SimpleKleinGeodesic
{


  public static double cosh(double x)
  {
    return 0.5*(Math.exp(x)+Math.exp(-x));
  }

  public static double sqr(double x)
  {
    return x*x;
  }

  public static double arccosh(double x)
  {
    return Math.log(x+Math.sqrt(x*x-1.0));
  }


  public static double KleinDistance(Point2D p, Point2D q)
  {
    double np2=p.sqrnorm();
    double nq2=q.sqrnorm();
    return arccosh( (1-(p.x*q.x+p.y*q.y))/Math.sqrt((1-np2)*(1-nq2)));
  }

  public static double max(double a, double b)
  {
    if (a<b) return b; 
    else return a;
  }


  public static Point2D LERP(Point2D p, Point2D q, double alpha)
  {
    Point2D res=new Point2D();
    res.x=p.x+alpha*(q.x-p.x);
    res.y=p.y+alpha*(q.y-p.y);

    return res;
  }


  public static double KleinGeodesicC(Point2D p, Point2D q, double alpha)
  {
    double a=1-p.sqrnorm();
    double b=p.inner(q.minus(p));
    double c=(q.minus(p)).sqrnorm();
    double d=cosh(alpha*KleinDistance(p, q));

    return (  a*d*Math.sqrt((a*c+b*b)*(d*d-1))  +a*b*(1-d*d)  )/(a*c*d*d+b*b);
  }


  public static void main(String [] args)
  {
    Point2D p, q;
    p=new Point2D(); 
    q=new Point2D();

    p.rand();
    q.rand();  

    double alpha=Math.random();


    double s=Math.random();
    double t=Math.random();

    Point2D u=LERP(p, q, KleinGeodesicC(p, q, s));
    Point2D v=LERP(p, q, KleinGeodesicC(p, q, t));

    double dist1=Math.abs(s-t)*KleinDistance(p, q);
    double dist2=KleinDistance(u, v);
    double err2=Math.abs(dist1-dist2)/max(dist1, dist2);
    
    System.out.println("Check geodesic metric space for s="+s+" and t="+t);
    System.out.println("dist(KleinGeodesicC(p,q, s),KleinGeodesicC(p,q, t))="+dist2+" versus |s-t|dist(p,q)="+dist1+"\nRelative error:"+err2);
  }
}
