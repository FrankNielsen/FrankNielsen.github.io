// Frank.Nielsen@acm.org
// May 2021, Morley theorem
// https://en.wikipedia.org/wiki/Morley%27s_trisector_theorem

import processing.pdf.*;
import java.util.Arrays;


float ptsize=6.0;

class HPoint2D {
  float x, y, w;
  HPoint2D() {
    x=y=0;
    w=1;
  }

  void print() {
    System.out.println(x+" "+y+" "+w);
  }
  double sqr(double x) {
    return x*x;
  }

  HPoint2D(float  xx, float  yy) {
    x=xx;
    y=yy;
    w=1;
  }

  HPoint2D(double  xx, double  yy) {
    x=(float)xx;
    y=(float)yy;
    w=1;
  }
  void normalize() {
    x/=w;
    y/=w;
  }

  HPoint2D minus(HPoint2D pt)
  {
    return new HPoint2D(x-pt.x, y-pt.y);
  }
  HPoint2D plus(HPoint2D pt)
  {
    return new HPoint2D(x+pt.x, y+pt.y);
  }
  double Norm(HPoint2D pt)
  {
    return Math.sqrt(sqr(pt.x-x)+sqr(pt.y-y));
  }
  double DotProduct(HPoint2D pt)
  {
    return x*pt.x+y*pt.y;
  }
}

double dot(HPoint2D p, HPoint2D q)
{
  return p.x*q.x+p.y*q.y;
}


HPoint2D  [] pt;
HPoint2D p01, p12, p02;
HPoint2D q1, q2, q3; // equilateral coordinates
HPoint2D e01, e12, e20;
HPoint2D   tri10, tri12;
HPoint2D l10, l12, l01, l02, l20, l21; // the six lines of the trisectors


double angle102, angle012, angle201;

double angle01, angle02;
double angle10, angle12;
double angle20, angle21;

double [] speedx, speedy;


int W=512;
int H=512;

boolean anim=false;

// trisector lines and equilateral triangle points
void Calculate()
{
  e01=CrossProduct(pt[0], pt[1]);// e01.normalize();
  e12=CrossProduct(pt[1], pt[2]);// e12.normalize();
  e20=CrossProduct(pt[2], pt[0]);// e20.normalize();

  angle012=Angle(pt[0], pt[1], pt[2]);
  angle102=Angle(pt[1], pt[0], pt[2]);
  angle201=Angle(pt[2], pt[0], pt[1]);

  /*
          double suma=angle012+angle102+angle201;
   println("check sum angles:"+suma); // pi! 
   */
  double r=100;
  double a;

  // 6 trisectors lines

  angle10=Math.atan2(pt[1].y-pt[0].y, pt[1].x-pt[0].x);
  angle20=Math.atan2(pt[2].y-pt[0].y, pt[2].x-pt[0].x);
  a=min(angle10, angle20)+(1.0/3.0)*angle012;
  l01=CrossProduct(pt[0], pt[0].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));
  a=min(angle10, angle20)+(2.0/3.0)*angle012;
  l02=CrossProduct(pt[0], pt[0].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));


  angle01=Math.atan2(pt[0].y-pt[1].y, pt[0].x-pt[1].x);
  angle21=Math.atan2(pt[2].y-pt[1].y, pt[2].x-pt[1].x);
  a=min(angle01, angle21)+(1.0/3.0)*angle102;
  l10=CrossProduct(pt[1], pt[1].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));
  a=min(angle01, angle21)+(2.0/3.0)*angle102;
  l12=CrossProduct(pt[1], pt[1].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));


  angle02=Math.atan2(pt[0].y-pt[2].y, pt[0].x-pt[2].x);
  angle12=Math.atan2(pt[1].y-pt[2].y, pt[1].x-pt[2].x);
  a=min(angle02, angle12)+(1.0/3.0)*angle201;
  l20=CrossProduct(pt[2], pt[2].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));
  a=min(angle02, angle12)+(2.0/3.0)*angle201;
  l21=CrossProduct(pt[2], pt[2].plus(new HPoint2D(r*Math.cos(a), r*Math.sin(a))));

  q1=CrossProduct(l01, l12);
  q1.normalize();
  q2=CrossProduct(l10, l21);
  q2.normalize();
  q3=CrossProduct(l20, l02);
  q3.normalize();
}

void animate()
{
  int i;
  for (i=0; i<3; i++)
  {
    pt[i].x+=speedx[i];
    pt[i].y+=speedy[i];
    if  ((pt[i].x>W-offset)||(pt[i].x<offset)) speedx[i]=-speedx[i];
    if  ((pt[i].y>offset)||(pt[i].y<offset)) speedy[i]=-speedy[i];
  }

  Calculate();
}


double offset=30;
double maxx=W-offset;
double maxy=H-offset;
double minx=offset;
double miny=offset;

double min(double x, double y) {
  if (x<y) return x; 
  else return y;
}

double Angle(HPoint2D  pt0, HPoint2D  pt1, HPoint2D  pt2)
{
  double e1=pt0.Norm(pt1);
  double e2=pt0.Norm(pt2);
  double dot=(pt1.minus(pt0)).DotProduct(pt2.minus(pt0));
  return Math.acos(dot/(e1*e2));
}

double degree(double ang) {
  return (180/Math.PI)*ang;
}

void Initialize()
{ 
  pt=new HPoint2D[3];
  pt[0]=new HPoint2D(offset+(W-2*offset)*Math.random(), offset+(H-2*offset)*Math.random());
  pt[1]=new HPoint2D(offset+(W-2*offset)*Math.random(), offset+(H-2*offset)*Math.random());
  pt[2]=new HPoint2D(offset+(W-2*offset)*Math.random(), offset+(H-2*offset)*Math.random());

  speedx=new double[3];  
  speedy=new double[3];
  speedx[0]=Math.random();
  speedx[1]=Math.random();
  speedx[2]=Math.random();
  speedy[0]=Math.random();
  speedy[1]=Math.random();
  speedy[2]=Math.random();

  /*
          float alpha10=atan2(pt[0].x-pt[1].x,pt[0].y-pt[1].y);
   float alpha12=atan2(pt[2].x-pt[1].x,pt[2].y-pt[1].y);
   float alpha102l=(1.0/3.0)*alpha10+(2.0/3.0)*alpha12;
   
   HPoint2D pt102l=new HPoint2D(pt[1].x+100*cos(alpha102l),pt[1].y+100*sin(alpha102l));
   
   l10=CrossProduct(pt[1],pt102l);
   //l10.normalize();
   */


  Calculate();
}




void exportPDF()
{
  beginRecord(PDF, "MorleyTheorem-"+millis()+".pdf"); 
  draw();
  endRecord();
}

void setup()
{
  int i;
  size(512, 512);
  Initialize();
}

static float y(HPoint2D l, double x)
{
  return (float)((-l.x*x-l.w)/l.y);
}

void drawLine(HPoint2D l)
{
  line(0, y(l, 0), W, y(l, W));
}

void draw()
{ 
  int i, j;
  background(255);
  stroke(255, 0, 0);

  /*
  drawLine(e01);
   drawLine(e12); 
   drawLine(e20);
   */

  strokefill(0, 0, 0);
  strokefill(255, 0, 0);
  ellipse((float)pt[0].x, (float)pt[0].y, ptsize, ptsize);
  strokefill(0, 255, 0);
  ellipse((float)pt[1].x, (float)pt[1].y, ptsize, ptsize);
  strokefill(0, 0, 255);
  ellipse((float)pt[2].x, (float)pt[2].y, ptsize, ptsize);
  strokefill(0, 0, 0);


  line((float)pt[0].x, (float)pt[0].y, (float)pt[1].x, (float)pt[1].y); 
  line((float)pt[1].x, (float)pt[1].y, (float)pt[2].x, (float)pt[2].y); 
  line((float)pt[2].x, (float)pt[2].y, (float)pt[0].x, (float)pt[0].y); 


  stroke(255,0, 255);
  //l10.print();


  drawLine(l01); 
  drawLine(l02);

  drawLine(l10);
  drawLine(l12);

  drawLine(l20);
  drawLine(l21);


  stroke(0);


  strokefill(0, 0, 0);
  strokefill(255, 0, 0);
  ellipse((float)q1.x, (float)q1.y, ptsize, ptsize);
  strokefill(0, 255, 0);
  ellipse((float)q2.x, (float)q2.y, ptsize, ptsize);
  strokefill(0, 0, 255);
  ellipse((float)q3.x, (float)q3.y, ptsize, ptsize);
  strokefill(0, 0, 0);

  line((float)q1.x, (float)q1.y, (float)q2.x, (float)q2.y);
  line((float)q2.x, (float)q2.y, (float)q3.x, (float)q3.y);
  line((float)q3.x, (float)q3.y, (float)q1.x, (float)q1.y);

  if (anim) animate();
}

void strokefill(int r, int g, int b) {
  stroke(r, g, b); 
  fill(r, g, b);
}


HPoint2D CrossProduct(HPoint2D p1, HPoint2D p2)
{
  HPoint2D result=new HPoint2D();

  result.x=p1.y*p2.w-p1.w*p2.y;
  result.y=p1.w*p2.x-p1.x*p2.w;
  result.w=p1.x*p2.y-p1.y*p2.x;

  return result;
}


void keyPressed() {
  if  (key=='s') {

    Initialize();
  }

  if (key=='q') { 
    exit();
  }

  if (key=='p') { 
    exportPDF();
  }

  if (key==' ') { 
    Initialize();
    redraw();
  }

  if (key=='a') {
    anim=!anim;
  }
}
