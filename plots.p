#set terminal tikz color
set terminal png size 800,1200

set xlabel "Dimensions"
set ylabel "Completion time"

set style line 1 lc rgb '#77F00000' pt 5   # square
set style line 2 lc rgb '#7700F000' pt 7   # circle
set style line 3 lc rgb '#770000F0' pt 9   # triangle

set key right bottom

set output 'hypercube_total.png'
set multiplot layout 3,2

set title 'Random'
unset key

f(x) = a*x + b
fit f(x) 'Routing/hypercube.random.DOR.txt' using 1:4 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.random.VALIANT.txt' using 1:4 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.random.VOCK.txt' using 1:4 via a2,b2

plot 'Routing/hypercube.random.DOR.txt' using 1:4 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.random.VALIANT.txt' using 1:4 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.random.VOCK.txt' using 1:4 title "VOCK" w p ls 3, \
      h(x) with lines ls 3 

set title 'Inverse'

f(x) = a*x + b
fit f(x) 'Routing/hypercube.inverse.DOR.txt' using 1:4 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.inverse.VALIANT.txt' using 1:4 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.inverse.VOCK.txt' using 1:4 via a2,b2

plot 'Routing/hypercube.inverse.DOR.txt' using 1:4 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.inverse.VALIANT.txt' using 1:4 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.inverse.VOCK.txt' using 1:4 title "VOCK" w p ls 3, \
      h(x) with lines ls 3 


set xlabel "Dimensions"
set ylabel "Dilation"

set title 'Random'

f(x) = a*x + b
fit f(x) 'Routing/hypercube.random.DOR.txt' using 1:5 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.random.VALIANT.txt' using 1:5 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.random.VOCK.txt' using 1:5 via a2,b2

plot 'Routing/hypercube.random.DOR.txt' using 1:5 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.random.VALIANT.txt' using 1:5 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.random.VOCK.txt' using 1:5 title "VOCK" w p ls 3, \
      h(x) with lines ls 3

set title 'Random'

f(x) = a*x + b
fit f(x) 'Routing/hypercube.inverse.DOR.txt' using 1:5 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.inverse.VALIANT.txt' using 1:5 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.inverse.VOCK.txt' using 1:5 via a2,b2

plot 'Routing/hypercube.inverse.DOR.txt' using 1:5 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.inverse.VALIANT.txt' using 1:5 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.inverse.VOCK.txt' using 1:5 title "VOCK" w p ls 3, \
      h(x) with lines ls 3


set xlabel "Dimensions"
set ylabel "Avg. Congestion"

f(x) = a*x + b
fit f(x) 'Routing/hypercube.random.DOR.txt' using 1:6 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.random.VALIANT.txt' using 1:6 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.random.VOCK.txt' using 1:6 via a2,b2

plot 'Routing/hypercube.random.DOR.txt' using 1:6 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.random.VALIANT.txt' using 1:6 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.random.VOCK.txt' using 1:6 title "VOCK" w p ls 3, \
      h(x) with lines ls 3

set title 'Inverse'

f(x) = a*x + b
fit f(x) 'Routing/hypercube.inverse.DOR.txt' using 1:6 via a,b

g(x) = a1*x + b1
fit g(x) 'Routing/hypercube.inverse.VALIANT.txt' using 1:6 via a1,b1

h(x) = a2*x + b2
fit h(x) 'Routing/hypercube.inverse.VOCK.txt' using 1:6 via a2,b2

plot 'Routing/hypercube.inverse.DOR.txt' using 1:6 title "DOR" w p ls 1 , \
      f(x) with lines ls 1, \
     'Routing/hypercube.inverse.VALIANT.txt' using 1:6 title "VALIANT" w p ls 2, \
      g(x) with lines ls 2, \
     'Routing/hypercube.inverse.VOCK.txt' using 1:6 title "VOCK" w p ls 3, \
      h(x) with lines ls 3

