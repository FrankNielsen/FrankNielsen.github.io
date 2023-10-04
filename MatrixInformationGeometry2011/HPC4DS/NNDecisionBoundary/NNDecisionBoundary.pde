// (C) 2015 Frank Nielsen, tested using Processing.org v 2.2.1
// "Introduction to HPC with MPI for Data Science", Springer UTiCS, 2016
// Program that displays the decision boundary of the nearest neighbor classification rule
// Use keys 'c', 's', 'i', 'd', 'q', 'v', 'r', 'l', 'b', ' '
int ww=512;
int hh=ww;
int delta=1;

static int nmax=100;

float[][] class1=new float [100][2];
float[][] class2=new float[nmax][2];
float ws=10;
int pale=255;
int n1, n2;

boolean showLegend=true;
boolean showBorder=true;
boolean showCursor=true;
boolean showBoundary=true;

PImage vor = createImage(ww, hh, RGB);
PImage voronoicell = createImage(ww, hh, RGB);

int argdist1(int i, int j)
{
  int l;
  int winner=-1;
  float dd=1.0e8;
  for (l=0; l<n1; l++)
  {
    if (dist(i, j, class1[l][0], class1[l][1])<dd) 
    {
      dd=dist(i, j, class1[l][0], class1[l][1]); 
      winner=l;
    }
  }

  return winner;
}



int argdist2(int i, int j)
{
  int l;
  int winner=-1;
  float dd=1.0e8;
  for (l=0; l<n2; l++)
  {
    if (dist(i, j, class2[l][0], class2[l][1])<dd) 
    {
      dd=dist(i, j, class2[l][0], class2[l][1]); 
      winner=l;
    }
  }

  return winner;
}

float dist1(int i, int j)
{
  int l;
  float dd=1.0e8;
  for (l=0; l<n1; l++)
  {
    dd=min(dd, dist(i, j, class1[l][0], class1[l][1]));
  }

  return dd;
}


float dist2(int i, int j)
{
  int l;
  float dd=1.0e8;
  for (l=0; l<n2; l++)
  {
    dd=min(dd, dist(i, j, class2[l][0], class2[l][1]));
  }

  return dd;
}

int label(int i, int j)
{
  if (dist1(i, j)<dist2(i, j)) return 1; 
  else return 2;
}

// get closest label number (unique id of cells
int arglabel(int i, int j)
{
  if (dist1(i, j)<dist2(i, j)) return argdist1(i, j) ; 
  else return n1+argdist2(i, j);
}


void Voronoi()
{
  int i, j, index;
  vor.loadPixels();

  for (i=0; i<hh-delta; i++)
    for (j=0; j<ww-delta; j++)
    {
      index=i+ww*j; 

      if (dist1(i, j)<dist2(i, j))
      {
        vor.pixels[index] = color(pale, 0, 0);
      } else
      {
        vor.pixels[index] = color(0, 0, pale);
      }


      if ((label(i, j)!=label(i, j+delta))||(label(i, j)!=label(i+delta, j))||(label(i, j)!=label(i+delta, j+delta)))
      {
        vor.pixels[index] = color(0, 0, 0);
      } else
      {
        if (showBorder) {
          vor.pixels[index] = color(255, 255, 255);
        }
      }
    }


  vor.updatePixels();
}

//
// compute all the Voronoi cells
//
void VoronoiCell()
{
  int i, j, index;
  voronoicell.loadPixels();

  for (i=0; i<hh-delta; i++)
    for (j=0; j<ww-delta; j++)
    {
      index=i+ww*j; 

      if (dist1(i, j)<dist2(i, j))
      {
        voronoicell.pixels[index] = color(pale, 0, 0);
      } else
      {
        voronoicell.pixels[index] = color(0, 0, pale);
      }


      if ((arglabel(i, j)!=arglabel(i, j+delta))||(arglabel(i, j)!=arglabel(i+delta, j))||(arglabel(i, j)!=arglabel(i+delta, j+delta)))
      {
        voronoicell.pixels[index] = color(0, 0, 0);
      } else
      {
        if (showBorder) {
          voronoicell.pixels[index] = color(255, 255, 255);
        }
      }
    }


  voronoicell.updatePixels();
}

void setup()
{
  n1=n2=0;
  size(ww, hh);
}

void fillstroke(int r, int g, int b) {
  fill(r, g, b); 
  stroke(r, g, b);
}


void draw()
{
  background(255);
  int i;

  if (n1+n2>0) 
  {
    if (showBoundary) image(vor, 0, 0); 
    else
    { 
      image(voronoicell, 0, 0);
    }
  }

  stroke(0);
  fill(255, 0, 0);
  for (i=0; i<n1; i++)
  {
    ellipse(class1[i][0], class1[i][1], ws, ws);
  }

  fill(0, 0, 255);
  for (i=0; i<n2; i++)
  {
    rect(class2[i][0], class2[i][1], ws, ws);
  }

  if (showCursor) {
    noFill();
    stroke(0);
    ellipse(mouseX, mouseY, 50, 50);
  }

  stroke(0);
  fill(0);
  if (showLegend) {
    text("Nearest neighbor decision boundary", 15, 15);
  }
}


void mousePressed() {

  if ( mouseButton == LEFT) {
    class1[n1][0]=mouseX;
    class1[n1][1]=mouseY;
    n1++;
    Voronoi();
    VoronoiCell();
  }
  if (mouseButton == RIGHT) {
    class2[n2][0]=mouseX;
    class2[n2][1]=mouseY;
    n2++;
    Voronoi();
    VoronoiCell();
  }
}

void keyPressed()
{
  if (key=='c') {
    showCursor=!showCursor;
  }
  if (key=='s') {
    saveFrame("NNrule-######.png");
  }

  if (key=='i') {
    delta++;
    Voronoi();
    VoronoiCell();
  }
  if (key=='d') {
    delta=max(1, delta-1);
    Voronoi();
    VoronoiCell();
  }

  if (key=='q') exit(); 
  if (key=='v') {
    Voronoi();
    VoronoiCell();
  }

  if (key=='r') {
    n1=n2=0;
    Voronoi();
    VoronoiCell();
  }

  if (key=='l') {
    showLegend=!showLegend;
  }
  if (key=='b') {
    showBorder=!showBorder;
    Voronoi();
    VoronoiCell();
  }

  if (key==' ') {
    showBoundary=!showBoundary; 
    Voronoi(); 
    VoronoiCell();
  }
  draw();
}

