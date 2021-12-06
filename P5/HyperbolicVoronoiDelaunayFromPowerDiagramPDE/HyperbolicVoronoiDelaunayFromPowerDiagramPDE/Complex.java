
// http://introcs.cs.princeton.edu/java/97data/Complex.java.html
class Complex {
     double re;   // the real part
   double im;   // the imaginary part

 
  public  Complex dualFocus(Complex a)
 {Complex z=new Complex(this);
   Complex a2=a.times(a);
  Complex num=(a2.minus(1.0)).times(z);
   Complex den=a2.times(z.times(z)).minus(1);
   
   return num.divides(den);
 }
 
 
 public   Complex isometry(double theta, Complex z0)
{
// z\maps e^{i\theta} \frac{z+z_0}{\bz_0 z+1}, \theta\in\mathbb{R}, $|z_0|<1$  
Complex eitheta=new Complex(Math.cos(theta),Math.sin(theta));
Complex z=new Complex(this);
Complex result=(z.plus(z0)).divides(((z0.conjugate().times(z)).plus(1)));
return eitheta.times(result);
}

 
    // create a new object with the given real and imaginary parts
    public Complex(double real, double imag) {
        re = real;
        im = imag;
    }


public Complex(Complex z) {
        re = z.re;
        im = z.im;
    }


    // return a string representation of the invoking Complex object
    public String toString() {
        if (im == 0) return re + "";
        if (re == 0) return im + "i";
        if (im <  0) return re + " - " + (-im) + "i";
        return re + " + " + im + "i";
    }

    // return abs/modulus/magnitude and angle/phase/argument
    public double abs()   { return Math.hypot(re, im); }  // Math.sqrt(re*re + im*im)
    public double phase() { return Math.atan2(im, re); }  // between -pi and pi

    // return a new Complex object whose value is (this + b)
    public Complex plus(Complex b) {
        Complex a = this;             // invoking object
        double real = a.re + b.re;
        double imag = a.im + b.im;
        return new Complex(real, imag);
    }
    
     public Complex plus(double b) {
        Complex a = this;             // invoking object
        double real = a.re + b;
        double imag = a.im  ;
        return new Complex(real, imag);
    }
    
    
    
       Complex plus(Complex a, Complex b) {
        
        double real = a.re + b.re;
        double imag = a.im + b.im;
        return new Complex(real, imag);
    }
    

    // return a new Complex object whose value is (this - b)
    public Complex minus(Complex b) {
        Complex a = this;
        double real = a.re - b.re;
        double imag = a.im - b.im;
        return new Complex(real, imag);
    }
    
        public Complex minus(double b) {
        Complex a = this;
        double real = a.re - b;
        double imag = a.im ;
        return new Complex(real, imag);
    }
    
    
        public  Complex minus(Complex a,Complex b) {
        
        double real = a.re - b.re;
        double imag = a.im - b.im;
        return new Complex(real, imag);
    }



    // return a new Complex object whose value is (this * b)
    public Complex times(Complex b) {
        Complex a = this;
        double real = a.re * b.re - a.im * b.im;
        double imag = a.re * b.im + a.im * b.re;
        return new Complex(real, imag);
    }
    
    public   Complex times( Complex a,Complex b) {
      
        double real = a.re * b.re - a.im * b.im;
        double imag = a.re * b.im + a.im * b.re;
        return new Complex(real, imag);
    }

    // scalar multiplication
    // return a new object whose value is (this * alpha)
    public Complex times(double alpha) {
        return new Complex(alpha * re, alpha * im);
    }
    
     public   Complex times(Complex z, double alpha) {
        return new Complex(alpha * z.re, alpha * z.im);
    }
    

    // return a new Complex object whose value is the conjugate of this
    public Complex conjugate() {  return new Complex(re, -im); }

    // return a new Complex object whose value is the reciprocal of this
    public Complex reciprocal() {
        double scale = re*re + im*im;
        return new Complex(re / scale, -im / scale);
    }

    // return the real or imaginary part
    public double re() { return re; }
    public double im() { return im; }

    // return a / b
    public Complex divides(Complex b) {
        Complex a = this;
        return a.times(b.reciprocal());
    }

    // return a new Complex object whose value is the complex exponential of this
    public Complex exp() {
        return new Complex(Math.exp(re) * Math.cos(im), Math.exp(re) * Math.sin(im));
    }

    // return a new Complex object whose value is the complex sine of this
    public Complex sin() {
        return new Complex(Math.sin(re) * Math.cosh(im), Math.cos(re) * Math.sinh(im));
    }

    // return a new Complex object whose value is the complex cosine of this
    public Complex cos() {
        return new Complex(Math.cos(re) * Math.cosh(im), -Math.sin(re) * Math.sinh(im));
    }

    // return a new Complex object whose value is the complex tangent of this
    public Complex tan() {
        return sin().divides(cos());
    }
    
    
    

}
 
