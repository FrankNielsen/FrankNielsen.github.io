// Frank Nielsen, 9th August 2024
// demonstrates alpha-power -alpha power yield geometric mean

// rho-tau inductive mean

// question what is (rho,rhoinv)-inductive mean

/*
double rho(double u) {
  return u;
}

double rhoinv(double u) {
  return u;
}

double tau(double u)
{
  return 1.0/u;
}

double tauinv(double u)
{
  return 1.0/u;
}
*/

/*
double alpha=-5+10+Math.random();

double rho(double u) {
  return Math.pow(u,alpha);
}

double rhoinv(double u) {
  return Math.pow(u,1.0/alpha);
}

double tau(double u)
{
  return Math.pow(u,-alpha);
}

double tauinv(double u)
{
  return Math.pow(u,-1.0/alpha);
}
*/

double rho(double u) {
  return Math.exp(u);
}

double rhoinv(double u) {
  return Math.log(u);
}

double tau(double u)
{
  return rhoinv(u);
}

double tauinv(double u)
{
  return rho(u);
}


double QAMRho(double x, double y) {
  return rhoinv((rho(x)+rho(y))/2.0);
}
double QAMTau(double x, double y) {
  return tauinv((tau(x)+tau(y))/2.0);
}

double GeometricMean(double x, double y) {
  return Math.sqrt(x*y);
}
double InductiveMean(double x, double y, int nbiter)
{
  double xx, yy;
  if (nbiter==0) return x;
  else
  {
    xx=QAMRho(x, y);
    yy=QAMTau(x, y);
    return InductiveMean(xx, yy, nbiter-1);
  }
}

void init()
{
  double x=Math.random();
  double y=Math.random();

  double m=InductiveMean(x, y, 30);
  println(m);

  double g=GeometricMean(x, y);
  println(g);
}

void setup()
{
  init();
}
