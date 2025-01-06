// (c) 2024 Frank Nielsen
// converted from the C/C++ code in 
// Nielsen, Frank. Visual computing: Geometry, graphics, and vision (graphics series). Charles River Media, Inc., 2005.
// https://en.wikipedia.org/wiki/Curvature


import processing.pdf.*;
float W = 800;
float H = 800;

boolean toggleAnimation=true; 

float r, curv;
PVector center, pleft, p, pright;

void setup() {
  size(800,800);
  center = new PVector();
  p = new PVector(0.5, (float)f(0.5));
  calculateCircle();
}

void draw() {
  background(255);
  
  // Draw curve
  stroke(0);
  noFill();
  beginShape();
  for (float x = 0; x < 1.0; x += 0.001) {
    double y = f(x);
    vertex((float)(x * W), (float)(H - y * H));
  }
  endShape();

  // Draw point on the curve
  fill(255, 0, 0);
  ellipse((float)(p.x * W), (float)(H - p.y * H), 10, 10);

  // Draw circle center
  fill(0, 255, 0);
  ellipse((float)(center.x * W), (float)(H - center.y * H), 10, 10);

  // Draw osculating circle
  noFill();
  
  stroke(0, 0, 255);
  ellipse((float)(center.x * W), (float)(H - center.y * H), r * 2 * W, r * 2 * H);


double curvexact=Curvature(p.x);
double err=Math.abs(curv-curvexact);
  // Display text
  stroke (0); fill( 0);
  textSize(16);
  text(String.format("Move the point with arrow keys (x=%.3f, y=%.3f)", p.x, p.y), 50, 20);
  text(String.format("Radius=%.3f Curvature=%.6f Exact:%.6f  Error:%.6f", r, curv,curvexact,err), 50, H - 20);
  
  if (toggleAnimation) animate();
}

 float inc = 0.01;
void animate()
{

    p.x += inc ;
   
  if (p.x > 1.0) inc=-inc;
  if (p.x < 0.0) inc=-inc;
  
  p.y = (float)f(p.x);
  calculateCircle();
}


void savepdffile()
{
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "OsculatingCircleCurvature-"+suffix+".pdf");


  draw();

  save("OsculatingCircleCurvature-"+suffix+".png");
  endRecord();
}


void keyPressed() {
  float inc = 0.01;
  if (key == CODED) {
    if (keyCode == RIGHT) { p.x += inc;calculateCircle();}
    if (keyCode == LEFT) {p.x -= inc;calculateCircle();}
  }
  
  if (key=='a') toggleAnimation=!toggleAnimation;
  
  
  if (key=='q') exit();
  
  
  if (key=='p'){}
  
  
  if (toggleAnimation){

  if (p.x > 1.0) p.x = 0;
  if (p.x < 0.0) p.x = 1.0;

  p.y =(float) f(p.x);
  calculateCircle();}
}

double sqr(double x){return x*x;}

double Curvature(double x)
{
  return fpp(x)/Math.pow(1+sqr(fp(x)),1.5);
}

/*
f(x):=5*((x-(1/2))**3)+(1/2);
derivative(f(x),x,1); ratsimp(%); fortran(%);
derivative(f(x),x,2); ratsimp(%); fortran(%);
*/

double f(double x) {
  return 5 * pow((float)(x - 0.5), 3.0) + 0.5;
}

double fp(double x) {
  return       (60*sqr(x)-60*x+15)/4;
}

double fpp(double x) {
  return       30*x-15;
}
 

void calculateCircle() {
  float inc = 0.01;
  pleft = new PVector((float)(p.x - inc),(float)( f(p.x - inc)));
  pright = new PVector((float)(p.x + inc),(float)( f(p.x + inc)));
  solveDisc3(pleft, p, pright);
  curv = 1.0 / r;
}

void solveDisc3(PVector p1, PVector p2, PVector p3 ) {
  float a = p2.x - p1.x;
  float b = p2.y - p1.y;
  float c = p3.x - p1.x;
  float d = p3.y - p1.y;
  float e = a * (p2.x + p1.x) * 0.5 + b * (p2.y + p1.y) * 0.5;
  float f = c * (p3.x + p1.x) * 0.5 + d * (p3.y + p1.y) * 0.5;
  float det = a * d - b * c;

  center.x = (d * e - b * f) / det;
  center.y = (-c * e + a * f) / det;
  r = PVector.dist(p1, center);
}
