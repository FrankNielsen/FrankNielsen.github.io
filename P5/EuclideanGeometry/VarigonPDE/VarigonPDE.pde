// April 1st, 2020
// (C) Frank.Nielsen@acm.org
// https://mathworld.wolfram.com/VarignonsTheorem.html
//  midpoints of the sides of a convex quadrilateral form a parallelogram.
int side =512;
float ptsize=6;
BB bb=new BB(0, 1, 0, 1, side, side);

double  []a=new double [2];
double  []b=new double [2];
double  []c=new double [2];
double  []d=new double [2];

double speed=0.01;
double  []va=new double [2];
double  []vb=new double [2];
double  []vc=new double [2];
double  []vd=new double [2];


double  []ab=new double [2];
double  []bc=new double [2];
double  []cd=new double [2];
double  []da=new double [2];

boolean animate=true;

void Initialize()
{
  a[0]=Math.random(); 
  a[1]=Math.random(); 
  b[0]=Math.random(); 
  b[1]=Math.random(); 
  c[0]=Math.random(); 
  c[1]=Math.random(); 
  d[0]=Math.random(); 
  d[1]=Math.random(); 

  va[0]=Math.random(); 
  va[1]=Math.random(); 
  vb[0]=Math.random(); 
  vb[1]=Math.random(); 
  vc[0]=Math.random(); 
  vc[1]=Math.random(); 
  vd[0]=Math.random(); 
  vd[1]=Math.random();
}

void Parallelogram()
{

  ab[0]=0.5*(a[0]+b[0]); 
  ab[1]=0.5*(a[1]+b[1]);
  bc[0]=0.5*(b[0]+c[0]); 
  bc[1]=0.5*(b[1]+c[1]);
  cd[0]=0.5*(c[0]+d[0]); 
  cd[1]=0.5*(c[1]+d[1]);
  da[0]=0.5*(d[0]+a[0]); 
  da[1]=0.5*(d[1]+a[1]);
}

void setup()
{
  size(512, 512);
  Initialize();
}

void drawPoint(double [] p)
{
  ellipse(bb.x2X(p[0]), bb.y2Y(p[1]), ptsize, ptsize);
}

void drawLine(double [] p, double [] q)
{
  line(bb.x2X(p[0]), bb.y2Y(p[1]), bb.x2X(q[0]), bb.y2Y(q[1]));
}


void draw()
{
  background(255);

  stroke(0, 0, 0);
  fill(0, 0, 0);

 // println(a[0]+" "+bb.x2X(a[0])+" "+bb.y2Y(a[1]));

  ellipse(bb.x2X(a[0]), bb.y2Y(a[1]), ptsize, ptsize);
  ellipse(bb.x2X(b[0]), bb.y2Y(b[1]), ptsize, ptsize);
  ellipse(bb.x2X(c[0]), bb.y2Y(c[1]), ptsize, ptsize);
  ellipse(bb.x2X(d[0]), bb.y2Y(d[1]), ptsize, ptsize);


  line(bb.x2X(a[0]), bb.y2Y(a[1]), bb.x2X(b[0]), bb.y2Y(b[1]));
  line(bb.x2X(b[0]), bb.y2Y(b[1]), bb.x2X(c[0]), bb.y2Y(c[1]));
  line(bb.x2X(c[0]), bb.y2Y(c[1]), bb.x2X(d[0]), bb.y2Y(d[1]));
  line(bb.x2X(d[0]), bb.y2Y(d[1]), bb.x2X(a[0]), bb.y2Y(a[1]));

  Parallelogram();

  stroke(255, 0, 0); 
  fill(255, 0, 0);
  drawPoint(ab);
  drawPoint(bc);
  drawPoint(cd);
  drawPoint(da);

  drawLine(ab, bc);
  drawLine(bc, cd);
  drawLine(cd, da);
  drawLine(da, ab);
  
 // stroke(0,0,255);
  drawLine(ab, cd);
  drawLine(da, bc);
  

  if (animate) { 
    a[0]+=speed*va[0];
    a[1]+=speed*va[1];
    if ((a[0]>1)||(a[0]<0)) va[0]=-va[0];
    if ((a[1]>1)||(a[1]<0)) va[1]=-va[1];
    
    b[0]+=speed*vb[0];
    b[1]+=speed*vb[1];
    if ((b[0]>1)||(b[0]<0)) vb[0]=-vb[0];
    if ((b[1]>1)||(b[1]<0)) vb[1]=-vb[1];
    
    
    c[0]+=speed*vc[0];
    c[1]+=speed*vc[1];
    if ((c[0]>1)||(c[0]<0)) vc[0]=-vc[0];
    if ((c[1]>1)||(c[1]<0)) vc[1]=-vc[1];
    
    
    d[0]+=speed*vd[0];
    d[1]+=speed*vd[1];
    if ((d[0]>1)||(d[0]<0)) vd[0]=-vd[0];
    if ((d[1]>1)||(d[1]<0)) vd[1]=-vd[1];
    
  }

  // https://en.wikipedia.org/wiki/Varignon%27s_theorem
}

void keyPressed()
{
  
  if (key=='a') {animate=!animate;}
  if (key==' ') {
    Initialize();
    draw();
  }
}
