/* 
Nov 2015
Fast stabbing of boxes in high dimensions. 
Frank Nielsen
Theoretical Computer Science 246(1-2): 53-72 (2000)
http://www.sciencedirect.com/science/article/pii/S0304397598003363

@Article{n-fsbhd-2000,
 author = {Frank Nielsen},
 title = {Fast stabbing of boxes in high dimensions},
 journal = {Theoretical Computer Science},
 volume = {246},
 number = {1/2},
 year = {2000},
 issn = {0304-3975},
 pages = {53--75},
 publisher = {Elsevier Science Publishers Ltd.},
 doi= {10.1016/S0304-3975(98)00336-3}
 }
 
On point covers of c-oriented polygons. 
Frank Nielsen
Theoretical Computer Science  263(1-2): 17-29 (2001)

see CCCG 1996 and also

Maintenance of a Piercing Set for Intervals with Applications. 
Matthew J. Katz, Frank Nielsen, Michael Segal
Algorithmica 36(1): 59-73 (2003)

The heuristics compute in output-sensitive time an approximation of :
- a maximum independent set of rectangles  (axis-parallel also called isothetic d-dimensional boxes, independent set into k pairwise non-connected vertices)
- a minimum clique cover of rectangles (vertices of a graph can be partitioned into k cliques)
without computing the intersection graph (that would require quadratic time)


Original code by Frank Nielsen, converted to processing code (11/2015) by Antoine Chatalic.
*/

import java.util.ArrayList;

import processing.pdf.*;

private Button reset;
private Button pierce;
private Button about;
private DropDown randomdd;
private DropDown selectalg;
private int x1;
private int y1;
private int x2;
private int y2;
private int Xp;
private int Yp;
private int DXp;
private int DYp;
private boolean addingRect; // true if currently hand-drawing a rectangle
private ArrayList VRect;
private ArrayList VPPoints;
private ArrayList VIRect;
private int WIDTH;
private int HEIGHT;
private int salg;
private int ABOUT;

private int xbutton;
private int ybutton;
private int hbutton;
private int mbutton;
private int xpad;
private int ypad;
private int hmenu;

private String tRects;
private String tIRects;
private String tPoints;

private color bgcol = color(253);	// Background color
private color bgbordercol = color(200); // Canvas frame color
private color buttonBgCol = bgcol; // Buttons background color
private color buttonOverBgCol = color(240); // Buttons background color
private color buttonSelCol = color(200); // Buttons background color
private color buttonBorderCol = color(0); // Buttons border color
private color buttonTextCol = buttonBorderCol; // Buttons text color
private color rectsCol = color(0); // Rectangles color
private color bgRectDistinctCol = color(20,133,204,30);  // Non-overlapping rectangles bg color
private color pointsCol = color(220,18,18); // Stabbing points color

boolean showTop=true;

void keyPressed()
{
  
  if (key=='q') exit();
  
if (key=='p') {
// save into pdf 
showTop=false;
 beginRecord(PDF, "stabbing-snapshot.pdf");
 draw();
 endRecord();
 showTop=true;
}
}

void settings() {
  size(800, 500); // Warning: Can't use variables WIDTH and HEIGHT here!
  WIDTH = 800;
  HEIGHT = 500;
}

void setup() {
	
  /*fullScreen();*/

  frameRate(30);

	tRects = "Rectangles : ";
	tPoints = "Stabbing points : ";
	tIRects = "Size of computed pairwise nonintersecting set : ";

	mbutton = 8;
	xpad = 8;
	ypad = 5;
	xbutton = mbutton;
	ybutton = mbutton;
  textSize(12); 
	hbutton = ceil(textAscent())+2*ypad;
	hmenu = 2*ypad+2*mbutton+ceil(textAscent());

  VRect = new ArrayList(20);
  VPPoints = new ArrayList(20);
  VIRect = new ArrayList(20);
  background(255,255,255);
  stroke(0);

  reset = new Button("Reset");
  pierce = new Button("Pierce");
  about = new Button("About");
  randomdd = new DropDown("Random generation : ");
  randomdd.addItem("20 rectangles");
  randomdd.addItem("50 rectangles");
  randomdd.addItem("100 rectangles");
  randomdd.addItem("200 rectangles");
  randomdd.addItem("500 rectangles");
  randomdd.addItem("1000 rectangles");
  /*randomdd.addItem("10000 rectangles");*/

  salg = 2;
  selectalg = new DropDown("Heuristics : ");
  selectalg.addItem("Heuristic 1, 1996");
  selectalg.addItem("Heuristic 2, 1997");
  selectalg.sel = 1;
} 

void draw() {
	background(bgcol);
	stroke(bgbordercol);
	fill(0,0,0,0);
	rect(0,0,WIDTH-1,HEIGHT-1);

  if(ABOUT == 1)
  {
		fill(buttonTextCol);
		int xab = 100;
    text("Piercing Isothetic Boxes / Report an Independent Set", xab, 100);
    text("Nielsen Frank, Frank.Nielsen@acm.org", xab+60, 115);
    text("An output-sensitive precision-sensitive algorithm", xab, 140);
    text("DOES NOT COMPUTE THE INCIDENCE/INTERSECTION GRAPH", xab, 160);
  }
  else {
  	stroke(0);
  	fill(bgRectDistinctCol);
  	int l = VIRect.size()
  ;
  	for(int i = 0; i < l; i++)
  	{
    	Rectangle rectangle = (Rectangle)VIRect.get(i);
    	rect(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
  	}

  	fill(0,0,0,0);
  	stroke(rectsCol);
  	l = VRect.size();
  	byte byte0 = 5;
  	for(int j = 0; j < l; j++)
  	{
    	Rectangle rectangle1 = (Rectangle)VRect.get(j);
    	rect(rectangle1.x, rectangle1.y, rectangle1.width, rectangle1.height);
  	}

  	l = VPPoints.size();
  	fill(pointsCol);
  	stroke(pointsCol);
  	for(int k = 0; k < l; k++)
  	{
    	Point point = (Point)VPPoints.get(k);
    	ellipse(point.x,point.y,6,6);
  	}
  }

if (showTop){
  reset.update();
  if(reset.clicked) {
  	VRect.clear();
  	VIRect.clear();
  	VPPoints.clear();
		ABOUT=0;
  }

  pierce.update();
  if(pierce.clicked) {
		actionPierce();
  }

  about.update();
  if(about.clicked) {
		ABOUT=1;
  }
  
  randomdd.update();
  selectalg.update();

	if(addingRect){
		stroke(0,0,255);
		fill(0,0,0,0);
  	rect(min(x1,mouseX), min(y1,mouseY), abs(x1-mouseX), abs(y1-mouseY));
  }
}

	String tmpS = tRects + VRect.size() + "  -  " + tPoints + VPPoints.size() + "  -  " + tIRects + VIRect.size();
	fill(buttonTextCol);
	text(tmpS, mbutton, HEIGHT-mbutton-ypad);
}

void randomRectangles(int c){
	ABOUT=0;
  ArrayList vector = new ArrayList(c);
  VRect.clear();
  for(int i = 0; i < c; i++)
  {
    int j1 = ceil(random(mbutton,WIDTH-mbutton));
    int j2 = ceil(random(mbutton,WIDTH-mbutton));
    int k1 = ceil(random(hmenu,HEIGHT-hmenu));
    int k2 = ceil(random(hmenu,HEIGHT-hmenu));
    Rectangle rectangle3 = new Rectangle(min(j1,j2), min(k1,k2), abs(j1-j2), abs(k1-k2));
    VRect.add(rectangle3);
    vector.add(rectangle3);
  }

	actionPierce();
}

void changeHeuristic(int i){
	if(i==2 || i==1){
		salg = i;
	}
	actionPierce();
}

void actionPierce(){
	if(VRect.size()>0){
  	Pierce pierce1 = new Pierce(VRect);
  	if(salg == 1)
  	  pierce1.Alg1();
  	if(salg == 2)
  	  pierce1.Alg2();
  	VPPoints = pierce1.VPoints;
  	VIRect = pierce1.VIRectangles;
  }
}

void mousePressed(){
	ABOUT=0;
	if(mouseY>hmenu){
  	addingRect = true;
    x1 = mouseX;
    y1 = mouseY;
  }
}

void mouseReleased(){
	if(addingRect){
  	addingRect = false;
  	int rectw = abs(mouseX-x1);
  	int recth = abs(mouseY-y1);
    x1 = min(mouseX,x1);
    y1 = min(mouseY,y1);
    Rectangle newrect = new Rectangle(x1, y1, rectw, recth);
    VRect.add(newrect);
  }
}

class IntervalSet
{

  private int n;
  private int Xmed;
  private int x[];
  private int y[];
  public ArrayList<Point> ISVPoints;
  public ArrayList<Point> VIindex;

  public IntervalSet(int i, int ai[], int ai1[], int j)
  {
    n = i;
    x = new int[n];
    y = new int[n];
    for(int k = 0; k < i; k++)
    {
      x[k] = ai[k];
      y[k] = ai1[k];
    }

    ISVPoints = new ArrayList(0);
    VIindex = new ArrayList(0);
    Xmed = j;
  }

  public IntervalSet(int i, Rectangle arectangle[], int j)
  {
    n = i;
    x = new int[n];
    y = new int[n];
    for(int k = 0; k < i; k++)
    {
      x[k] = arectangle[k].x;
      y[k] = arectangle[k].x + arectangle[k].height;
    }

    ISVPoints = new ArrayList(0);
    VIindex = new ArrayList(0);
    Xmed = j;
  }

  public void ISPierce()
  {
    int ai[] = new int[n];
    int l = 0;
    for(int i = 0; i < n; i++)
      ai[i] = 0;

    while(l < n) 
    {
      int i1 = 0;
      int j1 = 0;
      for(int j = 0; j < n; j++)
        if(x[j] >= i1 && ai[j] == 0)
        {
          i1 = x[j];
          j1 = j;
        }

      Point point = new Point(Xmed, i1);
      Point point1 = new Point(j1, j1);
      ISVPoints.add(point);
      VIindex.add(point1);
      for(int k = 0; k < n; k++)
        if(ai[k] == 0 && x[k] <= i1 && y[k] >= i1)
        {
          l++;
          ai[k] = 1;
        }

    }
  }
}

class Pierce
{

  private int n;
  private int x[];
  private int y[];
  public ArrayList VPoints;
  public ArrayList VIRectangles;

  public Pierce(ArrayList vector)
  {
    n = vector.size();
    x = new int[2 * n];
    y = new int[2 * n];
    for(int i = 0; i < n; i++)
    {
      Rectangle rectangle = (Rectangle)vector.get(i);
      x[i] = rectangle.x;
      y[i] = rectangle.y;
      x[i + n] = x[i] + rectangle.width;
      y[n + i] = y[i] + rectangle.height;
    }

    VPoints = new ArrayList(5);
    VIRectangles = new ArrayList(5);
  }

  public void Alg1()
  {
    Statistic statistic = new Statistic(2 * n, x);
    int i2 = statistic.Median(n);
    int k1;
    int l1;
    int j1 = k1 = l1 = 0;
    for(int i = 0; i < n; i++)
      if(x[i] <= i2 && x[n + i] >= i2)
        l1++;
      else
        if(x[i] < i2)
          j1++;
        else
          k1++;

    int ai[] = new int[l1];
    int ai1[] = new int[l1];
    ArrayList vector = new ArrayList(j1);
    ArrayList vector1 = new ArrayList(k1);
    l1 = 0;
    for(int j = 0; j < n; j++)
      if(x[j] <= i2 && x[n + j] >= i2)
      {
        ai[l1] = y[j];
        ai1[l1++] = y[n + j];
      } else
      {
        Rectangle rectangle = new Rectangle(x[j], y[j], x[j + n] - x[j], y[j + n] - y[j]);
        if(x[j] < i2)
          vector.add(rectangle);
        else
          vector1.add(rectangle);
      }

    if(l1 > 0)
    {
      IntervalSet intset = new IntervalSet(l1, ai, ai1, i2);
      intset.ISPierce();
      for(int k = 0; k < intset.ISVPoints.size(); k++)
        VPoints.add(intset.ISVPoints.get(k));

    }
    if(j1 > 0)
    {
      Pierce pierce = new Pierce(vector);
      pierce.Alg1();
      for(int l = 0; l < pierce.VPoints.size(); l++)
        VPoints.add(pierce.VPoints.get(l));

    }
    if(k1 > 0)
    {
      Pierce pierce1 = new Pierce(vector1);
      pierce1.Alg1();
      for(int i1 = 0; i1 < pierce1.VPoints.size(); i1++)
        VPoints.add(pierce1.VPoints.get(i1));

    }
  }

  public void Alg2()
  {
    int ai[] = new int[n];
    int ai1[] = new int[n];
    for(int i = 0; i < n; i++)
    {
      ai[i] = x[i];
      ai1[i] = x[i + n];
    }

    IntervalSet intset = new IntervalSet(n, ai, ai1, 0);
    intset.ISPierce();

    int l3 = ((Point)intset.ISVPoints.get((int)(intset.ISVPoints.size() / 2))).y;
    int k2;
    int l2;
    int j2 = k2 = l2 = 0;
    int j3;
    int k3;
    int i3 = j3 = k3 = 0;
    for(int j = 0; j < n; j++)
      if(x[j] <= l3 && x[n + j] >= l3)
        l2++;
      else
        if(x[j] < l3)
          j2++;
        else
          k2++;

    Rectangle arectangle[] = new Rectangle[l2];
    ArrayList vector = new ArrayList(j2);
    ArrayList vector1 = new ArrayList(k2);
    l2 = 0;
    for(int k = 0; k < n; k++)
      if(x[k] <= l3 && x[n + k] >= l3)
      {
        arectangle[l2] = new Rectangle(x[k], y[k], x[k + n] - x[k], y[k + n] - y[k]);
        l2++;
      } else
      {
        Rectangle rectangle = new Rectangle(x[k], y[k], x[k + n] - x[k], y[k + n] - y[k]);
        if(x[k] < l3)
          vector.add(rectangle);
        else
          vector1.add(rectangle);
      }

    Rectangle1D rectangle1d = new Rectangle1D(l2, arectangle, l3);
    if(l2 > 0)
    {
      rectangle1d.R1DPierce();
      for(int l = 0; l < rectangle1d.VPoints.size(); l++)
        VPoints.add(rectangle1d.VPoints.get(l));

      k3 = rectangle1d.VIRectangles.size();
    }
    Pierce pierce = new Pierce(vector);
    if(j2 > 0)
    {
      pierce.Alg2();
      i3 = pierce.VIRectangles.size();
      for(int i1 = 0; i1 < pierce.VPoints.size(); i1++)
        VPoints.add(pierce.VPoints.get(i1));

    }
    Pierce pierce1 = new Pierce(vector1);
    if(k2 > 0)
    {
      pierce1.Alg2();
      j3 = pierce1.VIRectangles.size();
      for(int j1 = 0; j1 < pierce1.VPoints.size(); j1++)
        VPoints.add(pierce1.VPoints.get(j1));

    }
    if(i3 + j3 <= k3)
    {
      for(int k1 = 0; k1 < k3; k1++)
        VIRectangles.add(rectangle1d.VIRectangles.get(k1));

    } else
    {
      for(int l1 = 0; l1 < i3; l1++)
        VIRectangles.add(pierce.VIRectangles.get(l1));

      for(int i2 = 0; i2 < j3; i2++)
        VIRectangles.add(pierce1.VIRectangles.get(i2));

    }
  }

  public int size()
  {
    return n;
  }
}

 class Rectangle1D
{

    public Rectangle1D(int i, Rectangle arectangle[], int j)
    {
        n = i;
        R = new Rectangle[i];
        for(int k = 0; k < i; k++)
            R[k] = arectangle[k];

        VPoints = new ArrayList(0);
        VIRectangles = new ArrayList(0);
        Xmed = j;
    }

    public void R1DPierce()
    {
        int j1 = -1;
        int ai[] = new int[n];
        int l = 0;
        for(int i = 0; i < n; i++)
            ai[i] = 0;

        while(l < n) 
        {
            int i1 = 0;
            for(int j = 0; j < n; j++)
                if(R[j].y >= i1 && ai[j] == 0)
                {
                    i1 = R[j].y;
                    j1 = j;
                }

            Point point = new Point(Xmed, i1);
            Rectangle rectangle = new Rectangle(R[j1].x, R[j1].y, R[j1].width, R[j1].height);
            VPoints.add(point);
            VIRectangles.add(rectangle);
            for(int k = 0; k < n; k++)
                if(ai[k] == 0 && R[k].y <= i1 && R[k].y + R[k].height >= i1)
                {
                    l++;
                    ai[k] = 1;
                }

        }
    }

    private int n;
    private int Xmed;
    private Rectangle R[];
    public ArrayList VPoints;
    public ArrayList VIRectangles;
}

class Statistic
{

    public Statistic(int i, int ai[])
    {
        n = i;
        tab = new int[n];
        for(int j = 0; j < n; j++)
            tab[j] = ai[j];

    }

    public int Median(int i)
    {
        int j = 0;
        if(n == 1)
        {
            j = tab[0];
        } else
        {
            int k = tab[0];
            int k1 = 0;
            int l1 = 0;
            for(int l = 0; l < n; l++)
            {
                if(tab[l] < k)
                    k1++;
                if(tab[l] > k)
                    l1++;
            }

            if(i <= k1)
            {
                int ai[] = new int[k1];
                k1 = 0;
                for(int i1 = 0; i1 < n; i1++)
                    if(tab[i1] < k)
                        ai[k1++] = tab[i1];

                Statistic statistic = new Statistic(k1, ai);
                j = statistic.Median(i);
            }
            if(i > n - l1)
            {
                int ai1[] = new int[l1];
                l1 = 0;
                for(int j1 = 0; j1 < n; j1++)
                    if(tab[j1] > k)
                        ai1[l1++] = tab[j1];

                Statistic statistic1 = new Statistic(l1, ai1);
                j = statistic1.Median((i - n) + l1);
            }
            if(i > k1 && i <= n - l1)
                j = k;
        }
        return j;
    }

    private int tab[];
    private int n;
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
  				case "20 rectangles":
  					randomRectangles(20);
  					break;
  				case "50 rectangles":
  					randomRectangles(50);
  					break;
  				case "100 rectangles":
  					randomRectangles(100);
  					break;
  				case "200 rectangles":
  					randomRectangles(200);
  					break;
  				case "500 rectangles":
  					randomRectangles(500);
  					break;
  				case "1000 rectangles":
  					randomRectangles(1000);
  					break;
  				case "10000 rectangles":
  					randomRectangles(10000);
  					break;

  				case "Heuristic 1, 1996":
  					changeHeuristic(1);
  					break;
  				case "Heuristic 2, 1997":
  					changeHeuristic(2);
  					break;
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

class Rectangle {

	int x, y, width, height;

	Rectangle(int xx, int yy, int ww, int hh) {
		x = xx;
		y = yy;
		width = ww;
		height = hh;
	}

}

class Point {

	int x, y;

	Point(int xx, int yy) {
		x = xx;
		y = yy;
	}

}