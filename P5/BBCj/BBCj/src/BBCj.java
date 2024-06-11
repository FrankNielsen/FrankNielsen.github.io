 //
// "On Approximating the Smallest Enclosing Bregman Balls"
//
// Applet for the 22nd ACM Symposium on Computational Geometry (SoCG 2006)
// http://www.cs.arizona.edu/~socg06/
//
// Java Applet that demonstrates the generalization of the iterative approximation algorithm
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
public class BBCj extends java.applet.Applet 
{
final int maxcard=50;
BregmanDivergence DF=new L22();
PointSet dataset= new PointSet(maxcard,DF);
Point circumcenter, FermatWeber, centroid;

//
// Points for BBC
//
Point center, furthestpoint;
int iter;
double radius;

//
// History
//
final static int maxhistory=1000; // keep at most 1000 points
PointSet historycenter=new PointSet(maxhistory);
double[] historyradius=new double[maxhistory];
int history=0;


//
// Window size 
//
int w, h;
Dimension dim;
boolean justinitialized;

Font helveticafont;
TextArea messageArea;
Label title;
InputPanel inputPanel;
ImageCanvas imageCanvas;


//
// Compute the furthest point to a point set
//
Point FurthestPoint(Point p)
{
int i,winner;
double div,maxdiv=0.0;

winner=0;

for(i=0;i<dataset.n;i++)
	{
		div=DF.divergence(p,dataset.array[i]);
		if (div>maxdiv) {maxdiv=div; winner=i;}
	}
return dataset.array[winner];
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
// Initialize the BBC algorithm:
// Choose at random a point and seek for a furthest point
//
public void InitializeBBC()
{
Random rand =new Random();
int pos;

pos=Math.abs(rand.nextInt())%dataset.n;
System.out.println("Choosing at random the seed point: Index "+pos+" of "+dataset.n);
center=dataset.array[pos];
historycenter.array[0]=center;

furthestpoint=FurthestPoint(center);
radius=MaxDivergence(center);

justinitialized=false;
iter=1;
history=1;

}

//
// Interpolation for the geodesic
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
// One iteration of the BBC algorithm
//
public void OneIterationBBC()
{
Point gradfp,gradc, cc;
double alpha;

// Move the center
alpha=(double)iter/(double)(iter+1.0);


gradfp=DF.gradF(furthestpoint);
gradfp.MultCste(1.0-alpha);
gradc=DF.gradF(center);
gradc.MultCste(alpha);

gradc.AddPoint(gradfp);
center=DF.gradFinv(gradc);

iter=iter+1;
radius=MaxDivergence(center);
furthestpoint=FurthestPoint(center);


if (history<1000) {
//
// Update (center,radius) history here
//
historycenter.array[history]=center;
historyradius[history]=radius;
  history++;
  }
}

//
// Many iterations
//
public void TenIterationBBC()
{int i;
for(i=0;i<1000;i++) 
{
OneIterationBBC();
}
}

//
// Applet initialization 
//
public void init()
{
int i;

dim=getSize();
w=getSize().width;
h=getSize().height;

System.out.println("BBCj:  Fitting the smallest enclosing balls by Frank Nielsen and Richard Nock. May 2006.");
System.out.println("Applet BBCj launched on "+dim);

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
	
		messageArea = new TextArea("", 3, 1);
		messageArea.setEditable(false);	
		messageArea.setBackground(Color.white);
		add("South", messageArea);
	
	  
		messageArea.setText("F.Nielsen and R. Nock: On Approximating the Smallest Enclosing Bregman Balls.  SoCG 2006\nR. Nock, F.Nielsen: Fitting the Smallest Enclosing Bregman Ball. ECML 2005: 649-656\nF. Nielsen: Visual Computing: Geometry, Graphics, and Vision. Charles River Media: ISBN: 1584504277  (2005)");

	//
	// Initialization for BBC
	//       
	DF=new L22();

	imageCanvas.worldminx=-0.5;
	imageCanvas.worldmaxx=1.5;
	imageCanvas.worldminy=-0.5;
	imageCanvas.worldmaxy=1.5;
	
	
	dataset=new PointSet(maxcard, DF);
	InitializeBBC();
}

public void paint(Graphics g)
{}

public String getAppletInfo() 
{
    return "Computes iteratively approximations of the smallest enclosing Bregman ball of a point set";
}

}


//
// Control panel: control the BBCj applet
//
class InputPanel extends Panel implements ActionListener, ItemListener, AdjustmentListener {
    
    Button applyButton;
    Label title;
    //
	// UI
	//
	Button refreshButton, newsetButton, initButton;
	Button oneiterationButton, teniterationButton;
	
	CheckboxGroup radioDFGroup; 
	Checkbox radioDFL22; 
 	Checkbox radioDFKL; 
 	Checkbox radioDFIS; 
 	Checkbox radioDFEXP; 
 	Checkbox radioDFCSIS;
 	Checkbox radioDFMAH;
 	Checkbox radioDFLL;

    BBCj applet;

    InputPanel(BBCj applet) {
	
	this.applet = applet;
	this.setBackground(Color.white);
	
	setLayout(new BorderLayout());

		title = new Label("BBCj - On Approximating the Smallest Enclosing Bregman Ball by F. Nielsen and R. Nock", Label.CENTER);

		title.setFont(applet.helveticafont);
		title.setBackground(Color.white);
		add("North", title);
		
		Panel p = new Panel();
		p.setLayout(new BorderLayout());
		
		
		Panel pp=new Panel();
		refreshButton=new Button("Refresh");
		newsetButton=new Button("Draw a new Set");
		initButton = new Button("BBC Initialize");
		pp.add("East",refreshButton);
		pp.add("Center",newsetButton);
		pp.add("West",initButton);
		
		Panel pb= new Panel();
		oneiterationButton=new Button("One BBC Iteration");
		teniterationButton=new Button("Many BBC Iterations");
		pb.add("West",oneiterationButton);
		pb.add("East",teniterationButton);
		
		p.add("North",pp);
		p.add("Center",pb);
	
		
		add("Center", p);

		newsetButton.addActionListener(this);
		refreshButton.addActionListener(this);

		initButton.addActionListener(this);
		oneiterationButton.addActionListener(this);
		teniterationButton.addActionListener(this);


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
		applet.InitializeBBC();
		applet.imageCanvas.repaint();
		}		
		
		
if (obj==initButton)
		{
		applet.InitializeBBC();
		applet.imageCanvas.repaint();
		}

if (obj==oneiterationButton)
		{
		applet.OneIterationBBC();
		applet.imageCanvas.paint();
		}

if (obj==teniterationButton)
		{
		applet.TenIterationBBC();
		applet.imageCanvas.paint();
		}
		
}
    
    // Slider
    public void adjustmentValueChanged(AdjustmentEvent e) {
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
		applet.InitializeBBC();
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
		applet.InitializeBBC();
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
		applet.InitializeBBC();
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
		    applet.InitializeBBC();
		    applet.imageCanvas.repaint();
			
			}
			
			
				if (radioDFCSIS.getState()==true)
		{
		applet.imageCanvas.worldminx=0.0;
			applet.imageCanvas.worldmaxx=1.5;
			applet.imageCanvas.worldminy=0.0;
				applet.imageCanvas.worldmaxy=1.5;

		applet.DF=new Csiszar();
		applet.dataset=new PointSet(applet.maxcard, applet.DF);
		applet.InitializeBBC();
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
		applet.InitializeBBC();
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
		applet.InitializeBBC();
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

// Constructor
PointSet(int card)
{
	int i;
	Random rand =new Random();

	n=card;
	array=new Point[card];

	// Uniform point set on the unit square
	for(i=0;i<n;i++)
		{
		array[i]=new Point();
		array[i].x=0.1+0.9*rand.nextDouble();
		array[i].y=0.1+0.9*rand.nextDouble();
		}
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

	// We need to get an idea of a Bregman ball
//	PointSet ptst=new PointSet(card);

	centerball.x=0.5;
	centerball.y=0.5;

/*	for(i=0;i<n;i++)
		{
		centerball.x+=ptst.array[i].x;
		centerball.y+=ptst.array[i].y;
		}

	centerball.x=(1.0/n)*centerball.x;
	centerball.y=(1.0/n)*centerball.y;

	radiusball=0.0;
	for(i=0;i<n;i++)
		{
		rad=BD.divergence(centerball, ptst.array[i]);
		if (rad>radiusball) radiusball=rad;
		}
*/

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
   BBCj applet;
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

//for(alpha=0; alpha<1.0; alpha+=increment)
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
//	g.fillRect(xx-1, yy-1, 3, 3);
}

}
// end of geodesic

    ImageCanvas(BBCj applet) {	
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

//
// The painting procedure for drawing the Bregman ball and its point set
//
public void paint()
{
paint(getGraphics() );
	}

public void paint(Graphics g) {	
int i;
int xx,yy;
int xx1,yy1,xx2,yy2;

System.out.println("Redrawing graphics...");

//setBackground(Color.white);
big.setBackground(Color.white);
big.setColor(Color.white);
big.clearRect(0, 0, 500,900);


drawBregmanBall(big);


big.setColor(Color.black);
big.setFont(applet.helveticafont);

big.drawString("Bregman Divergence:"+applet.DF.name+" (Iteration "+applet.iter+")", 5, 15);


for(i=0;i<applet.dataset.n;i++)
{
xx=xToX(applet.dataset.array[i].x);
yy=yToY(applet.dataset.array[i].y);

// We draw points as rectangles
big.fillRect(xx-1, yy-1, 3, 3);
}


if (applet.justinitialized == false)
{
xx1=xToX(applet.center.x);
yy1=yToY(applet.center.y);
xx2=xToX(applet.furthestpoint.x);
yy2=yToY(applet.furthestpoint.y);



big.setColor(Color.green);
if (applet.DF.type!=1) drawGeodesic(big,applet.center, applet.furthestpoint);
else big.drawLine(xx1,yy1,xx2,yy2);

big.setColor(Color.blue);
big.fillRect(xx2-3, yy2-3, 7, 7);

//
// Is there some history to draw ?
//
if (applet.history>0) 
	{ 
	//
	// Draw all geodesics
	//
	big.setColor(Color.red);
	
	for(i=0;i<applet.history-1;i++)
		{
			/*
		xx1=xToX(applet.historycenter.array[i].x);
		yy1=yToY(applet.historycenter.array[i].y);

		xx2=xToX(applet.historycenter.array[i+1].x);
		yy2=yToY(applet.historycenter.array[i+1].y);

		g.drawLine(xx1,yy1,xx2,yy2);
		*/
		
		drawGeodesic(big, applet.historycenter.array[i],applet.historycenter.array[i+1]);
		}
	}
	//draw the center position
big.setColor(Color.cyan);
big.fillRect(xx1-3, yy1-3, 7, 7);
}
  


g.setColor(Color.white);
g.fillRect(0,0,900,50);

g.drawImage(bi, 0, 0, this);  
           
g.setColor(Color.red);  
g.drawString("Center point:"+applet.center.x+" "+applet.center.y+" Radius:"+applet.radius+" "+applet.iter, 5, 30);


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





