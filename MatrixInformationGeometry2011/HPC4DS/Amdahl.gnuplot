set terminal png 
set output 'Amdahl.png'
set encoding iso_8859_1 
set logscale x 2
set xrange [1:65536] 
set autoscale
set xlabel "number of processors (P)"
set ylabel "speed-up"
set key on right bottom
set pointsize 2
Amdahl(p,s) = 1/(s + ( (1-s)/p))
set grid
show grid
plot Amdahl(x,1-0.75) title "0.75"  lt -1 lw 3,\
  Amdahl(x,1-0.90) title "0.9" lt -1 lw 5, \
Amdahl(x,1-0.95)title "0.95" lt -1 lw 7
