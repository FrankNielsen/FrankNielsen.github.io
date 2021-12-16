import java.io.*;


/*
 
 
 @proceedings{ETVC08/2008,
  editor    = {Frank Nielsen},
  title     = {Emerging Trends in Visual Computing, LIX Fall Colloquium,
               ETVC 2008, Palaiseau, France, November 18-20, 2008. Revised
               Invited Papers},
  booktitle = {ETVC},
  publisher = {Springer},
  series    = {Lecture Notes in Computer Science},
  volume    = {5416},
  year      = {2009},
  isbn      = {978-3-642-00825-2},
  ee        = {http://dx.doi.org/10.1007/978-3-642-00826-9},
  bibsource = {LIX, Ecole Polytechnique, NF}
}

*/

class toto
{
public static void main(String[] a)  
{	BufferedReader br=null ;
String title, name, pages;
int chapter=1;
 
String  doi, url, publisher, isbn, editor, year, booktitle;

doi="978-3-642-30232-9_";
url="http://www.informationgeometry.org/MIG/";
publisher="Springer";
isbn="978-3-642-30231-2";
editor="Frank Nielsen and Rajendra Bhatia";
year="2012"; 
booktitle="Matrix Information Geometry";

try {   br = new BufferedReader(new FileReader("toc.txt"));
    
        StringBuilder sb = new StringBuilder();
        String line = " ";

        while (line != null) {
           
            title = br.readLine();
            name = br.readLine();
            pages= br.readLine();
      // System.out.println("\t"+title+"\n"+name+"\n"+page);
 
 System.out.println("@inproceedings{MIG2012-Chapter"+chapter+",");
 System.out.println("\t author=\""+name+"\",");
 System.out.println("\t title=\""+title+"\",");
 System.out.println("\t editor=\""+editor+"\",");
 System.out.println("\t booktitle=\""+booktitle+"\",");
 System.out.println("\t pages=\""+pages+"\",");
 System.out.println("\t year=\""+year+"\",");
 System.out.println("\t doi=\""+doi+chapter+"\",");
 System.out.println("\t url=\""+url+"\",");
 System.out.println("\t pubblisher=\""+publisher+"\",");
 System.out.println("\t isbn=\""+isbn+"\"");
 System.out.println("}\n");
    
 
 line =pages;
 chapter++;
 if (chapter>20) System.exit(0);      
        }
       
        br.close();
    } 
    catch (IOException x) {
    System.err.format("IOException: %s%n", x);
}
 
}
}