// (C) February 2016.
// Frank Nielsen,  Frank.Nielsen@acm.org
// Ecole Polytechnique
// Tested with processing v3.0.1  processing.org

// Compute the k-ordered order Euclidean Voronoi diagram from the arrangement of lines
// See Hedelsbruner book, map for generator p to hyperplane of eq. z= -2 <x,p> + <p,p>
// The k ordered order 2D Voronoi diagram is the k-level of the arrangement of 3D planes
// When you move with the cursor, it shows the ordered list of the indices of the k-NN

/*
Spatial Tessellations: Concepts and Applications of Voronoi Diagrams. Second Edition. 
ATSUYUKI OKABE. University of Tokyo, Japan.
See sec 3.2.2 page 144
*/

/*
This is a brute force rasterization: For each pixel, I compute the list of n z-intersection and
store them in a 3D array raster. Then for a given level k, I compared whether neighborhood have the 
same ordered/unordered list or not

In an unordered k-order Voronoi diagram, the sorted list of k-NNs may vary, but
in an ordered k-order Voronoi diagram, the sorted list is fixed.

Can be adapted to any kind of distances D(p,q) by defining function z=D(p,x), (not necessarily equivalent to an hyperplane)
*/

// Maximal number of cells is obtained for k=n/2

/* Some keys:
x : count number of cells
a : save all orders
q : exit
i : info
' ' : initialize
f : farthest order
s : save current
+/- : increase/decrease level
*/

import java.util.Arrays;
import java.util.*;

float ptsize=5;
boolean showOrder=false;

class mPair implements Comparable<mPair>
{
double z;
int label;

public mPair(double zz, int ll)
{z=zz;label=ll;}

public int compareTo(mPair p)
{
if (this.z<p.z) return -1;
else
return 1;

}
  
}

class mHyperplane {
 
double a,b,c; // z=ax+by+c
int label;

public mHyperplane(double aa, double bb, double cc, int ll)
{a=aa;b=bb;c=cc;label=ll;}

public double evaluate(double x, double y)
{
return a*x+b*y+c;
}
  
}

int n;

double [] X;
double [] Y;
int [] red;
int [] green;
int [] blue;
mHyperplane [] hyper;

//  video
int side=512;
int w=side,h=side;

int level=0;

int [][][] raster; // for each xy pixel position the order of the n generators on z
 


double minx,maxx,miny,maxy;

boolean showInfo=true;

public  float x2X(double x)
{
  return (float)((x-minx)*side/(maxx-minx));
}

public  float y2Y(double y)
{
  return (float)((y-miny)*side/(maxy-miny));
}

public  float X2x(double X)
{return (float)(minx+(maxx-minx)*(X/(float)side));}

public  float Y2y(double Y)
{return (float)(miny+(maxy-miny)*((Y)/(float)side));}
 

void initialize()
{int i,j,k;
double r, a;

//n=256;
//n=100;
n=25;
//n=256;

X=new double[n];
Y=new double[n];
red=new int[n];
green=new int[n];
blue=new int[n];
hyper=new mHyperplane[n];
raster=new int[w][h][n];

/*
minx=-1;
maxx=1;
miny=-1;
maxy=1;
*/
minx=0;
maxx=1;
miny=0;
maxy=1;


double den;

for(i=0;i<n;i++)
{
  /*
r=Math.random();
a=6.28*Math.random();
X[i]=r*Math.cos(a);
Y[i]=r*Math.sin(a);
*/
X[i]=0.2+0.6*Math.random();
Y[i]=0.2+0.6*Math.random();

// choose random colors for generators
red[i]=(int)(random(256));
green[i]=(int)(random(256));
blue[i]=(int)(random(256));

// for Euclidean -2 <x,p> + <p,p>
hyper[i]=new mHyperplane(-2*X[i],-2*Y[i], X[i]*X[i]+Y[i]*Y[i], i);

// for Klein hyperbolic distance
/*
den=Math.sqrt(1-X[i]*X[i]-Y[i]*Y[i]);
hyper[i]=new mHyperplane(-X[i]/den,-Y[i]/den, 1/den, i);
*/
}

double xx; double yy;
mPair [] parray=new mPair[n];

for(i=0;i<h;i++){
for(j=0;j<w;j++)
{
  
   
xx=X2x(j);yy=Y2y(i);

for(k=0;k<n;k++)
{
parray[k]=new mPair(hyper[k].evaluate(xx,yy),k);
}



//Arrays.sort(parray);
QuickSort qs=new QuickSort();
qs.quicksort(parray);

// for each pixel, we get the order list in increasing z-intersection here
for(k=0;k<n;k++)
{
raster[j][i][k]=parray[k].label;
}


}
}

//level=0;
img=exportLevel(level);
}

// export the nearest neighbors
public int [] NN(int xpos, int ypos , int lev)
{
int [] res=new int[lev+1];
int i;

for(i=0;i<=lev;i++)
{
res[i]=raster[xpos][ypos][i];
}

Arrays.sort(res);
return res;
}


public int [] unorderedNN(int xpos, int ypos , int lev)
{
int [] res=new int[lev+1];
int i;

for(i=0;i<=lev;i++)
{
res[i]=raster[xpos][ypos][i];
}

 
return res;
}


// kNN same or not?
public boolean compare(int [] array1, int [] array2)
{
boolean result=true;
int i, len;
len=array1.length;

for(i=0;i<len;i++)
{
if (array1[i]!=array2[i]) return false;
}


return true;
}

public String convertString(int [] array)
{
String res="";
int i;

for(i=0;i<array.length;i++)
{
res=res+array[i]+" ";
}

return res;
}

// Export all non empty cells. here we can convert to a power diagram
int nbcell=0;


public String exportNonEmptyCells(int l)
{
int order=l+1;  
String res="# [Frank Nielsen] ordered Voronoi diagram, n="+n+" k-order, k="+order+"\n";
int i,j,index1;
int [] array1;
println("export level="+l);
double xx,yy;
nbcell=0;
Set<String> s = new HashSet<String>();
String celltype;
double centerx, centery, radius;

String genstring=""+n+"\n";

nbCellCount();

for(i=0;i<n;i++)
{
genstring=genstring+X[i]+"\n"+X[i]+"\n";
}

res=res+genstring;

res=res+nbcell+"\n";
 
for(i=0;i<w-1;i++)
for(j=0;j<h-1;j++)
{ 
  
  
  xx=X2x(i);
  yy=Y2y(j);
  
  index1=raster[i][j][l]; 
  array1=NN(i,j,l);
  celltype=convertString(array1);
   
               if (s.add(celltype))
               {
                 
                 centerx=centery=radius=0;
        
                 for(int ll=0;ll<l+1;ll++)
{
int lll=array1[l];// point index in the subset
double scale=2*Math.sqrt(1.0-(X[lll]*X[lll]+Y[lll]*Y[lll]));
centerx += X[lll]/scale; 
centery += Y[ll]/scale;  
radius += 2.0/scale;  
}
// center of mass
centerx/=order;
centery/=order;
radius/=order;
radius= (centerx*centerx + centery*centery) - radius;
                 
             // equivalent center, radius
         res=res+centerx+"\n";
          res=res+centery+"\n";
         res=res+radius+"\n";    
             // label
             res=res+celltype+"\n";
               
             }
}

println(s.size() + " distinct non-empty cells at level (=order-1)"+l);

return res;
}

 


public void nbCellCount()
{
String res="";
int i,j,index1;
int [] array1;
double xx,yy;
nbcell=0;
StringList s = new StringList();
String celltype;
 
for(i=0;i<w-1;i++)
for(j=0;j<h-1;j++)
{ 

  
  xx=X2x(i);
  yy=Y2y(j);
  
  index1=raster[i][j][level]; 
  array1=NN(i,j,level);
  celltype=convertString(array1);
   
           if (!s.find(celltype))  s.insert(celltype);
              

}

nbcell=s.size() ;
}

public PImage exportLevel(int l)
{PImage res=exportBorderLevel(l);
 nbCellCount();
return res;
//return exportRegionLevel(l);
// return exportBorderLevelLessOrEqual(l);
 
}

public PImage exportRegionLevel(int l)
{
PImage result=createImage(w,h,RGB);
int i,j,index;

println("export level="+l);

result.loadPixels();

for(i=0;i<w;i++)
for(j=0;j<h;j++)
{
  index=raster[i][j][l];
color c=color(  red[index],green[index],blue[index]);
 result.pixels[j*w+i]=c;
}

result.updatePixels();

return result;
}

public double sqr(double x){return x*x;}




boolean showSelect=false;

public void mousePressed()
{
showSelect=true;
}


public void mouseReleased()
{
showSelect=false;
}


public void mousePressedBefore()
{
double xx, yy;
double zl,zlp1,dz,rec;
double rr;

if (level<n-2){
  xx=X2x(mouseX);
  yy=Y2y(mouseY);
  rr=1-xx*xx-yy*yy;
//  X[0]=xx;Y[0]=yy;
zl=hyper[raster[mouseX][mouseY][level]].evaluate(xx,yy);
zlp1=hyper[raster[mouseX][mouseY][level+1]].evaluate(xx,yy);
dz=zlp1-zl;
rec=dz*rr;
println(dz+"  "+rec+"     -->"+ zl+" "+zlp1);
}
}

//
// export the k-level
//

public PImage exportBorderLevel(int l)
{
PImage result=createImage(w,h,RGB);
int i,j,index1, index2,index3, index4;
int [] array1,  array2,  array3,  array4;

println("export level="+l);
color c;
result.loadPixels();

double xx,yy;
 

for(i=0;i<w-1;i++)
for(j=0;j<h-1;j++)
{c=color(  255,255,255);
  
  
  xx=X2x(i);
  yy=Y2y(j);
  
  index1=raster[i][j][l]; 
  index2=raster[i+1][j+1][l];
  index3=raster[i][j+1][l];
  index4=raster[i+1][j][l];
  
  if (showOrder) {array1=NN(i,j,l);
 array2=NN(i+1,j+1,l);
  array3=NN(i,j+1,l);
  array4=NN(i+1,j,l);}
  else
  {array1=unorderedNN(i,j,l);
 array2=unorderedNN(i+1,j+1,l);
  array3=unorderedNN(i,j+1,l);
  array4=unorderedNN(i+1,j,l);}
  
  
  if ((compare(array1,array2))&&(compare(array1,array3))&&(compare(array1,array4))) 
 { c=color(255,255,255);}
  else
{
c=color(  0,0,0);

}
 
 result.pixels[j*w+i]=c;
}



result.updatePixels();

return result;
}



public double max(double a, double b)
{
if (a>b) return a; else return b;
}

public PImage exportBorderLevelLessOrEqual(int l)
{
PImage result=createImage(w,h,RGB);
int i,j,k,index1, index2,index3, index4;

println("export level="+l);
color c;
result.loadPixels();

for(i=0;i<w-1;i++)
for(j=0;j<h-1;j++)
{
 
  
   c=color(255,255,255);
   
  for(k=0;k<=l;k++)
  {
  index1=raster[i][j][k];
  index2=raster[i+1][j+1][k];
  index3=raster[i][j+1][k];
  index4=raster[i+1][j][k];
 
  
  if ((index1!=index2)||(index1!=index3)||(index4!=index1))
c=color(0);
//c=color(  red[k],green[k],blue[k]);
  }
  
  
 result.pixels[j*w+i]=c;
}

result.updatePixels();

return result;
}


void setup()
{
 size(512,512); 
//frame.setTitle("Visualizing k-ordered order Voronoi diagrams");
 initialize();
}

PImage img;

void draw()
{int i;
background(255); 
image(img,0,0);

stroke(0,0,0);
noFill();
//ellipse(side/2,side/2,side,side);

// draw generators
for(i=0;i<n;i++)
{
//stroke(red[i],green[i],blue[i]); 
stroke(0,0,0); 
fill(red[i],green[i],blue[i]); 
ellipse(x2X(X[i]),y2Y(Y[i]),ptsize,ptsize);

stroke(0,0,0); 
fill(0,0,0);
String infopt=str(i);
textSize(20);
text(infopt, x2X(X[i])+10,y2Y(Y[i])+10);
}

if (showSelect){
double xx, yy;
int index;
xx=X2x(mouseX);yy=Y2y(mouseY);
 
 stroke(255,0,0);
 fill(255,0,0); 
  
for(i=0;i<=level;i++)
{
index=raster[mouseX][mouseY][i];
ellipse(x2X(X[index]), y2Y(Y[index]), ptsize*2, ptsize*2 );
}
}

stroke(0,0,0); 
fill(0,0,0);
int kk=level+1;
String infoknn="unordered "+kk+" NNs: "+convertString(unorderedNN(mouseX,mouseY,level));
textSize(24);
text(infoknn, 10, h-65);
infoknn="ordered "+kk+" NNs: "+convertString(NN(mouseX,mouseY,level));
text(infoknn, 10, h-45);


if (showInfo)
{int order=level+1;
String type;
if (showOrder) type="unordered (sorted NNs)"; else type="ordered (unsorted NNs)";
String info="Order "+order+" "+type;
textSize(24);
fill(255,0,0);
text(info, 10, 50);  //
if (nbcell!=0){info="#cells="+nbcell;
textSize(24);
text(info, 10, h-20);}
}

}

//
// Handle events
//
void keyPressed()
{
  if (key=='t')
 {int order=level+1;
 String test=String.format("%03d",order);
 println(test);
 }
 
 if (key=='x')
 {
  nbCellCount();
 }
 
 
  if (key=='u')
 {
 showOrder=!showOrder;
  img=exportLevel(level);
 nbCellCount();
 draw();
 }
 
 
 
 if (key=='a')
 {int i;
 showInfo=true;
 for(i=0;i<n-1;i++){
 level=i;
 img=exportLevel(level);
 nbCellCount();
 draw();
 int order=level+1;
   String ext=String.format("%03d",order);
  String output = "allorders/kKleinHVD-"+ext;
save(output+".png");
 
 }
 }
  
if (key=='q') exit();

if (key=='e') {
  String res=exportNonEmptyCells(level);
 
 String[] list = split(res, '\n');

// Writes the strings to a file, each on a separate line
saveStrings("exportcells-"+level+".txt", list);

}


if (key=='i') {showInfo=!showInfo;}

if (key==' ') {//level=0;
initialize();}



if (key=='1') 
{
level=0;
img=exportLevel(level);
}

if (key=='2') 
{
level=1;
img=exportLevel(level);
}

if (key=='3') 
{
level=2;
img=exportLevel(level);
}

if (key=='4') 
{
level=3;
img=exportLevel(level);
}

if (key=='5') 
{
level=4;
img=exportLevel(level);
}


if (key=='6') 
{
level=5;
img=exportLevel(level);
}

if (key=='7') 
{
level=6;
img=exportLevel(level);
}

if (key=='8') 
{
level=7;
img=exportLevel(level);
}

if (key=='9') 
{
level=8;
img=exportLevel(level);
}



if (key=='+') 
{
level++;
if (level>n-1) level=n-1;
img=exportLevel(level);
}


if (key=='r') 
{
level=0;
img=exportLevel(level);
}



if (key=='f') 
{
level=n-2; // = n-1 because we do <=
img=exportLevel(level);
}



if (key=='-') 
{
level--;
if (level<0) level=0;
img=exportLevel(level);
}


if (key=='s') 
{int kk=level+1;
String type;
if (showOrder) type="unordered"; else type="ordered";

  String ext=year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  String output = "VD-k="+kk+"-"+type+"-"+ext;
save(output+".png");
}


draw();
}



 class Node {
      String item;   // One of the items in the list
      Node next;     // Pointer to the node containing the next item.
                     //   In the last node of the list, next is null.
   }
   
class StringList {

int nbel;
   /**
    * Internally, the list of strings is represented as a linked list of 
    * nodes belonging to the nested class Node.  The strings in the list 
    * are stored in increasing order (using the order given by the 
    * compareTo() method from the string class, which is the same as 
    * alphabetical order if all the strings are made up of lower 
    * case letters).
    */
   


   private Node head;  // A pointer to the first node in the linked list.
                       // If the list is empty, the value is null.


   /**
    * Searches the list for a specified item.  (Note: for demonstration
    * purposes, this method does not use the fact that the items in the
    * list are ordered.)
    * @param searchItem the item that is to be searched for
    * @return true if searchItem is one of the items in the list or false if
    *    searchItem does not occur in the list.
    */
   public boolean find(String searchItem) {

      Node runner;    // A pointer for traversing the list.

      runner = head;  // Start by looking at the head of the list.
      
      while ( runner != null ) {
            // Go through the list looking at the string in each
            // node.  If the string is the one we are looking for,
            // return true, since the string has been found in the list.
            // (Note:  Since the list is ordered, if we find an item
            // that is greater than searchItem, we could immediately
            // return false.)
         if ( runner.item.equals(searchItem) )
            return true;
         runner = runner.next;  // Move on to the next node.
      }

      // At this point, we have looked at all the items in the list
      // without finding searchItem.  Return false to indicate that
      // the item does not exist in the list.

      return false;

   } // end find()


   


   /**
    * Insert a specified item to the list, keeping the list in order.
    * @param insertItem the item that is to be inserted.
    */
   public void insert(String insertItem) {

      Node newNode;          // A Node to contain the new item.
      newNode = new Node();
      newNode.item = insertItem;  // (N.B.  newNode.next is null.)

nbel++;

      if ( head == null ) {
             // The new item is the first (and only) one in the list.
             // Set head to point to it.
         head = newNode;
      }
      else if ( head.item.compareTo(insertItem) >= 0 ) {
             // The new item is less than the first item in the list,
             // so it has to be inserted at the head of the list.
         newNode.next = head;
         head = newNode;
      }
      else {
             // The new item belongs somewhere after the first item
             // in the list.  Search for its proper position and insert it.
         Node runner;     // A node for traversing the list.
         Node previous;   // Always points to the node preceding runner.
         runner = head.next;   // Start by looking at the SECOND position.
         previous = head;
         while ( runner != null && runner.item.compareTo(insertItem) < 0 ) {
                // Move previous and runner along the list until runner
                // falls off the end or hits a list element that is
                // greater than or equal to insertItem.  When this 
                // loop ends, previous indicates the position where
                // insertItem must be inserted.
            previous = runner;
            runner = runner.next;
         }
         newNode.next = runner;     // Insert newNode after previous.
         previous.next = newNode;
      }

   }  // end insert()


   /**
    * Returns an array that contains all the elements in the list.
    * If the list is empty, the return value is an array of length zero.
    */
   public String[] getElements() {

      int count;          // For counting elements in the list.
      Node runner;        // For traversing the list.
      String[] elements;  // An array to hold the list elements.

      // First, go through the list and count the number
      // of elements that it contains.

      count = 0;
      runner = head;
      while (runner != null) {
         count++;
         runner = runner.next;
      }

      // Create an array just large enough to hold all the
      // list elements.  Go through the list again and
      // fill the array with elements from the list.

      elements = new String[count];
      runner = head;
      count = 0;
      while (runner != null) {
         elements[count] = runner.item;
         count++;
         runner = runner.next;
      }

      // Return the array that has been filled with the list elements.

      return elements;

   } // end getElements()

public StringList(){nbel=0;}

public int size(){return nbel;}

} // end class StringList


class QuickSort {
     long comparisons = 0;
     long exchanges   = 0;

   /***********************************************************************
    *  Quicksort code from Sedgewick 7.1, 7.2.
    ***********************************************************************/
    public  void quicksort(mPair[] a) {
        shuffle(a);                        // to guard against worst-case
        quicksort(a, 0, a.length - 1);
    }

    // quicksort a[left] to a[right]
    public   void quicksort(mPair[] a, int left, int right) {
        if (right <= left) return;
        int i = partition(a, left, right);
        quicksort(a, left, i-1);
        quicksort(a, i+1, right);
    }

    // partition a[left] to a[right], assumes left < right
    private   int partition(mPair[] a, int left, int right) {
        int i = left - 1;
        int j = right;
        while (true) {
            while (less(a[++i], a[right]))      // find item on left to swap
                ;                               // a[right] acts as sentinel
            while (less(a[right], a[--j]))      // find item on right to swap
                if (j == left) break;           // don't go out-of-bounds
            if (i >= j) break;                  // check if pointers cross
            exch(a, i, j);                      // swap two elements into place
        }
        exch(a, i, right);                      // swap with partition element
        return i;
    }

    // is x < y ?
    private  boolean less(mPair x, mPair y) {
         if (x.z<y.z)
        return true; else return false;
    }

    // exchange a[i] and a[j]
    private   void exch(mPair[] a, int i, int j) {
        exchanges++;
        mPair swap = a[i];
        a[i] = a[j];
        a[j] = swap;
    }

    // shuffle the array a[]
    private   void shuffle(mPair[] a) {
        int N = a.length;
        for (int i = 0; i < N; i++) {
            int r = i + (int) (Math.random() * (N-i));   // between i and N-1
            exch(a, i, r);
        }
    }

}
