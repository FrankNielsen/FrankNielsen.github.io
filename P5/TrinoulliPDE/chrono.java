public class chrono {

    long starts;
    double t;
 

 public chrono() {
    starts = System.nanoTime();
    }

    public void reset() {	
    starts = System.nanoTime();
    }

    public double time() {
    	long ends = System.nanoTime();
    	t= (ends - starts)*1.0e-9;
    return t;
    }
    
    



}
