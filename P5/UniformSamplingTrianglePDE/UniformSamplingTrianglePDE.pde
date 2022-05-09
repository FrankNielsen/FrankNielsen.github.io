// Frank.Nielsen@acm.org
// 9th May 2022
//
//A new method to simulate the triangular distribution
float [] p,q,r;
int WW=800,HH=WW;
int nbsample;

void initialize()
{
  background(255);
  
p=new float[2];p[0]=(float)Math.random()*WW;p[1]=(float)Math.random()*HH;
q=new float[2];q[0]=(float)Math.random()*WW;q[1]=(float)Math.random()*HH;
r=new float[2];r[0]=(float)Math.random()*WW;r[1]=(float)Math.random()*HH;
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
  stroke(0);fill(0);
  
  if (!pause){
  float u1=random(0,1);
  float u2=random(0,1);
  float m=min(u1,u2);
  float M=max(u1,u2);
  float [] s=new float[2];
  s[0]=m*p[0]+(M-m)*q[0]+(1-M)*r[0];
  s[1]=m*p[1]+(M-m)*q[1]+(1-M)*r[1];
  
   stroke(0,0,255);fill(0,0,255);
    ellipse(s[0],s[1],3,3);
  //ellipse(s[0],s[1],PTS,PTS);
  }
  
  stroke(0);fill(0);
  line(p[0],p[1],q[0],q[1]);
   line(q[0],q[1],r[0],r[1]);
    line(r[0],r[1],p[0],p[1]);
    
  ellipse(p[0],p[1],PTS,PTS);
  ellipse(q[0],q[1],PTS,PTS);
  ellipse(r[0],r[1],PTS,PTS);
  
  textSize(24);
text(text1, 10, 24);
text(text2, 10, 50);

  textSize(16);
text("Frank.Nielsen@acm.org", 10, HH-20);
}

void keyPressed()
{
 if (key==' ') {initialize();draw();} 
 
 if (key=='p') {pause=!pause;}
}
