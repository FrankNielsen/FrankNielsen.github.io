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


println("detected #count (=number of cards):"+count);

// shuffle the deck
int perm, nbperm=1000;
for (  perm=0; perm<nbperm; perm++)
{
  String tmp;
  int ii, jj;
  ii=(int)(Math.random()*count);
  jj=(int)(Math.random()*count);
  tmp=cardfilename[ii];
  cardfilename[ii]=cardfilename[jj];
  cardfilename[jj]=tmp;
}

int maxcount=count-1;
int i;
String initcard="<h1>List of cards</h1>\n Click on a card and then browse the previous card or the following card from the current card.<BR>There are at most 25 cards per page<BR>The card order is random (at HTML compile time).<ul>"; 
String allcardshtml=initcard;

String htmlstr;
String filenamehtml;
String [] strfile=new String[1];
String prevfile, nextfile;
String metahtml="";

int page =0;
int maxpage=(int)(count/25)+1;

for (i=0; i<count; i++)
{

  if (i==0) {
    prevfile="card-"+(maxcount)+".html";
  } else {
    prevfile="card-"+(i-1)+".html";
  }
  if (i==maxcount) nextfile="card-"+0+".html"; 
  else nextfile="card-"+(i+1)+".html";

  /*
htmlstr="<center><A HREF=\""+cardfilename[i]+"\" target=\"_blank\"><IMG SRC=\""
   +cardfilename[i]+"\" border=\"3\"
   width=\"60%\" height=\"60%\"></HREF><BR>";
   //<A HREF=\""+prevfile+"\">prev</A> next </center>";
   */

  htmlstr="<center><A HREF=\""+cardfilename[i]+"\" target=\"_blank\"><IMG SRC=\""+cardfilename[i]
    +"\" width=\"60%\"  border=\"3\"></A>(#"+i+")<BR> <A HREF=\""
    +prevfile+"\">prev</A> &nbsp;&nbsp;&nbsp;<A HREF=\""+nextfile+"\">next</A></center>\n";

  filenamehtml=yourPath+"/card-"+i+".html";
  //filenamehtml="card-"+i+".html";

print("saving file "+filenamehtml+" "+cardfilename[i]+"\n");
  strfile[0]=htmlstr;
  saveStrings(filenamehtml, strfile);
  
  
  allcardshtml+="<LI><center><A HREF=\"card-"+i+".html\" target=\"_blank\"><IMG SRC=\""+cardfilename[i]
    +"\" width=\"60%\" border=\"3\"></A>("+i+")</LI>\n";
  
  
//  "<LI><A HREF=\""+filenamehtml+"\" target=\"_blank\"><IMG SRC=\""+cardfilename[i]+"\" width=\"30%\" height=\"30%\" border=\"3\"></HREF></LI>\n\n";




// flush at set of 25 cards
  if (((i+1)%25)==0) {
    println("flush a card page");
    allcardshtml+="</ul><BR> <A HREF=\"index"
      +(page-1)
      +".html\">Previous card page</A>&nbsp;&nbsp;&nbsp; <A HREF=\"index"+(page+1)
      +".html\">Next card page</A>"; 
      
    filenamehtml=yourPath+"/index"+page+".html";
    
 
  
    
       page++;
    
    strfile[0]=allcardshtml;
    saveStrings(filenamehtml, strfile);
    
    metahtml=metahtml+allcardshtml;
    
    allcardshtml=initcard;
  }
}



// last card
    println("flush a card page");
    allcardshtml+="</ul><BR> <A HREF=\"index"
      +(page-1)
      +".html\">Previous card page</A>&nbsp;&nbsp;&nbsp; <A HREF=\"index"+(page+1)
      +".html\">Next card page</A>"; 
      
    filenamehtml=yourPath+"/index"+page+".html";
    
 
  
    
       page++;
    
    strfile[0]=allcardshtml;
    saveStrings(filenamehtml, strfile);
    
    metahtml=metahtml+allcardshtml;
    
    allcardshtml=initcard;
    

println(count);

strfile[0]=metahtml+"</ul>";
//print(allcardshtml);


filenamehtml=yourPath+"/fullindex.html";
saveStrings(filenamehtml, strfile);


print("Done!");
