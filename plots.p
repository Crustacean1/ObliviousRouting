set terminal tikz color

set xlabel "Dimensions"
set ylabel "Completion time"

set style line 1 lc rgb '#77F00000' pt 5   # square
set style line 2 lc rgb '#7700F000' pt 7   # circle
set style line 3 lc rgb '#770000F0' pt 9   # triangle

set key right bottom

stats 'Routing/hypercube.random.DOR.txt' using 1:4 nooutput
stats 'Routing/hypercube.random.VALIANT.txt' using 1:4 nooutput
stats 'Routing/hypercube.random.VOCK.txt' using 1:4 nooutput

set output 'random_hypercube_completion.tex'
set title 'Random Permutation in Hypercube [10 trials]'

plot 'Routing/hypercube.random.DOR.txt' using 1:4 title "DOR" w p ls 1 , \
     'Routing/hypercube.random.VALIANT.txt' using 1:4 title "VALIANT" w p ls 2, \
     'Routing/hypercube.random.VOCK.txt' using 1:4 title "VOCK" w p ls 3,

set output 'inverse_hypercube_completion.tex'
set title 'Inverse Permutation in Hypercube [10 trials]'

plot 'Routing/hypercube.inverse.DOR.txt' using 1:4 title "DOR" w p ls 1 , \
     'Routing/hypercube.inverse.VALIANT.txt' using 1:4 title "VALIANT" w p ls 2, \
     'Routing/hypercube.inverse.VOCK.txt' using 1:4 title "VOCK" w p ls 3,


set xlabel "Dimensions"
set ylabel "Dilation"

set output 'inverse_hypercube_dilation.tex'
set title 'Inverse Permutation in Hypercube [10 trials]'

plot 'Routing/hypercube.inverse.DOR.txt' using 1:5 title "DOR" w p ls 1 , \
     'Routing/hypercube.inverse.VALIANT.txt' using 1:5 title "VALIANT" w p ls 2, \
     'Routing/hypercube.inverse.VOCK.txt' using 1:5 title "VOCK" w p ls 3,


set output 'random_hypercube_dilation.tex'
set title 'Random Permutation in Hypercube [10 trials]'

plot 'Routing/hypercube.random.DOR.txt' using 1:5 title "DOR" w p ls 1 , \
     'Routing/hypercube.random.VALIANT.txt' using 1:5 title "VALIANT" w p ls 2, \
     'Routing/hypercube.random.VOCK.txt' using 1:5 title "VOCK" w p ls 3,

