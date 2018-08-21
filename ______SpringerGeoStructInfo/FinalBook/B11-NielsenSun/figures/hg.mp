verbatimtex
%&latex
\documentclass{article}
\usepackage{amsmath,amssymb,bm}
\begin{document}
etex

u:=3cm;
def drawwhitearrow expr p = _apth:=p; _finwhitearr enddef;
def _finwhitearr text t =
    draw _apth t;
    fill arrowhead _apth  t withcolor white;
    draw arrowhead _apth  t
enddef;

beginfig(1);
path box;
box:=(-u,0)--(u,0)--(0,1.73u)--cycle;
draw box;

path l,r,e;
l:=(-u,0)--(0,1.73u);
r:=(u,0)--(0,1.73u);
e:=(point .4 of l)--(point .15 of r);
draw e;

fill fullcircle scaled 4bp shifted point 0 of e;
fill fullcircle scaled 4bp shifted point .3 of e;
fill fullcircle scaled 4bp shifted point .7 of e;
fill fullcircle scaled 4bp shifted point 1 of e;

label.top( btex $t_0$ etex, point 0 of e );
label.bot( btex $A$ etex, point 0 of e );
label.top( btex $0$ etex, point .3 of e );
label.bot( btex $M (p)$ etex,  point .3 of e );
label.top( btex $1$ etex, point .7 of e );
label.bot( btex $M' (q)$ etex, point .7 of e );
label.top( btex $t_1$ etex, point 1 of e );
label.bot( btex $A'$ etex, point 1 of e );
label.top( btex $p(t)=(1-t)p+tq$ etex rotated -16, point .5 of e shifted (0,.02u) );

endfig;

verbatimtex
\end{document}
etex

end
