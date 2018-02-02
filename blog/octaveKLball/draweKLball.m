# Frank.Nielsen@acm.org
# Draw using an implicit function an extended Kullback-Leibler ball in Octave

printf("Drawing the eKL ball...")
clear, clf, cla
figure('Position',[0,0,512,512]);
xm = 0:0.01:3;  
ym = 0:0.01:3;
[x, y] = meshgrid(xm, ym);
xc = 0.5; 
yc = 0.5;
r = 0.3;
f= (x.*log(x./xc).+xc.-x).+(y.*log(y./yc).+yc.-y)-r;
contour(x,y,f,[0,0],'linewidth',2)
grid on
xlabel('x', 'fontsize',16);
ylabel('y', 'fontsize',16)
hold on
plot(xc,yc,'+1','linewidth',5);
 

print ("C:/travail/eKL-ball.pdf", "-dpdf");
print('eKL-ball.png','-dpng','-r300');
hold off
# That's all folks!

#clear, clf, cla
#figure('Position',[0,0,512,512]);
#contour(x,y,f,'showtext','on');
#print('eKL-level-ball.png','-dpng','-r300');
printf("done!");
