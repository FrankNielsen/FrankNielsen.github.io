import processing.pdf.*;

int side = 512;
int ww = side;
int hh = side;


 
double minx=0;
double maxx=1;
double miny=0;
double maxy=1;

float ptsize=3;
 
boolean toggleRectify=false;


int n;
double [][] ps; // stored 2d coordinates of 3-mixtures

double [] a,g,c;



void initialize()
{
 n=10;int i;
 ps=new double[n][3];
 for(i=0;i<n;i++){ps[i][0]=Math.random();ps[i][1]=(1-ps[i][0])*Math.random();ps[i][2]=1-ps[i][0]-ps[i][1];}
  
  a=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps);
  g=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps);
   c=StandAloneJeffreysHistogramCentroid.ArithmeticMean(ps); 
}

void setup()
{
size(512,512);
initialize();
}

void MyLine(double x1, double y1, double x2, double y2)
{
if (toggleRectify) MyLineRectify(x1,y1,x2,y2); else  MyLineNoRectify(x1,y1,x2,y2);
}


void MyPoint(double x, double y)
{

if (toggleRectify) MyPointRectify(x,y); else MyPointNoRectify(x,y);
}

void MyLineRectify(double x1, double y1, double x2, double y2)
{int nbstep=10;
double x, xx, y,yy;
line(x2X(x1+0.5*y1), y2Y(y1*sqrt(3)/2.0), x2X(x2+0.5*y2), y2Y(y2*sqrt(3)/2.0)) ;
}
 
void MyLineNoRectify(double x1, double y1, double x2, double y2)
{int nbstep=10;
double x, xx, y,yy;
line(x2X(x1), y2Y(y1), x2X(x2), y2Y(y2)) ;
}


void MyPointRectify(double x, double y)
{
  ellipse((float)x2X(x+0.5*y), (float)y2Y(y*sqrt(3)/2.0), ptsize,ptsize);
}

void MyPointNoRectify(double x, double y)
{
  ellipse((float)x2X(x), (float)y2Y(y), ptsize,ptsize);
}



void draw()
{int i,j,ii,jj; 
 

surface.setTitle("Standard simplex (trinoulli)");



background(255, 255, 255);

stroke(0);
strokeWeight(1);


 for (i=0;i<n;i++) {   
   MyPoint(ps[i][0],ps[i][1]);
 
  }
 

}



public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

public  float X2x(double X)
{return (float)(minx+(maxx-minx)*((X)/(float)side));}



public  float y2Y(double y)
{
  return (float)(side- ((y-miny)*side/(maxy-miny)));
}

public  float Y2y(double Y)
{return (float)(miny+(maxy-miny)*((side-Y)/(float)side));}



void savepdffile()
{int s=0;
  String suffix=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();  

  beginRecord(PDF, "Trinoulli-"+s+"-"+suffix+".pdf");
  
 
  draw();
 
  save("Trinoulli-"+s+"-"+suffix+".png");
  endRecord();
  
}
 
 
 
 void keyPressed()
{
 if (key=='q') exit();
 if (key==' ') {initialize(); draw();}
   
 if ((key=='p')||(key=='P')) savepdffile();
 
  if (key=='r') {toggleRectify=!toggleRectify; draw();}
}
