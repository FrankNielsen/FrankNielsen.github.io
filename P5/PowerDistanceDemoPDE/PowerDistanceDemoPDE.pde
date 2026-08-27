class Disk {
  PVector c;
  float r;

  Disk(float x, float y, float r) {
    this.c = new PVector(x, y);
    this.r = r;
  }
}

class Tangent {
  PVector n;       // unit normal
  float c;         // line: n.x*x + n.y*y + c = 0
  PVector p1, p2;  // tangent points

  Tangent(PVector n, float c, PVector p1, PVector p2) {
    this.n = n;
    this.c = c;
    this.p1 = p1;
    this.p2 = p2;
  }
}

double sqr(double x){ return x*x;}

double Distance(PVector p1,PVector p2)
{
 return Math.sqrt(sqr(p2.x-p1.x)+sqr(p2.y-p1.y)); 
}

double PowerDistance(PVector p, Disk d)
{
 return (sqr(p.x-d.c.x)+sqr(p.y-d.c.y))-sqr(d.r); 
}

// ------------------------------------------------------------
// Compute the two exterior common tangents
// ------------------------------------------------------------

Tangent[] externalTangents(Disk d1, Disk d2) {

  PVector delta = PVector.sub(d2.c, d1.c);
  float dist = delta.mag();

  if (dist == 0)
    return new Tangent[0];

  float dr = d1.r - d2.r;

  // No exterior tangents if one disk is strictly inside the other
  if (abs(dr) > dist)
    return new Tangent[0];

  // Unit vector between centers
  PVector u = delta.copy();
  u.normalize();

  // Perpendicular unit vector
  PVector v = new PVector(-u.y, u.x);

  // Component of tangent normal along u
  float a = (d2.r - d1.r) / dist;

  // Numerical protection
  float b2 = max(0, 1 - a*a);
  float b = sqrt(b2);

  Tangent[] result = new Tangent[2];

  for (int k = 0; k < 2; k++) {

    float s = (k == 0) ? 1 : -1;

    // Unit normal to tangent
    PVector n = PVector.add(
      PVector.mult(u, a),
      PVector.mult(v, s*b)
    );

    // Line equation:
    // n.x*x + n.y*y + c = 0
    float c = d1.r - PVector.dot(n, d1.c);

    // Tangency points
    PVector p1 = PVector.sub(
      d1.c,
      PVector.mult(n, d1.r)
    );

    PVector p2 = PVector.sub(
      d2.c,
      PVector.mult(n, d2.r)
    );

    result[k] = new Tangent(n, c, p1, p2);
  }

  return result;
}


// ------------------------------------------------------------
// Draw a tangent line, clipped to the window
// ------------------------------------------------------------

void drawTangent(Tangent t) {

  // Direction vector along the line
  PVector dir = new PVector(-t.n.y, t.n.x);

  // Find a point on the line
  PVector q = PVector.mult(t.n, -t.c);

  // Make it very long
  float L = 2000;

  PVector a = PVector.add(q, PVector.mult(dir, -L));
  PVector b = PVector.add(q, PVector.mult(dir,  L));

  line(a.x, a.y, b.x, b.y);
}


// ------------------------------------------------------------
// Draw tangent point
// ------------------------------------------------------------

void drawTangentPoint(PVector p) {
  fill(255, 80, 80);
  noStroke();
  circle(p.x, p.y, 10);

  stroke(0);
  noFill();
  circle(p.x, p.y, 16);
  

}


// ------------------------------------------------------------
// Main Processing sketch
// ------------------------------------------------------------

Disk d1;
Disk d2;

void setup() {

  size(900, 650);
  
  int delta=50;
  //int w=100*100; // 436
  //int wp=400*400;
  
  int w=0;
 // int wp=400*400+100*100;
int wp=200*200;

  d1 = new Disk(270, 330, (int) Math.sqrt(w));
  d2 = new Disk(600, 330, (int)Math.sqrt(wp));
}

void mouseDragged() {
  d2.c.set(mouseX, mouseY);
}

void draw() {

  background(250);

  // ----------------------------------------------------------
  // Recompute tangents
  // ----------------------------------------------------------

  Tangent[] tangents = externalTangents(d1, d2);
  
  /*
  if (tangents.length>0){
    println();
  println("1 Distance:"+Distance(tangents[0].p1,tangents[0].p2));
 // println("2 Distance:"+Distance(tangents[1].p1,tangents[1].p2));
  }
  */
  
  
  
  // ----------------------------------------------------------
  // Draw exterior tangent lines
  // ----------------------------------------------------------

  strokeWeight(3);
  stroke(30, 100, 200);

  for (Tangent t : tangents)
    drawTangent(t);

if ((tangents!=null)&&(tangents.length>0)){
  stroke(255,0,0);
  strokeWeight(5);
  line(tangents[0].p1.x,tangents[0].p1.y,tangents[0].p2.x,tangents[0].p2.y);
   line(tangents[1].p1.x,tangents[1].p1.y,tangents[1].p2.x,tangents[1].p2.y);
   strokeWeight(5);
}
   
  // ----------------------------------------------------------
  // Draw disks
  // ----------------------------------------------------------

  strokeWeight(2);
  stroke(40);
  fill(230, 240, 255);

  circle(d1.c.x, d1.c.y, 2*d1.r);

  fill(240, 235, 220);
  circle(d2.c.x, d2.c.y, 2*d2.r);


  // ----------------------------------------------------------
  // Draw centers
  // ----------------------------------------------------------

  stroke(40);
  strokeWeight(2);

  fill(40);
  circle(d1.c.x, d1.c.y, 8);
  circle(d2.c.x, d2.c.y, 8);


  // ----------------------------------------------------------
  // Draw line connecting centers
  // ----------------------------------------------------------

  stroke(120);
  strokeWeight(1);
  line(d1.c.x, d1.c.y,
       d2.c.x, d2.c.y);


  // ----------------------------------------------------------
  // Draw tangent points
  // ----------------------------------------------------------

  for (Tangent t : tangents) {
    drawTangentPoint(t.p1);
    drawTangentPoint(t.p2);
  }


  // ----------------------------------------------------------
  // Labels
  // ----------------------------------------------------------


String msg;
if ((tangents!=null)&&(tangents.length>0))
msg="Power distance: "+PowerDistance(d1.c,d2)+ "\nvs exterior tangent segment sqr length:"+sqr(Distance(tangents[0].p1,tangents[0].p2));
else msg="Power distance: "+PowerDistance(d1.c,d2)+ "\nNo exterior tangent segments";
 textSize(32);
  text(msg, 20, 30);
  
  


if (false){
  fill(30);
  textSize(18);

  text("Disk 1", d1.c.x - 30, d1.c.y + 125);
  text("Disk 2", d2.c.x - 30, d2.c.y + 175);

  textSize(16);
  text("Exterior common tangents", 20, 30);
}
}
