// Frank.Nielsen@acm.org
// October 2024

// Extending Hausdorff Distances to Asymmetric Geometries, page 64
import processing.pdf.*;

void savepdffile()
{
  int s=0;
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();

  beginRecord(PDF, "BregmanSpherePotential-"+suffix+".pdf");


  draw();

  save("BregmanSpherePotential-"+suffix+".png");
  endRecord();
}


boolean toggleAnimation=true;

boolean toggleLeftBregmanSphere=true;
boolean toggleRightBregmanSphere=true;

boolean toggleRight=true;
boolean toggleLeft=true;
boolean toggleSym=true;

boolean toggleTangentCenter=false;

BB bb;
int ww=800,hh=800;
int step=4;

int n;
double [] set;

double deltay=1;



double A(double [] s)
{double res=0;
int i;

for(i=0;i<s.length;i++) res+=s[i];

  
 return res/(double)s.length; 
}


double H(double [] s)
{double res=0;
int i;

for(i=0;i<s.length;i++) res+=1.0/s[i];

  
 return 1.0/(res/(double)s.length); 
}

double SISInformation(double [] s, double c)
{
  double res=0;
int i;

for(i=0;i<s.length;i++)  res+=SIS(s[i],c);

return res;
}

// Euclidean case
double centerE, radiusE, leftE, rightE;

double centerl, centerr, centers;
double radiusl, radiusr, radiuss;

  static double W(double x)
  {
    return LambertW.branch0(x);
  }

/*
// Burg entropy
double F(double theta) {
  return -Math.log(theta);
}
*/

// paraboloid of revolution
double F(double theta) {
  return theta*theta;
}

double gradF(double theta) {
  return  2.0*theta;
}


// Itakura-Saito distance
double  IS(double p, double q) {
  return (p/q)-Math.log(p/q)-1;
}

// symmetrized IS = COSH
double SIS(double p, double q) {
  return (p/q)+(q/p)-2;
}

double xmin=-4, xmax=4;

double right1, right2, left1,left2,sym1,sym2;


double GeometricMean(double p1,double p2){return Math.sqrt(p1*p2);}


double speed=0.01;

void animate()
{
  centerE=centerE+speed;
  if (centerE>bb.maxx-Math.sqrt(radiusE)) {speed=-speed;}
   if (centerE<bb.minx+Math.sqrt(radiusE)) {speed=-speed;}
  
  leftE=centerE-Math.sqrt(radiusE);
rightE=centerE+Math.sqrt(radiusE);
  
}


void init()
{
  int i;
  n=10;
  set=new double[n];
  
  for(i=0;i<n;i++) set[i]=Math.random()*5;
  
  double a=A(set),h=H(set);
  System.out.println("Same SIS information:"+SISInformation(set,a)+" "+SISInformation(set,h));
  
 centerl=Math.random();
  radiusl=1+Math.random();
  
  
 centerr=Math.random();
  radiusr=1+Math.random();

 centers=Math.random();
  radiuss=1+Math.random();
  
  sym1=0.5*(centers*radiuss-centers*Math.sqrt(radiuss*(radiuss+4))+2*centers);
  sym2=0.5*(centers*radiuss+centers*Math.sqrt(radiuss*(radiuss+4))+2*centers);
 System.out.println("symmetrized check:"+SIS(sym1,centers)+" "+SIS(sym2,centers)+" vs "+radiuss); 
 
 
 double rie=GeometricMean(a,h);
 System.out.println("Rie centroid:"+rie+" SISinfo:"+SISInformation(set,rie));

right1=-centerr*W(-Math.exp(-radiusr-1));
System.out.println("Right 1: "+right1+" IS="+IS(right1,centerr)+" vs "+radiusr);

 

left1=-centerl/W(-Math.exp(-radiusl-1));
System.out.println("Left 1: "+IS(centerl,left1)+" vs "+radiusl);


centerE=xmin+(xmax-xmin)*Math.random();
radiusE=Math.random();
leftE=centerE-Math.sqrt(radiusE);
rightE=centerE+Math.sqrt(radiusE);

/*
assume(r>0);
solve([(x-c)**2-r**2=0],x);
*/

  bb=new BB(xmin, xmax, -deltay, F(xmax)+deltay, ww, hh); //
}

void setup()
{
  size(800,800);
  init();
}

float ptsize=3;

// main drawing procedure
void draw()
{
  background(255);
  int i;


  
  
  stroke(128);
  line(bb.x2X(xmin),bb.y2Y(0),bb.x2X(xmax),bb.y2Y(0));
  
     strokeWeight(3);
  stroke(255,0,0);fill(255,0,0);
  line(bb.x2X(leftE),bb.y2Y(0),bb.x2X(rightE),bb.y2Y(0) );
  ellipse(bb.x2X(centerE),bb.y2Y(0),ptsize,ptsize);
   ellipse(bb.x2X(leftE),bb.y2Y(0),ptsize,ptsize);
    ellipse(bb.x2X(rightE),bb.y2Y(0),ptsize,ptsize);
    
    
    stroke(128,0,0);
    line(bb.x2X(centerE),bb.y2Y(0), bb.x2X(centerE),bb.y2Y(F(centerE)));
     line(bb.x2X(leftE),bb.y2Y(0), bb.x2X(leftE),bb.y2Y(F(leftE)));
      line(bb.x2X(rightE),bb.y2Y(0), bb.x2X(rightE),bb.y2Y(F(rightE)));
      
      
      if (toggleLeftBregmanSphere){
      stroke(0,255,0);
      ellipse(bb.x2X(centerE),bb.y2Y(F(centerE)-radiusE ),ptsize,ptsize);
      
Line  tangentLeft, tangentRight;

tangentLeft=new Line(centerE,F(centerE)-radiusE ,leftE,F(leftE));
tangentRight=new Line(centerE,F(centerE)-radiusE ,rightE,F(rightE));
      
      line(bb.x2X(centerE),bb.y2Y(F(centerE)-radiusE), bb.x2X(bb.maxx),bb.y2Y(tangentRight.x2y(bb.maxx)));
        line(bb.x2X(centerE),bb.y2Y(F(centerE)-radiusE), bb.x2X(bb.minx),bb.y2Y(tangentLeft.x2y(bb.minx)));
    //   line(bb.x2X(centerE),bb.y2Y(0), bb.x2X(centerE),bb.y2Y(F(centerE)));
      }
       
       if(toggleRightBregmanSphere)
       {
       stroke(0,0,255);
       Line tangentCenter=new Line(gradF(centerE),F(centerE)-gradF(centerE)*centerE);
       
       if (toggleTangentCenter){
       strokeWeight(1);
       line(bb.x2X(bb.minx),bb.y2Y(tangentCenter.x2y(bb.minx)), bb.x2X(bb.maxx),bb.y2Y(tangentCenter.x2y(bb.maxx)) );
       }
       
        strokeWeight(3);
       Line supportBS=tangentCenter.translate( (radiusE));
        line(bb.x2X(bb.minx),bb.y2Y(supportBS.x2y(bb.minx)), bb.x2X(bb.maxx),bb.y2Y(supportBS.x2y(bb.maxx)) );
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
  
  
  
   strokeWeight(1);
  
  
    stroke(0);
    
  double y, ny;
  for (i=0; i<ww-step; i+=step)
  {
    y=F(bb.X2x(i));
    ny=F(bb.X2x(i+step));
    
    line((float)i, (float)bb.y2Y(y), (float)(i+step), (float)bb.y2Y(ny));
  }
  
  stroke(255,0,0);
  double xx, stepxx=0.01;
  for (xx=leftE; xx<=rightE; xx+=stepxx)
  {
    y=F(xx);
    
    
    ellipse(bb.x2X(xx), bb.y2Y(y), ptsize,ptsize);
  }
  
  if (toggleAnimation) animate();
}

void keyPressed()
{
    if (key=='q') exit();
  
  if (key=='p') savepdffile();
  
   if (key=='a'){toggleAnimation=!toggleAnimation;} 
   
 if (key==' '){init();} 
 
  if (key=='t'){toggleTangentCenter=!toggleTangentCenter;}
 
  if (key=='r'){toggleRightBregmanSphere=!toggleRightBregmanSphere;}
  
    if (key=='l'){toggleLeftBregmanSphere=!toggleLeftBregmanSphere;}
}
