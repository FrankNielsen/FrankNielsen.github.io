 // Frank.Nielsen@acm.org 6th April 2021
 
// https://github.com/OpenSourcePhysics/osp/blob/master/jars/osp.jar
// https://fem.um.es/Javadoc/OSP_EJS/org/opensourcephysics/numerics/ComplexEigenvalueDecomposition.html
// https://github.com/OpenSourcePhysics/osp/blob/master/src/org/opensourcephysics/numerics/Complex.java

int d=3;
Complex[][] M;
Complex[] eigval;
double [] r;
int side=512;
float ptsize=5;

BB bb;

double min(double a ,double b){if (a<b) return  a; else return b;}
 double max(double a ,double b){if (a>b) return  a; else return b;}
 
 
  void Initialize()
  {
    ComplexEigenvalueDecomposition CEig=new ComplexEigenvalueDecomposition();
// eigen(Complex[][] A, Complex[] lambda, Complex[][] vec, boolean[] fail)

int i,j;

 
M=new Complex[d][d];

  eigval=new Complex[d];
  r=new double[d];


for(i=0;i<d;i++)
{Complex rr=new Complex(0,0);
double maxv=10;
  for(j=0;j<d;j++)
{
M[i][j]=new Complex(-maxv/2+maxv*Math.random(),-maxv/2+maxv*Math.random());
if (i!=j) rr=rr.add(M[i][j].abs());
}
r[i]=rr.re(); // i-th Gershgorin disk
}




Complex[][] eigvec=new Complex[d][d];
boolean [] fail=new boolean[d];


CEig.eigen(M,eigval,eigvec,fail);

double lm=eigval[0].re(),lM=eigval[0].re();

for(i=0;i<d;i++) {println(eigval[i]);
lm=min(lm,eigval[i].re());
lm=min(lm,eigval[i].im());
lM=max(lM,eigval[i].re());
lM=max(lM,eigval[i].im());
}
//for(i=0;i<d;i++) println("real:"+eigval[i].re());
//println("done");

double border=1;
double lmb=lm-border*(lM-lm);
double lMb=lM+border*(lM-lm);

println("BB:"+lm+" "+lM);
bb=new BB(lmb,lMb,lmb,lMb, side, side);



}
  
void keyPressed()  
  {
  if (key==' ') Initialize();
  if (key=='>') {d++;Initialize();}
  if (key=='<') {d--;if (d<2) d=2;Initialize();}
  if (key=='q') exit();
  }
  
  double  M(double p, double q){return Math.sqrt(p*q);}
    double  G(double p, double q){return Math.sqrt(p*q);}
  
  void test()
  {
    double p=Math.random();
double q=Math.random();
  
  double alpha=3/8.0;
double Gd=M(p,M(M(p,q),q));
 //double Gd=M(M(p,q),q);
//double Gd=  M(M(p,M(M(p,q),q)),q);
  
 // double Gd=G(G(p,G(p,q)),q);
 // double alpha=3/8.0;
  
  double G=Math.pow(p,alpha)*Math.pow(q,1-alpha);
println("weighted mean:"+Gd+" "+G);
}
  
void setup()
{
  test();
 size(512,512); 
 //test(); 
 Initialize();
}

void drawPoint(double x, double y)
{
  ellipse(bb.x2X(x), bb.y2Y(y), ptsize, ptsize);
}

void drawPoint(double x, double y, double pt)
{
  ellipse(bb.x2X(x), bb.y2Y(y), (float)pt, (float)pt);
}

void drawCircle(double cx, double cy,double r)
{double angle,x1,y1,x2,y2;
int i,nbsteps=100;
  for(i=0;i<nbsteps;i++)
  {
    angle=2*Math.PI*(i/(double)nbsteps);
    x1=cx+r*Math.cos(angle);
    y1=cy+r*Math.sin(angle);
     angle=2*Math.PI*((i+1)/(double)nbsteps);
    x2=cx+r*Math.cos(angle);
    y2=cy+r*Math.sin(angle);
    
      line(bb.x2X(x1), bb.y2Y(y1), bb.x2X(x2), bb.y2Y(y2));
      
  }
  

}

String toString(Complex[][] M)
{String res="";
int i,j;

//String formatted = String.format("%.2f", myDouble);
res="(";
for(i=0;i<d;i++){
{for(j=0;j<d;j++)
{
 res=res+"("+String.format("%.2f",M[i][j].re())+ "+i*"+String.format("%.2f",M[i][j].im())+") ";
//res=res+M[i][j];
}
res=res+")\n";
}}
res=res+")";
 return res; 
}

void draw()
{int i;
 background(255);
 stroke(0);fill(0);
 
 textSize(10); 
 text(toString(M),10,10);
 
 stroke(0,0,255);
 fill(0,0,255);
 
 for(i=0;i<d;i++)
 {
   String s="λ["+i+"]"+String.format("%.2f",eigval[i].re())+"+i*"+String.format("%.2f",eigval[i].im());
 text(s,10,20*d+10*i);
 }

  stroke(255,0,0);
  fill(255,0,0);
   for(i=0;i<d;i++)
 {
  drawCircle(M[i][i].re(),M[i][i].im(),r[i]);
 }
 
  stroke(0,0,255);
 fill(0,0,255);
 for(i=0;i<d;i++)
 {
  drawPoint(eigval[i].re(),eigval[i].im(),2*ptsize);
 }
 
 
  stroke(255,0,0);
 fill(255,0,0);
 for(i=0;i<d;i++)
 {
  drawPoint(M[i][i].re(),M[i][i].im());
 }
  textSize(20); 
   stroke(0);fill(0);
 text("Gershgorin circle theorem (eigenvalues in disks)",10,side-10);
}
