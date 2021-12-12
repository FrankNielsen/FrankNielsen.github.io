// MAPAS - LAPIN
// Mouse Associative Pincode Authentification System
// (C) February 2013   Frank Nielsen

// For mouse wrapping, install
// http://www.networkactiv.com/SoundyMouse.html

// AWT Robot
// http://docs.oracle.com/javase/1.4.2/docs/api/java/awt/Robot.html

// Processing V2. http://wiki.processing.org/w/Window_Size_and_Full_Screen


abstract class skinBoard{

abstract   void init();
abstract   void permute();
abstract   void draw(int x, int y);
}

class digitBoard extends skinBoard
{
   void init(){}
 void permute(){}
   void draw(int x, int y){}
}




String title="LAPIN | Sony Computer Science Laboratories Inc | Frank Nielsen | (C) 2013";

String loginName="FavoriteUser";
String login="myName";
String passwd="31413";
String assocpasswd="CAHBE";
String associativepin="";


int [] offset={2,0,7,1,4};

int cwidth, cheight;


int sidebutton=150;
int side=3*sidebutton;
int w=3*sidebutton;

int panelh=0;
int h=3*sidebutton+panelh;


int offsetkeyx=sidebutton/2;
int offsetkeyy=sidebutton/2;

/*
int offsetkeyx=0;
int offsetkeyy=0;
*/
int offsetkx=(cwidth-side)/2, offsetky=(cheight-side)/2;

int pwdlength=0;
String pwd="";

boolean showPlain=true;

int nbassoc;
int [] assocPwd;
String plainPassword="";


boolean displayCoord=false;
boolean displayMouse=true;
boolean viewport=true;
boolean showMessage=true;
boolean showInfo=true;

long lasttime;

final color WHITE = color(255, 255, 255); 
final color BLACK = color(0, 0, 0); 
final color LIGHTGRAY = color(220,220,220);
final color GRAY = color(155,155,155);
final color ORANGE = color(255,155,51);
final color YELLOW = color(255,255,51);
final color RED = color(255,51,51);
final color BLUE = color(51,51,255);
final color GREEN = color(0,155,0);
final color PURPLE = color(255,0,255);
final color AQUA= color(0,255,255);
final color OLIVE = color(128,128,0);

int mode =3; // digits-letters association


int fixedMode=0;
int moveableMode=1;



// String[] textPin={"0","1", "2", "3", "4","5","6","7","8","9"};

String[] digitPin={"1","2","3","4","5","6","7","8","9"};
String[] textPin={"A","B", "C", "D", "E","F","G","H","I","J"};
PImage[] iconCursor=new PImage[9];
PImage[] userCursor=new PImage[9]; // like ramen, etc.


String[] digitPinInit={"1","2","3","4","5","6","7","8","9"};
String[] textPinInit={"A","B", "C", "D", "E","F","G","H","I","J"};
PImage[] iconCursorInit=new PImage[9];

color [] digitColor={BLACK, GRAY, ORANGE, YELLOW, RED, BLUE, GREEN, PURPLE, OLIVE};
color [] digitColorInit={BLACK, GRAY, ORANGE, YELLOW, RED, BLUE, GREEN, PURPLE, OLIVE};

int cursortopx=82, cursortopy=7;

int mouseCursorX=31, mouseCursorY=31;

int nbdigits=9;
PImage [][] colorCursor;

String[][] digits=new String[3][3];


PFont f; 


int [][][] palette=new int[3][3][3];

PImage mouseCursor;


//boolean sketchFullScreen() {
//  return true;
//}



String msg;

//
// Initialization
//
void setup() {
  int i,j,k;
  
 // cwidth=displayWidth; 
  //cheight=displayHeight;
  
    cwidth=1024; 
  cheight=800;
  
  
  offsetkx=(cwidth-side)/2;
  offsetky=(cheight-side)/2;
  
  size(1024,800);
  //size(cwidth,cheight);
  
  //cursor(CROSS);
  mouseX=mouseY=side/2;
  noCursor();
  frame.setTitle(title);
  
  colorCursor=new PImage[3][3];
  
  
  mouseCursor=loadImage("mouseCursor.png");
  
  for(i=0;i<9;i++) {iconCursor[i]=loadImage(".//icon/"+i+".png");
iconCursorInit[i]=loadImage(".//icon/"+i+".png");
}
  
  // cursors with different colors
  for(i=0;i<3;i++)
  for(j=0;j<3;j++)
  {colorCursor[i][j]=loadImage("cursor-0.png");}
  
   for(i=0;i<3;i++)
  for(j=0;j<3;j++)
  for(k=0;k<3;k++)
    palette[i][j][k]=(int)random(0,256);


f = loadFont("CourierNew36.vlw");
  textAlign(CENTER);
smooth();
  // Set the font and its size (in units of pixels)
  textFont(f, 48);


//fill(0);

digits[0][0]="1";
digits[0][1]="2";
digits[0][2]="3";
digits[1][0]="4";
digits[1][1]="5";
digits[1][2]="6";
digits[2][0]="7";
digits[2][1]="8";
digits[2][2]="9";


nbassoc=5;
assocPwd=new int[nbassoc];
for(i=0;i<nbassoc;i++)
{
assocPwd[i]=(int)random(0,9); 
associativepin=associativepin.concat(Integer.toString(assocPwd[i]));
// between 0 to 8
}

 

lasttime=System.nanoTime();
}

void permutationColor()
{
color tmp;
int i,i1, i2;

  for(i=0;i<10;i++)
{

  i1=(int)random(0,9);
  i2=(int)random(0,9);
  
  tmp=digitColor[i1];
  digitColor[i1]=digitColor[i2];
  digitColor[i2]=tmp;
  
}

}



void permutationText()
{
String tmp;
int i,i1, i2;
PImage tmpimg;


  for(i=0;i<10;i++)
{

  i1=(int)random(0,9);
  i2=(int)random(0,9);
  
  tmp=textPin[i1];
  textPin[i1]=textPin[i2];
  textPin[i2]=tmp;
  
}


}


// new to recreate icons, cannot equate PImage
void permutationIcon()
{
String tmp;
int i,i1, i2;
PImage tmpimg;



  for(i=0;i<10;i++)
{

  i1=(int)random(0,9);
  i2=(int)random(0,9);
  
  
  tmpimg=iconCursor[i1].get();
 iconCursor[i1]=iconCursor[i2].get();
 iconCursor[i2]=tmpimg.get();
  
}


}


void permutation()
{int x1,y1, x2,y2, i1,i2,i;
 for(i=0;i<9;i++)
  {
  i1=(int)random(0,9);
  i2=(int)random(0,9);
  
  
  String tmp=digitPin[i1];
  digitPin[i1] =digitPin[i2];
  digitPin[i2]=tmp;
  
  } 
}


void beforepermutation()
{int x1,y1, x2,y2, i1,i2,i;
 for(i=0;i<9;i++)
  {
  i1=(int)random(0,9);
  i2=(int)random(0,9);
  x1=i1/3;y1=i1%3;
   x2=i2/3;y2=i2%3;
  
  String tmp=digits[x1][y1];
  digits[x1][y1]=digits[x2][y2];
  digits[x2][y2]=tmp;
  
  } 
}

int posx, posy;

void fimage(PImage img, int x, int y)
{image(img,x%side,y%side);}


// Return the index
void index(int x, int y)
{
//y=h-y;// reverse

if (x<offsetkx)   index(x+side,y);
if (x>offsetkx+side)   index(x-side,y);

if(y<offsetky)  index(x,y+side);
if(y>offsetky+side)  index(x,y-side);

msg="x:"+x+" y:"+y;

posx=(x-offsetkx)/sidebutton;
posy=(y-offsetky)/sidebutton;

 msg=msg+" posx:"+posx+" posy:"+posy;
 if ((posx<3)&&(posx>=0)&&(posy<3)&&(posy>=0))  msg=msg+" input:"+digitPin[3*posy+posx];


 
}


 
void Rect(int x, int y, int ww, int hh)
{rect(x%side,y%side,ww,hh);}

void Line(int x1, int y1, int x2, int y2)
{
line(x1+offsetkx, y1+offsetky, x2+offsetkx, y2+offsetky);  
}

void Text(String S, int x, int y)
{
//text(S, offsetkx+ x%side, offsetkeyy+ y%side);
text(S, offsetkx+ x, offsetkeyy+ y);
}


  int a=0;

//
// General drawing procedure
//
void draw()
{int i,j;
 background(255,255,255);
 stroke(0);
  strokeWeight(3);

 
 // 3x3 button canvas
 Line(0,0, 0, side);
 Line(sidebutton,0, sidebutton, side);
 Line(2*sidebutton,0, 2*sidebutton, side);
 Line(3*sidebutton,0, 3*sidebutton, side);
   
 Line(0,0,side,0);  
 Line(0,sidebutton,side,sidebutton);
 Line(0,2*sidebutton, side,2*sidebutton);
 Line(0,3*sidebutton, side,3*sidebutton);
 
 //
 // Display the digit key panel
 //
 
 if (fixedMode==0){
 textSize(48);
 fill(BLACK);
 for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
 text(digitPin[3*i+j],((j)*sidebutton)+offsetkeyx+offsetkx,((i)*sidebutton)+offsetkeyy+offsetky);
 }
 }
 }
 
 if (fixedMode==2){
for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
   if (iconCursor[i*3+j]!=null)
       image(iconCursor[i*3+j],i*sidebutton+ offsetkx+32 , (j*sidebutton)+ offsetky+32);

 }
 }
 }
 
 
 
 // Mode 0: digits
 
 if (moveableMode==0)
 {
   String assoc;
{
  fill(BLUE);stroke(BLUE);
  textSize(46);
   for(i=0;i<3;i++){
for(j=0;j<3;j++)
{


for(int l=-5;l<=5;l++)
for(int m=-5;m<=5;m++){
  
for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
   assoc=digitPin[i*3+j];
   if (displayCoord) assoc=assoc+j+i;
 text(assoc,(mouseX+l*side+(i)*sidebutton)+offsetkeyx+offsetkx,mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky);
 }
 }
 
}

}
   }
}
 }
 
 if (moveableMode==1)
 {
   String assoc;
{
   for(i=0;i<3;i++){
for(j=0;j<3;j++)
{
fill(BLUE);stroke(BLUE);

if (displayMouse) text("+",mouseX, mouseY);

//Text(textPin[i*3+j],mouseX+j*sidebutton, mouseY+i*sidebutton); 
 

 //text(textPin[0],(mouseX)+offsetkeyx+offsetkx,mouseY+ +offsetkeyy+offsetky);
 

for(int l=-5;l<=5;l++)
for(int m=-5;m<=5;m++){
  
for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
   assoc=textPin[i*3+j];
   if (displayCoord) assoc=assoc+j+i;
 text(assoc,(mouseX+l*side+(i)*sidebutton)+offsetkeyx+offsetkx,mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky);
 }
 }
 
}

}
   }
}
 }

if (moveableMode==2)
{
 
for(int l=-5;l<=5;l++)
for(int m=-5;m<=5;m++){
  
for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
  stroke(digitColor[i*3+j]);
fill(digitColor[i*3+j]);
tint(digitColor[i*3+j],0.5);
rect(mouseX+l*side+(i)*sidebutton+offsetkeyx+offsetkx , mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky, 30, 30);

 //text(assoc,(mouseX+l*side+(i)*sidebutton)+offsetkeyx+offsetkx,mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky);
 }
 }
 
}

for(i=0;i<3;i++)
for(j=0;j<3;j++)
{
// stroke(palette[i][j][0],palette[i][j][1],palette[i][j][2]);
//fill(palette[i][j][0],palette[i][j][1],palette[i][j][2]);

  //fimage(colorCursor[i][j], mouseX+j*sidebutton,mouseY+i*sidebutton);
}

}
  

 //
 
 if (moveableMode==3)
{
 
for(int l=-5;l<=5;l++)
for(int m=-5;m<=5;m++){
  
for(i=0;i<3;i++){
 for(j=0;j<3;j++)
 {
   if (iconCursor[i*3+j]!=null)
 image(iconCursor[i*3+j],mouseX+l*side+(i)*sidebutton+offsetkeyx+offsetkx , mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky);

 //text(assoc,(mouseX+l*side+(i)*sidebutton)+offsetkeyx+offsetkx,mouseY+m*side+((j)*sidebutton)+offsetkeyy+offsetky);
 }
 }
 
}

 

}
  
 
 //
 
  if (moveableMode==4)
{
 
for(int l=-5;l<=5;l++)
for(int m=-5;m<=5;m++)
 {
 image(mouseCursor,mouseX+l*side +offsetkeyx-mouseCursorX  , mouseY+m*side+offsetkeyy-mouseCursorY);
 }
 
 
}

 


  
 
 //
 
 
 //Line(0,panelh,w,panelh);  
 
 /*
 int offsetm=30;
 if (mouseX>side-offsetm) mouseX=offsetm;
 if (mouseX<offsetm) mouseX=side-offsetm;
  if (mouseY>offsetm) mouseY=offsetm;
 if (mouseY<offsetm) mouseY=side-offsetm;
 */
 

 
 if (keyPressed == true)
 {
if (key =='q') exit();   

if (System.nanoTime()-lasttime>200000000){
lasttime=System.nanoTime();
if (key =='c') displayCoord=!displayCoord;

if (key =='0') moveableMode=0;
if (key =='1') moveableMode=1;
if (key =='2') moveableMode=2;
if (key =='3') moveableMode=3;
if (key =='4') moveableMode=4;


if (key =='v') viewport=!viewport;

if (key =='g'){showMessage=!showMessage;}

if (key =='m') {displayMouse=!displayMouse;}

if (key =='p') {showPlain=!showPlain;}

if (key =='i') {showInfo=!showInfo;}


if (key =='d') 
{// demo mode
viewport=true; displayCoord=false; displayMouse=false;showPlain=false;showMessage=false;
showInfo=false;
}

if (key =='r') 
{
plainPassword="";  
// reset
pwdlength=0;
nbassoc=5;
assocPwd=new int[nbassoc];
associativepin="";
for(i=0;i<nbassoc;i++)
{
assocPwd[i]=(int)random(0,9); 
associativepin=associativepin.concat(Integer.toString(assocPwd[i]));
// between 0 to 8
}

permutation();
permutationColor(); 
permutationText();
permutationIcon();
}
    
 } 
 
 }
 
 
 if (mousePressed == true  ) {


// avoids multiple events
//println(System.nanoTime()-lasttime);
if (System.nanoTime()-lasttime>200000000)
 {
   lasttime=System.nanoTime();
   a=0;pwdlength++;

 index(mouseX+offsetkeyx,mouseY+offsetkeyy);
 
if ((posx>=0)&(posx<3)&(posy>=0)&(posy<3))
plainPassword=plainPassword.concat(digitPin[3*posy+posx]+"["+textPin[2]+"]"); 
 

permutation();
permutationColor(); 
permutationText();
permutationIcon();

 }
 }
 
 
// to simulate viewport clipping, draw 4 rectangles. 
stroke(WHITE);
fill(WHITE);
int bd=3;

if (viewport){
rect(0,0,cwidth,offsetky-bd); // top rectangle
rect(0,offsetky+side+bd,cwidth,cheight); // bottom rectangle

rect(0,0,offsetkx-bd,cheight); // left rectangle
rect(offsetkx+side+bd,0, cwidth,cheight); // right rectangle
}

stroke(BLACK);fill(BLACK);
text("LAPIN", offsetkx+side/2,40);

textSize(20);
text("Logging using Associative Personal Identification Numbers", offsetkx+side/2,70);

 // Display the password
 color(RED);
 stroke(RED);fill(RED);
 String pwdshow="";
 for(int ii=0;ii<pwdlength;ii++)
 {pwdshow=pwdshow.concat("*");}
 Text(pwdshow,side/2,30);
 
 if (showPlain)
 {
    color(PURPLE);
 stroke(PURPLE);fill(PURPLE);
  text(plainPassword,side/2+offsetkx,cheight-100);
 }
 
stroke(BLACK); 
fill(BLACK); 
textSize(26); 
text("(C) 2013 Frank Nielsen, Sony Computer Science Laboratories Inc",600,cheight-50); 


if (showMessage) text(">"+msg,600,cheight-150); 

textSize(46);
fill(BLUE);stroke(BLUE);

if (showInfo)
{
int dx=150;
stroke(BLACK); 
fill(BLACK); 
textSize(20); 
text("Login:"+loginName,dx,offsetky);
text("PIN:"+passwd,dx, offsetky+30);
text("Assoc. PIN:"+associativepin,dx, offsetky+60);

for(  i=0;i<nbassoc;i++)
{
  
if (mode==0) {
text(textPinInit[assocPwd[i]],40+i*20,offsetky+140);
}  

if (mode==1){
  stroke(digitColorInit[assocPwd[i]]);  
 fill(digitColorInit[assocPwd[i]]); 
rect(40+i*40,offsetky+140,30,30);
}

if (mode==2)
    image(iconCursorInit[assocPwd[i]],64*i+20,offsetky+140);

}

}

if (displayMouse) {text("+",mouseX, mouseY);text(".",mouseX+offsetkeyx, mouseY+offsetkeyy);}


}
