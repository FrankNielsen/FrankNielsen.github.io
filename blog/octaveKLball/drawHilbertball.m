# Frank.Nielsen@acm.org
# Draw using an implicit function a Hilbert ball in the data space

function result = distance2(p,q)
result= dot(p,p)+dot(q,q)-2*dot(p,q);
return;
endfunction

function res = kernel(p,q)
alpha=5;
res=exp(-alpha*distance2(p,q));
return;
endfunction

printf("Wait while drawing the eKL ball...")
clear, clf, cla
figure('Position',[0,0,512,512]);
xm = -3:0.01:3;  
ym = -3:0.01:3;
[x, y] = meshgrid(xm, ym);
xc = 0.5; 
yc = 0.5;
c=[xc,yc];
r2 = 1;
r2=r2*r2;
p=[x,y];
f= kernel(c,c).+kernel(p,p) -2.*kernel(p,c).-r2;
contour(x,y,f,[0,0],'linewidth',2)
grid on
xlabel('x', 'fontsize',16);
ylabel('y', 'fontsize',16)
hold on
plot(xc,yc,'+1','linewidth',5);
print('HilbertBall.png','-dpng','-r300');
hold off

printf("done!");