
static double sqr(double x) {
  return x*x;
}

static double beforem(double a1, double b1, double x)
{
  return a1+b1*x*2+(1-a1-b1)*x*x*3;
}


static double m(double a, double b, double x)
{
  return (1-a-b)+a*x*2+b*x*x*3;
}

// chatgpt
/*
compute differential entropy of $$
m_\theta(x)=  (1-\theta_1-\theta_2) + 2\theta_1 x + 3\theta_2 x^2,
$$

*/
static double differentialEntropy(double theta1, double theta2 )
{
  double a, b, c;

  a = 1 - theta1 - theta2;
  b = 2*theta1;
  c= 3*theta2;


  double h= (1.0/(12.0*sqr(c))) *  ( sqr(a + b + c)  * (2* Math.log(a + b + c) - 1 ) - sqr(a) * (2*Math.log(a) - 1) - 2*a*c + sqr(b));



  return h;
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


    public static double wolfH(double a, double b, double x) {
        double sqrtTerm = Math.sqrt(a * a + 3 * a * b + 3 * (b - 1) * b);
        double logArg1 = 1 - a - b + 2 * a * x + 3 * b * x * x;
        double logArg2 = (a + 3 * b * x) / sqrtTerm;

        double numeratorPart1 = -3 * b * x * (4 * a * a - 3 * a * b * (-5 + 4 * x) + 3 * b * (-5 + b * (5 + 2 * x * x)));
        double numeratorPart2 = (4 * Math.pow(a, 3) + 9 * a * a * b + 9 * a * (b - 1) * b + 27 * Math.pow(b, 3) * Math.pow(x, 3)) * Math.log(logArg1);
        double numeratorPart3 = sqrtTerm * (4 * a * a + 3 * a * b + 3 * (b - 1) * b) *
                (-Math.log(1 - logArg2) + Math.log(1 + logArg2));

        double numerator = numeratorPart1 + numeratorPart2 + numeratorPart3;
        double denominator = 27 * b * b;

        return numerator / denominator;
    }

 public static double wolfH(double a, double b) {
 return  wolfH(a,b,1)-wolfH(a,b,0);
 }


/*

primitive (1-a-b)+2*a*x+3*b*x^2)*log((1-a-b)+2*a*x+3*b*x^2))


integral((1 - a - b) + 2 a x + 3 b x^2 log((1 - a - b) + 2 a x + 3 b x^2)) dx =

(-3 b x (4 a^2 - 3 a b (-5 + 4 x) + 3 b (-5 + b (5 + 2 x^2))) + (4 a^3 + 9 a^2 b + 9 a (-1 + b) b + 27 b^3 x^3) Log[1 - a - b + 2 a x + 3 b x^2] 
+ Sqrt[a^2 + 3 a b + 3 (-1 + b) b] (4 a^2 + 3 a b + 3 (-1 + b) b) (-Log[1 - (a + 3 b x)/Sqrt[a^2 + 3 a b + 3 (-1 + b) b]] 
+ Log[1 + (a + 3 b x)/Sqrt[a^2 + 3 a b + 3 (-1 + b) b]]))/(27 b^2)

(-3 b x (4 a^2 - 3 a b (-5 + 4 x) + 3 b (-5 + b (5 + 2 x^2))) + (4 a^3 + 9 a^2 b + 9 a (-1 + b) b + 27 b^3 x^3) Log[1 - a - b + 2 a x + 3 b x^2] + Sqrt[a^2 + 3 a b + 3 (-1 + b) b] (4 a^2 + 3 a b + 3 (-1 + b) b) (-Log[1 - (a + 3 b x)/Sqrt[a^2 + 3 a b + 3 (-1 + b) b]] + Log[1 + (a + 3 b x)/Sqrt[a^2 + 3 a b + 3 (-1 + b) b]]))/(27 b^2)

*/


/*
primitive (a+2*b*x+3*(1-a-b)*x^2)*log(a+2*b*x+3*(1-a-b)*x^2)
 
 beware need internally complex
 
 integral(a + 2 b x + 3 (1 - a - b) x^2) log(a + 2 b x + 3 (1 - a - b) x^2) dx =
 
 1/27 ((6 x (3 a^2 (x^2 - 2) + a (b (6 x^2 - 3 x - 6) - 6 x^2 + 6) + b^2 (3 x^2 - 3 x - 1) + 3 b (1 - 2 x) x + 3 x^2))/(a + b - 1) + (4 (-3 a^2 - 3 a (b - 1) - b^2)^(3/2) tan^(-1)((-3 (a - 1) x - 3 b x + b)/sqrt(-3 a^2 - 3 a (b - 1) - b^2)))/(a + b - 1)^2 + (-(2 b^3)/(a + b - 1)^2 - (9 a b)/(a + b - 1) + 27 x (-a x^2 + a + x^2) - 27 b (x - 1) x^2) log(-3 x^2 (a + b - 1) + a + 2 b x))
 
 */

// Good
static double approxH(double a, double b)
{
  double res=0;
  double x;
  int nbstep=0;
  double mass=0;

  for (x=0; x<=1; x+=0.001)
  {
  //  mass+=m(a, b, x);
    res+=m(a, b, x)*Math.log(m(a, b, x));
    nbstep++;
  }

  //mass=mass/(double)nbstep;
  //println("checking mixture mass:"+mass);


  return -res/(double)nbstep;
}


static double approxKL(double a1, double b1, double a2, double b2)
{
  double res=0;
  double x;
  int nbstep=0;
  double mass=0;

  for (x=0; x<=1; x+=0.001)
  {
    mass+=m(a1, b1, x);
    res+=m(a1, b1, x)*Math.log(m(a1, b1, x)/m(a2, b2, x))+m(a2, b2, x)-m(a1, b1, x);
    nbstep++;
  }

  mass=mass/(double)nbstep;
  println("checking mixture mass:"+mass);


  return res/(double)nbstep;
}

static double F(double a, double b)
{
  return  mh(a, b, 1)-mh(a, b, 0);
}

public static void main(String[] args) {
  // Example usage
  double a = Math.random();
  double b = (1-a)*Math.random();
  
  System.out.println("2D mixture family: w1="+a+"\t w2="+b);

  /*
        double a1 = 0.2;
   double b1 = 0.1;
   
   double a2 = 0.3;
   double b2 = 0.5;
   
   
   double x = 0.5;
   
   double result = mh(a, b, x);
   System.out.println("Result: " + result);
   
   
   
   double akl=approxKL(a1,b1,a2,a2);
   println("Approximate KL:"+akl);
   */

  double hexp=differentialEntropy(a, b);
  double hest=approxH(a, b);
  println("Differential entropy:"+hexp);
  println("Differential entropy MC estimation:"+hest);
  
 // double result = mh(a, b, x);
  double Fab=F(a,b);
   System.out.println("Fab: " + Fab);
   
   
   double wH=wolfH(a,b);
   System.out.println("wolfram H: " +wH);


  // closed to
}

/*
compute differential entropy of 
$$
m(x)=  (1-a-b) + 2*a*x + 3*b*x*x
$$
*/
