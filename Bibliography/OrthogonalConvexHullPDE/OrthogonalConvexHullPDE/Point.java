
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;


class Point implements Comparable<Point> {
  
  static int orderx=1, ordery=1;
  public  double x;
  public  double y;
  public int id;
  
  public Point(double x, double y, int id) {
    this.x = x;
    this.y = y;
    this.id=id;
  }
  
  public Point(double x, double y) {
    this.x = x;
    this.y = y;
    this.id=0;
  }
  
  
  public String toString() {
    return String.format("Point(%g, %g)", x, y);
  }
  
  
  public boolean equals(Object obj) {
    if (!(obj instanceof Point))
      return false;
    else {
      Point other = (Point)obj;
      return x == other.x && y == other.y;
    }
  }
  
  
  public int hashCode() {
    return Objects.hash(x, y);
  }
  
  
  public int compareTo(Point other) {
    if (x != other.x)
      return orderx*Double.compare(x, other.x);
    else
      return ordery*Double.compare(y, other.y);
  }
  
}
