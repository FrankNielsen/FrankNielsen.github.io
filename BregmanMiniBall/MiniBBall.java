//
// Miniball extended to arbitrary Bregman divergences
//
// Java Applet that demonstrates the generalization of the MiniBall algorithm of Welzl
// Compiled using SUN Java Standard Edition J2SE 5.0
//
// Frank NIELSEN, May 2006
//
// Frank.Nielsen@acm.org

import java.awt.*;
import java.awt.event.*;
import java.util.Random;
import java.awt.image.*;

//
// Java Applet class   
//
public class MiniBBall extends java.applet.Applet 
{
int maxcard;
BregmanDivergence DF=new L22();
PointSet dataset= new PointSet(maxcard,DF);

//
// Center point, maximum radius
//
Point center;
double radius;

minibb mini;
BregmanDisk BD;



//
// Window size 
//
int w, h;
Dimension dim;
boolean justinitialized;

Font helveticafont;
Label title;
InputPanel inputPanel;
ImageCanvas imageCanvas;


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
// Applet initialization 
//
public void init()
{
int i;

maxcard=20;

dim=getSize();
w=getSize().width;
h=getSize().height;

System.out.println("MiniBBall: Computing Exactly the Smallest Bregman Balls by Frank Nielsen and Richard Nock. May 2006.");
System.out.println("Applet MiniBBall launched on "+dim);

helveticafont=new Font("Helvetica", Font.ITALIC,16);
        	
        setLayout(new BorderLayout());

		inputPanel = new InputPanel(this);
		inputPanel.setSize(w, 200);
		add("North", inputPanel);
			
		imageCanvas = new ImageCanvas(this);
		imageCanvas.setSize(500,500);
		imageCanvas.w=500;
		imageCanvas.h=500;
		
		add("Center", imageCanvas);
	
		
	DF=new L22();

	imageCanvas.worldminx=-0.5;
	imageCanvas.worldmaxx=1.5;
	imageCanvas.worldminy=-0.5;
	imageCanvas.worldmaxy=1.5;
	
	
	dataset=new PointSet(maxcard, DF);
	
	 mini=new minibb(dataset,DF);
	BD=mini.bdisk;
		
		justinitialized=false;

}

public void paint(Graphics g)
{}

public String getAppletInfo() 
{
    return "Computes  the exact smallest enclosing Bregman ball of a point set";
}

}


//
// Control panel
//
class InputPanel extends Panel implements ActionListener, ItemListener, AdjustmentListener {
    
    Button applyButton;
    Label title;
    //
	// UI
	//
	Button refreshButton, newsetButton;
	Button miniballButton;
	
	 Scrollbar slider;	// for parameter n
	
	CheckboxGroup radioDFGroup; 
	Checkbox radioDFL22; 
 	Checkbox radioDFKL; 
 	Checkbox radioDFIS; 
 	Checkbox radioDFEXP; 
 	Checkbox radioDFCSIS;
 	Checkbox radioDFMAH;
 	Checkbox radioDFLL;

    MiniBBall applet;

    InputPanel(MiniBBall applet) {
	
	this.applet = applet;
	this.setBackground(Color.white);
	
	setLayout(new BorderLayout());

		title = new Label("MiniBBall:  Smallest Enclosing Bregman Ball by F. Nielsen and R. Nock", Label.CENTER);

		title.setFont(applet.helveticafont);
		title.setBackground(Color.white);
		add("North", title);
		
		Panel p = new Panel();
		p.setLayout(new BorderLayout());
		
		
		Panel pp=new Panel();
		refreshButton=new Button("Refresh");
		newsetButton=new Button("Draw a new Set");
	
		pp.add("East",refreshButton);
		pp.add("Center",newsetButton);
	
		
		Panel pb= new Panel();
	
		miniballButton=new Button("Mini Bregman Ball");
		pb.add("Center", miniballButton);
	
		
		p.add("North",pp);
		p.add("Center",pb);
		
		slider = new Scrollbar(Scrollbar.HORIZONTAL,30 ,10, 2, 1000);
		p.add("South", slider);
		slider.addAdjustmentListener(this);
	
		
		add("Center", p);

		newsetButton.addActionListener(this);
		refreshButton.addActionListener(this);

	
		miniballButton.addActionListener(this);
	

		  radioDFGroup = new CheckboxGroup(); 
          radioDFL22 = new Checkbox("Squared Euclidean", radioDFGroup,true); 
          radioDFKL = new Checkbox("KullBack-Leibler", radioDFGroup,false); 
          radioDFIS= new Checkbox("Itakura-Saito", radioDFGroup,false); 
          radioDFEXP= new Checkbox("Exponential", radioDFGroup,false);
          radioDFCSIS= new Checkbox("Csiszar", radioDFGroup,false);
          radioDFMAH= new Checkbox("Mahalanobis", radioDFGroup,false);
          radioDFLL= new Checkbox("Logistic Loss", radioDFGroup,false);
          
          
         radioDFL22.addItemListener(this);
         radioDFKL.addItemListener(this);
         radioDFIS.addItemListener(this);
         radioDFEXP.addItemListener(this);  
         radioDFCSIS.addItemListener(this);  
          radioDFMAH.addItemListener(this);  
           radioDFLL.addItemListener(this);  
          
 
		Panel pc=new Panel();
		pc.setLayout(new GridLayout(4,2));
		
        pc.add(new Label("Bregman divergence:"));
		pc.add(radioDFL22);
		pc.add(radioDFKL);
		pc.add(radioDFIS);
		pc.add(radioDFEXP);
		pc.add(radioDFCSIS);
		pc.add(radioDFMAH);
	    pc.add(radioDFLL);
		
		add("East",pc);
		
		
		
    } 
    

public void actionPerformed(ActionEvent event)
{
	    Object obj = event.getSource();

if (obj==refreshButton)
		{
		applet.imageCanvas.repaint();
		}
		
if (obj==newsetButton)
		{
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
		applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
		applet.imageCanvas.repaint();
		}		
		
	
// Compute the smallest enclosing ball
if (obj==miniballButton)
		{
	  	
	  	// recompute the smallest enclosing disk
	  	applet.mini=new minibb(applet.dataset, applet.DF);
	  	// get the smallest enclosing disk
		applet.BD=applet.mini.bdisk;
		applet.justinitialized=false;
	  	applet.imageCanvas.repaint();
		}
 
		
}
    
    // Slider
    public void adjustmentValueChanged(AdjustmentEvent e) {
    	 applet.maxcard=slider.getValue();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
	applet.justinitialized=true;
		applet.imageCanvas.repaint();
	} 

	// Get the choice item events here
    public void itemStateChanged(ItemEvent e) {
    	
    	
    		if (radioDFKL.getState()==true)
		{
		applet.imageCanvas.worldminx=0.0;
			applet.imageCanvas.worldmaxx=1.5;
			applet.imageCanvas.worldminy=0.0;
				applet.imageCanvas.worldmaxy=1.5;

		applet.DF=new KullbackLeibler();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
		applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		
		
		if (radioDFIS.getState()==true)
		{
			applet.imageCanvas.worldminx=0.0;
			applet.imageCanvas.worldmaxx=4.0;
			applet.imageCanvas.worldminy=0.0;
			applet.imageCanvas.worldmaxy=4.0;

		applet.DF=new ItakuraSaito();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
	applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		
		if (radioDFL22.getState()==true)
		{
			applet.imageCanvas.worldminx=-0.5;
			applet.imageCanvas.worldmaxx=1.5;
			applet.imageCanvas.worldminy=-0.5;
			applet.imageCanvas.worldmaxy=1.5;

			applet.DF=new L22();
			applet.dataset=new PointSet(applet.maxcard, applet.DF);
		applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		
		if (radioDFEXP.getState()==true)
		{
			applet.imageCanvas.worldminx=-0.5;
			applet.imageCanvas.worldmaxx=1.5;
			applet.imageCanvas.worldminy=-0.5;
			applet.imageCanvas.worldmaxy=1.5;

			applet.DF=new EXP();
			applet.dataset=new PointSet(applet.maxcard, applet.DF);
		  applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		    applet.imageCanvas.repaint();
			
			}
			
			
				if (radioDFCSIS.getState()==true)
		{
		applet.imageCanvas.worldminx=0.0;
			applet.imageCanvas.worldmaxx=2.0;
			applet.imageCanvas.worldminy=0.0;
				applet.imageCanvas.worldmaxy=2.0;

		applet.DF=new Csiszar();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
	applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		
		
			if (radioDFMAH.getState()==true)
		{
		applet.imageCanvas.worldminx=-0.5;
			applet.imageCanvas.worldmaxx=2;
			applet.imageCanvas.worldminy=-0.5;
				applet.imageCanvas.worldmaxy=2;

		applet.DF=new Mahalanobis();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
	applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		
		
			if (radioDFLL.getState()==true)
		{
		applet.imageCanvas.worldminx=0.0;
			applet.imageCanvas.worldmaxx=1.5;
			applet.imageCanvas.worldminy=0.0;
				applet.imageCanvas.worldmaxy=1.5;

		applet.DF=new LogisticLoss();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
		applet.mini=new minibb(applet.dataset, applet.DF);
		applet.BD=applet.mini.bdisk;
			applet.justinitialized=false;
		applet.imageCanvas.repaint();
		}
		

	} 
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
	
	for(i=0;i<n;i++)
	System.out.println(i+" "+array[i].x+" "+array[i].y);
	
}

// Constructor
PointSet(int card)
{
	int i;
	Random rand =new Random();

	n=card;
	
	if (n>0)
	{
	array=new Point[card];

	// Uniform point set on the unit square
	for(i=0;i<n;i++)
		{
		array[i]=new Point();
		array[i].x=0.1+0.9*rand.nextDouble();
		array[i].y=0.1+0.9*rand.nextDouble();
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
	Random rand =new Random();
	Point centerball=new Point(rand.nextDouble(),rand.nextDouble());
	double radiusball=0.5+rand.nextDouble();
	double rad;
	Point drawpoint=new Point();

	n=card;

	centerball.x=0.5;
	centerball.y=0.5;

radiusball=BD.divergence(centerball, new Point(0.1,0.1));

	System.out.println("I have choosen theoretical center "+centerball.x+" "+centerball.y+" and divergence radius:"+radiusball);
	

	
	array=new Point[card];

	// Uniform point set on the unit square
	for(i=0;i<n;i++)
		{
		array[i]=new Point();

		drawpoint.x=rand.nextDouble();
		drawpoint.y=rand.nextDouble();
		
		while ( BD.divergence( centerball, drawpoint ) > radiusball )
		{
		drawpoint.x=rand.nextDouble();
		drawpoint.y=rand.nextDouble();
		}

		array[i].x=drawpoint.x;
		array[i].y=drawpoint.y;
		}
		
		System.out.println("Point set drawn.");
}


} // End of  point set class



//
// Canvas part for drawing the point set and Bregman ball
//
class ImageCanvas extends Canvas {
   MiniBBall applet;
   int w,h; // Dimension of the drawing canvas
  
//
// Bounding box of the world
//
double worldminx,worldmaxx;
double worldminy,worldmaxy;

BufferedImage bi;
Graphics2D big;



//
// Convert point set coordinates to screen display coordinates
//
int xToX(double x)
{
return (int)Math.rint(w*(x-worldminx)/(worldmaxx-worldminx));
}

int yToY(double y)
{
return h-(int)Math.rint(h*(y-worldminy)/(worldmaxy-worldminy));
}


//
// Convert screen display coordinates to point set coordinates
//
double Xtox(int X)
{
return worldminx+((double)X/(double)w)*(worldmaxx-worldminx);
}

double Ytoy(int Y)
{
return worldminy+((double)(h-Y)/(double)h)*(worldmaxy-worldminy);
}

//
// Draw a geodesic 
//
public void drawGeodesic(Graphics gg, Point source, Point dest)
{
int i;
int xx1,yy1;
int xx2,yy2;
int nbsteps=10;

double alpha;
double increment=1.0/(double)nbsteps;


for(i=0;i<nbsteps;i++)
	{
	alpha=(double)i/(double)nbsteps;
	Point p=applet.BBCPoint(alpha, source, dest);
	Point pp=applet.BBCPoint(alpha+increment, source, dest);

	xx1=xToX(p.x);
	yy1=yToY(p.y);
	xx2=xToX(pp.x);
	yy2=yToY(pp.y);

gg.drawLine(xx1,yy1,xx2,yy2);	
}

}
// end of geodesic

    ImageCanvas(MiniBBall applet) {	
	this.applet = applet;
	setBackground(Color.white);
	
	System.out.println("Initialization...");
	bi = new BufferedImage(500,500, BufferedImage.TYPE_INT_RGB);

	System.out.println("Graphics Initialization...");
    big = bi.createGraphics();
    
    System.out.println("Double image buffer created");
    
    
    }
    
//
// Brute force method for drawing the Bregman Ball
// (Level set approach)
//
public void drawBregmanBall(Graphics g)
{
int i,j;
Point p=new Point();

g.setColor(Color.orange);

for(i=0;i<h;i++)
{
	p.y=Ytoy(i);
	
	for(j=0;j<w;j++)
	{
	p.x=Xtox(j);
	if (applet.DF.divergence(applet.center,p)<applet.radius) g.fillRect(j,i, 1, 1);
	}
}

}

public void drawBregmanBall(Graphics g, BregmanDisk bd)
{
int i,j;
Point p=new Point();

g.setColor(Color.orange);

for(i=0;i<h;i++)
{
	p.y=Ytoy(i);
	
	for(j=0;j<w;j++)
	{
	p.x=Xtox(j);
	if (applet.DF.divergence(bd.center,p)<bd.rad) g.fillRect(j,i, 1, 1);
	}
}

}

//
// Draw the line associated to the homogeneous point 
//
void DrawLineProjectivePoint(Graphics g, PPoint p)
{
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

g.drawLine(xx1,yy1,xx2,yy2);	

}

}


public void DrawPoint(Graphics gg, Point p, int pwidth)
{
int xx,yy;
	
xx=xToX(p.x);
yy=yToY(p.y);

gg.fillRect(xx-pwidth/2, yy-pwidth/2, pwidth, pwidth);
}

//
// The painting procedure for drawing the Bregman ball and its point set
//
public void paint()
{
paint(getGraphics() );	}

public void paint(Graphics g) {	
int i;
int xx,yy;
int xx1,yy1,xx2,yy2;

System.out.println("Redrawing graphics with double buffering image...");

big.setBackground(Color.white);
big.setColor(Color.white);
big.clearRect(0, 0, 500,900);

big.setColor(Color.black);
big.setFont(applet.helveticafont);

if (applet.justinitialized!=true) drawBregmanBall(big,applet.BD);

big.setColor(Color.black);

for(i=0;i<applet.dataset.n;i++)
	{
	DrawPoint(big,applet.dataset.array[i],3);
	}

if (applet.justinitialized!=true)
{
//
// Draw the basis
//
big.setStroke(new BasicStroke( 2.0f )); 

if (applet.BD.basis.n==3)
{
DrawLineProjectivePoint(big, applet.mini.b12);
DrawLineProjectivePoint(big, applet.mini.b13);
DrawLineProjectivePoint(big, applet.mini.b23);


big.setColor(Color.green);
drawGeodesic(big,applet.BD.basis.array[0],applet.BD.basis.array[1]);
drawGeodesic(big,applet.BD.basis.array[1],applet.BD.basis.array[2]);
drawGeodesic(big,applet.BD.basis.array[0],applet.BD.basis.array[2]);

big.setColor(Color.red);
DrawPoint(big,applet.BD.basis.array[0],7);
DrawPoint(big,applet.BD.basis.array[1],7);
DrawPoint(big,applet.BD.basis.array[2],7);

}

if (applet.BD.basis.n==2)
{
PPoint l12=applet.DF.BregmanBisector(applet.BD.basis.array[0],applet.BD.basis.array[1]);	
DrawLineProjectivePoint(big,l12);

big.setColor(Color.green);
drawGeodesic(big,applet.BD.basis.array[0],applet.BD.basis.array[1]);
big.setColor(Color.red);
DrawPoint(big,applet.BD.basis.array[0],7);
DrawPoint(big,applet.BD.basis.array[1],7);
}

big.setColor(Color.cyan);
DrawPoint(big,applet.BD.center,9);

big.setStroke(new BasicStroke( 1.0f )); 
}

big.setColor(Color.black);
big.drawString("Bregman Divergence:"+applet.DF.name+"(n="+applet.maxcard+")", 5, 15);


g.setColor(Color.white);
g.fillRect(0,0,900,50);


g.drawImage(bi, 0, 0, this);  
           
g.setColor(Color.red);  
g.drawString("Center point:"+applet.BD.center.x+" "+applet.BD.center.y+" Radius:"+applet.BD.rad, 5, 30);
    }
    
}
//
// End of image canvas
//


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

//System.out.println("Bregman bisector of "+p.x+" "+p.y+" with "+q.x+" "+q.y);

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

// Random generator for choosing the pivot
Random random;

minibb(PointSet ps, BregmanDivergence div)
{
set=new PointSet(ps,0);
DF=div;

// At most 3 points in a basis

basis=new PointSet(0); 




random=new Random();

//bdisk=SolveDisc3(set.array[0],set.array[1],set.array[2]);
//bdisk=SolveDisc2(set.array[0],set.array[1]);

bdisk=MiniDisc(set,basis);

System.out.println("Solution to Miniball: "+bdisk.center.x+" "+bdisk.center.y+" radius="+bdisk.rad+" basis size="+bdisk.basis.n);
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
		k=Math.abs(random.nextInt())%n; // between 0 and n-1

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



