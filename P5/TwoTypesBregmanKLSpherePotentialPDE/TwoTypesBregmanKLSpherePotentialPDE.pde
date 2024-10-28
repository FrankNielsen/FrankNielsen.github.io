// Frank.Nielsen@acm.org
// October 2024
// KL

// Extending Hausdorff Distances to Asymmetric Geometries, page 64
import processing.pdf.*;

double WNeg1(double x)
{
  return LambertW.branchNeg1(x);
}

void savepdffile()
{
  int s=0;
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "BregmanKLSpherePotential-"+suffix+".pdf");


  draw();

  save("BregmanKLSpherePotential-"+suffix+".png");
  endRecord();
}


boolean toggleAnimation=false;

boolean toggleLeftBregmanSphere=true;
boolean toggleRightBregmanSphere=true;

boolean toggleRight=true;
boolean toggleLeft=true;
boolean toggleSym=true;

boolean toggleTangentCenter=true;

BB bb;
int ww=800, hh=800;
int step=4;

int n;
double [] set;

double deltay=3;



double center, radius;

static double W(double x)
{
  return LambertW.branch0(x);
}


// Shannon negentropy
double F(double theta) {
  return theta*Math.log(theta)-theta;
}

double gradF(double theta) {
  return  Math.log(theta);
}




double xmin=-1, xmax=6;
double ymin, ymax;

double right1, right2, left1, left2, sym1, sym2;


double GeometricMean(double p1, double p2) {
  return Math.sqrt(p1*p2);
}


double speed=0.01;

void animate()
{
  center=center+speed;
  
 if ((right1>bb.maxx)||(right2>bb.maxx)) {speed=0;}
 
 if ((left1<0.05 )||(left2<0.05))  {speed=0;}
 
   left1=-center*W0(-Math.exp(-radius/center-1));
  right1=-center*WNeg1(-Math.exp(-radius/center-1));

 

  right2=(radius-center)/W0((radius-center)*Math.exp(-1-Math.log(center)));
  left2=(radius-center)/WNeg1((radius-center)*Math.exp(-1-Math.log(center)));

 
}

// Lambert W principal branch
double W0(double x)
{
  return LambertW.branch0(x);
}

void init()
{

  center=1+Math.random();
  radius=0.4+Math.random();

  // left ball KL(center:x)=r
  left1=-center*W0(-Math.exp(-radius/center-1));
  right1=-center*WNeg1(-Math.exp(-radius/center-1));


  // right ball KL(x:center)=r
 

  right2=(radius-center)/W0((radius-center)*Math.exp(-1-Math.log(center)));
  left2=(radius-center)/WNeg1((radius-center)*Math.exp(-1-Math.log(center)));

  ymin=-deltay;
  ymax=F(xmax)+deltay;

  bb=new BB(xmin, xmax, ymin, ymax, ww, hh); //
}

void setup()
{
  size(800, 800);
  init();
}

float ptsize=3;

double y0right=-0.05;//;

//
// main drawing procedure
//
void draw()
{
  background(255);
  int i;
  double y, ny;
  Line  tangentLeft, tangentRight;
  double xx, stepxx=0.01;

// draw axis
  stroke(128);
  line(bb.x2X(xmin), bb.y2Y(0), bb.x2X(xmax), bb.y2Y(0));
  line(bb.x2X(0), bb.y2Y(ymin), bb.x2X(0), bb.y2Y(ymax));


  strokeWeight(3);
  stroke(0);
  // draw Potential function

  for (i=0; i<ww-step; i+=step)
  {
    y=F(bb.X2x(i));
    ny=F(bb.X2x(i+step));

    line((float)i, (float)bb.y2Y(y), (float)(i+step), (float)bb.y2Y(ny));
  }

  strokeWeight(1);
  
if (toggleLeftBregmanSphere) {

   // strokeWeight(3);
    stroke(255, 0, 0);
    fill(255, 0, 0);
    line(bb.x2X(left1), bb.y2Y(0), bb.x2X(right1), bb.y2Y(0) );
    ellipse(bb.x2X(center), bb.y2Y(0), ptsize, ptsize);
    ellipse(bb.x2X(left1), bb.y2Y(0), ptsize, ptsize);
    ellipse(bb.x2X(right1), bb.y2Y(0), ptsize, ptsize);


    stroke(0, 0, 0);
    strokeWeight(1);
    
    
    line(bb.x2X(center), bb.y2Y(0),bb.x2X(center), bb.y2Y(F(center)));
    line(bb.x2X(left1), bb.y2Y(0),bb.x2X(left1), bb.y2Y(F(left1)));
    line(bb.x2X(right1), bb.y2Y(0),bb.x2X(right1), bb.y2Y(F(right1)));
    

    ellipse(bb.x2X(center), bb.y2Y(F(center)-radius ), ptsize, ptsize);



    tangentLeft=new Line(center, F(center)-radius, left1, F(left1));
    tangentRight=new Line(center, F(center)-radius, right1, F(right1));

    line(bb.x2X(center), bb.y2Y(F(center)-radius), bb.x2X(bb.maxx), bb.y2Y(tangentRight.x2y(bb.maxx)));
    line(bb.x2X(center), bb.y2Y(F(center)-radius), bb.x2X(bb.minx), bb.y2Y(tangentLeft.x2y(bb.minx)));
    //   line(bb.x2X(centerE),bb.y2Y(0), bb.x2X(centerE),bb.y2Y(F(centerE)));

    stroke(255, 0, 0);
    fill(255, 0, 0);

    for (xx=left1; xx<=right1; xx+=stepxx)
    {
      y=F(xx);
      ellipse(bb.x2X(xx), bb.y2Y(y), ptsize/2, ptsize/2);
    }
  }




  if (toggleRightBregmanSphere)
  {
    // blue
    stroke(0, 0, 255);
    fill(0, 0, 255);

    // plot on x-axis
    line(bb.x2X(left2), bb.y2Y(y0right), bb.x2X(right2), bb.y2Y(y0right) );
    // with endpoints
    ellipse(bb.x2X(center), bb.y2Y(y0right), ptsize, ptsize);
    ellipse(bb.x2X(left2), bb.y2Y(y0right), ptsize, ptsize);
    ellipse(bb.x2X(right2), bb.y2Y(y0right), ptsize, ptsize);

    stroke(0, 0, 0);
    strokeWeight(1);
    Line tangentCenter=new Line(gradF(center), F(center)-gradF(center)*center);

    if (toggleTangentCenter) {
      strokeWeight(1);
      line(bb.x2X(bb.minx), bb.y2Y(tangentCenter.x2y(bb.minx)), bb.x2X(bb.maxx), bb.y2Y(tangentCenter.x2y(bb.maxx)) );
    }

 stroke(0, 0, 255);
    fill(0, 0, 255);
    Line supportBS=tangentCenter.translate( (radius));
    line(bb.x2X(bb.minx), bb.y2Y(supportBS.x2y(bb.minx)), bb.x2X(bb.maxx), bb.y2Y(supportBS.x2y(bb.maxx)) );


    stroke(0, 0, 255);
    fill(0, 0, 255);

    for (xx=left2; xx<=right2; xx+=stepxx)
    {
      y=F(xx);
      // println("on graph blue "+ xx+" "+y);
      ellipse(bb.x2X(xx), bb.y2Y(y+y0right), ptsize/2, ptsize/2);
    }
    
        line(bb.x2X(center), bb.y2Y(0),bb.x2X(center), bb.y2Y(F(center)));
    line(bb.x2X(left2), bb.y2Y(0),bb.x2X(left2), bb.y2Y(F(left2)));
    line(bb.x2X(right2), bb.y2Y(0),bb.x2X(right2), bb.y2Y(F(right2)));
    
  }


  noFill();


  /*
  stroke(255,0,0);
   line(bb.x2X(centerl),bb.y2Y(0),bb.x2X(left1),bb.y2Y(0) );
   ellipse(bb.x2X(centerl),bb.y2Y(0),ptsize,ptsize);
   
   
   stroke(0,0,255);
   line(bb.x2X(centerr),bb.y2Y(0),bb.x2X(right1),bb.y2Y(0) );
   ellipse(bb.x2X(centerr),bb.y2Y(0),ptsize,ptsize);
   */
 
  stroke(1);

  if (toggleAnimation) animate();
}



void keyPressed()
{
  if (key=='q') exit();

  if (key=='p') {
    println("saving file");
    savepdffile();
  }

  if (key=='a') {
    toggleAnimation=!toggleAnimation;
  }

  if (key==' ') {
    init();speed=0.01;
  }

  if (key=='t') {
    toggleTangentCenter=!toggleTangentCenter;
  }

  if (key=='r') {
    toggleRightBregmanSphere=!toggleRightBregmanSphere;
  }

  if (key=='l') {
    toggleLeftBregmanSphere=!toggleLeftBregmanSphere;
  }
}
