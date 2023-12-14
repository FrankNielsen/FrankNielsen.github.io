void setup()
{
 println("Lorenz cone"); 
 
 Test1();
}


void PrintPoint(double [] p)
{int i,d=p.length;
String res="";

for(i=0;i<d;i++) res=res+" "+p[i];

println(res);
}



void Test1()
{
  int d=5;
double [] p=LorentzCone.randomPointLorentzCone(d);
double [] q=LorentzCone.randomPointLorentzCone(d);

PrintPoint(p);
PrintPoint(q);

double BD=LorentzCone.BirkhoffDistance(p,q);

println("Birkhoff distance:"+BD);


double [] pk=LorentzCone.normalizeKleinDisk(p);
double [] qk=LorentzCone.normalizeKleinDisk(q);

PrintPoint(pk);
PrintPoint(qk);

double KD=KleinDisk.KleinDistance(pk,qk);
println("Klein distance:"+KD);
}
