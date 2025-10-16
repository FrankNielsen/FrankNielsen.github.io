import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;


  class MaximalLayer {
  
static boolean isMaximal2(Point p, List<Point>  points)
{int i,n=points.size();
boolean res=true;

for(i=0;i<n;i++)
{
 Point q=points.get(i);
 if ((q.x>p.x)&&(q.y<p.y)) {res=false;break;}
}

  return res;
}


static boolean isMaximal(Point p,List<Point>  points, int orderx, int ordery)
{int i,n=points.size();
boolean res=true;

for(i=0;i<n;i++)
{
 Point q=points.get(i);
 if ((q.x>orderx*p.x)&&(q.y<ordery*p.y)) {res=false;break;}
}

  return res;
}


static boolean isMaximal(Point p, List<Point>  points)
{int i,n=points.size();
boolean res=true;

for(i=0;i<n;i++)
{
 Point q=points.get(i);
 if ((q.x>p.x)&&(q.y>p.y)) {res=false;break;}
}

  return res;
}


  public static List<Point> makeLayer(List<Point> points, int orderx, int ordery) 
  {
    List<Point> newPoints = new ArrayList<>(points);
     List<Point> result = new ArrayList<>();
     
    int i;
    
    for(i=0;i<points.size();i++)
    {
     if (isMaximal(points.get(i),points, orderx, ordery)) {result.add(points.get(i));} 
    }
    
    System.out.println("Maximal layer size:"+result.size());
   
  //  Collections.sort(result);
     return result;
    
    //return  null; // makeHullPresorted(newPoints);
  }
  
  
  
  public static List<Point> makeLayer(List<Point> points) 
  {
    List<Point> newPoints = new ArrayList<>(points);
     List<Point> result = new ArrayList<>();
     
    int i;
    
    for(i=0;i<points.size();i++)
    {
     if (isMaximal(points.get(i),points)) {result.add(points.get(i));} 
    }
    
    System.out.println("Maximal layer size:"+result.size());
   
    Collections.sort(result);
     return result;
    
    //return  null; // makeHullPresorted(newPoints);
  }
  
  
  }
  
  
