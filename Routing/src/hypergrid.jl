module Hypergrid

using Random
using Base.Iterators
using PrettyTables

include("utils.jl")
include("topologies.jl")
include("optimal.jl")
include("obl_direct.jl")
include("obl_intermediate.jl")
include("obl_racke.jl")
include("obl_tree.jl")
include("visual.jl")

Random.seed!(2137)

routings = [
	("optimal_fraction", (g,d)-> perm_mccf(g,d)),
	("direct", (g,d) -> route_directly(g)),
	("valiant", (g,d) -> valiant_routing(g)),
	("random_tree", (g,d) -> route_tree(g))]

demand_patterns = [("permutation", permutation_demands)]

topologies = collect(Iterators.flatten([[(j, i, permutation_demands(2^i), hypergrid(2,i)) for j in 1:10] for i in 2:10]))

experiments = collect(Iterators.product(topologies, routings))

println("Experiment shape $(size(experiments))")
println("Topology shape $(size(topologies))")
println("Executing on $(Threads.nthreads()) threads")

Threads.@threads for (sample, routing ) = experiments
	(trial, dimension, demand, topology) = sample
	(name, rout) = routing
	instance = rout(topology, demand)
	assert_routing(topology, instance)
	congestion = compute_congestion(topology, instance, demand)
	println(join(string.([name,trial,dimension, congestion]), ", "))
end

#for (t_name, topology) in topologies
#	graph = topology()
#
#	for (demand_name, demand_pattern) in demand_patterns
#		demands = [demand_pattern(size(graph)[1]) for i in 1:trials]
#		if size(graph)[1] < 20
#			optimal_congestion = [mccf(graph,d) for d in demands]
#		else
#			optimal_congestion = [Inf for d in demands]
#		end
#
#		for (r_name, routing) in routings
#
#			push!(congestion_data, [])
#			for (i,d) in enumerate(demands)
#				r = routing(graph)
#
#				# Route drawing
#        		if i == 1
#        		  for a in 1:size(graph)[1]
#        		    for b in 1:size(graph)[1]
#        		      #draw_route(graph,a ,b ,r(a,b), "$(t_name)/$(r_name)/$(a)-$(b)")
#        		    end
#        		  end
#        		end
#
#				assert_routing(graph, r)
#				routing_congestion = compute_congestion(graph, r, d)
#				push!(congestion_data[end], routing_congestion)
#				println(t_name, "\t", r_name, "\t", demand_name, "\t", optimal_congestion[i], "\t", routing_congestion)
#			end
#
#			push!(optimal_data, optimal_congestion)
#			push!(topology_data, [t_name])
#			push!(routing_data, [r_name])
#			push!(demand_data, [demand_name])
#		end
#	end
#end
#
#data = hcat(topology_data, demand_data,  routing_data, optimal_data, congestion_data)
#data = ([vcat(data[i,:]...) for i in 1:size(data)[1]])
#data = [data[i][j] for i in 1:size(data)[1] , j in 1:size(data[1])[1]]
#
#pretty_table( data, header = header)
#pretty_table( data, header = header,  backend = Val(:latex))
#
#end # module Routing
#
end # module 
