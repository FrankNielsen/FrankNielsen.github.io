#(C) Frank Nielsen, November 2013  (5793b870, Frank.Nielsen@acm.org)
# Licensed under GPL v3.0 for academic non-commercial research purpose only. No warranties or whatsoever.
# http://www.gnu.org/copyleft/gpl.html


# This package implements the symmetric Kullback-Leibler centroid, also called symmetrical Kullback-Leibler centroid
# or symmetrized Kullback-Leibler centroid, or Jeffreys centroid, etc.
#
# Jeffreys centroids: A closed-form expression for positive histograms and a guaranteed tight approximation for frequency histograms
# IEEE Signal Process. Lett. 20(7): 657-660 (2013)
# http://arxiv.org/pdf/1303.7286v2.pdf
#  
# By interpreting the multinomials as exponential families, the symmetric Kullback-Leibler centroid amounts
# to compute an equivalent symmetric/symmetrical/symmetrized Bregman centroid. 
# See:
# Sided and symmetrized Bregman centroids 
# IEEE Transactions on Information Theory 55(6): 2882-2904 (2009)
# http://arxiv.org/pdf/0711.3242v1.pdf
#
# Another popular symmetrization of the Kullback-Leibler divergence is the Jensen-Shannon divergence.
# See: 
# The Burbea-Rao and Bhattacharyya Centroids. 
# IEEE Transactions on Information Theory 57(8): 5455-5466 (2011)
# http://arxiv.org/abs/1004.5049

options(digits=22)
PRECISION=.Machine$double.xmin

LambertW0<-function(z)
	{
		S = 0.0
		for (n in 1:100)
		{
			 Se = S * exp(S)
			 S1e = Se + exp(S)  
			if (PRECISION > abs((z-Se)/S1e)) { 
			break}
			S = S -	(Se-z) / (S1e - (S+2) * (Se-z) / (2*S+2))
		}
		S
	}
	
	#
# Symmetrized Kullback-Leibler divergence (same expression for positive arrays or unit arrays since the +q -p terms cancel)
# SKL divergence, symmetric Kullback-Leibler divergence, symmetrical Kullback-Leibler divergence, symmetrized KL, etc.
#
JeffreysDivergence<-function(p,q)
{
d=length(p)
res=0
for(i in 1:d)
{res=res+(p[i]-q[i])*log(p[i]/q[i])}
res
}

normalizeHistogram<-function(h)
{
d=length(h)
result=rep(0,d)
wnorm=cumsum(h)[d]
for(i in 1:d)
{result[i]=h[i]/wnorm; }
result
}

#
# Weighted arithmetic center 
#
ArithmeticCenter<-function(set,weight)
{
dd=dim(set)
n=dd[1]
d=dd[2]
result=rep(0,d)
for(j in 1:d)
{
for(i in 1:n)
{result[j]=result[j]+weight[i]*set[i,j]}
}
result
}

#
# Weighted geometric center
#
GeometricCenter<-function(set,weight)
{
dd=dim(set)
n=dd[1]
d=dd[2]
result=rep(1,d)
for(j in 1:d)
{
for(i in 1:n)
{result[j]=result[j]*(set[i,j]^(weight[i]))}
}
result
}

cumulativeSum<-function(h)
{
d=length(h)
cumsum(h)[d]
}

#
# Optimal Jeffreys (positive array) centroid expressed using Lambert W0 function 
#
JeffreysPositiveCentroid<-function(set,weight) 
{
dd=dim(set)
d=dd[2]
result=rep(0,d)
a=ArithmeticCenter(set,weight)
g=GeometricCenter(set,weight)
for(i in 1:d)
	{result[i]=a[i]/LambertW0(exp(1)*a[i]/g[i])}
result
}

#
# A 1/w approximation to the optimal Jeffreys frequency centroid (the 1/w is a very loose upper bound)
#
JeffreysFrequencyCentroidApproximation<-function(set,weight) 
{
result=JeffreysPositiveCentroid(set,weight) 
w=cumulativeSum(result)
result=result/w
result
}

#
# By introducing the Lagrangian function enforcing the frequency histogram constraint
#
cumulativeCenterSum<-function(na,ng,lambda)
{
d=length(na)
cumul=0
for(i in 1:d)
{cumul=cumul+(na[i]/LambertW0(exp(lambda+1)*na[i]/ng[i]))}
cumul
}

#
# Once lambda is known, we get the Jeffreys frequency cetroid
#
JeffreysFrequencyCenter<-function(na,ng,lambda)
{
d=length(na)
result=rep(0,d)
for(i in 1:d)
{result[i]=na[i]/LambertW0(exp(lambda+1)*na[i]/ng[i])}
result
}

#
# Approximating lambda up to some numerical precision for computing the Jeffreys frequency centroid 
#
JeffreysFrequencyCentroid<-function(set,weight) 
{
na=normalizeHistogram(ArithmeticCenter(set,weight))
ng=normalizeHistogram(GeometricCenter(set,weight))
d=length(na)
bound=rep(0,d)
for(i in 1:d) {bound[i]=na[i]+log(ng[i])}
lmin=max(bound)-1 
lmax=0
while(lmax-lmin>1.0e-10)
{
lambda=(lmax+lmin)/2
cs=cumulativeCenterSum(na,ng,lambda);
if (cs>1)
{lmin=lambda} else {lmax=lambda}
}

JeffreysFrequencyCenter(na,ng,lambda)
}


