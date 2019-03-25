// Frank@Nielsen@acm.org
/*
Cross-entropy, differential entropy and Kullback-Leibler divergence between Rayleigh distributions

https://www.researchgate.net/publication/331768321_Cross-entropy_differential_entropy_and_Kullback-Leibler_divergence_between_Rayleigh_distributions

https://franknielsen.github.io
*/

/* Example of run
--------------------Configuration: <Default>--------------------
Information-theoretic measures for the family of Rayleigh distributions
sigma1:4.439137065806854
exact E[k(x)]:1.5484257608360412
numerical integration for E[k(x)]:1.5484257609673768
error:1.313356090548723E-10
----------------------------
closed-form for Shannon entropy h:2.4324942451776286
numerical integration for h:2.4324942453476623
error:1.7003376484581167E-10
----------------------------
sigma2:4.647347281758366
closed-form cross-entropy h:2.436570715326289
numerical integration cross-entropy:2.4365707154752028
error:1.489137702037624E-10
----------------------------
closed-form KL:0.004076470148660458
closed-form KL difference cross-entropy minus entropy:0.004076470148660416
numerical integration KL:0.004076470127149636
error:2.1510821769654687E-11
--- completed ---
*/
 
class RayleighCrossEntropy
{
	
	public static double xmax=100;
	public static double stepx=1.e-6;
	public static double xmin=0;
	
	// Euler-Mascheroni constant
	public static final double gamma = 0.577215664901532860606512090082;
	
	// Rayleigh density with scale factor s
	/* see 
	Statistical exponential families: A digest with flash cards
	 */
	public static double density(double x, double s)
	{
	return (x/(s*s))*Math.exp(-0.5*x*x/(s*s));	
	}
	
	// E[k(x)] auxiliary carrier term for IT measures
	public static double RieEk(double s)
	{
	double x;
	double res=0.0;
	
	for(x=stepx;x<=xmax;x+=stepx)
	{
	res=res+Math.log(x)*density(x,s);	
	}
	return res*stepx;
	}
	
	// Riemann numerical integration for Shannon cross-entropy 
	public static double Rieh(double s1,double s2)
	{
	double x;
	double res=0.0;
	double p, q;
	
	for(x=stepx;x<=xmax;x+=stepx)
	{
		p=density(x,s1);
		q=density(x,s2);
	res=res-p*Math.log(q);	
	}
	return res*stepx;
	}
	
	
	// Riemann numerical integration for Shannon entropy h
	public static double Rieh(double s)
	{
	double x;
	double res=0.0;
	double p;
	
	for(x=stepx;x<=xmax;x+=stepx)
	{
		p=density(x,s);
	
	res=res+p*Math.log(p);	
	}
	return -res*stepx;
	}
	
	
	// Riemann numerical integration for Kullback-Leibler divergence
	public static double RieKL(double s1, double s2)
	{
	double x;
	double res=0.0;
	double p, q;
	
	for(x=stepx;x<=xmax;x+=stepx)
	{
		p=density(x,s1);
	q=density(x,s2);
	res=res+p*Math.log(p/q);	
	}
	return res*stepx;
	}
	
	// Closed-form formula for auxiliary carrier term
	public static double Ek(double s)
	{
	return 0.5*(Math.log(2)-gamma)+Math.log(s);	
	}
	
	// Closed-form formula for cross-entropy
	public static double h(double s1, double s2)
	{
	return 2.0*Math.log(s2)+(s1*s1/(s2*s2))-Ek(s1);	
	}
	
	// Closed-form formula for entropy
	public static double h(double s)
	{
	return 1.0+Math.log(s/Math.sqrt(2.0))+0.5*gamma;
	}
	
	// Closed-form formula for Kullback-Leibler divergence
	public static double KL(double s1, double s2)
	{
	return 2.0*Math.log(s2/s1)+(s1*s1-s2*s2)/(s2*s2);
	}
	
	// Definition of the Kullback-Leibler divergence
	public static double KLh(double s1, double s2)
	{
	return h(s1,s2)-h(s1);
	}
	
	
public static void main(String [] args)
{
	double s1=2+5*Math.random();
	double s2=2+5*Math.random();

    double rie,exact,err;
    
    System.out.println("Information-theoretic measures for the family of Rayleigh distributions");
 	System.out.println("sigma1:"+s1);
 	
 	rie=RieEk(s1);
	exact=Ek(s1);
	err=Math.abs(rie-exact);
	
	System.out.println("exact E[k(x)]:"+exact);
	System.out.println("numerical integration for E[k(x)]:"+rie);
	System.out.println("error:"+err);
	
	System.out.println("----------------------------");
	 	
	 	
	exact=h(s1);
	rie=Rieh(s1);
	err=Math.abs(rie-exact);
	
	System.out.println("closed-form for Shannon entropy h:"+exact);
	System.out.println("numerical integration for h:"+rie);
	System.out.println("error:"+err);
	System.out.println("----------------------------");
	 
	System.out.println("sigma2:"+s2);
		
	exact=h(s1,s2);
	rie=Rieh(s1,s2);
	err=Math.abs(rie-exact);
		
	System.out.println("closed-form cross-entropy h:"+exact);
	System.out.println("numerical integration cross-entropy:"+rie);
	System.out.println("error:"+err);
	System.out.println("----------------------------");
 
	exact=KL(s1,s2);
	rie=RieKL(s1,s2);
	err=Math.abs(rie-exact);
		
	System.out.println("closed-form KL:"+exact);
	System.out.println("closed-form KL difference cross-entropy minus entropy:"+KLh(s1,s2));
	System.out.println("numerical integration KL:"+rie);
	System.out.println("error:"+err);
	
	System.out.println("--- completed ---");
}
	
	
}