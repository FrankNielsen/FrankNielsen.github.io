/* 
 (C) 2015 Frank Nielsen  Frank.Nielsen@acm.org
 
 Implementation of Charikar heuristic for finding an 
 approximation of the best dense subgraph (2-approximation)
 
 Scenario 1: press 's'elect et 'd'elete until you obtain null graph
 Scenario 2: press 'e'xample graph, 'b' to visualize dense subgraph

 - 'q' exit 
 - 'b' find approximate best dense subgraph
 - 'r' print rho density 
 - ' ' draw new random graph
 - 's' select min deg node
 - 'd' delete selected from graph
 - 'a' erase densest subgraph (for viz.)
 - 'e' load example graph
 - 'p' save pdf
 - 'h' print current graph
 
 January 2015, Frank.Nielsen@acm.org
 
Beware the implementation of this algorithm is in $O(n^3)$ non optimal
 */

int n=11;
int w=800, h=400;
double threshold=0.15;
float delta=10.0f;
graph G, denseG=null;
int nodes=-1;
int border=50;
int step=0;
double bestd;

import processing.pdf.*;

int [] coords = {
  39, 192, 127, 62, 116, 305, 290, 351, 260, 196, 230, 29, 370, 31, 395, 139, 472, 266, 610, 154,  618, 342
};

int[][] adj= {
  { 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0 }
  , { 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 }
  , { 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0 }
  , { 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 }
  , {0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0 }
  , { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 }
  , {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 }
  , { 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0}
  , { 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1 }
  , {0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
  , { 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 }
};

void ExampleGraph()
{
  G=new graph(11);
  int i, j;
  for (i=0; i<11; i++) {G.tabnode[i]=new node(coords[2*i], coords[2*i+1], str(i));}

  for (i=0; i<11; i++)
    for (j=0; j<11; j++)
      if (adj[i][j]==1) G.adjacency[i][j]=true; 
      else  G.adjacency[i][j]=false;
  savepdf();
}

// draw a random graph
void randomGraph(graph G)
{
  int i, j, nn=G.n;

  G.tabnode=new node[nn];
  for (i=0; i<n; i++)
  {
    G.tabnode[i]=new node((double)random(border, w-border), (double)random(border, h-border), str(i));
  }

  G.adjacency=new boolean[nn][nn];
  for (i=0; i<nn; i++)
    for (j=i+1; j<nn; j++)
    {
      if (random(0, 1)<threshold) {
        G.adjacency[i][j]=true; 
        G.adjacency[j][i]=true;
      }
    }
}

void setup()
{
  size(w, h);
  G=new graph(n);
  ExampleGraph();
  // randomGraph(G);
  bestd=G.density();
  textSize(26); 
  savepdf();
}


void drawGraph(graph GG)
{
  int i, j;
  int nn=GG.n;

  if (nn>0) {

    for (i=0; i<nn; i++)
      for (j=i+1; j<nn; j++)
        if (GG.adjacency[i][j]) {
          // draw edge
          line((float)GG.tabnode[i].x, (float)GG.tabnode[i].y, (float)GG.tabnode[j].x, (float)GG.tabnode[j].y );
        }

    for (i=0; i<nn; i++)
    {
      ellipse((float)(GG.tabnode[i].x), (float)(GG.tabnode[i].y), delta, delta);
    }


    for (i=0; i<nn; i++)
    {
      text(GG.tabnode[i].label, (float)(GG.tabnode[i].x+delta), (float)(GG.tabnode[i].y+delta));
    }
  }
}

void draw()
{
  background(255);

  stroke(0);
  fill(0);
  drawGraph(G);
  fill(0);

  if (denseG==null) text("density: "+G.density(), w/2, 20);

  if (denseG!=null) {
    strokeWeight(3);
    stroke(0);
    drawGraph(denseG);
    text("best density: "+denseG.density(), w/2, 20);
    strokeWeight(1);
  }


  if (nodes!=-1) {
    strokeWeight(3); 
    stroke(0); 
    noFill();  
    ellipse((float)(G.tabnode[nodes].x), (float)(G.tabnode[nodes].y), 2*delta, 2*delta);
    strokeWeight(1);
  }
}


void savepdf()
{
  beginRecord(PDF, "pdfscreenshot/densesubgraph-"+step+".pdf"); 
  draw();
  endRecord();
}

void keyPressed()
{
  if (key=='q') exit();

  if (key=='b')
  {
    denseG=G.denseSubgraph();
    println("density G:"+G.density());
    println("dense subgraph G:"+denseG.density());
  }

  if (key=='r') {
    println("density:"+G.density());
  }

  if (key==' ') { 
    randomGraph(G);
    denseG=null; 
    nodes=-1;
    step=0;
  }

  if (key=='s') {// select; 
    nodes=G.selectMinDeg(); 
    step++; 
    savepdf();
  }

  if (key=='d') {if (G.n>0){
    G=G.subgraph(nodes);
    nodes=-1; 
    step++; 
    if (G.density()>bestd) bestd=G.density(); 
    savepdf();
  }
  }

  if (key=='a') {
    denseG=null;
  }

  if (key=='e') {
    ExampleGraph();
    draw();
  }

  if (key=='p') {
    savepdf();
  }


  if (key=='h')
  {
    println(G);
  }
}

