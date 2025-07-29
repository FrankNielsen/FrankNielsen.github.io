// Frank.Nielsen@acm.org, July 2025
// to debug

abstract class PairConvex
{
  // Two convex functions
  abstract double F1(double theta);
  abstract double F2(double theta);


// Legendre dual convex functions
  double G1(double eta) {
    double theta=gradG1(eta);
    return eta*theta - F1(theta);
  }
  
  double G2(double eta) {
    double theta=gradG2(eta);
    return eta*theta -F2(theta);
  }

  abstract double gradF1(double theta);
  abstract double gradF2(double theta);
  
  // reciprocal gradient
  abstract double gradG1(double eta);
  abstract double gradG2(double eta);
  
  double FY1(double t1, double e2)
  {return F1(t1)+G1(e2)-t1*e2;}
  
    double FY2(double t1, double e2)
  {return F2(t1)+G2(e2)-t1*e2;}
  
  void check(){
  double theta=Math.random();
  double eta=gradF1(theta);
  System.out.println(FY1(theta,eta));
  eta=gradF2(theta);
    System.out.println(FY2(theta,eta));
  
  }

// Primal CCCP  min F1-F2
  double CCCP(double start, int nbiter)
  {
    double sol=start;
    int i;

    for (i=0; i<nbiter; i++)
    {
      double obj=F1(sol)-F2(sol);
      System.out.println("\tprimal:"+sol+"\t"+obj);
      sol=gradG1(gradF2(sol));
    }

    return F1(sol)-F2(sol);
  }

// Dual CCCP min G2-G1
  double CCCPdual(double start, int nbiter)
  {
    double sol=start;
    int i;

    for (i=0; i<nbiter; i++)
    {
      double obj=G2(sol)-G1(sol);
      System.out.println("\tdual:"+sol+"  \t"+obj);
      sol=gradF2(gradG1(sol));
    }

    return G2(sol)-G1(sol);
  }
}

// plot x*x-x^4
class SimpleExample extends PairConvex {

  SimpleExample() {
  }

  double F1(double theta) {
    return theta*theta;
  }
    double gradF1(double theta) {
    return 2.0*theta;
  }
   double gradG1(double eta) {
    return eta/2.0;
  }
  
  double F2(double theta) {
    return theta*theta*theta*theta;
  }

  double gradF2(double theta) {
    return 4.0*theta*theta*theta;
  }

  double gradG2(double eta) {
    return Math.pow(eta/4.0, 1.0/3.0);
  }
}


void setup()
{
  PairConvex PC=new SimpleExample();
  
  PC.check();
  
  int nbiter=15;
  
  double sol1=PC.CCCP(1.0, nbiter);
  
  double sol2=PC.CCCPdual(1.0, nbiter);

  System.out.println("primal solution:"+sol1+" dual solution:"+sol2);
}
