String [] cardfilename=new String[800];

int count=0;
//String yourPath = "C:/Travail/AllCards13Nov2021";

String yourPath = "C:/Travail/WWWGitHubFrankNIELSEN/FrankNielsen.github.io/Cards";
File someFolder = new File(yourPath);
File[] someFolderList = someFolder.listFiles();

for (File someFile : someFolderList) {
  // Check if it's a file or not
  if (someFile.isFile()) {
    // Check if string ends with extension
    if (someFile.getName().endsWith(".png")||someFile.getName().endsWith(".jpg")) {
      println(someFile.getName());
      cardfilename[count]=someFile.getName();
      count++;
    }
  }
}

 
println("count:"+count);

int perm, nbperm=1000;
for(  perm=0;perm<nbperm;perm++)
{
 String tmp;
 int ii,jj;
 ii=(int)(Math.random()*count);
 jj=(int)(Math.random()*count);
 tmp=cardfilename[ii];
 cardfilename[ii]=cardfilename[jj];
 cardfilename[jj]=tmp;
 
}

int i;

for(i=0;i<count;i++)
{
 String allcardshtml=""; 
 String htmlstr="<A HREF=\""+cardfilename[i]+"\" target=\"_blank\"><IMG SRC=\""+cardfilename[i]+"\" width="30%" height="30%"></HREF>";
 String [] strfile=new String[1];
 strfile[0]=htmlstr;
 String filenamehtml=yourPath+"/card-"+i+".html";
 saveStrings(filenamehtml, strfile);
}
