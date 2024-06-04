PImage img;

void setup() {
  size(512,512);
  //img = loadImage("Barbara-gray.png");
img = loadImage("Lena-gray.png");
  img.loadPixels();
}

void draw() {
  image(img, 0, 0);
}

void histogram(){
float [] histo=new float[256];
println("#pixels="+img.width*img.height);
for(int i=0;i<img.width*img.height;i++)
{
int val=(int)(red(img.pixels[i])); 
//println(val);
histo[val]=histo[val]+1.0;
}

int i;
for( i=0;i<256;i++) histo[i]=(histo[i]+1)/(float)(256+img.width*img.height);

String [] data=new String[256];
for( i=0;i<256;i++) data[i]=String.valueOf(histo[i]);

String [] data2=new String[1];
data2[0]="{";
for( i=0;i<256;i++) data2[0]+=data[i]+",";
//saveStrings("Lena.histogram", data);
//saveStrings("Barbara.histogram", data);

saveStrings("Lena4Java.histogram", data2);
}

void keyPressed()
{
if (key=='h'){histogram();}
if (key=='q') exit();
}
