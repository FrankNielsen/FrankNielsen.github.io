
/* (c) October 2023 Frank Nielsen Frank.Nielsen@acm.org  
 see
 Closed-form expression of geodesics in the Klein model of hyperbolic geometry
 or
 The hyperbolic Voronoi diagram in arbitrary dimension
 https://arxiv.org/abs/1210.8234
 */
 
 import processing.pdf.*;
 
 double t=1;
 //double t=2.5;
 
 
 double distE(Point2D p, Point2D q)
 {
   return Math.sqrt(sqr(p.x-q.x)+sqr(p.y-q.y));
 }
 
 
 
 double HilbertDistance(Point2D p, Point2D q)
 {
   Line2D lpq=new Line2D(p,q);
   
 double A,B,C;
 double xsol1, xsol2;
    A=1+sqr(lpq.a/lpq.b);
    B=2*lpq.a*lpq.c/sqr(lpq.b);
    C=-1+sqr(lpq.c/lpq.b);
    
    double Delta=B*B-4*A*C;
    xsol1=(-B-Math.sqrt(Delta))/(2*A);
     xsol2=(-B+Math.sqrt(Delta))/(2*A);
 Point2D i1=new Point2D(xsol1,lpq.y(xsol1));
 Point2D i2=new Point2D(xsol2,lpq.y(xsol2));
 double crossratio=(distE(p,i1)*distE(q,i2))/(distE(p,i2)*distE(q,i1));
 
 return Math.abs(logt(crossratio));  //Math.abs(0.5*logt(crossratio));
 }
 
 double logt(double x)
    {
      if (Math.abs(t-1.0d)<1.0e-2) return Math.log(x);
      else
      return (1.0d/(1.0d-t))*(Math.pow(x,1.0d-t)-1.0d);
      }

int winwidth=512,winheight=512;
int side=winheight;
 
 double minx=-1, maxx=1;
 double miny=-1, maxy=1;
 
 
 int n=1;
 Point2D [] parray,qarray;
double alpha=0;
double dalpha=0.01;
 boolean animation=true;
 
 void Initialize()
 {
  int i;
  parray=new Point2D[n];
  qarray=new Point2D[n];
  for(i=0;i<n;i++) {parray[i]=new Point2D(); parray[i].rand();qarray[i]=new Point2D(); qarray[i].rand();}

// reference distance
 double dist=KleinDistance(parray[0],qarray[0]);
 
 
   for(i=0;i<n;i++)
   {double ratio=dist/KleinDistance(parray[i],qarray[i]);
  qarray[i]=LERP(parray[i],qarray[i],KleinGeodesicC(parray[i],qarray[i],ratio));
  println("dist:"+dist+" "+i+" "+KleinDistance(parray[i],qarray[i]));
 }
 }

public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

// inverse
public  float X2x(double X)
{
  return (float)(minx+(maxx-minx)*(X/(float)side));
}

public  float Y2y(double Y)
{
  return (float)(miny+(maxy-miny)*((side-Y)/(float)side));
}


// flip or not flip
public  float y2Y(double y)
{
  return (float)(side-(y-miny)*side/(maxy-miny));
}


 void drawLine(double a, double b, double c, double d)
{
line(x2X(a),y2Y(b),x2X(c),y2Y(d));
}

 void drawPoint(double a, double b)
{
ellipse(x2X(a),y2Y(b),5,5);
}


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

void keyPressed()
{
if (key==' ') {Initialize();draw();}
if (key=='q') {exit();}
if (key=='p') {savepdffile();}

}

void setup()
{
Initialize();
size(512,512);}
 double tplus(double x,double y)
   {
     return x+y+(1-t)*x*y;
   }
   
   
void drawGeodesic(Point2D p, Point2D q)
   {
   drawLine(p.x,p.y,q.x,q.y);
   }
   
     
void drawGeodesicBruteForce(Point2D p, Point2D q)
{
int i,j; 
Point2D r;
double xx,yy;
double tolerance=1.0e-3;

for(i=0;i<side;i++)
for(j=0;j<side;j++)
{
xx=X2x(i);
yy=Y2y(j);
if (xx*xx+yy*yy<1){
r=new Point2D(xx,yy);
if (Math.abs(tplus(HilbertDistance(p,r),HilbertDistance(r,q))-HilbertDistance(p,q))<tolerance) ellipse(i,j,1,1);
}

}

}

void draw(){
background(255, 255, 255);


// draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(3);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);
  Line2D lpq;
  
  
  if (n>0){
    Point2D p,q;
  p=new Point2D(parray[0].x,parray[0].y);
  q=new Point2D(qarray[0].x,qarray[0].y);
   lpq=new Line2D(p,q);
 
  //stroke(128,128,128);fill(128,128,128);
  // drawLine(-1,lpq.y(-1),1,lpq.y(1)); 

 double A,B,C;
 double xsol1, xsol2;
    A=1+sqr(lpq.a/lpq.b);
    B=2*lpq.a*lpq.c/sqr(lpq.b);
    C=-1+sqr(lpq.c/lpq.b);
    
    double Delta=B*B-4*A*C;
    //println(Delta);
    
    xsol1=(-B-Math.sqrt(Delta))/(2*A);
     xsol2=(-B+Math.sqrt(Delta))/(2*A);
     //println(xsol1+" "+xsol2);
     stroke(255,0,0);fill(255,0,0);
     drawPoint(xsol1,lpq.y(xsol1));
      drawPoint(xsol2,lpq.y(xsol2));
     
     
     double dKlein=KleinDistance(p,q);
     double dHilbert=HilbertDistance(p,q);
     println("Klein:"+dKlein+" Hilbert:"+dHilbert);
     
       drawGeodesic(p,q);
    }
    
    
  
   
    
  int i;
  for(i=0;i<n;i++)
  {
   //drawLine(parray[i].x,parray[i].y,qarray[i].x,qarray[i].y); 
   /*
   Point2D m=LERP(parray[i],qarray[i],KleinGeodesicC(parray[i],qarray[i],alpha));
   
   stroke(255,0,0);
     drawPoint(m.x,m.y);
*/
   
   stroke(0);fill(0);
   drawPoint(parray[i].x,parray[i].y);
    drawPoint(qarray[i].x,qarray[i].y);
    
  }
  
  

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
    strokeWeight(1);
  // end draw disk
  
      
}



void drawGoodKleinGeo(){
background(255, 255, 255);


// draw disk with center cross
  stroke(0);
  noFill();
  strokeWeight(3);
  float cx=x2X(0), cy=y2Y(0);
  float rad=y2Y(1.0);
  ellipse(cx,cy, side,side);
  

  
  int i;
  for(i=0;i<n;i++)
  {
   drawLine(parray[i].x,parray[i].y,qarray[i].x,qarray[i].y); 
   
   Point2D m=LERP(parray[i],qarray[i],KleinGeodesicC(parray[i],qarray[i],alpha));
   
   stroke(255,0,0);
     drawPoint(m.x,m.y);
   stroke(0);
   drawPoint(parray[i].x,parray[i].y);
    drawPoint(qarray[i].x,qarray[i].y);
  }
  
  

  float cross=5;
  strokeWeight(1.0);
  // center

  line(cx-cross, cy, cx+cross, cy);
  line(cx, cy-cross, cx, cy+cross);
    strokeWeight(1);
  // end draw disk
  
     if(animation)
   {
    alpha+=dalpha;
    if (alpha>1) dalpha=-dalpha;
   if (alpha<0) dalpha=-dalpha;
 }
}


void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  
   
 

  beginRecord(PDF, "KleinGeodesics-"+suffix+".pdf");
  background(255);
  draw();
 
  save("KleinGeodesics-"+suffix+".png");
  endRecord();
}
