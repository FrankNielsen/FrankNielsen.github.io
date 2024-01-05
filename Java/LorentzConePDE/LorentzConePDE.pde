// Frank.Nielsen@acm.org

void setup()
{
 println("2023 Dec, FN. Demo: Lorentz cone"); 
 
 KleinDisk.Test();
 
 Test1();
 //Test2();
}


public static double InnerProduct(double [] p , double [] q)
  {
   int d=p.length; 
   int i;
   double res=0;
   
   for(i=0;i<d;i++) res+=p[i]*q[i];
   
   return res;
    
  }
  
  
void PrintPoint(double [] p)
{int i,d=p.length;
String res="";

for(i=0;i<d;i++) res=res+" "+p[i];

println(res);
}


// if we want to change the curvature, we need to multiply by $\sqrt{-\kappa}$ the distance
void Test2()
{
  double R;
    int d=15;
   
  
  println("Demo 2");
  
  
   R=1+Math.random()*5;
  println("Radius R="+R);
  
  double [] p, q, pk,qk;
  double BD,KD;
  
 p=LorentzCone.randomPointLorentzCone(d);
 q=LorentzCone.randomPointLorentzCone(d);

  BD=LorentzCone.BirkhoffDistance(p,q);

println("Birkhoff cone/Hilbert projective distance between rays:"+BD);

double alpha=LorentzCone.alpha(p,q);

println(LorentzCone.lessthanorequal(p,LorentzCone.scale(alpha,q)));
println(LorentzCone.diff(p,LorentzCone.scale(alpha,q)));

// Get the points on the unit disk
   pk=LorentzCone.normalizeKleinDisk(R,p);
   qk=LorentzCone.normalizeKleinDisk(R,q);

  KD=KleinDisk.KleinDistance(R,pk,qk);
  println("Klein distance:"+KD);
  
  // model size
     R=1+Math.random()*5;
  println("Radius R="+R);
   pk=LorentzCone.normalizeKleinDisk(R,p);
   qk=LorentzCone.normalizeKleinDisk(R,q);

  KD=KleinDisk.KleinDistance(R,pk,qk);
//double rp=Math.sqrt(InnerProduct(pk,pk));
//println("rp="+rp);

println("Klein distance:"+KD);

}

void Test1()
{double R;
  
   println("Demo 1");
   
  int d=10;
   R=1+Math.random()*50;
  
double [] p=LorentzCone.randomPointLorentzCone(d);
double [] q=LorentzCone.randomPointLorentzCone(d);

//PrintPoint(p);
//PrintPoint(q);

// projective distance between rays
double BD=LorentzCone.BirkhoffDistance(p,q);

println("Birkhoff cone/Hilbert projective distance between rays:"+BD);

// Get the points on the unit disk
double [] pk=LorentzCone.normalizeKleinDisk(p);
double [] qk=LorentzCone.normalizeKleinDisk(q);

//PrintPoint(pk);
//PrintPoint(qk);

//double rp=Math.sqrt(InnerProduct(pk,pk));
//double rq=Math.sqrt(InnerProduct(qk,qk));

//println("rp="+rp+" rq="+rq);


double KD=KleinDisk.KleinDistance(pk,qk);
println("Klein distance:"+KD);

double err=Math.abs(KD-BD);
println("Error:"+err);

double [] ph,qh;
double HD;

// Get the points on the unit disk
  ph=LorentzCone.normalizeHyperboloid(p);
 qh=LorentzCone.normalizeHyperboloid(q);

//println("ph:"+LorentzCone.MInnerProduct(ph,ph));
//println("qh:"+LorentzCone.MInnerProduct(qh,qh));

 HD=MinkowskiHyperboloid.HyperboloidDistance(ph,qh);
println("Hyperboloid distance:"+HD);

  R=1+Math.random();

  ph=LorentzCone.normalizeHyperboloid(R,p);
 qh=LorentzCone.normalizeHyperboloid(R,q);

//println("ph:"+LorentzCone.MInnerProduct(ph,ph));
//println("qh:"+LorentzCone.MInnerProduct(qh,qh));

 HD=MinkowskiHyperboloid.HyperboloidDistance(ph,qh);
println("Hyperboloid distance (new scaled model):"+HD);


double[] pp=KleinDisk.Klein2Poincare(pk);
double[] pq=KleinDisk.Klein2Poincare(qk);
double PD=PoincareDisk.PoincareDistance(pp,pq);
println("Poincare distance:"+PD);

}
