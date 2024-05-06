// April 26 2024
// implements
// Nakamura, Yoshimasa. "Algorithms associated with arithmetic, geometric and harmonic means and integrable systems." Journal of computational and applied mathematics 131.1-2 (2001): 161-174.

float m=0, M=512;


double A(double x, double y)
{
  return (x+y)/2.0;
}

double G(double x, double y)
{
  return Math.sqrt(x*y);
}

double H(double x, double y)
{
  return 1/(A(1/x, 1/y));
}



double A(double alpha, double x, double y)
{
  return alpha*x+(1-alpha)*y;
}


double H(double alpha, double x, double y)
{
  return 1/(A(alpha, 1/x, 1/y));
}


double x1, y1, x2, y2;
double gx, gy;

void init()
{
  x1=M*Math.random();
  y1=M*Math.random();
  x2=M*Math.random();
  y2=M*Math.random();

  gx=G(x1, x2);
  gy=G(y1, y2);
}

void setup()
{
  size(512, 512);
  init();
}

void strokefill(int r, int g, int b) {
  stroke(r, g, b);
  fill(r, g, b);
}

void drawAgeodesic(double xx1, double yy1, double xx2, double yy2)
{
  line((float)xx1, (float)yy1, (float)xx2, (float)yy2);
}


void drawHgeodesic(double xx1, double yy1, double xx2, double yy2)
{
  double xx, yy, xxt, yyt;
  double alpha, dalpha=0.05;

  for (alpha=0; alpha<1; alpha+=dalpha)
  {
    xx=H(alpha, x1, x2);
    yy=H(alpha, y1, y2);
    xxt=H(alpha+dalpha, x1, x2);
    yyt=H(alpha+dalpha, y1, y2);
    line((float)xx, (float)yy, (float)xxt, (float)yyt);
  }
}


void draw()
{
  int i;
  double px1, px2, py1, py2;
  double npx1, npx2, npy1, npy2;

  background(255);


  px1=x1;
  py1=y1;
  
  px2=x2;
  py2=y2;

  for (i=0; i<5; i++)
  {
    strokefill(255, 0, 0);
    ellipse((float)px1, (float)py1, 5, 5);
    drawAgeodesic(px1, py1, px2, py2);
    
    strokefill(0, 0, 255);
    ellipse((float)px2, (float)py2, 5, 5);
    drawHgeodesic(px1, py1, px2, py2);

// AHM mean converges to AGM mean
    npx1=A(px1, px2);
    npx2=H(px1, px2);
    
    npy1=A(py1, py2);
    npy2=H(py1, py2);

    px1=npx1;
    py1=npy1;
    
    px2=npx2;
    py2=npy2;
  }
  
  double err=Math.abs(gx-px1);

System.out.println(i+" iterations: Geometric mean: "+gx+" AHM mean:"+px1+"  error:"+err);

  strokefill(0, 255, 0);
  ellipse((float)gx, (float)gy, 5, 5);
}

void keyPressed()
{
  if (key=='q') exit();
  if (key==' ') {
    System.out.println("new data set");
    init();
    draw();
  }
}
