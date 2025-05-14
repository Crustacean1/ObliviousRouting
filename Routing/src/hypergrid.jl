module Hypergrid
using Random
using Base.Iterators

include("utils.jl")
include("topologies.jl")
include("optimal.jl")
include("obl_direct.jl")
include("obl_intermediate.jl")
include("obl_racke.jl")
include("obl_tree.jl")

Random.seed!(2138)

routings = [
	("optimal_fraction", (g,d)-> perm_mccf(g,d)),
	("optimal", (g,d)-> perm_mccf_int(g,d)),
	("direct", (g,d) -> route_directly(g)),
	("valiant", (g,d) -> valiant_routing(g)),
	("random_tree", (g,d) -> route_tree(g))]

demand_patterns = [("permutation", permutation_demands)]

topologies = collect(Iterators.flatten([[(j, i, permutation_demands(2^i), hypergrid(2,i)) for j in 1:20] for i in 2:8]))

experiments = collect(Iterators.product(topologies, routings))

println("Experiment shape $(size(experiments))")
println("Topology shape $(size(topologies))")
println("Executing on $(Threads.nthreads()) threads")


Threads.@threads for (sample, routing ) = experiments
	(trial, dimension, demand, topology) = sample
	(name, rout) = routing
	instance = rout(topology, demand)
	assert_routing(topology, demand, instance)
	congestion = compute_congestion(topology, instance, demand)
	open("results.txt", "a") do io
		write(io, join(string.([name,trial,dimension, congestion]), ", "))
		write(io, "\n")
		flush(io)
	end

end

end # module 
