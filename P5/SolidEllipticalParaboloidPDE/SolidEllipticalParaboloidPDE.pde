// Frank Nielsen, 2025 April 21

import peasy.*;
import processing.pdf.*;


PeasyCam cam;

boolean savePDF = false;
boolean savePNG = false;

boolean toggleParaboloid=true;
boolean toggleTransparency=true;
boolean togglePlane1=true;
boolean togglePlane2=true;
boolean togglePlane3=true;

void setup() {
  //size(800, 800, P3D);
  size(900, 900, P3D);
  cam = new PeasyCam(this, 400);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(1000);
  
  // Enable depth sorting for transparency to work properly
  hint(ENABLE_DEPTH_SORT);
}

void draw() {
  
  if (savePDF) {
    beginRecord(PDF, "LiftingPotential.pdf");
  }
  
  
  background(255);
  lights();
  
  
  if (toggleParaboloid){ 
  
  translate(0, 0, -150);
  
  // Light grey with 30% opacity
  //fill(200, 200, 200, 255);
 if (toggleTransparency) fill(200, 200, 200, 230); 
 else fill(200, 200, 200, 255);
//  noStroke();  // Optional: remove outlines for smooth look
  
  drawEllipticalParaboloid(40, 40, 300, 1.0, 1.0);
  }
  
  
  float transparency=255;
  
  // Draw slanted cutting plane
 
 
if (togglePlane1)
{fill(100, 200, 255, transparency);  // Light blue, semi-transparent
  drawSlantedPlane(-150, 150, -150, 150, 50, 0.5, -0.3, 40);
} 
 
  if (togglePlane2){
  // Red plane
  fill(255, 100, 100,  transparency);
  drawSlantedPlane(-150, 150, -150, 150, 50, -0.4, 0.5, 20);
  }
  /*
  Blue plane: z = 0.5x - 0.3y + 40

Red plane: z = -0.4x + 0.5y + 20
*/
  if (togglePlane3)
  {
  // Green plane
    fill(100, 255, 100,  transparency);  // R,G,B,A (A ≈ 76 ≈ 30%)
  drawSlantedPlane(-150, 150, -150, 150, 50, 0.6, 0.4, 10);
  }
  
  if ( (togglePlane1) & (togglePlane2))
  {
    // Draw intersection line (black, thick)
  drawIntersectionLineOfPlanes(
    0.5, -0.3, 40,   // Plane 1
   -0.4,  0.5, 20,   // Plane 2
   -150, 150, 200    // x range and steps
  );
  }
  
  
  if ( (togglePlane2) & (togglePlane3))
  {
  drawIntersectionLineOfPlanes(
   -0.4,  0.5, 20,   // Plane 2
   0.6, 0.4, 10, // plane 3
   -150, 150, 200    // x range and steps
  );
  }
  
  
  if ( (togglePlane1) & (togglePlane3))
  {
   drawIntersectionLineOfPlanes(
    0.5, -0.3, 40,   // Plane 1
   0.6, 0.4, 10, // plane 3
   -150, 150, 200    // x range and steps
  );
  }
 
  
   if (savePDF) {
    endRecord();
    println("PDF saved as 'paraboloid_scene.pdf'");
    savePDF = false; // Reset
  }
  
    if (savePNG) {
    saveFrame("paraboloid_scene_####.png");
    println("PNG image saved.");
    savePNG = false;
  }
}



void drawIntersectionLineOfPlanes(float m1, float n1, float c1,
                                  float m2, float n2, float c2,
                                  float xStart, float xEnd, int steps) {
  float dx = (xEnd - xStart) / float(steps);

  stroke(0);
  strokeWeight(4);
  noFill();
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float x = xStart + i * dx;
    
    // Solve (m1 - m2)x + (n1 - n2)y = c2 - c1 for y
    float denominator = n1 - n2;
    if (abs(denominator) < 0.0001) continue; // avoid division by zero

    float y = (c2 - c1 - (m1 - m2) * x) / denominator;
    float z = m1 * x + n1 * y + c1;

    vertex(x, y, z);
  }
  endShape();
  strokeWeight(1); // Reset
  
  /*
  
  PVector[] intersectionPoints = findParaboloidLineIntersections(
    0.5, -0.3, 40,  // Plane 1
   -0.4,  0.5, 20,  // Plane 2
    1.0, 0.6,       // Paraboloid a, b
   -150, 150, 1000  // Scan range and resolution
  );

  fill(0);
  noStroke();
  for (PVector pt : intersectionPoints) {
    pushMatrix();
    translate(pt.x, pt.y, pt.z);
    sphere(4);  // Small black sphere
    popMatrix();
  }
  
  */
  
}

void keyPressed() {
  
  
  if (key == '1'  ) {
    togglePlane1 = !togglePlane1;
  }
  
  if (key == '2'  ) {
    togglePlane2 = !togglePlane2;
  }
  
  if (key == '3'  ) {
    togglePlane3 = !togglePlane3;
  }
  
  
  if (key == 'p' || key == 'P') {
    savePDF = true;
  }
  
  if (key == 't' || key == 'T') {
    toggleTransparency = !toggleTransparency;
  }
  
  
  if (key == 'f' || key == 'F') {
    toggleParaboloid=!toggleParaboloid;
  }
  
  
  if (key == 'g' || key == 'G') {
    savePNG = true;}
}

void drawEllipticalParaboloid(int resX, int resY, float height, float a, float b) {
  float maxR = sqrt(height); // Max radius based on z = r^2
  float scale=10;
  
  for (int i = 0; i < resY; i++) {
    float z1 = map(i, 0, resY, 0, height);
    float z2 = map(i + 1, 0, resY, 0, height);
    
    float r1 = scale*sqrt(z1);
    float r2 = scale* sqrt(z2);
    
    beginShape(QUAD_STRIP);
    for (int j = 0; j <= resX; j++) {
      float theta = TWO_PI * j / resX;
      
      float x1 = a * r1 * cos(theta);
      float y1 = b * r1 * sin(theta);
      
      float x2 = a * r2 * cos(theta);
      float y2 = b * r2 * sin(theta);
      
      vertex(x1, y1, z1);
      vertex(x2, y2, z2);
    }
    endShape();
  }
}


// Draws a slanted plane defined by z = mx + ny + c
void drawSlantedPlane(float xMin, float xMax, float yMin, float yMax, int res, float m, float n, float c) {
  float dx = (xMax - xMin) / float(res);
  float dy = (yMax - yMin) / float(res);
  
  for (int i = 0; i < res; i++) {
    float y1 = yMin + i * dy;
    float y2 = yMin + (i + 1) * dy;
    
    beginShape(QUAD_STRIP);
    for (int j = 0; j <= res; j++) {
      float x = xMin + j * dx;
      float z1 = m * x + n * y1 + c;
      float z2 = m * x + n * y2 + c;
      
      vertex(x, y1, z1);
      vertex(x, y2, z2);
    }
    endShape();
  }
}


PVector[] findParaboloidLineIntersections(float m1, float n1, float c1,
                                           float m2, float n2, float c2,
                                           float a, float b,
                                           float xMin, float xMax, int steps) {
  float dx = (xMax - xMin) / float(steps);
  ArrayList<PVector> hits = new ArrayList<PVector>();

  for (int i = 0; i <= steps; i++) {
    float x = xMin + i * dx;

    float denom = n1 - n2;
    if (abs(denom) < 1e-5) continue;  // Skip degenerate case

    float y = (c2 - c1 - (m1 - m2) * x) / denom;
    float zPlane = m1 * x + n1 * y + c1;
    float zParab = (x * x) / (a * a) + (y * y) / (b * b);

    if (abs(zParab - zPlane) < 0.5) {  // Tolerance
      hits.add(new PVector(x, y, zPlane));
      if (hits.size() == 2) break;
    }
  }

  if (hits.size() == 2) {
    return new PVector[] { hits.get(0), hits.get(1) };
  } else {
    return new PVector[0]; // No intersection found
  }
}
