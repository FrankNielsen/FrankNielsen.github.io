// Frank.Nielsen@acm.org  1st July 2024
//
void setup()
{
  System.out.println("Legendre invariance: multivariate case");
  //MVNChernoff.TestChernoffMVN
  TestLegendre();
}

void TestLegendre()
{
 println("Legendre trinoulli");
 
 A=new Matrix(2,2); int i,j;
 for(i=0;i<2;i++) for(j=0;j<2;j++) A.set(i,j,Math.random());
 
 
 Ainv=A.inverse();
 
 b=new Matrix(2,1); for(i=0;i<2;i++) b.set(i,0,Math.random());
 c=new Matrix(2,1); for(i=0;i<2;i++) c.set(i,0,Math.random());
d=Math.random();
lambda=Math.random();

A.print(6,3);
b.print(6,3);
c.print(6,3);
println("lambda="+lambda);

double[] p1, p2;
p1=new double [3]; p2=new double [3];
 for(i=0;i<3;i++) {p1[i]=Math.random();p2[i]=Math.random();}
 
 Matrix t1,t2;
 
 t1=new Matrix(2,1); t1.set(0,0,Math.log(p1[0]/p1[2]));t1.set(1,0,Math.log(p1[1]/p1[2]));
  t2=new Matrix(2,1); t2.set(0,0,Math.log(p2[0]/p2[2]));t2.set(1,0,Math.log(p2[1]/p2[2]));
  
  double bd=BF(t1,t2);
  
  Matrix e1,e2;
  e1=gradF(t1);e2=gradF(t2);
  
  double bg=BG(e2,e1);
 
 println("check Bregman divergences:" + bd+" "+bg);
 
 Matrix bart1,bart2;
 
  bart1=Ainv.times(t1.minus(b)); 
  bart2=Ainv.times(t2.minus(b));
  
 
  
  double res=(1.0/lambda)*barBF(bart1,bart2);
  
  println("check invariance BFbar: "+ res);
  
  
   Matrix bare1,bare2;
   
   bare1=gradFbar(bart1);
    bare2=gradFbar(bart2);
  
    double res2=  (1.0/lambda)*barBG(bare2,bare2);
 println("check invariance BGbar: "+ res);
}


Matrix A,Ainv,b,c;
double lambda,d;

double F(Matrix t){
return Math.log(1+ Math.exp(t.get(0,0)) +Math.exp(t.get(1,0)));
}

Matrix gradF(Matrix t){
Matrix res=new Matrix(2,1);
double den=(1+Math.exp(t.get(0,0))+Math.exp(t.get(1,0)));
  res.set(0,0,Math.exp(t.get(0,0))/den);
  res.set(1,0,Math.exp(t.get(1,0))/den);
  return res;
}

Matrix gradG(Matrix e){
Matrix res=new Matrix(2,1);
double den=1-e.get(0,0)-e.get(1,0);
  res.set(0,0,Math.log(e.get(0,0)/den));
  res.set(1,0,Math.log(e.get(1,0)/den));
  return res;
}


double G(Matrix e){
return Inner(e,gradG(e))-F(gradG(e));
}

double BF(Matrix t1, Matrix t2)
{return F(t1)-F(t2)-Inner(t1.minus(t2),gradF(t2));}

double BG(Matrix e1, Matrix e2)
{return G(e1)-G(e2)-Inner(e1.minus(e2),gradG(e2));
}

double YFG(Matrix t1, Matrix e2)
{return F(t1)+G(e2)-Inner(t1,e2);}

double YGF( Matrix e1, Matrix t2)
{return F(t2)+G(e1)-Inner(t2,e1);}


double Inner(Matrix v1, Matrix v2)
{return ((v1.transpose()).times(v2)).get(0,0);}



double Fbar(Matrix t){return lambda*F(A.times(t).plus(b))+Inner(c,t)+d;}

Matrix gradFbar(Matrix t){return (A.transpose()).times(lambda).times(gradF(A.times(t).plus(b))).plus(c);}


Matrix gradGbar(Matrix e)
{return (Ainv.times(Ainv.transpose().times(1.0/lambda).times(e.minus(c)))).minus(b);}

double Gbar(Matrix e){return Inner(e,gradGbar(e))-Fbar(gradGbar(e));}

double barBF(Matrix t1, Matrix t2)
{return Fbar(t1)-Fbar(t2)-Inner(t1.minus(t2),gradFbar(t2));}


double barBG(Matrix e1, Matrix e2)
{return Gbar(e1)-Gbar(e2)-Inner(e1.minus(e2),gradGbar(e2));}
