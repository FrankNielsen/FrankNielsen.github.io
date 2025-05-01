
static double sqr(double x){return x*x;}

static double m(double a1,double b1,double x)
{
 return a1+b1*x*2+(1-a1-b1)*x*x*3; 
}


    public static double mh(double a, double b, double x) {
        double denominator1 = a + b - 1;
        double denominator2 = Math.pow(denominator1, 2);

        // Part 1: Rational fraction
        double part1Numerator = 3 * a * a * (x * x - 2)
            + a * (b * (6 * x * x - 3 * x - 6) - 6 * x * x + 6)
            + b * b * (3 * x * x - 3 * x - 1)
            + 3 * b * (1 - 2 * x) * x
            + 3 * x * x;

        double part1 = (6 * part1Numerator) / denominator1;

        // Part 2: Arc tangent expression
        double sqrtTerm = -3 * a * a - 3 * a * (b - 1) - b * b;
        double atanNumerator = -3 * (a - 1) * x - 3 * b * x + b;

        double part2 = 4 * Math.pow(sqrtTerm, 1.5)
                * Math.atan(atanNumerator / Math.sqrt(sqrtTerm)) / denominator2;

        // Part 3: Logarithmic expression
        double logBase = -3 * x * x * denominator1 + a + 2 * b * x;
        double part3 = (-2 * Math.pow(b, 3)) / denominator2
                - (9 * a * b) / denominator1
                + 27 * x * (-a * x * x + a + x * x)
                - 27 * b * (x - 1) * x * x;
        part3 *= Math.log(logBase);

        // Final result
        double result = (1.0 / 27.0) * (part1 + part2 + part3);
        return result;
    }



static double approxKL(double a1,double b1, double a2,double b2)
{
 double res=0;
 double x; int nbstep=0;
 double mass=0;
 
 for(x=0;x<=1;x+=0.001)
 {mass+=m(a1,b1,x);
   res+=m(a1,b1,x)*Math.log(m(a1,b1,x)/m(a2,b2,x))+m(a2,b2,x)-m(a1,b1,x);
 nbstep++;}
 
 mass=mass/(double)nbstep;
 println("checking mixture mass:"+mass);
 
 
 return res/(double)nbstep;
}

static double F(double a, double b)
{
return  mh(a,b,1)-mh(a,b,0);
}

    public static void main(String[] args) {
        // Example usage
        double a = 0.2;
        double b = 0.1;
        
        double a1 = 0.2;
        double b1 = 0.1;
        
        double a2 = 0.3;
        double b2 = 0.5;
        
        
        double x = 0.5;

        double result = mh(a, b, x);
        System.out.println("Result: " + result);
        
        double Fab=F(a,b);
        System.out.println("Fab: " + result);
        
        double akl=approxKL(a1,b1,a2,a2);
        println("Approximate KL:"+akl);
    }
