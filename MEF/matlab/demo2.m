function demo2
% Put jMEF.jar in a directory with absolute path
close all hidden
% javaclasspath({'D:\Work\jMEF.jar','D:\Work\Tools.jar'});
% Import it
import jMEF.*;
import Tools.*;

n=5;
dim=2;

mm=jMEF.MixtureModel(n);
mm.EF=MultivariateGaussian;

for i=1:n
    mm.weight(i)=1/n;
    mm.param(i) = PVectorMatrix.RandomDistribution(dim); %Random Mean and covariance
    mm.param(i).v.array = mm.param(i).v.array+4*(rand(2,1)-[0.5;0.5]);
    mm.param(i).M.array = mm.param(i).M.array+0.1*eye(2);
end


A=[-5:0.1:5];
figure;
xlim([-5 5]);
ylim([-5 5]);
zlim([0 0.3]);
hold on

plotmmm(mm,A,'blue');
title('original distribution');
camorbit(10,-80);
% legend('original');
hold off;


% Generate 1000 samples
m=1000;
ppoints = mm.drawRandomPoints(m);
% ppoints is a PVector[], Matlabers prefer Matrices
points=PVector.Vector2Matrix(ppoints);

figure;
xlim([-5 5]);
ylim([-5 5]);
plot(points(:,1),points(:,2),'x');
title('1000 samples from distribution');

% Initialize clusters with kMeans
clusters = Tools.KMeans.run(ppoints, 3);
		
% Estimation of the mixture of Gaussians
mm_estimated    = BregmanSoftClustering.initialize(clusters, mm.EF);
mm_estimated    = BregmanSoftClustering.run(ppoints, mm_estimated );

A=[-5:0.1:5];
figure;
xlim([-5 5]);
ylim([-5 5]);
zlim([0 0.3]);
hold on
plotmmm(mm_estimated,A,'red');
title('distribution recovered from samples');
camorbit(10,-80);
% legend('estimated');
hold off;

%Kullback Leibler divergence
fprintf('Kullback Leibler divergence between original and estimated: \n %f \n',mm.KLDMC (mm, mm_estimated, 10000));







