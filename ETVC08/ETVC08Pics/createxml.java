import java.io.*;
import java.io.Reader.*;

class createxml
{
public static void main(String [] a)
{
String s;

try{

BufferedReader in= new BufferedReader(new FileReader("ls.txt"));

do{

s=in.readLine();
System.out.println("<image>\n\t<filename>"+s+"</filename>\n\t<caption>"+s+"</caption>\n</image>\n");	
	} while (s.length()>0);
	}catch(Exception e){}

	
}


	
}