// April 2020
// Frank.Nielsen@acm.org


import processing.pdf.*;

boolean display=true;

void strokefill(float r, float g, float b)
{stroke(r,g,b); fill(r,g,b);}

public   int n=3;
public   int d;
public   double rmin;
public   double rmax, r;
public   point[] set;
public   ball[] setb;
public   double precision=1.0e-3;

public   int iteration=0;
public   point [] projp;

public   double lambdar=0.5; // mid point of min max; 

double worldminx, worldmaxx;
double worldminy, worldmaxy;
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


void exportPDF()
{String name="BregmanProjection-"+millis()+".pdf";
 beginRecord(PDF, name); 
 draw();
 endRecord();
}


void keyPressed()
{
if (key=='p'){Project();}
if (key=='q'){exit();}
if (key==' '){Initialize();}
if (key=='.') {n*=2;Initialize();}
if (key==',') {n/=2;Initialize();}

 if (key=='x') {
  exportPDF();
  }
  
}

void drawBall(ball b)
{
  double theta, x1, y1, x2, y2, dtheta=0.01;
  int xx1, xx2, yy1, yy2;

//println("ball:"+b.center.coord[0]+" "+b.center.coord[1]+" rad:"+b.radius);
  strokefill(0,0,0);

  for (theta=0.0; theta<=2.0*Math.PI; theta+=dtheta)
  {
    x1=b.center.coord[0]+b.radius*Math.cos(theta);
    y1=b.center.coord[1]+b.radius*Math.sin(theta);
    x2=b.center.coord[0]+b.radius*Math.cos(theta+dtheta);
    y2=b.center.coord[1]+b.radius*Math.sin(theta+dtheta);

    xx1=xToX(x1);
    yy1=yToY(y1);
    xx2=xToX(x2);
    yy2=yToY(y2);

//println(xx1,yy1);
    line(xx1, yy1, xx2, yy2);
  }
}

//
// Main rendering procedure
//
void draw()
{
  background(255);
  int i;
  
  stroke(0);
  
  for (i=0; i<n; i++)
  {
    drawBall(setb[i]);
  }



  strokefill(0, 255, 0);
  for (i=0; i<=iteration-1; i++)
  {
    float xx1=xToX(projp[i].coord[0]);
    float yy1=yToY(projp[i].coord[1]);
    float xx2=xToX(projp[i+1].coord[0]);
    float yy2=yToY(projp[i+1].coord[1]);  
    line(xx1, yy1, xx2, yy2);
  }


  // Draw projected points
  strokefill(255, 0, 0); 
  for (i=0; i<= iteration; i++)
  {
    float xx=xToX( projp[i].coord[0]);
    float yy=yToY( projp[i].coord[1]);  
    rect(xx-1, yy-1, 3, 3);
  }


  // Draw last point bigger  
  float xx=xToX(projp[iteration].coord[0]);
  float  yy=yToY(projp[iteration].coord[1]);  
  rect(xx-3, yy-3, 9, 9);
}

int w, h;

void Initialize()
{
  int i, j;
  System.out.println("Bregman alternating projection");

 
/*
worldminx=-2;
worldmaxx=2;
worldminy=-2;
worldmaxy=2;
  */
  
  worldminx=-0.5;
  worldminy=-0.5;
  
worldmaxx=1.5;
worldmaxy=1.5;

  
   
  InitData();
}

void Project()
{
  double lambda, norm;  
  // Cyclic order
  int constraint=iteration%n;

  point pc=new point(d);
  projp[iteration+1]=new point(d);
  //
  // Display
  //
 if (display) System.out.println("Iteration "+(iteration+1)+" Constraint:"+constraint);


  /*
 // Uncomment below for setting the center as projected points
   projp[iteration+1]=setb[constraint].center;
   */


  //
  //inside/outside the constraint (ball)?
  //
  if (setb[constraint].Inside(projp[iteration]))
  {// Projected point does not change

    // Save for history
    for (int j=0; j<d; j++)
      projp[iteration+1].coord[j]=projp[iteration].coord[j];
  } else 
  {
    for (int j=0; j<d; j++)
      pc.coord[j]=projp[iteration].coord[j]-setb[constraint].center.coord[j];

    // Bregman (squared Euclidean) projection onto the boundary spheres
    norm=pc.Norm();
    lambda=setb[constraint].radius/norm;

    for (int j=0; j<d; j++)
      projp[iteration+1].coord[j]=setb[constraint].center.coord[j]+lambda*(projp[iteration].coord[j]-setb[constraint].center.coord[j]);
  }



  iteration++;

if (display){
  System.out.println("New projected point:");    
  for (int j=0; j<d; j++)
    System.out.print(projp[iteration].coord[j]+" ");
  System.out.println();}
  
}  

boolean DecisionProblem()
{
  int i, j, constraint, iter, inside;
  double lambda, norm;
  boolean convergence=false;

  /*
      System.out.println("Solve a decision problem...");
   point p=new point(setb[0].d);
   point pc=new point(setb[0].d);
   
   // Initialization (a seed, center of mass, etc.)
   for(j=0;j<d;j++)
   p.coord[j]=setb[0].coord[j];
   
   constraint=0;
   iter=0;
   inside=0;
   
   //
   // Relaxation method
   //
   while(iter<10*n)
   {
   
   //outside the constraint?
   if (!setb[constraint].Inside(p))
   {
   for(j=0;j<d;j++)
   pc.coord[j]=p.coord[j]-setb[constraint].coord[j];
   
   // Bregman (squared Euclidean) projection onto the boundary spheres
   norm=pc.Norm();
   lambda=setb[constraint].radius/norm;
   
   for(j=0;j<d;j++)
   p.coord[j]=pc.coord[j]*lambda;
   }
   else
   {
   inside++;
   }
   
   
   //System.out.println("Iteration "+iter+" Constraint "+constraint+" "+p.coord[0]+" "+p.coord[1]);
   
   // Cyclic order of constraint
   constraint++;
   if (constraint>=n) constraint=0;
   
   iter++;
   
   //
   // Convergence after all constraints fulfilled?
   //
   if (inside>n) {convergence=true; break;}
   }
   
   return convergence;
   */
  return true;
}



void setup()
{
 // size(800, 800);
  size(512,512);
  w=h=512;
  
  Initialize();
}

public   void InitRadius()
{

  r=lambdar*rmax;
 if (display) System.out.println("r="+r);

// Frank changed hee
  for (int i=0; i<n; i++)
  {
   // for intersection  setb[i]=new ball(set[i], r);
 
  setb[i]=new ball(set[i], r*1.2);
  //setb[i]=new ball(set[i], r*0.9);

}

}


public   void InitData()
{
  int i, j;

  // number of dimensions
  d=2;
  set=new point[n];
  setb=new ball[n];

  for (i=0; i<n; i++)
  {
    set[i]=new point(d);
    set[i].rand();
  }

  double distmax=0.0, dist;

 
  for (i=1; i<n; i++)
  {
    dist=set[0].Distance(set[i]);
    if (dist>distmax) distmax=dist;
  }

  rmax=distmax;
  rmin=rmax/2.0;

if (display){
  System.out.println("Radius min="+rmin);
  System.out.println("Radius max="+rmax);
}
  //
  // Prepare for solving a decision problem
  //
  
  InitRadius();


  //Initialization
  projp=new point[1000];

  //for(i=0;i<1000;i++) projp[i]=new point(d);
  projp[0]=new point(d);

  iteration=0;
  projp[iteration].rand();
}
