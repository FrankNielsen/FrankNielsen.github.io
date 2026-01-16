// Frank.Nielsen@acm.org
// 9th May 2022
//
// Devroye triangular sampling method
// Paper "A new method to simulate the triangular distribution"
//
import processing.pdf.*;

boolean showText=true;


void exportPDF()
{
  String strname=month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+millis();
  beginRecord(PDF, "TriangularVariates-"+strname+".pdf"); 
  draw();
  endRecord();
  
  save("TriangularVariates-"+strname+".png");
}

float [][] points;


float [] p,q,r;
int WW=800,HH=WW;
int MAXSAMPLE=500;
int nbsample, n;

//
// 2D probability simplex
//
void initializeEquilateral()
{float HY=10, HX=10;
p=new float[2];p[0]=HX;p[1]=HH-HY-0;
q=new float[2];q[0]=WW-2*HX;q[1]=HH-HY-0;
r=new float[2];r[0]=WW/2.0;r[1]=HH-HY-(float)(HH-2*HX)*sqrt(3.0)/2.0;

points=new float[MAXSAMPLE][2];
n=0;
}


void initialize()
{
p=new float[2];p[0]=(float)Math.random()*WW;p[1]=(float)Math.random()*HH;
q=new float[2];q[0]=(float)Math.random()*WW;q[1]=(float)Math.random()*HH;
r=new float[2];r[0]=(float)Math.random()*WW;r[1]=(float)Math.random()*HH;

points=new float[MAXSAMPLE][2];
n=0;
}

void sample()
{int i;
for(i=0;i<MAXSAMPLE;i++)
{
  float u1=random(0,1);
  float u2=random(0,1);
  float m=min(u1,u2);
  float M=max(u1,u2);
  float [] s=new float[2];
  
  s[0]=m*p[0]+(M-m)*q[0]+(1-M)*r[0];
  s[1]=m*p[1]+(M-m)*q[1]+(1-M)*r[1];
  
  points[i][0]=s[0];
  points[i][1]=s[1];
  
}
  n=i-1;
}

void setup() {
  size(800,800);
  
initialize();
}

float PTS=8;

/*
https://twitter.com/sp_monte_carlo/status/1114547722261078017
 draw u,v ~ iid U[0,1], set m = min(u,v), M = max(u,v), set x = m*A + (M-m)*B + (1-M)*C.
 */
 
 String text1="U1=Unif(0,1); U2=Unif(0,1); m=min(U1,U2); M=Max(U1,U2)";
 String text2="S=m*P+(1-M)*Q+(M-m)*R";
 
 boolean pause=true;
 
void draw() {
  
    background(255);
  stroke(0);fill(0);
  
  if (!pause){
  float u1=random(0,1);
  float u2=random(0,1);
  float m=min(u1,u2);
  float M=max(u1,u2);
  float [] s=new float[2];
  
  s[0]=m*p[0]+(M-m)*q[0]+(1-M)*r[0];
  s[1]=m*p[1]+(M-m)*q[1]+(1-M)*r[1];
  
  points[n][0]=s[0];
  points[n][1]=s[1];
  if (n<MAXSAMPLE-1) n++;
  }
  
   stroke(0,0,255);fill(0,0,255);
  
    for(int i=0;i<n;i++) ellipse(points[i][0],points[i][1],3,3);
    //ellipse(s[0],s[1],3,3);
  //ellipse(s[0],s[1],PTS,PTS);
  
  
  stroke(0);fill(0);
  line(p[0],p[1],q[0],q[1]);
   line(q[0],q[1],r[0],r[1]);
    line(r[0],r[1],p[0],p[1]);
    
  ellipse(p[0],p[1],PTS,PTS);
  ellipse(q[0],q[1],PTS,PTS);
  ellipse(r[0],r[1],PTS,PTS);
  
  if (showText){
  textSize(24);
text(text1, 10, 24);
text(text2, 10, 50);

  textSize(16);
text("Frank.Nielsen@acm.org", 10, HH-20);
  }
}

void keyPressed()
{
 if (key==' ') {initialize();draw();} 
 
 if (key=='x') {
   exportPDF();
 // grab pdf
 }
 
  if (key=='e') {// equilateral triangle
    initializeEquilateral();draw();
 }
 
 if (key=='q') {exit();}
 
 if (key=='p') {pause=!pause;}
 
 if (key=='s') {sample();draw();}
 
 if (key=='t') {showText=!showText;draw();}
}
