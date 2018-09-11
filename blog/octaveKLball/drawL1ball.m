# Frank.Nielsen@acm.org
# Draw using an implicit function an extended Kullback-Leibler ball in Octave

printf("Drawing the L1 ball in the standard simplex...")
clear, clf, cla
figure('Position',[0,0,128,128]);
xm = 0:0.01:3;  
ym = 0:0.01:3;
[x, y] = meshgrid(xm, ym);
xc = 0.25; 
yc = 0.25;
r = 0.3;
f= abs(x.-xc)+abs(y.-yc);
#f= (x.*log(x./xc).+xc.-x).+(y.*log(y./yc).+yc.-y)-r;
contour(x,y,f,[0,0],'linewidth',2)
grid on
xlabel('x', 'fontsize',16);
ylabel('y', 'fontsize',16)
hold on
plot(xc,yc,'+1','linewidth',5);
 

print ("C:/travail/L1simplex.pdf", "-dpdf");
print('L1simplex.png','-dpng','-r300');
hold off
# That's all folks!

#clear, clf, cla
#figure('Position',[0,0,512,512]);
#contour(x,y,f,'showtext','on');
#print('eKL-level-ball.png','-dpng','-r300');
printf("done!");
