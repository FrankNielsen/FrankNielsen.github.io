// Frank.Nielsen@acm.org
// December 2020, revised April 2021
// IPL O(n \log h)
// Classify the points in 5 types: maximal wrt to a quadrant or dominated (inside the orthogonal convex hull)

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import processing.pdf.*;


public enum TYPE {
  UpperRight, BottomRight, UpperLeft, BottomLeft
}

boolean anim=false;

boolean toggleOrthoCH=true;
boolean toggleMaximalQuadrant=false;
// Symmetrize



int n=24;

int FirstLayers=1;

float [] colorr, colorg, colorb;

int maxlayers=100;
int nb=100;

Point [] speed;

Point [] c;
double [] r;



int W=512;
int H=512;


int nQuadrant[]=new int[4];
Point[][] QuadrantLayers=new Point[4][];

ArrayList<Edge>  OrthoCH ;



ArrayList<Point> set ;
List<Point>  CH ;
Point [][] CHLayers;

int [] nLayers;

List<Point> setBR ;
List<Point>  CHBR ;
Point [][] CHLayersBR;
int [] nLayersBR;


boolean [] free;
int layer;
int nlayer=0;

double offset=100;
double maxx=W-offset;
double maxy=H-offset;
double minx=offset;
double miny=offset;

void InitializeColors()
{
  int i;
  colorr=new float[maxlayers];
  colorg=new float[maxlayers];
  colorb=new float[maxlayers];

  /*
 for(i=0;i<FirstLayers;i++)
   {
   colorr[i]=(float)(255.0*Math.random());
   colorg[i]=(float)(255.0*Math.random());
   colorb[i]=(float)(255.0*Math.random());
   }
   */

  // Blue
  colorr[0]=255;
  colorg[0]=0;
  colorb[0]=0;

  colorr[1]=0;
  colorg[1]=255;
  colorb[1]=0;

  colorr[2]=0;
  colorg[2]=0;
  colorb[2]=255;

  colorr[3]=255;
  colorg[3]=0;
  colorb[3]=255;


  colorr[4]=0;
  colorg[4]=255;
  colorb[4]=255;


  colorr[5]=128;
  colorg[5]=128;
  colorb[5]=255;
}

void InitializePoints()
{ 
  int i;

  InitializeColors();



  c=new Point[n];
  speed=new Point[n];

  // point position and speed vectors for animation
  for (i=0; i<n; i++)
  { 

    c[i]=new Point(0.1*W+0.6*W*Math.random(), 0.1*H+0.6*H*Math.random(), i);
    speed[i]=new Point(0.1*W*(-0.5+Math.random()), 0.1*H*(-0.5+Math.random()));
  }
}


// reflections wrt to x-axis and y-axis by setting order x ox and order y oy
ArrayList<Point>  Symmetrize(ArrayList<Point> s, int ox, int oy)
{
  int i, n;
  ArrayList<Point> res=new ArrayList<Point>();
  n=s.size();

  for (i=0; i<n; i++)
  {
    Point p=s.get(i);
    res.add(new Point(ox*p.x, oy*p.y));
  }

  return res;
}

//
// main initialization procedure
//
void Initialize()
{
  int i;

  List<Point> QuadrantLayer;
  set = new ArrayList<Point>();

  for (i=0; i<n; i++)
  { 
    set.add(new Point(c[i].x, c[i].y, i));
  }


  int orderx;
  int ordery;
  int quad=0;

  // 4 quadrants
  for (orderx=-1; orderx<=1; orderx+=2)
    for (ordery=-1; ordery<=1; ordery+=2)
    {

      QuadrantLayer=MaximalLayer.makeLayer(Symmetrize(set, orderx, ordery));

      int nb=nQuadrant[quad]=QuadrantLayer.size();
      QuadrantLayers[quad]=new Point[nQuadrant[quad]];

      for (i=0; i<nb; i++)
      {
        Point p=null;
        // sorting in ascending order
        if ((quad==1)||(quad==3)) p=QuadrantLayer.get(i);

        // sorting in descending order
        if ((quad==0)||(quad==2)) p=QuadrantLayer.get(nb-1-i);

        // remove the symmetry
        QuadrantLayers[quad][i]=new Point(p.x*orderx, p.y*ordery);
      }

      quad++;
    }
}


void setup()
{
  int i;
  size(512, 512);

  InitializePoints();

  Initialize();
}


void keyPressed() {
  if (key=='p') {
    exportPDF();
  }
  
   if (key=='o') {
    toggleOrthoCH=!toggleOrthoCH;
  }
  
    if (key=='m') {
    toggleMaximalQuadrant=!toggleMaximalQuadrant;
  }

  if (key=='a') {
    anim=!anim;
  }

  if (key=='.') {
    n=n/2;
    InitializePoints();
    Initialize();
    redraw();
  }
  if (key=='/') {
    n=n*2;
    InitializePoints();
    Initialize();
    redraw();
  }


  if (key==' ') {
    InitializePoints();
    Initialize();
  }

  if (key=='q') {
    exit();
  }
}
int nbcapture=0;

void exportPDF()
{
  String str=Integer.toString(nbcapture); nbcapture++;
  beginRecord(PDF, "OrthogonalConvexLayers-"+str+".pdf"); 
  draw();
  endRecord();
}

void strokefill(float r, float g, float b)
{
  stroke(r, g, b); 
  fill(r, g, b);
}

void ExportOrthoCH()
{
  int quad, i,j;
  Edge edge=new Edge();
  OrthoCH=new ArrayList<Edge>();
  
  for(quad=0;quad<4;quad++)
  {
  for (i=0; i<nQuadrant[quad]-1; i++)
      {
        Point p1=QuadrantLayers[quad][i];
        Point p2=QuadrantLayers[quad][i+1];
        
        
          if (quad==0) {edge=new Edge();
        edge.p1=new Point(p1.x,p1.y);
        edge.p2=new Point(p1.x,p2.y);
         OrthoCH.add(edge);edge=new Edge();
         edge.p1=new Point(p1.x,p2.y);
        edge.p2=new Point(p2.x,p2.y);
         OrthoCH.add(edge);
        }
        
        
        
          if (quad==1) {edge=new Edge();
        edge.p1=new Point(p1.x,p1.y);
        edge.p2=new Point(p2.x,p1.y);
         OrthoCH.add(edge);edge=new Edge();
         edge.p1=new Point(p2.x,p1.y);
        edge.p2=new Point(p2.x,p2.y);
         OrthoCH.add(edge);
        }
        
        
          if (quad==2) {edge=new Edge();
        edge.p1=new Point(p1.x,p1.y);
        edge.p2=new Point(p1.x,p2.y);
         OrthoCH.add(edge);edge=new Edge();
         edge.p1=new Point(p1.x,p2.y);
        edge.p2=new Point(p2.x,p2.y);
         OrthoCH.add(edge);
        }
        
        
        if (quad==3) {
         // println(".");
          edge=new Edge();
        edge.p1=new Point(p1.x,p1.y);
        edge.p2=new Point(p2.x,p1.y);
         OrthoCH.add(edge);edge=new Edge();
         edge.p1=new Point(p2.x,p1.y);
        edge.p2=new Point(p2.x,p2.y);
         OrthoCH.add(edge);
        }
        
       
      }
}

println("#edges:"+OrthoCH.size());
}


//
// Main drawing function of the orthogonal convex hull
//
void drawOneLayer()
{
  int i;
  background(255);

  if(toggleOrthoCH){  ExportOrthoCH();
  drawOrthoCH();}

  strokefill(255, 0, 0); 

  boolean [] drawQuad=new boolean[4];
  
  if (!toggleMaximalQuadrant){
 drawQuad[0]=false;
   drawQuad[1]=false;
   drawQuad[2]=false;
   drawQuad[3]=false;
  }
  else{
  drawQuad[0]=true;
  drawQuad[1]=true;
  drawQuad[2]=true;
  drawQuad[3]=true;
  }
  float nbpt=5;

  int quad;
  
      // draw point set first
    strokefill(0, 0, 0);//noFill();
    for (  i=0; i<n; i++)
    {  
      ellipse((float)c[i].x, (float)c[i].y, nbpt, nbpt);
    }
 
 
  for (quad=0; quad<4; quad++)
  {
    if (drawQuad[quad]) {
      println("drawing "+quad+" nb extrema:"+nQuadrant[quad]);
      
    

      for (i=0; i<nQuadrant[quad]; i++)
      {
        Point p1=QuadrantLayers[quad][i];
      
        if (quad==0)
        {   strokefill(colorr[quad], colorg[quad], colorb[quad]);
          rect(0, 0, (float)p1.x, (float)p1.y);
          //noFill();

stroke(0,0,0);noFill();
          line((float)p1.x, (float)p1.y, (float)p1.x, 1);
          line((float)p1.x, (float)p1.y, 1, (float)p1.y);
        }


        if (quad==1)
        { 
  strokefill(colorr[quad], colorg[quad], colorb[quad]);
          //fill(0,255,0);
          rect(0, (float)p1.y, (float)p1.x, H-(float)p1.y);
          // noFill();


stroke(0,0,0);noFill();
          line((float)p1.x, (float)p1.y, (float)p1.x, H);
          line((float)p1.x, (float)p1.y, 1, (float)p1.y); // ok

          //  stroke(0,0,0);noFill();
          //  ellipse((float)p1.x, (float)p1.y, 3, 3);
        }

        if (quad==2)
        { // blue
  strokefill(colorr[quad], colorg[quad], colorb[quad]);
          rect((float)p1.x, 0, W-(float)p1.x, (float)p1.y);
stroke(0,0,0);noFill();
          line((float)p1.x, (float)p1.y, (float)p1.x, 1);
          line((float)p1.x, (float)p1.y, W, (float)p1.y);
        }


        if (quad==3)
        { // purple
  strokefill(colorr[quad], colorg[quad], colorb[quad]);
          rect((float)p1.x, (float)p1.y, W-(float)p1.x, H-(float)p1.y);
          
          stroke(0,0,0);noFill();
          line((float)p1.x, (float)p1.y, (float)p1.x, H);
          line((float)p1.x, (float)p1.y, W, (float)p1.y);
        }
      }

    
    }
  } // end quad
  
  
  stroke(0,0,0);noFill();
  
   for (quad=0; quad<4; quad++)
  {
    if (drawQuad[quad]) {
      println("drawing "+quad+" nb extrema:"+nQuadrant[quad]);
      
    

      for (i=0; i<nQuadrant[quad]; i++)
      {
        Point p1=QuadrantLayers[quad][i];
      
        if (quad==0)
        {    
stroke(0,0,0);noFill();
          line((float)p1.x, (float)p1.y, (float)p1.x, 1);
          line((float)p1.x, (float)p1.y, 1, (float)p1.y);
        }


        if (quad==1)
        { 
 
 
          line((float)p1.x, (float)p1.y, (float)p1.x, H);
          line((float)p1.x, (float)p1.y, 1, (float)p1.y); // ok

          //  stroke(0,0,0);noFill();
          //  ellipse((float)p1.x, (float)p1.y, 3, 3);
        }

        if (quad==2)
        { // blue
 
          line((float)p1.x, (float)p1.y, (float)p1.x, 1);
          line((float)p1.x, (float)p1.y, W, (float)p1.y);
        }


        if (quad==3)
        { // purple
 
          line((float)p1.x, (float)p1.y, (float)p1.x, H);
          line((float)p1.x, (float)p1.y, W, (float)p1.y);
        }
      }

    
    }
  } // end quad
  
  

  
  for (quad=0; quad<4; quad++)
  {
    if (drawQuad[quad]) {
      println("drawing "+quad+" nb extrema:"+nQuadrant[quad]);
      
    

      for (i=0; i<nQuadrant[quad]; i++)
      {
        Point p1=QuadrantLayers[quad][i];
        
          strokefill(colorr[quad], colorg[quad], colorb[quad]);
   ellipse((float)p1.x, (float)p1.y, nbpt, nbpt);   
      noFill();
      stroke(0,0,0);
      strokeWeight(4);
ellipse((float)p1.x, (float)p1.y, 2*nbpt, 2*nbpt);
       strokeWeight(1);
      }

    
    }
  } // end quad
  

}

void drawOrthoCH()
{
 int i;
 
 strokefill(150,150,150);
 //stroke(50,50,50);
 strokeWeight(5);
 
 for(i=0;i<OrthoCH.size();i++)
 {
  Edge edge=OrthoCH.get(i);
  line((float)edge.p1.x,(float)edge.p1.y,(float)edge.p2.x,(float)edge.p2.y);
 }
  
  
  strokeWeight(1);
}

void draw()
{
  drawOneLayer();

  if (anim) animate();
}

//
// Main drawing procedure
//
void drawSeveralLayers()
{
  Point p1, p2;
  int i;
  background(255);

  strokefill(0, 0, 0);
  for (  i=0; i<n; i++)
  {  
    ellipse((float)c[i].x, (float)c[i].y, 3, 3);
  }

  strokefill(255, 0, 0); 


  for (int l=0; l<FirstLayers; l++)
  {
    strokefill(colorr[l], colorg[l], colorb[l]);

    if (nLayers[l]==1) {  
      p1=CHLayers[l][0]; 
      ellipse((float)p1.x, (float)p1.y, 10, 10);
    }

    p1=CHLayers[l][0];
    line((float)0, (float)p1.y, (float)p1.x, (float)p1.y);

    for (i=0; i<nLayers[l]-1; i++)
    {

      p1=CHLayers[l][i];
      p2=CHLayers[l][(i+1)%nLayers[l]];

      //strokefill(0.1,0.1,0.1);
      //vertical line
      /*
     line((float)p1.x, (float)p1.y, (float)p1.x, 0);
       line((float)p1.x, (float)p1.y, W, (float)p1.y);
       */



      line((float)p1.x, (float)p1.y, (float)p1.x, (float)p2.y);
      line((float)p1.x, (float)p2.y, (float)p2.x, (float)p2.y);

      ellipse((float)p1.x, (float)p1.y, 10, 10);
      //inefficient but ok
      ellipse((float)p2.x, (float)p2.y, 10, 10);
    }

    p1=CHLayers[l][nLayers[l]-1];
    line((float)p1.x, (float)p1.y, (float)p1.x, (float)H);
  }

  strokefill(0, 0, 0);
  textSize(32);
  String s=" "+nLayers[2]+" "+nLayers[3]+" "+nLayers[4];
  text("Maximal points:"+nLayers[0]+" "+nLayers[1]+s, 10, H-10);  //+" "+nLayers[2]

  if (anim) animate();
}


void animate()
{
  int i;
  //  set = new ArrayList<Point>();
  Point p;
  double scale=0.03;



  for (i=0; i<c.length; i++)
  { 

    p=c[i];



    p=new Point(c[i].x+scale*speed[i].x, c[i].y+scale*speed[i].y);
    c[i]=p;

    if (p.x>W) speed[i].x=-speed[i].x;  
    if (p.y>H) speed[i].y=-speed[i].y;
    if (p.x<0) speed[i].x= -speed[i].x;
    if (p.y<0) speed[i].y= -speed[i].y;
  }

  /*
  set = new ArrayList<Point>();
   
   for (i=0; i<c.length; i++)
   {
   set.add(c[i]);
   }
   */

  println("reinitialize animation");
  Initialize();


  //CH = MaximalLayer.makeLayer(set);
}


void drawCH()
{
  int i;
  background(255);


  noFill();

  stroke(0);

  for (int l=0; l<nlayer; l++)
  {
    for (i=0; i<nLayers[l]; i++)
    {
      Point p1, p2;
      p1=CHLayers[l][i];
      p2=CHLayers[l][(i+1)%nLayers[l]];

      //if (p1.id!=p2.id)
      { 
        line((float)p1.x, (float)p1.y, (float)p2.x, (float)p2.y);
      }
    }
  }


  stroke(255, 0, 0);
  fill(255, 0, 0);
  for (i=0; i<n; i++)
  {
    ellipse((float)c[i].x, (float)c[i].y, 10, 10);
  }

  /*
  stroke(255,0,0);
   fill(255,0,0);
   for(i=0;i<h;i++)
   {Point p1, p2;
   p1=CH.get(i);p2=CH.get((i+1)%h);
   if (p1.id!=p2.id) {ellipse((float)p1.x,(float)p1.y,5,5);
   ellipse((float)p2.x,(float)p2.y,5,5);
   }
   }
   */
}



class IdPoint  
{
  double x, y, id;
  IdPoint(double X, double Y, int ID)
  {
    x=X;
    y=Y; 
    id=ID;
  }

  IdPoint(double X, double Y)
  {
    x=X;
    y=Y;
  }
}
