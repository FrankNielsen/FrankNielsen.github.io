public class NestedHilbertDistance
{
	
static double HilbertDistance1D(double p,double q, double pbar, double qbar)
{
double alpham, alphap;
double delta=q-p;

alpham=(pbar-p)/delta; // <0
alphap=(qbar-p)/delta; // >1

return Math.log(alphap*(1.0-alpham)/(-alpham*(alphap-1.0)));	
	
}	
	
public static void  test()
{
	double p,q, barp1, barq1, barp2, barq2;
	
	p=Math.random(); q=p+Math.random(); // q>p
	barq1=q+Math.random();barq2=barq1+Math.random();
	barp1=p-Math.random();barp2=barp1-Math.random();
	
	double H1, H2;
	H1=HilbertDistance1D(p,q,barp1,barq1);
	H2=HilbertDistance1D(p,q,barp2,barq2);
	
	
	// Omega1 is contained inside Omega2
	System.out.println("Check that: "+H1+"\t>=\t"+H2);
	if (H1<H2) {	System.out.println("Error!"); System.exit(-1);}
}	


public static void  main(String [] a)
{
	System.out.println("Nested Hilbert Distances");
	int i;
	for(i=0;i<16;i++)
		test();
}
	
	
}
