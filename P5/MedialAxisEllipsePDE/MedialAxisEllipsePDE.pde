// Frank.Nielsen@acm.org
// 8th Sept. 2021
// The medial axis of an object is the set of all points having 
// more than one closest point on the object's boundary. 

// The medial axis of an object is the locii of centers of disks that touch the object boundary in at least two points.

import processing.pdf.*;

boolean toggleAnimation=true;

double cx, cy;
double f1x, f1y, f2x, f2y;
double  a;
double  b;
double c;
double  theta;
double t;
double dt=0.01;
double ra;
double rb;

double angletouch;

int nb=1000;

int W=800;
int H=W;

double touchx1, touchy1, touchx2, touchy2;

double minEllipse(double cx, double cy, double a, double b, double theta, double x, double y, int nb)
{
  int i;
  double px,py;
  double dist, mdist=1.e8;

  for (i=0; i<nb; i++)
  {
    double angle=2.0*Math.PI*i/(double) nb;
      px =cx+a*Math.cos(angle)*Math.cos(theta)-b*Math.sin(angle)*Math.sin(theta);
      py=cy+b*Math.sin(angle)*Math.cos(theta)+a*Math.cos(angle)*Math.sin(theta);
   // ellipse((float)px, (float)py, 3, 3);
   dist=(px-x)*(px-x)+(py-y)*(py-y);
   
   if (dist<mdist) {mdist=dist;angletouch=angle;
   touchx1=px;
 }
  }
  
  double rad=Math.sqrt(mdist);
  
  double alpha=Math.acos(touchx1/(x+rad));
  
 touchx1=cx+a*Math.cos(angletouch)*Math.cos(theta)-b*Math.sin(angletouch)*Math.sin(theta);
 touchy1=cy+b*Math.sin(angletouch)*Math.cos(theta)+a*Math.cos(angletouch)*Math.sin(theta);
 
 //touchx2=x+rad*Math.cos(-theta+alpha);
 //touchy2=y+rad*Math.sin(-theta+alpha);
 
 return rad;
}


void drawEllipse(double cx, double cy, double a, double b, double theta, int nb)
{
  int i;
  double px,py;

  for (i=0; i<nb; i++)
  {
    double angle=2.0*Math.PI*i/(double) nb;
      px = cx+a*Math.cos(angle)*Math.cos(theta)-b*Math.sin(angle)*Math.sin(theta);
      py=cy+b*Math.sin(angle)*Math.cos(theta)+a*Math.cos(angle)*Math.sin(theta);
    ellipse((float)px, (float)py, 3, 3);
  }
  
  /*
  px=cx+c*Math.cos(theta);py=cy+c*Math.sin(theta);
  ellipse((float)px, (float)py, 5, 5);
  px=cx-c*Math.cos(theta);py=cy-c*Math.sin(theta);
  ellipse((float)px, (float)py, 5, 5);
  */
   ellipse((float)f1x, (float)f1y, 5, 5);
   ellipse((float)f2x, (float)f2y, 5, 5);
}


void drawCircle(double cx, double cy, double r, int nb)
{
  int i;
  double px,py;
   double px2,py2;
   double dangle=2.0*Math.PI/(double) nb;

  for (i=0; i<nb; i++)
  {
    double angle=2.0*Math.PI*i/(double) nb;
      px = cx+r*Math.cos(angle);
      py=cy+r*Math.sin(angle);
      px2 = cx+r*Math.cos(angle+dangle);
      py2=cy+r*Math.sin(angle+dangle);
      
      
   // ellipse((float)px, (float)py, 3, 3);
   line((float)px, (float)py, (float)px2, (float)py2);
  }
  
 
}

void Initialize()
{
  int i;


  cx=W/3+W/3*Math.random();
  cy=H/3+H/3*Math.random();

  a=10+Math.random()*150;
  b=10+Math.random()*150;
  
  //b=a; //circle
  
  if (a<b) {double tmp; tmp=a;a=b;b=tmp;}
  c=Math.sqrt(a*a-b*b);
  
  theta=Math.random()*2.0*Math.PI;
  
  
  f1x=cx+c*Math.cos(theta);
  f1y=cy+c*Math.sin(theta);  
  f2x=cx-c*Math.cos(theta);
  f2y=cy-c*Math.sin(theta); 
  
  ra=a-c;
   
}

void settings() {
  size(W,H);
}

void setup()
{
  int i;
  //size(W,H);
  Initialize();
}

void draw()
{
  int i;
  background(255);
  stroke(0);
  noFill();


  push();
  translate((float)cx, (float)cy);
  push();
  rotate((float)theta);
  ellipse(0, 0, (float)(2.0*a), (float)(2.0*b));
  pop();

  pop();


  //drawEllipse(cx, cy, a, b, theta, 100);
  
  stroke(0,0,255);
  line((float)f1x,(float)f1y,(float)f2x,(float)f2y);
  
  stroke(0,255,0);
   ellipse((float)f1x, (float)f1y, 5, 5);
   ellipse((float)f2x, (float)f2y, 5, 5);
  
  stroke(255,0,0);
  double xx=t*f1x+(1-t)*f2x;
   double yy=t*f1y+(1-t)*f2y;
   ellipse((float)xx,(float)yy,5,5);
   
   //double u=0.5-Math.abs(t-0.5);
   //double rr=(1-u)*ra+u*b;
   
   double rr=minEllipse(cx,  cy,  a, b,  theta,xx, yy,  nb);
   
  // double rr=ra;
   
   drawCircle(xx,yy,rr,100);
   
   /*
   double px,py;
   stroke(255,0,255);
    px = cx+a*Math.cos(angletouch)*Math.cos(theta)-b*Math.sin(angletouch)*Math.sin(theta);
      py=cy+b*Math.sin(angletouch)*Math.cos(theta)+a*Math.cos(angletouch)*Math.sin(theta);
      ellipse((float)px,(float)yy,5,5);
     */  
      stroke(255,0,255);
      ellipse((float)touchx1,(float)touchy1,5,5);
       ellipse((float)touchx2,(float)touchy2,5,5);
     
      
  if (toggleAnimation) update();
}

void update()
{
 t=t+dt;if ((t>1)||(t<0)) dt=-dt;  
}



void keyPressed() {
if (key=='a') toggleAnimation=!toggleAnimation;

  if (key=='p') {
    exportPDF();
  }


  if (key==' ') {
    Initialize();
  }

  if (key=='q') {
    exit();
  }
}

void exportPDF()
{
  beginRecord(PDF, "EllipseMedialAxis.pdf"); 
  draw();
  endRecord();
}
