// (C) 2015 Frank Nielsen, tested using Processing.org v 2.2.1
// "Introduction to HPC with MPI for Data Science", Springer UTiCS, 2016
// Program that implements Lloyd's k-means heuristic

// First time user: create/erase all files in output directory, launch program, press x and press q then look at png in directory output.
// manual: press 'q' for exit, 'n' for new set and ' ' for Lloyd assign/relocation/cost steps
// press 'p' for capture in png and pdf
// press 'l' for  Lloyd assign/relocation/cost steps with  capture in png and pdf
// 's' save point set   'l' load point set

import processing.pdf.*;

class cigWPoint {
  double x, y, w; 
  cigWPoint() {
    x=0;
    y=0;
    w=1;
  } 
  cigWPoint(double xx, double yy, double ww) {
    x=xx; 
    y=yy; 
    w=ww;
  } 
  void add(cigWPoint q) {
    x+=q.x;
    y+=q.y;
  }
  void divide(double nb) {
    x/=nb; 
    y/=nb;
  }
}

cigWPoint [] set;
cigWPoint [] center;
int NMAX=4000;
int n=100;
int k=9;
color [] colorCluster;
int [] label;
int pointwidth=3;
int displaySide=750;
int capturenb=0;
int nbiter=0;
double loss;

boolean toggleVoronoi=false;

double Distance(cigWPoint p, cigWPoint q) {
  if ((p==null)||(q==null)) return Double.MAX_VALUE; // in case of empty centers
  return (p.x-q.x)*(p.x-q.x) + (p.y-q.y)*(p.y-q.y);
}

int argminDistance(cigWPoint q)
{
  int winner=0; 
  double mdist=Distance(q, center[0]);
  for (int j=1; j<k; j++) {
    if (Distance(q, center[j])<mdist) {
      mdist=Distance(q, center[j]); 
      winner=j;
    }
  }
  return winner;
}

double cost()
{
  double res=0;
  int i;
  for (i=0; i<n; i++) {
    if (Distance(set[i], center[label[i]])!=Double.MAX_VALUE) res+=set[i].w*Distance(set[i], center[label[i]]);
  }
  return res;
}

void randomSeedForgy()
{
  cigWPoint tmp;
  int j; 
  center=new cigWPoint[k];
  for (int i=0; i<k; i++) {
    j=(int)random(i, k-1); 
    tmp=set[i];
    set[i]=set[j];
    set[j]=tmp;
    center[i]=set[i];
  }
}

void assignPointToCluster()
{
  label=new int[n];
  for (int i=0; i<n; i++ ) label[i]=argminDistance(set[i]);
}

// relocate the center to the centroid
void relocateCenter()
{
  center=new cigWPoint[k];
  int i;
  for (i=0; i<k; i++) center[i]=new cigWPoint(0, 0, 1);
  double [] nb=new double[k];


  for (i=0; i<n; i++) {
    nb[label[i]]+=set[i].w; 
    center[label[i]].add(set[i]);
  }
  for (i=0; i<k; i++) {
    if (nb[i]!=0.0) center[i].divide(nb[i]);
    else {
      center[i]=null;
      println("empty cluster happened in Lloyd"); 
      exit();
    }
  }

  nbiter++;
}

void palette() {
  colorCluster[0]=color(255, 0, 0);
  colorCluster[1]=color(255, 255, 0);
  colorCluster[2]=color(0, 255, 0);
  colorCluster[3]=color(0, 255, 255);
  colorCluster[4]=color(0, 0, 255);
  colorCluster[5]=color(255, 0, 255);
  colorCluster[6]=color(127, 127, 127);
  colorCluster[7]=color(0, 0, 0);
}


void drawRandomClusterColor()
{
  colorCluster=new color[k];

  if (k==8) palette(); 
  else {
    for (int i=0; i<k; i++ )colorCluster[i]=color(random(0, 255), random(0, 255), random(0, 255));
  }
}

void drawRandomPoints()
{
  set=new cigWPoint[n];

  for (int i=0; i<n; i++ )
  {
    float x = random(20, width-20);
    float y = random(20, height-20);
    set[i] = new cigWPoint(x, y, 1);
  }

  nbiter=0;
}


void setup() {
  size(displaySide, displaySide); 
  drawRandomPoints(); 
  drawRandomClusterColor();
  randomSeedForgy();
  assignPointToCluster();
  relocateCenter();
  println(cost());
}

// procedure pour visualiser le clustering
void draw()
{
  background(255);
  stroke(0);
  fill(0);
  for (int i=0; i<n; i++)
  { 
    if (label!=null) {
      stroke(0);
      line((int)center[label[i]].x, (int)center[label[i]].y, (int)set[i].x, (int)set[i].y);
      stroke(colorCluster[label[i]]); 
      fill(colorCluster[label[i]]);
    }
    ellipse((int)set[i].x, (int)set[i].y, pointwidth, pointwidth);
  }

  if (center!=null)
  { 
    for (int i=0; i<k; i++) {
      stroke(colorCluster[i]); 
      fill(colorCluster[i]);
      ellipse((int)center[i].x, (int)center[i].y, 3*pointwidth, 3*pointwidth);
    }

    // cost 
    stroke(0);
    fill(0);
    textSize(26); 
    text("k-means objective function:"+nfs((float)cost(), 10, 3)+" Iteration #"+nbiter, 10, 20);
  }
}

void capture(String tag)
{
  {
    String filename="output/kmeans-"+capturenb+"-"+tag+"-"+loss;
    capturenb++;
    draw();
    saveFrame(filename+".png");
    beginRecord(PDF, filename+".pdf"); 
    draw();
    endRecord();
  }
}

void keyPressed()
{
  if (key=='q') exit();

  if (key=='>') {
    n*=2; 
    if (n>NMAX) n=NMAX; 
    capturenb=0; 
    drawRandomPoints(); 
    drawRandomClusterColor();
    randomSeedForgy();
    assignPointToCluster();
    relocateCenter();
    draw();
    println("n="+n);
  }


  if (key=='<') {
    n/=2; 
    if (n>NMAX) n=NMAX; 
    capturenb=0; 
    drawRandomPoints(); 
    drawRandomClusterColor();
    randomSeedForgy();
    assignPointToCluster();
    relocateCenter();
    draw();
    println("n="+n);
  }



  if (key=='a') {
    assignPointToCluster();
    println(cost());
    draw();
  }


  if (key=='r') {  
    relocateCenter();
    println(cost());
    draw();
  }


  if (key==' ') {
    assignPointToCluster();
    relocateCenter();  
    println(cost());
    draw();
  }

  if (key=='n') {
    capturenb=0; 
    drawRandomPoints(); 
    drawRandomClusterColor();
    randomSeedForgy();
    assignPointToCluster();
    relocateCenter();
    nbiter=1;
    println(cost());
  }

  if (key=='v') {
    toggleVoronoi=!toggleVoronoi;
  }

  if (key=='p')
  {
    capture("screen");
  }

  // full Lloyd k-means
  if (key=='x')
  {
    double floss=-1;
    loss=Double.MAX_VALUE;
    capturenb=0; 
    drawRandomPoints(); 
    drawRandomClusterColor();
    randomSeedForgy();

    while (loss!=floss) {
      assignPointToCluster();
      // capture("assign");
      floss=loss;
      loss=cost();
      relocateCenter();
      print(".");
      // capture("relocate");
    }
  }


  if (key=='l')
  {
    assignPointToCluster();
    capture("assign");
    relocateCenter();  
    capture("relocate"); 
    println(cost());
    draw();
  }

  if (key=='s') {
    savePointSet("data/pointset.csv");
  }

  if (key=='f') {
    loadPointSet("data/pointset.csv");
  }
}


void savePointSet(String filename)
{
  Table table;
  table = new Table();
  table.addColumn("x");
  table.addColumn("y");
  table.addColumn("w");
  for (int i=0; i<n; i++) {
    TableRow newRow = table.addRow();
    newRow.setFloat("x", (float)set[i].x);
    newRow.setFloat("y", (float)set[i].y);
    newRow.setFloat("w", (float)set[i].w);
  }

  saveTable(table, filename);
}


void loadPointSet(String filename)
{
  Table table = loadTable(filename, "header");
  n=table.getRowCount();
  set=new cigWPoint[n];
  int i=0;
  for (TableRow row : table.rows()) {

    float xx = row.getFloat("x");
    float yy = row.getFloat("y");
    float ww = row.getFloat("w");
    set[i++]=new cigWPoint(xx, yy, ww);
  }
}
