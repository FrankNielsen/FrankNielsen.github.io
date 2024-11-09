// Frank Nielsen, Nov. 7 2024

// Lambert W principal branch
double W0(double x)
{
  return LambertW.branch0(x);
}

void setup()
{
println("Chernoff information between categorical distributions"); 


BernoulliExpFam.Test();

Test();
}

void Test()
{
double p=Math.random();
double q=Math.random();

double lambda=ChernoffDistribution(p,q);

double kl1=KL(lambda,p);
double kl2=KL(lambda,q);

println("lambda="+lambda);

println(kl1+" "+kl2);

}

double kl(double a, double b){return a*Math.log(a/b);}

// Bernoulli KLD
double KL(double p, double q){return kl(p,q)+kl(1-p,1-q);}

double ChernoffDistribution(double p, double q)
{
 double a=Math.log(q/p);
 double b=q-p;
 double c=q*Math.log(q)+p*Math.log(p);
 
 return (b/a)*W0((a/b)*Math.exp(c/b)); 
}
