// Frank.Nielsen@acm.org
// April 2020  (update from old Applet to processing.org)
// Exact Bregman balls

import processing.pdf.*;

int side=512;
int W=side,H=side;
int w=side,h=side;
int n=24;
int maxcard=n;

//boolean anim=false;
boolean anim=true;

double clearance=0.5;


double worldminx=-0.5;
double worldmaxx=1.5;
double worldminy=-0.5;
double worldmaxy=1.5;
BregmanDivergence DF=new L22();
 String name="Squared Euclidean divergence";


/*
double worldminx=0.0;
double worldmaxx=2.5;
double worldminy=worldminx;
double worldmaxy=worldmaxx;
BregmanDivergence DF=new KullbackLeibler();
  String name="Extended Kullback-Leibler divergence";
  */  
    
    /*
      double worldminx=0.0;
      double worldmaxx=4.0;
      double worldminy=0.0;
      double worldmaxy=4.0;
 BregmanDivergence   DF=new ItakuraSaito();
  String name="Itakura-Saito divergence";
 */
 
 /*
double worldminx=0.0;
double worldmaxx=1.5;
double worldminy=0.0;
double worldmaxy=1.5;
BregmanDivergence DF=new LogisticLoss();
 String name="Logistic loss";
    */
    
PointSet dataset= new PointSet(maxcard,DF);


Point [] speed; // speed vector
 

//
// Center point, maximum radius
//
Point center;
double radius;

MiniBregmanBall mini;
BregmanDisk BD=null;


//
// Compute the maximal divergence to a point set
//
double MaxDivergence(Point p)
{
int i;
double div,maxdiv=0.0;

for(i=0;i<dataset.n;i++)
  {
    div=DF.divergence(p,dataset.array[i]);
    if (div>maxdiv) {maxdiv=div;}
  }

return maxdiv;
}


//
// Interpolation for the geodesic: draw path [pq]  
//
public Point BBCPoint(double alpha, Point p, Point q)
{
Point gradfp,gradc;
Point cc=new Point();

gradfp=DF.gradF(q);
gradfp.MultCste(1.0-alpha);

gradc=DF.gradF(p);
gradc.MultCste(alpha);

gradc.AddPoint(gradfp);

cc=DF.gradFinv(gradc);

return cc;
}


void Initialize()
{
 dataset=new PointSet(maxcard, DF);
   mini=new MiniBregmanBall(dataset, DF);
    BD=mini.bdisk;
    
    speed=new Point[n];
     
    
    int i;
    double scale=0.005;
    
    for(i=0;i<n;i++)
  { 
  speed[i]=new Point(scale*Math.random(),scale*Math.random());
 

}

}



//
// Convert point set coordinates to screen display coordinates
//
int xToX(double x)
{
return (int)Math.rint(w*(x-worldminx)/(worldmaxx-worldminx));
}

int yToY(double y)
{
return h-(int)Math.rint(h*(y-worldminy)/(worldmaxy-worldminy));
}


//
// Convert screen display coordinates to point set coordinates
//
double Xtox(int X)
{
return worldminx+((double)X/(double)w)*(worldmaxx-worldminx);
}

double Ytoy(int Y)
{
return worldminy+((double)(h-Y)/(double)h)*(worldmaxy-worldminy);
}

//
// Draw a geodesic 
//
public void drawGeodesic(Point source, Point dest)
{
int i;
int xx1,yy1;
int xx2,yy2;
int nbsteps=10;

double alpha;
double increment=1.0/(double)nbsteps;


for(i=0;i<nbsteps;i++)
  {
  alpha=(double)i/(double)nbsteps;
  Point p=BBCPoint(alpha, source, dest);
  Point pp=BBCPoint(alpha+increment, source, dest);

  xx1=xToX(p.x);
  yy1=yToY(p.y);
  xx2=xToX(pp.x);
  yy2=yToY(pp.y);

line(xx1,yy1,xx2,yy2);  
}

}
// end of geodesic




public void drawBregmanBall()
{
int i,j;
Point p=new Point();

//stroke(255,0,0);
stroke(240,249,159);

for(i=0;i<h;i++)
{
  p.y=Ytoy(i);
  
  for(j=0;j<w;j++)
  {
  p.x=Xtox(j);
   if (DF.divergence(center,p)<radius) rect(j,i, 1, 1);
  }
}

}

public void drawBregmanBall( BregmanDisk bd)
{
int i,j;
Point p=new Point();

 

for(i=0;i<h;i++)
{
  p.y=Ytoy(i);
  
  for(j=0;j<w;j++)
  {
  p.x=Xtox(j);
  if (DF.divergence(bd.center,p)<bd.rad) rect(j,i, 1, 1);
  }
}

}

//
// Draw the line associated to the homogeneous point 
//
void DrawLineProjectivePoint(PPoint p)
{
double x1,fx1,x2,fx2;
int xx1,yy1,xx2,yy2;

if (p.w!=0.0){
  

x1=worldminx;
fx1=(-p.w-p.x*x1)/p.y;

x2=worldmaxx;
fx2=(-p.w-p.x*x2)/p.y;

xx1=xToX(x1);
yy1=yToY(fx1);
xx2=xToX(x2);
yy2=yToY(fx2);

line(xx1,yy1,xx2,yy2);  

}

}


 void DrawPoint(Point p, int pwidth)
{
int xx,yy;
  
xx=xToX(p.x);
yy=yToY(p.y);

rect(xx-pwidth/2, yy-pwidth/2, pwidth, pwidth);
}


void setup()
{
size(800,800);  
Initialize();
}

void strokefill(float r, float g, float b)
{
stroke(r,g,b); fill(r,g,b);}

void draw()
{int i;
  background(255);
  
 if (BD!=null){ strokefill(240,249,159);
  drawBregmanBall(BD);
 }
  strokefill(0,0,0);
  
  for(i=0;i<dataset.n;i++)
  {
  DrawPoint(dataset.array[i],3);
  }
  
  
  
  if (BD.basis.n==3)
{
DrawLineProjectivePoint(mini.b12);
DrawLineProjectivePoint(mini.b13);
DrawLineProjectivePoint(mini.b23);


strokefill(0,255,0);
drawGeodesic(BD.basis.array[0],BD.basis.array[1]);
drawGeodesic(BD.basis.array[1],BD.basis.array[2]);
drawGeodesic(BD.basis.array[0],BD.basis.array[2]);

strokefill(255,0,0);
DrawPoint(BD.basis.array[0],7);
DrawPoint(BD.basis.array[1],7);
DrawPoint(BD.basis.array[2],7);

}

if (BD.basis.n==2)
{
PPoint l12=DF.BregmanBisector(BD.basis.array[0],BD.basis.array[1]);  
DrawLineProjectivePoint(l12);

strokefill(0,255,0);
drawGeodesic(BD.basis.array[0],BD.basis.array[1]);
strokefill(255,0,0);
DrawPoint(BD.basis.array[0],7);
DrawPoint(BD.basis.array[1],7);
}

strokefill(0,0,255);
DrawPoint(BD.center,9); 


strokefill(0,0,0);
textSize(24);
text("Bregman divergence: "+name, 10, 30); 

if (anim) animate();
}


void animate()
{int i;
 
for(i=0;i<n;i++)
  { 
  dataset.array[i]=new Point(dataset.array[i].x+speed[i].x,dataset.array[i].y+speed[i].y);
  

 if (dataset.array[i].x>worldmaxx-clearance) speed[i]=new Point(-speed[i].x,speed[i].y);
 if (dataset.array[i].y>worldmaxy-clearance) speed[i]=new Point(speed[i].x,-speed[i].y);
  if (dataset.array[i].x<worldminx+clearance) speed[i]=new Point(-speed[i].x,speed[i].y);;
 if (dataset.array[i].y<worldminy+clearance) speed[i]=new Point(speed[i].x,-speed[i].y);

}
 mini=new MiniBregmanBall(dataset, DF);
    BD=mini.bdisk;
}

void keyPressed()
{
 if (key==' ') {Initialize();} 
  if (key=='q') {exit();}
  
   if (key=='a') {
 anim=!anim;
  }
  
  
  if (key=='e')
{
 worldminx=-0.5;
 worldmaxx=1.5;
 worldminy=-0.5;
worldmaxy=1.5;
 DF=new L22();
 name="Squared Euclidean divergence";
 Initialize();
}


 if (key=='k'){

 worldminx=0.0;
 worldmaxx=2.5;
 worldminy=worldminx;
 worldmaxy=worldmaxx;
 DF=new KullbackLeibler();
 name="Extended Kullback-Leibler divergence";
  Initialize();
 } 
    
if (key=='i')
{
  worldminx=0.0;
   worldmaxx=4.0;
  worldminy=0.0;
 worldmaxy=4.0;
   DF=new ItakuraSaito();
 name="Itakura-Saito divergence";
  Initialize();
}
 
 if (key=='l'){
 worldminx=0.0;
 worldmaxx=1.5;
 worldminy=0.0;
 worldmaxy=1.5;
 DF=new LogisticLoss();
 name="Logistic loss";
  Initialize();
 }
 

}
