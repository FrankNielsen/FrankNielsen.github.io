function demo1
% Put jMEF.jar in a directory with absolute path
close all hidden
javaclasspath('D:\Work\jMEF.jar');

% Import it
import jMEF.*;


% Ok, let us create a Gaussian Mixture Model (GMM) of 5 gaussians in
% dimension 2
n=5;
dim=2;

mm=MixtureModel(n);
mm.EF=MultivariateGaussian;

for i=1:n
    mm.weight(i)=1/n;
    mm.param(i) = PVectorMatrix.RandomDistribution(dim); %Random Mean and covariance
    % /!\ These are the SOURCE parameters of the exponential family, if you
    % want to work with (MU,SIGMA) = (mean,covariance matrix), you need to
    % convert the parameters
    
    % Let us regularize a little bit 
    mm.param(i).v.array = mm.param(i).v.array+3*(rand(2,1)-[0.5;0.5]);
    mm.param(i).M.array = mm.param(i).M.array+0.1*eye(2);
    % Let us convert them back to NATURAL parameters in order to use the
    % centroid function
    mm.param(i)=mm.EF.Lambda2Theta(mm.param(i));
end


% Java Enum type has a bug in Matlab 2009b, here is a hack to fix it
p=Clustering();
classname=p.getClass.getClasses;
MessageTypes = classname(1).getEnumConstants;

% What is the symmetrized centroid of this GMM using Kullback-Leibler
% divergence ?
% MessageType(1) is left
% MessageType(2) is right
% MessageType(3) is symmetric


symmetric_centroid=jMEF.Clustering.getCentroid(mm,MessageTypes(3));
% Now I want to see (MU,SIGMA)
% symmetric_centroid.type
mm.EF.Theta2Lambda(symmetric_centroid);

mm_centroid=MixtureModel(1);
mm_centroid.EF=MultivariateGaussian;
mm_centroid.weight(1)=1;
mm_centroid.param(1)=symmetric_centroid;


%Ok let's plot it now
A=[-5:0.1:5];
figure;
xlim([-5 5]);
ylim([-5 5]);
zlim([0 0.5]);
hold on
plotmmm(mm,A,'blue');
plotmmm(mm_centroid,A,'red');
camorbit(10,-70);
legend('GMM','Centroid');
hold off;










