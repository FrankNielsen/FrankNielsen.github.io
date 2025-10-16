// Frank.Nielsen@acm.org

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

import processing.pdf.*;

boolean anim=true;


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


int n=32;
int maxlayers=100;
int nb=100;

Point [] speed;

Point [] c;
double [] r;



int W=512;
int H=512;
List<Point> set ;
List<Point>  CH ;
Point [][] CHLayers;
int [] nLayers;
boolean [] free;
int layer;
int nlayer=0;

double offset=100;
double maxx=W-offset;
double maxy=H-offset;
double minx=offset;
double miny=offset;




void Initialize()
{
  int i;

  c=new Point[n];
  free=new boolean[n];
  r=new double [n];
  CHLayers=new Point[n][];
  nLayers=new int[n];

  set = new ArrayList<Point>();
  speed=new Point[n];

  for (i=0; i<n; i++)
  { 

    c[i]=new Point(0.1*W+0.8*W*Math.random(), 0.1*H+0.8*H*Math.random(), i);
    speed[i]=new Point(0.1*W*(-0.5+Math.random()), 0.1*H*(-0.5+Math.random()));

    set.add(new Point(c[i].x, c[i].y, i));
    free[i]=true;
  }
  nlayer=0;

  layer=0;

  while (nlayer<n)
  {
    //CH=ConvexHull.makeHull(set);
    CH=MaximalLayer.makeLayer(set);
    nLayers[layer]=CH.size();
    nlayer+=CH.size();
    CHLayers[layer]=new Point[CH.size()];
    println(CH.size());

    for (i=0; i<CH.size(); i++)
    {
      Point p=CH.get(i);
      free[p.id]=false;
      CHLayers[layer][i]=p;
    }

    set = new ArrayList<Point>();
    for (i=0; i<n; i++)
    {
      if (free[i]) set.add(c[i]);
    }

    layer++;

    if (layer==1) break;
  }
}

void setup()
{
  int i;
  size(512, 512);

  Initialize();
}


void keyPressed() {
  if (key=='p') {
    exportPDF();
  }

  if (key=='a') {
    int i=0;  
    while (i<300) { 
      Initialize();
      redraw();
      i++;
    }
  }

  if (key=='.') {
    n=n/2;
    Initialize();
    redraw();
  }
  if (key=='/') {
    n=n*2;
    Initialize();
    redraw();
  }


  if (key==' ') {
    Initialize();
  }

  if (key=='q') {
    exit();
  }
}

void exportPDF()
{
  beginRecord(PDF, "MaximalLayers.pdf"); 
  draw();
  endRecord();
}

void draw()
{
  int i;
  background(255);



  stroke(0);
  fill(0);

  for (int l=0; l<set.size(); l++)
  {
    Point p=set.get(l);
    ellipse((float)p.x, (float)p.y, 5, 5);
  }

  stroke(255, 0, 0); 
  fill(255, 0, 0);

  for (int l=0; l<nlayer; l++)
  {
    for (i=0; i<nLayers[l]; i++)
    {
      Point p1, p2;
      p1=CHLayers[l][i];
      p2=CHLayers[l][(i+1)%nLayers[l]];
      { 
        ellipse((float)p1.x, (float)p1.y, 10, 10);
      }
    }
  }

  if (anim) animate();
}


void animate()
{
  int i;
  //  set = new ArrayList<Point>();
  Point p;
  double scale=0.1;

  println("**n="+n);
  for (i=0; i<c.length; i++)
  { 

    p=new Point(c[i].x+scale*speed[i].x, c[i].y+scale*speed[i].y);
    c[i]=p;

    if (p.x>maxx) speed[i]=new Point(-speed[i].x, speed[i].y);
    if (p.y>maxy) speed[i]=new Point(speed[i].x, -speed[i].y);
    if (p.x<minx) speed[i]=new Point(-speed[i].x, speed[i].y);
    ;
    if (p.y<miny) speed[i]=new Point(speed[i].x, -speed[i].y);
  }

  set = new ArrayList<Point>();

  for (i=0; i<c.length; i++)
  {
    set.add(c[i]);
  }
  CH = MaximalLayer.makeLayer(set);
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
