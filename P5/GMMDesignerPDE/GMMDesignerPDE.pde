// Frank.Nielsen@acm.org
// October 2023
// https://math.stackexchange.com/questions/159095/how-to-derive-ellipse-matrix-for-general-ellipse-in-homogenous-coordinates
// https://www.johndcook.com/blog/2023/06/19/conic-through-five-points/

import processing.pdf.*;
import Jama.*;

int side=800;
double  minx=-1, maxx=1, miny=-1, maxy=1;

BB bb=new BB(minx, maxx, miny, maxy, side, side);

Ellipse ell;
boolean toggleEll=true;

class Ellipse{
 double a,b,c,d,e,f;
 double tolerance=1.0e-3;
 
 public String toString(){return a+"x**2+"+b+"y**2+"+c+"xy+"+d+"x+"+e+"y+"+f+"=0";
 }
 
public double evaluate(double x, double y)
 {return a*x*x+b*y*y+c*x*y+d*x+e*y+f;}
 
 public Matrix HomogeneousMatrix()
 {
  Matrix res=new Matrix(3,3);
  //matrix([a,c/2,d/2],[c/2,b,e/2],[d/2,e/2,f]);
  
  res.set(0,0,a);res.set(0,1,c/2.0);res.set(0,2,d/2.0);
  res.set(1,0,c/2.0);res.set(1,1,b);res.set(1,2,e/2.0);
  res.set(2,0,d/2.0);res.set(2,1,e/2.0);res.set(2,2,f);
  
  return  res;
 }
 
  boolean PointOnEllipse(double x, double y) 
 {Matrix v;
  v=new Matrix(3,1);
  // homogeneous vector
  v.set(0,0,x);v.set(1,0,y);v.set(2,0,1.0);
  
  double eq=(v.transpose().times(HomogeneousMatrix()).times(v)).get(0,0);
  println(eq+" "+evaluate(x,y));
  
  if (Math.abs(eq)<tolerance) return true; else return false;
 }
 
 
 public double evaluatey1(double x)
 {
  double aa,bb,cc,delta;
  aa=b;bb=c*x+e;cc=d*x+f-a*x*x;
  delta=bb*bb-4*aa*cc;
  if (delta>0) return (-bb-Math.sqrt(delta))/(2.0*aa); else return Double.NaN;
 }
 
 
  public double evaluatey2(double x)
 {
  double aa,bb,cc,delta;
  aa=b;bb=c*x+e;cc=d*x+f-a*x*x;
  delta=bb*bb-4*aa*cc;
  if (delta>0) return (-bb+Math.sqrt(delta))/(2.0*aa); else return Double.NaN;
 }
 
 void solve(double [] x , double []y)
 {
  Matrix A=new Matrix (5,5);
  Matrix bv=new Matrix(5,1);
  int i;
  for(i=0;i<5;i++)
  {A.set(i,0,y[i]*y[i]); A.set(i,1,x[i]*y[i]); A.set(i,2,x[i]); A.set(i,3,y[i]);A.set(i,4,1.0);
  bv.set(i,0,x[i]*x[i]);
  }
  
  Matrix sol=A.inverse().times(bv);
  a=1.0;  
  b=sol.get(0,0);
  c=sol.get(1,0);
  d=sol.get(2,0);
  e=sol.get(3,0);
  f=sol.get(4,0);
  
  print(this);
  
 }
  
}


void MyEllipse(Matrix m, Matrix Sigma)
{
  int nbpoints=1000, i;
  double x1, y1, theta1;
  double x2, y2, theta2;
  Matrix v1, v2;
  v1=new Matrix(2, 1);
  v2=new Matrix(2, 1);

  CholeskyDecomposition CD=new CholeskyDecomposition(Sigma);
  Matrix M=CD.getL().transpose();

//Matrix M=Sigma;

double scale=0.2;

  for (i=0; i<nbpoints; i++)
  {
    theta1=Math.PI*2.0*i/(double)nbpoints;
    theta2=Math.PI*2.0*(i+1)/(double)nbpoints;
    x1=scale*Math.cos(theta1);
    y1=scale*Math.sin(theta1);
    x2=scale*Math.cos(theta2);
    y2=scale*Math.sin(theta2);
    v1.set(0, 0, x1);
    v1.set(1, 0, y1);
    v2.set(0, 0, x2);
    v2.set(1, 0, y2);
    v1=M.times(v1);
    v2=M.times(v2);
    x1=m.get(0, 0)+v1.get(0, 0);
    y1=m.get(1, 0)+v1.get(1, 0);
    x2=m.get(0, 0)+v2.get(0, 0);
    y2=m.get(1, 0)+v2.get(1, 0);
    MyLine(x1, y1, x2, y2);
  }
}
void MyLine(double x1, double y1, double x2, double y2)
{

  line((float)bb.x2X(x1), (float)bb.y2Y(y1), (float)bb.x2X(x2), (float)bb.y2Y(y2)) ;
}


void MyLine(Matrix v1, Matrix v2)
{

  line((float)bb.x2X(v1.get(0,0)), (float)bb.y2Y(v1.get(1,0)), 
  (float)bb.x2X(v2.get(0,0)), (float)bb.y2Y(v2.get(1,0))) ;
}


int n=0;
double [] xarray;
double [] yarray;

void init(){
xarray=new double[5];
yarray=new double[5];
ell=null;
}

void setup()
{
  size(800, 800);
  init();
  background(255, 255, 255);
}

void draw()
{int i;
background(255, 255, 255);
stroke(200);

if (toggleEll) {drawEllipse(ell);}

stroke(255,0,0);
for(i=0;i<n;i++)
{
line(bb.x2X(xarray[i])-5,bb.y2Y(yarray[i]),bb.x2X(xarray[i])+5,bb.y2Y(yarray[i]));
line(bb.x2X(xarray[i]) ,bb.y2Y(yarray[i])-5,bb.x2X(xarray[i]),bb.y2Y(yarray[i])+5);
}



}



void drawEllipse(Ellipse ell)
{
int i,j;
double xx,yy,xxn,yyn;
if (ell==null) return;
int step=5;

for(i=0;i<side;i+=step)
{
xx=bb.X2x(i); xxn=bb.X2x(i+step);

yy=ell.evaluatey1(xx);
yyn=ell.evaluatey1(xxn);
line(i,bb.y2Y(yy),i+step,bb.y2Y(yyn));

yy=ell.evaluatey2(xx);
yyn=ell.evaluatey2(xxn);
line(i,bb.y2Y(yy),i+step,bb.y2Y(yyn));
}

}


void drawEllipsetry(Ellipse ell)
{
int i,j;
double xx,yy;
if (ell==null) return;


for(i=0;i<side;i++)
for(j=0;j<side;j++)
{
xx=bb.X2x(i);yy=bb.Y2y(j);

if (  ell.evaluate(xx,yy)<1  ) ellipse(i,j,1,1);

}


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
  // ellipse((float)f1x, (float)f1y, 5, 5);
  // ellipse((float)f2x, (float)f2y, 5, 5);
}


void mousePressed() {
if (n<5){xarray[n]=bb.X2x(mouseX);
yarray[n]=bb.Y2y(mouseY);
println("mouse :"+n+"\t"+xarray[n]+" "+yarray[n]);}
if (n<5) n++; else n=0;
}

void savePDF()
{
String ss=""+millis();
  
  
   beginRecord(PDF, "5pointsEllipse-"+ss+".pdf");
  draw();
  endRecord();
  
 
}


void keyPressed()
{if (key=='e') {toggleEll=!toggleEll;}
  if (key==' '){ell=new Ellipse(); ell.solve(xarray,yarray);
int i;
for(i=0;i<n;i++) println(ell.PointOnEllipse(xarray[i],yarray[i]));
}
  
  if (key=='p'){savePDF();}
  
}
