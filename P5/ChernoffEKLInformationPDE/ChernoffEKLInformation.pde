//
// Miniball extended to arbitrary Bregman divergences
//
// Java Applet that demonstrates the generalization of the MiniBall algorithm of Welzl
// Compiled using SUN Java Standard Edition J2SE 5.0
//
// Frank NIELSEN, May 2006
//
// Frank.Nielsen@acm.org
//
// https://processing.org/
// Processing Adaptation: 28/11/2015, Antoine Chatalic, with further enhancements by Frank Nielsen (Dec 2015)

import processing.pdf.*;

String filenameprefix="SmallestEnclosingBregmanBall";
int snapshotnb=0;

String L22="squared Euclidean", KL="Kullback-Leibler", IS="Itakura-Saito" ;
String EXP="exponential", CSI="Csiszar  (0.5)", MAH="squared Mahalanobis", LOG="Logistic Loss";

private int xbutton;
private int ybutton;
private int hbutton;
private int mbutton;
private int xpad;
private int ypad;
private int hmenu;

private int maxcard;
private int MAXCARD=200;



private BregmanDivergence DF=new L22();
private PointSet dataset= new PointSet(maxcard,DF);

//
// Center point, maximum radius
//
private Point center;
private double radius;

private minibb mini;
private BregmanDisk BD, BD0, BD1;

// Window size 
private int w, h;
private boolean justinitialized;

private double worldminx=-0.5;
private double worldmaxx=1.5;
private double worldminy=-0.5;
private double worldmaxy=1.5;

// UI Buttons
private Button applyButton;
private Button newsetButton;
private Button miniballButton;

private DropDown dFList; // DropDown list (Bregman divergences)

private color bgcol = color(253);	// Background color
private color bgbordercol = color(200); // Canvas frame color
private color buttonBgCol = bgcol; // Buttons background color
private color buttonOverBgCol = color(240); // Buttons background color
private color buttonSelCol = color(200); // Buttons background color
private color buttonBorderCol = color(0); // Buttons border color
private color buttonTextCol = buttonBorderCol; // Buttons text color

private color pointsCol = color(255,0,0);
private color centerCol = color(10,0,255);
private color geodesicCol = color(0,255,0);
//private color ballCol = color(255,204,0); // Bregman ball color


private color ballCol = color(255,0,0,80); // Bregman ball color

private color dualballCol = color(0,0,255,80); // dual Bregman ball color

boolean showTop=true;

void keyPressed()
{
   if (key=='a') {// add a new point
 double xx=Xtox(mouseX);
 double yy=Ytoy(mouseY);
 dataset=new PointSet(dataset,new Point(xx,yy));
 }
   
  if (key==' ') initSet();
  
  
if ((key=='+') || (key =='=')) {if (maxcard<MAXCARD) maxcard++; initSet();}
if ((key=='-') || (key =='6')) {maxcard--; if (maxcard<3) maxcard=3; initSet();}

if (key=='q') exit();
  
if (key=='p') {
// save into pdf 
showTop=false;
 beginRecord(PDF, filenameprefix+"-"+snapshotnb+".pdf");
 draw();
 save(filenameprefix+"-"+snapshotnb+".png");
 endRecord();
 snapshotnb++;
 showTop=true;
}

if (key=='c') {  mini=new minibb(dataset, DF);
    // get the smallest enclosing disk
    BD=mini.bdisk;
    justinitialized=false;}

}


void initSet()
{
  dataset=new PointSet(maxcard, DF);
  mini=new minibb(dataset,DF);
  BD=mini.bdisk;
}


void setup(){

	frameRate(30);
size(800,800); // Can't use w and h here!

//	maxcard=30;
maxcard=2;

w=800;
h=800;
	int i;

	mbutton = 8;
	xpad = 8;
	ypad = 5;
	xbutton = mbutton;
	ybutton = mbutton;
  textSize(12); 
	hbutton = ceil(textAscent())+2*ypad;
	hmenu = 2*ypad+2*mbutton+ceil(textAscent());

	DF=new L22();

initSet();

	justinitialized=false;

	dFList = new DropDown("Bregman divergence: ");
     dFList.addItem("squared Euclidean");
	dFList.addItem("Kullback-Leibler");
	dFList.addItem("Itakura-Saito");
	dFList.addItem("Exponential");
	dFList.addItem("Csiszar (0.5)");
	dFList.addItem("squared Mahalanobis");
	dFList.addItem("Logistic Loss");

	/*
	fill(buttonTextCol);
	text("MiniBBall:  Smallest Enclosing Bregman Ball by F. Nielsen and R. Nock");
	*/

	newsetButton = new Button("Draw a new Set");
	miniballButton=new Button("Mini Bregman Ball");

}

void draw(){

	fill(bgcol);
	rect(0, 0, w,h);

	int i;
	int xx,yy;
	int xx1,yy1,xx2,yy2;

	/*System.out.println("Redrawing graphics with double buffering image...");*/

BD0=new BregmanDisk(dataset.array[0],BD.rad);
BD1=new BregmanDisk(dataset.array[1],BD.rad);

drawDualBregmanBall(BD0);
drawDualBregmanBall(BD1);

	drawBregmanBall(BD);

	stroke(0,0,0);

	for(i=0;i<dataset.n;i++)
		DrawPoint(dataset.array[i],3);

	if (BD.basis.n==3) {
		DrawLineProjectivePoint(mini.b12);
		DrawLineProjectivePoint(mini.b13);
		DrawLineProjectivePoint(mini.b23);

		fill(geodesicCol);
		stroke(geodesicCol);
		drawGeodesic(BD.basis.array[0],BD.basis.array[1]);
		drawGeodesic(BD.basis.array[1],BD.basis.array[2]);
		drawGeodesic(BD.basis.array[0],BD.basis.array[2]);

		fill(pointsCol);
		stroke(pointsCol);
		DrawPoint(BD.basis.array[0],7);
		DrawPoint(BD.basis.array[1],7);
		DrawPoint(BD.basis.array[2],7);
	}

	if (BD.basis.n==2) {
		PPoint l12=DF.BregmanBisector(BD.basis.array[0],BD.basis.array[1]);	
		DrawLineProjectivePoint(l12);

		fill(geodesicCol);
		stroke(geodesicCol);
		drawGeodesic(BD.basis.array[0],BD.basis.array[1]);

		fill(pointsCol);
		stroke(pointsCol);
		DrawPoint(BD.basis.array[0],7);
		DrawPoint(BD.basis.array[1],7);
	}

	fill(centerCol);
	stroke(centerCol);
	DrawPoint(BD.center,9);

	// Text at bottom
	fill(bgcol);
	stroke(0,0,0);
	rect(0, h-hmenu, w,h);

	stroke(buttonTextCol);
	fill(buttonTextCol);
	text("Bregman divergence: "+DF.name+" (n="+maxcard+")", xpad, h-hmenu+16);
	text("Center point: ("+String.format("%.3f",BD.center.x)+" "+String.format("%.3f",BD.center.y)+") −  Radius:"+String.format("%.3f",BD.rad), xpad, h-hmenu+31);
  
	fill(bgcol);
	rect(0, 0, w, hmenu);

if (showTop){
	newsetButton.update();
	if (newsetButton.clicked) {
		dataset=new PointSet(maxcard, DF);
		mini=new minibb(dataset, DF);
		BD=mini.bdisk;
	}		

	// Compute the smallest enclosing ball
	miniballButton.update();
	if (miniballButton.clicked) {
	  // recompute the smallest enclosing disk
	  mini=new minibb(dataset, DF);
	  // get the smallest enclosing disk
		BD=mini.bdisk;
		justinitialized=false;
	}

	dFList.update();
}
}

// Convert point set coordinates to screen display coordinates
int xToX(double x) {
	return (int)Math.rint(w*(x-worldminx)/(worldmaxx-worldminx));
}

int yToY(double y) {
	// hmenu is the size of the status bar (last hmenu pixels are not visible, so we shift the whole image)
	return h-(int)Math.rint(h*(y-worldminy)/(worldmaxy-worldminy))-hmenu;
	/*return h-(int)Math.rint(h*(y-worldminy)/(worldmaxy-worldminy));*/
}

// Convert screen display coordinates to point set coordinates
double Xtox(int X) {
	return worldminx+((double)X/(double)w)*(worldmaxx-worldminx);
}

double Ytoy(int Y) {
	// hmenu is the size of the status bar (last hmenu pixels are not visible, so we shift the whole image)
	return worldminy+((double)(h-(Y+hmenu))/(double)h)*(worldmaxy-worldminy);
	/*return worldminy+((double)(h-Y)/(double)h)*(worldmaxy-worldminy);*/
}

// Draw a geodesic 
public void drawGeodesic(Point source, Point dest) {

	int i;
	int xx1,yy1;
	int xx2,yy2;
	int nbsteps=10;

	double alpha;
	double increment=1.0/(double)nbsteps;

	for(i=0;i<nbsteps;i++)
	{
		alpha=(double)i/(double)nbsteps;
		Point p=BBCPoint(alpha, source, dest);
		Point pp=BBCPoint(alpha+increment, source, dest);

		xx1=xToX(p.x);
		yy1=yToY(p.y);
		xx2=xToX(pp.x);
		yy2=yToY(pp.y);

		line(xx1,yy1,xx2,yy2);	
	}

} // end of geodesic


public void drawDualBregmanBall(BregmanDisk bd) {

  int i,j;
  Point p=new Point();

  stroke(dualballCol);
  fill(dualballCol);

  for(i=0;i<h;i++)
  {
    p.y=Ytoy(i);

    for(j=0;j<w;j++)
    {
      p.x=Xtox(j);
      if (DF.divergence(p,bd.center)<bd.rad) rect(j,i, 1, 1);
    }
  }

}


public void drawBregmanBall(BregmanDisk bd) {

	int i,j;
	Point p=new Point();

	stroke(ballCol);
	fill(ballCol);

	for(i=0;i<h;i++)
	{
		p.y=Ytoy(i);

		for(j=0;j<w;j++)
		{
			p.x=Xtox(j);
			if (DF.divergence(bd.center,p)<bd.rad) rect(j,i, 1, 1);
		}
	}

}

// Draw the line associated to the homogeneous point 
void DrawLineProjectivePoint(PPoint p) {

	double x1,fx1,x2,fx2;
	int xx1,yy1,xx2,yy2;

	if (p.w!=0.0){
		x1=worldminx;
		fx1=(-p.w-p.x*x1)/p.y;

		x2=worldmaxx;
		fx2=(-p.w-p.x*x2)/p.y;

		xx1=xToX(x1);
		yy1=yToY(fx1);
		xx2=xToX(x2);
		yy2=yToY(fx2);

		line(xx1,yy1,xx2,yy2);	
	}

}

public void DrawPoint(Point p, int pwidth) {

	int xx,yy;

	xx=xToX(p.x);
	yy=yToY(p.y);
	rect(xx-pwidth/2, yy-pwidth/2, pwidth, pwidth);

}


//
// Compute the maximal divergence to a point set
//
double MaxDivergence(Point p)
{
	int i;
	double div,maxdiv=0.0;

	for(i=0;i<dataset.n;i++)
	{
		div=DF.divergence(p,dataset.array[i]);
		if (div>maxdiv) {maxdiv=div;}
	}

	return maxdiv;
}


//
// Interpolation for the geodesic: draw path [pq]  
//
public Point BBCPoint(double alpha, Point p, Point q)
{
	Point gradfp,gradc;
	Point cc=new Point();

	gradfp=DF.gradF(q);
	gradfp.MultCste(1.0-alpha);

	gradc=DF.gradF(p);
	gradc.MultCste(alpha);

	gradc.AddPoint(gradfp);

	cc=DF.gradFinv(gradc);

	return cc;
}



//
// Class for manipulating a 2D point
// 

class Point
{
	public double x,y;

	// Constructor
	Point()
	{
		x=0.0;
		y=0.0;
	}

	Point (double xx, double yy)
	{x=xx; y=yy;}	


	double distSqr(Point q)
	{
		return (q.x-x)*(q.x-x)+(q.y-y)*(q.y-y);
	}
	//
	// Java does not allow operator overloading
	// Thus, we need to do it coordinatewise
	//
	public void AddPoint(Point p)
	{
		x=x+p.x;
		y=y+p.y;
	}

	public void MultCste(double cste)
	{
		x=cste*x;
		y=cste*y;
	}

}

//
// A Point set class
//
class PointSet
{
	public int n;
	public Point array[];


	public void PrintSet()
	{
		int i;

		/*
		for(i=0;i<n;i++)
			println(i+" "+array[i].x+" "+array[i].y);
			*/

	}

	// Constructor
	PointSet(int card)
	{
		int i;

		n=card;

		if (n>0)
		{
			array=new Point[card];

			// Uniform point set on the unit square
			for(i=0;i<n;i++)
			{
				array[i]=new Point();
				array[i].x=0.1+random(0.9);
				array[i].y=0.1+random(0.9);
			}
		}
	}

	//
	// Truncated copy of the point set
	//
	PointSet(PointSet another, int start)
	{
		int i;

		n=another.n-start;
		array=new Point[n];

		for(i=0;i<n;i++)
		{
			array[i]=new Point();
			array[i]=another.array[i+start];
		}

	}


	//
	// Copy of the point set+ an extra point
	//
	PointSet(PointSet another, Point p)
	{
		int i;

		n=another.n+1;
		array=new Point[n];

		for(i=0;i<another.n;i++)
		{
			array[i]=new Point();
			array[i]=another.array[i];
		}

		array[n-1]=new Point();
		array[n-1]=p;
	}



	//
	// Constructor with a divergence for sampling inside a ball
	//
	PointSet(int card, BregmanDivergence BD)
	{
		int i;
		double xx,yy;
		Point centerball=new Point(random(1.0),random(1.0));
		double radiusball=0.5+random(1.0);
		double rad;
		Point drawpoint=new Point();

		n=card;

		centerball.x=0.5;
		centerball.y=0.5;

		radiusball=BD.divergence(centerball, new Point(0.1,0.1));

		/*String label = "I have choosen theoretical center "+centerball.x+" "+centerball.y+" and divergence radius:"+radiusball;*/
		/*text(label,100,100);*/

		array=new Point[card];

		// Uniform point set on the unit square
		for(i=0;i<n;i++)
		{
			array[i]=new Point();

			drawpoint.x=random(1.0);
			drawpoint.y=random(1.0);

			while ( BD.divergence( centerball, drawpoint ) > radiusball )
			{
				drawpoint.x=random(1.0);
				drawpoint.y=random(1.0);
			}

			array[i].x=drawpoint.x;
			array[i].y=drawpoint.y;
		}

		/*println("Point set drawn.");*/
	}


} // End of  point set class



//
// Generic Bregman divergence class
//
class BregmanDivergence
{
	String name;
	double dd=0.001; // for computing gradients
	int type;

	BregmanDivergence()
	{name="Bregman divergence";
		type=0; // not linear
	}


	double DotProduct(Point p,Point q)
	{
		return p.x*q.x+p.y*q.y;
	}

	PPoint BregmanBisector(Point p, Point q)
	{
		Point  gradp,gradq;
		PPoint result=new PPoint();

		/*println("Bregman bisector of "+p.x+" "+p.y+" with "+q.x+" "+q.y);*/

		gradp=gradF(p);
		gradq=gradF(q);

		//
		// Equation of the bisector stored as a projective point
		//
		result.x=gradp.x-gradq.x;
		result.y=gradp.y-gradq.y;

		result.w=F(p)-F(q)+DotProduct(q,gradq)-DotProduct(p,gradp);

		return result;
	}

	//
	// The convex function F defining the Bregman divergence
	//
	double Fx(double x)
	{
		return 1.0;	
	}

	double Fy(double y)
	{
		return Fx(y); // by default the same on each axis
	}

	double F(Point p)
	{
		return  Fx(p.x)+Fy(p.y);
	}

	/*
		 Point gradF_Discrete(Point p)
		 {
		 Point px=new Point(p.x+dd,p.y);
		 Point py=new Point(p.x,p.y+dd);

		 return new Point((F(px)-F(p))/dd, (F(py)-F(p))/dd);

		 }

		 Point gradFinv_Discrete(Point p)
		 {
		 Point px=new Point(p.x+dd,p.y);
		 Point py=new Point(p.x,p.y+dd);

		 return new Point((p.x*dd)/(F(px)-F(p)), (p.y*dd)/(F(py)-F(p)));		
		 }
		 */
	//
	// Compute the gradient operators by discretization 
	// (In case we do not compute symbolically the exact derivatives)
	//
	Point gradF(Point p)
	{
		return new Point(0,0);
		//return gradF_Discrete(p);
	}

	Point gradFinv(Point q)
	{
		return new Point(0,0);	
		//return gradFinv_Discrete(q);
	}

	//
	// return 0 iff p=q
	// return >0 if both p<>q and p,q belongs to the domain
	// return <0 if p or q is out of the domain
	// F(p)-F(q)-DotProduct(p-q,gradF(q))
	//
	double divergence(Point p, Point q)
	{
		Point gradFq=gradF(q);

		return F(p)-F(q)-((p.x-q.x)*gradFq.x+(p.y-q.y)*gradFq.y);
	}


	double Divergence(Point p, Point q)
	{
		return divergence(p,q)+divergence(q,p);
	}
}

//
// The squared Euclidean distance is a usual Bregman divergence
// F(x)=x^2
//
class L22 extends BregmanDivergence
{

	double Fx(double x)
	{
		return x*x;	
	}

	L22()
	{
		name="squared Euclidean distance";
		type=1;
	}
	// Gradient operator
	Point gradF(Point p)
	{
		return new Point(2*p.x,2*p.y);
	}

	// Inverse Gradient Operator
	Point gradFinv(Point q)
	{
		return new Point(0.5*q.x,0.5*q.y);
	}

	// Squared Euclidean distance
	double divergence(Point p, Point q)
	{
		return (p.x-q.x)*(p.x-q.x)+(p.y-q.y)*(p.y-q.y);
	}

}


//
// The squared Euclidean distance is a usual Bregman divergence
// F(x)=x^2
//
class EXP extends BregmanDivergence
{

	EXP()
	{
		name="Exponential distance";
	}

	double Fx(double x)
	{
		return Math.exp(x);	
	}

	// Gradient operator
	Point gradF(Point p)
	{
		return new Point(Math.exp(p.x),Math.exp(p.y));
	}

	// Inverse Gradient Operator
	Point gradFinv(Point q)
	{
		return new Point(Math.log(q.x),Math.log(q.y));
	}

	// Exponential Euclidean distance
	double divergence(Point p, Point q)
	{
		return Math.exp(p.x)-Math.exp(q.x)-(p.x-q.x)*Math.exp(q.x)+Math.exp(p.y)-Math.exp(q.y)-(p.y-q.y)*Math.exp(q.y);
	}

}

class KullbackLeibler extends BregmanDivergence
{

	KullbackLeibler()
	{
		name="Kullback-Leibler divergence";
	}

	double Fx(double x)
	{
		return x*Math.log(x);	
	}

	// Gradient operator
	Point gradF(Point p)
	{
		return new Point(Math.log(p.x)+1.0, Math.log(p.y)+1.0);
	}

	// Inverse Gradient Operator
	Point gradFinv(Point p)
	{
		return new Point(Math.exp(p.x-1.0),Math.exp(p.y-1.0));
	}

	// Kullback-Leibler divergence
	double divergence(Point p, Point q)
	{
		return p.x*Math.log(p.x/q.x)-(p.x-q.x)+p.y*Math.log(p.y/q.y)-(p.y-q.y);
	}

}

class ItakuraSaito extends BregmanDivergence
{
	ItakuraSaito()
	{
		name="Itakura-Saito Divergence";
	}

	double Fx(double x)
	{
		return -Math.log(x);
	}

	// Gradient operator
	Point gradF(Point p)
	{
		return new Point(-1.0/p.x, -1.0/p.y);
	}

	// Inverse Gradient Operator
	Point gradFinv(Point p)
	{
		return new Point(-1.0/p.x, -1.0/p.y);
	}

	// Itakura-Saito
	double divergence(Point p, Point q)
	{
		return (p.x/q.x)-Math.log(p.x/q.x)-1.0 + p.y/q.y-Math.log(p.y/q.y)-1.0;
	}

}

class Csiszar extends BregmanDivergence
{
	Csiszar()
	{
		name="Csiszar Divergence (Alpha=0.5)";
	}

	double Fx(double x)
	{
		return -4.0*Math.sqrt(x);
	}

	// Gradient operator
	Point gradF(Point p)
	{
		return new Point(-2.0/Math.sqrt(p.x), -2.0/Math.sqrt(p.y));
	}

	// Inverse Gradient Operator
	Point gradFinv(Point p)
	{
		return new Point(4.0/(p.x*p.x), 4.0/(p.y*p.y));
	}

	// Csiszar
	double divergence(Point p, Point q)
	{
		return 4.0 * (Math.sqrt(q.x) - Math.sqrt(p.x) + ((p.x-q.x) / (2.0*Math.sqrt(q.x)))) + 4.0 * (Math.sqrt(q.y) - Math.sqrt(p.y) + ((p.y-q.y) / (2.0*Math.sqrt(q.y)))) ;
	}

}

//
// Logistic loss 
//
class LogisticLoss extends BregmanDivergence
{
	LogisticLoss()
	{
		name="Logistic Loss Divergence";
	}

	double Fx(double x)
	{
		return 	x*Math.log(x)+(1.0-x)*Math.log(1.0-x);
	}

	// Gradient operator

	Point gradF(Point p)
	{
		return new Point( Math.log(p.x/(1.0-p.x)), Math.log(p.y/(1.0-p.y)) );
	}

	Point gradFinv(Point p)
	{
		return new Point( Math.exp(p.x)/(1.0+Math.exp(p.x)), Math.exp(p.y)/(1.0+Math.exp(p.y)));
	}


	// Logistic loss

	double divergence(Point p, Point q)
	{
		return p.x*Math.log(p.x/q.x)+(1.0-p.x)*Math.log((1.0-p.x)/(1.0-q.x))+ p.y*Math.log(p.y/q.y)+(1.0-p.y)*Math.log((1.0-p.y)/(1.0-q.y));
	}


}


//
// Mahalanobis   
//

class Mahalanobis extends BregmanDivergence
{
	double[][]A;
	double s;


	Mahalanobis()
	{
		name="Mahalanobis Divergence";
		//type=1;

		A=new double[2][2];

   	A[0][0]=0.6;
   	A[0][1]=0.4;
   	A[1][0]=0.1;
  	A[1][1]=0.5;

  	s=4.0*A[0][0]*A[1][1]-((A[0][1]+A[1][0])*(A[0][1]+A[1][0]));
    s=1.0/s;

    //A is the inverse of the covariance matrix for Mahalanobis distortion
	}


	double F(Point p)
	{
		return (A[0][0]*p.x*p.x+A[1][1]*p.y*p.y+(A[1][0]+A[0][1])*p.x*p.y);
	}

	double divergence(Point p, Point q)
	{
		Point r=new Point(p.x-q.x , p.y-q.y);
		return F(r);	
	}


	Point gradF(Point p)
	{
		return new Point( 2.0*A[0][0]*p.x+p.y*(A[0][1]+A[1][0]) ,  2.0*A[1][1]*p.y+p.x*(A[0][1]+A[1][0]) );
	}


	Point gradFinv(Point p)
	{


		return new Point( s*(2.0*A[1][1]*p.x-(A[0][1]+A[1][0])*p.y)  , s*(2.0*A[0][0]*p.y-(A[0][1]+A[1][0])*p.x ) ) ;
	}


}


// End of divergence classes    


//
// Begin projective point
//
class PPoint {

	public double x,y,w;

	PPoint(Point p)
	{
		x=p.x;
		y=p.y;
		w=1.0;
	}

	PPoint(double xx, double yy)
	{
		x=xx;
		y=yy;
		w=1.0;
	}

	PPoint()
	{x=y=0.0; w=1.0;}


	// Dehomogenization (perspective division)
	void Normalize()
	{
		if (w!=0) {x/=w; y/=w; w=1.0;}
	}




	// Return the ycoord corresponding to xcoord
	double XtoY(double xcoord)
	{
		return (-w-x*xcoord)/y;
	}


	void SetInfinite()
	{
		w=0.0;
	}

};

//
// Class Bregman disk
//
class BregmanDisk
{
	// Center and radius of the disk
	public Point center;
	public double rad;

	// Combinatorial basis
	public PointSet basis;

	BregmanDisk()
	{
		center=new Point();

		center.x=0.0;
		center.y=0.0;
		rad=0.0;

		basis=new PointSet(1);
		basis.array[0].x=center.x;
		basis.array[0].y=center.y;
	}


  BregmanDisk(Point P,double rr)
  {
    center=new Point();

    center.x=P.x;
    center.y=P.y;
    rad=rr;

 
  }

};

//
// The Bregman MiniBall class
//
class minibb
{
	/* intersection point is normalized */
	public PPoint b12, b13, b23,intersection;  
	PointSet set;
	BregmanDivergence DF;

	// Solution
	BregmanDisk bdisk;
	PointSet basis;

	minibb(PointSet ps, BregmanDivergence div)
	{
		set=new PointSet(ps,0);
		DF=div;

		// At most 3 points in a basis

		basis=new PointSet(0); 

		//bdisk=SolveDisc3(set.array[0],set.array[1],set.array[2]);
		//bdisk=SolveDisc2(set.array[0],set.array[1]);

		bdisk=MiniDisc(set,basis);

		/*println("Solution to Miniball: "+bdisk.center.x+" "+bdisk.center.y+" radius="+bdisk.rad+" basis size="+bdisk.basis.n);*/
	}


	PPoint CrossProduct(PPoint p1, PPoint p2)
	{
		PPoint result=new PPoint();

		result.x=p1.y*p2.w-p1.w*p2.y;
		result.y=p1.w*p2.x-p1.x*p2.w;
		result.w=p1.x*p2.y-p1.y*p2.x;

		return result;
	}

	double DotProduct(Point p,Point q)
	{
		return p.x*q.x+p.y*q.y;
	}

	//
	// Compute the linear equation of a Bregman Bisector (type 1)
	//
	PPoint BregmanBisector(Point p, Point q)
	{
		Point  gradp,gradq;
		PPoint result=new PPoint();

		//System.out.println("Bregman bisector of "+p.x+" "+p.y+" with "+q.x+" "+q.y);

		gradp=DF.gradF(p);
		gradq=DF.gradF(q);

		//
		// Equation of the bisector stored as a projective point
		//
		result.x=gradp.x-gradq.x;
		result.y=gradp.y-gradq.y;

		result.w=DF.F(p)-DF.F(q)+DotProduct(q,gradq)-DotProduct(p,gradp);

		return result;
	}

	//
	// Solve the basic problem for three points:
	// Note that not all disks can pass by three points
	//
	BregmanDisk SolveDisc3(Point d1, Point d2, Point d3)
	{
		BregmanDisk result=new BregmanDisk();


		b12=BregmanBisector(d1,d2);
		b13=BregmanBisector(d1,d3);
		b23=BregmanBisector(d2,d3);

		intersection=CrossProduct(b12,b13);
		intersection.Normalize();

		result.center.x=intersection.x;
		result.center.y=intersection.y;

		result.rad=DF.divergence(result.center, d1); // trisector

		result.basis=new PointSet(3);
		result.basis.array[0]=d1;
		result.basis.array[1]=d2;
		result.basis.array[2]=d3;

		return result;
	}


	//
	// Solve minimum divergence for two points 
	//
	public Point BBCPoint(double alpha, Point p, Point q)
	{
		Point gradfp,gradc;
		Point cc=new Point();

		gradfp=DF.gradF(q);
		gradfp.MultCste(1.0-alpha);

		gradc=DF.gradF(p);
		gradc.MultCste(alpha);

		gradc.AddPoint(gradfp);

		cc=DF.gradFinv(gradc);

		return cc;
	}

	BregmanDisk SolveDisc2(Point d1, Point d2)
	{
		BregmanDisk result=new BregmanDisk();
		double mindiv,div;
		int i,nbsteps=1000;
		double alpha;
		double increment=1.0/(double)nbsteps;

		/*
			 Point p=new Point();
			 b12=BregmanBisector(d1,d2);

			 mindiv=Double.MAX_VALUE;

			 for(i=0;i<nbsteps;i++)
			 {
			 alpha=(double)i/(double)nbsteps;
			 p=BBCPoint(alpha, d1,d2);

			 div=Math.abs(DF.divergence(p,d1)-DF.divergence(p,d2));
			 if (div<mindiv) 
			 {mindiv=div;
			 result.center=p;
			 }
			 }
			 */


		Point pq2=new Point();
		double lambda, lambdamin, lambdamax;

		lambdamin=0.0;
		lambdamax=1.0;

		while(Math.abs(lambdamax-lambdamin)>1.0e-5)
		{
			lambda=0.5*(lambdamin+lambdamax);
			pq2=BBCPoint(lambda, d1,d2);


			if (DF.divergence(pq2,d1)>DF.divergence(pq2,d2))
				lambdamin=lambda;
			else
				lambdamax=lambda;
		}

		result.center=pq2;

		result.rad=DF.divergence(result.center, d1); // should be mindiv
		result.basis=new PointSet(2);
		result.basis.array[0]=d1;
		result.basis.array[1]=d2;

		return result;
	}


	BregmanDisk SolveDisc1(Point c)
	{
		BregmanDisk result=new BregmanDisk();
		result.rad=0.0; 
		result.center=c;
		result.basis=new PointSet(1); 
		result.basis.array[0]=result.center;

		return result;
	}

	//
	// FallOutside bypasses the computation of the exact casis
	//
	boolean FallOutside(BregmanDisk b, Point p)
	{
		/*
			 if (b.basis.n==2)
			 {
		// Exact computation
		BregmanDisk d3=SolveDisc3(p,b.basis.array[0],b.basis.array[1]);

	  // Can the SEB of the basis be below d3.rad ?
		return SolveDisc2DP(b.basis.array[0],b.basis.array[1],d3.rad);
			 }
			 else
			 */ 
		if 	(DF.divergence(b.center,p)>b.rad) return true;
		else return false;
	}

	//
	// Miniball recursive algorithm "as is"
	// See Welzl's paper 
	//
	BregmanDisk MiniDisc(PointSet set, PointSet basis)
	{
		int k,b,n;


		b=basis.n;
		n=set.n;

		//System.out.println("Set size:"+set.n+" Basis size:"+basis.n);
		//set.PrintSet(); 
		//basis.PrintSet();

		//
		// Terminal cases
		//
		if (b==3)  
		{   BregmanDisk result;
			//	System.out.println("Solve terminal case with basis=3");
			result=SolveDisc3(basis.array[0], basis.array[1], basis.array[2]);
			return result;
		}
		// divergence is zero by definition
		if ((n==1)&&(b==0))
	 	{
	 		BregmanDisk result;
	 		result=SolveDisc1(set.array[0]);
	 		return result;}

		if ((n==2)&&(b==0))  
		{
			BregmanDisk result; 
			result=SolveDisc2(set.array[0],set.array[1]);
			return result;}

		if ((n==0)&&(b==2))  
		{BregmanDisk result;
			result=SolveDisc2(basis.array[0],basis.array[1]); 
			//	System.out.println("Terminal case b=2 n=0 "+result.rad);
			return result;
		}

		if ((n==1)&&(b==1))
		{BregmanDisk result;
		  result=SolveDisc2(basis.array[0], set.array[0]);
		  return result;} 

		//
		// General case
		//
		if (n+b>2)
		{
			BregmanDisk result;
			// Randomization: choosing a pivot
			k=int(random(n)); // between 0 and n-1

			if (k!=0) { 
				// Swap two points for a randomized miniball
				Point tmp=new Point();

				tmp=set.array[0];
				set.array[0]=set.array[k];
				set.array[k]=tmp;
			}

			//	System.out.println("Pivot "+k);

			// Copy the point set except the first element	
			PointSet remainset=new PointSet(set,1); 
			// Remove the first element
			result=MiniDisc(remainset,basis);

			// If the point falls outside the Bregman disk, this means that
			// it should belong to the basis
			//	if (DF.divergence(result.center,set.array[0])>result.rad)
			if (FallOutside(result,set.array[0]))
			{
				// Then point stored at set[0] necessarily belongs to the basis.
				//	basis.array[basis.n]=new Point();

				//	System.out.println("Upgrade basis "+basis.n);

				PointSet newbasis=new PointSet(basis,set.array[0]);

				//		System.out.println("... new basis "+newbasis.n);
				result=MiniDisc(remainset,newbasis);
			}	
			return result;
		}  // end of not terminal case

		// we should not reach that stage but Java requires to return some value for all paths
		return new BregmanDisk();  
	}


}

class Button{
  int xpos, ypos, wid, hei;
  String label;
  boolean over = false;
  boolean down = false; 
  boolean clicked = false;
  
  Button(String tlabel)
  {
    xpos = xbutton;
    ypos = ybutton;
    wid = ceil(textWidth(tlabel))+2*xpad;
    hei = hbutton;
    label = tlabel;

    xbutton = xbutton + wid + mbutton;
  }

  void update(){
    //it is important that this comes first
    if(down&&over&&!mousePressed){
      clicked=true;
    }else{
      clicked=false;
    }
    
    //UP OVER AND DOWN STATE CONTROLS
    if(mouseX>xpos && mouseY>ypos && mouseX<xpos+wid && mouseY<ypos+hei){
      over=true;
      if(mousePressed){
        down=true;
      }else{
        down=false;
      }
    }else{
      over=false;
    }
    smooth();
    
    //box color controls
    if(!over){
    	fill(buttonBgCol);
    }else{
    	fill(buttonOverBgCol);
    }
    stroke(buttonBorderCol);
    rect(xpos, ypos, wid, hei, 0); // draws the button, the last param is the round corners
    
    //Text Color Controls
    fill(buttonTextCol);
    text(label, xpos+xpad, ypos+hei-ypad); 
  } 
}

void changeDivergence(double wmix, double wmax, double wmiy, double wmay){
	worldminx = wmix;
	worldmaxx = wmax;
	worldminy = wmiy;
	worldmaxy = wmay;

	dataset=new PointSet(maxcard, DF);
	mini=new minibb(dataset, DF);
	BD=mini.bdisk;
	justinitialized=false;
}

class DropDown{

  int xpos, ypos, wid, hei;
  int xlabel, ylabel, wlabel;
  int sel;
  String label;
  ArrayList<String> items;
  boolean over = false;
  boolean overDeployed = false;
  boolean down = false; 

  DropDown(String tlabel)
  {
    wid = 100;
    hei = hbutton;

  	xlabel = xbutton;
  	ylabel = ybutton+hei;
    wlabel = ceil(textWidth(tlabel));

  	xbutton = xbutton + wlabel;
    xpos = xbutton;
    ypos = ybutton;
    label = tlabel;

    xbutton = xbutton + wid + mbutton;
    items = new ArrayList();
    sel = 0;
  }

  void addItem(String s) {
		items.add(s);
		int nwid = max(wid, ceil(textWidth(s))+2*xpad);
		xbutton = xbutton + (nwid-wid);
		wid = nwid;
  }

  void update(){
    //it is important that this comes first
    if(down&&!mousePressed){
      int nsel = -ceil((ypos-mouseY)/hei)-1;
      if(nsel >= 0 && nsel < items.size() && overDeployed && mouseY>ylabel){
      	sel = nsel;
  			switch(getSelectedString()) {
             
/*
    dFList.addItem("squared Euclidean");
  dFList.addItem("Kullback-Leibler");
  dFList.addItem("Itakura-Saito");
  dFList.addItem("Exponential");
  dFList.addItem("Csiszar (0.5)");
  dFList.addItem("squared Mahalanobis");
  dFList.addItem("Logistic Loss"
  */

case "squared Euclidean":
						DF=new L22();
						changeDivergence(-0.5,1.5,-0.5,1.5);
						break;
					case "Kullback-Leibler":
						DF=new KullbackLeibler();
						changeDivergence(0.0,1.5,0.0,1.5);
						break;
					case "Itakura-Saito":
						DF=new ItakuraSaito();
						changeDivergence(0.0,4.0,0.0,4.0);
						break;
					case "Exponential":
						DF=new EXP();
						changeDivergence(-0.5,1.5,-0.5,1.5);
						break;
					case "Csiszar (0.5)":
						DF=new Csiszar();
						changeDivergence(0.0,2.0,0.0,2.0);
						break;
					case "squared Mahalanobis":
						DF=new Mahalanobis();
						changeDivergence(-0.5,2.0,-0.5,2.0);
						break;
					case "Logistic Loss":
						DF=new LogisticLoss();
						changeDivergence(0.0,1.5,0.0,1.5);
						break;
					// Other DropDown List options go here
  			}
      }
    }else{
    }
    
    //UP OVER AND DOWN STATE CONTROLS
    if(mouseX>xpos && mouseY>ypos && mouseX<xpos+wid && mouseY<ypos+hei){
      over=true;
      if(mousePressed){
        down=true;
      }
    }else{
      over=false;
    }
    if(!mousePressed){
    	down=false;
    }
    if(down && mouseX>xpos && mouseY>ypos && mouseX<xpos+wid && mouseY<ylabel+items.size()*hei){
      overDeployed=true;
    }
    else{
    	overDeployed=false;
    }
    smooth();
    
    //box color controls
    if(!over){
      fill(255);
    }else{
      if(!down){
        fill(100);
      }else{
        fill(0);
      }
    }

    stroke(0);
    fill(buttonTextCol);
    text(label, xlabel, ylabel-ypad); // label

    fill(buttonBgCol);
    rect(xpos, ypos, wid, hei, 0); // button rectangle
    fill(0);
    text(items.get(sel), xpos+xpad, ylabel-ypad);
    
    // If drop-down
    if(down)
    {
    	stroke(0);
    	for( int i = 0 ; i < items.size() ; i++ )
    	{
    		if(i==sel){
    			fill(buttonSelCol);
    		}
    		else if(i== -ceil((ypos-mouseY)/hei)-1){
    			fill(buttonOverBgCol);
    		}
    		else{
    			fill(255);
    		}
    		rect(xpos,ylabel+i*hei,wid,hei);
    		fill(0);
    		text(items.get(i), xpos+xpad, ylabel+(i+1)*hei-ypad); 
    	}
    } // end if drop-down
  } // end update 

  String getSelectedString(){
  	return items.get(sel);
  }
} // end DropDown   
