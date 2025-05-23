module Routing

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

routings = [
  ("direct", route_directly),
	("indirect", route_with_intermediary),
	("valiant", valiant_routing),
	("random_tree", route_tree)
]

demand_patterns = [
	#("random", random_demands),
	("permutation", permutation_demands)
  # h-relation 
  # permutation routing
  # random (with threshold)
  # random (no threshold)
  # Antipodal ???
]



topologies = [
	  ("hypergrid-2-4", () -> hypergrid(2,4)),
	  ("hypergrid-2-5", () -> hypergrid(2,5)),
	  ("hypergrid-2-6", () -> hypergrid(2,6)),
	  ("hypergrid-2-7", () -> hypergrid(2,7)),
	  #("gnp 100", () -> gnp(10,0.1))
	]
Random.seed!(2137)

topology_data = []
congestion_data = []
optimal_data = []
routing_data = []
demand_data = []

trials = 5
header = vcat(["Topology", "Demands", "Routing"] , ["Opt. $(i)"  for i in 1:trials], ["Cong. $(i)"  for i in 1:trials])

# topology, routing, demand, 

for (t_name, topology) in topologies
	graph = topology()

	for (demand_name, demand_pattern) in demand_patterns
		demands = [demand_pattern(size(graph)[1]) for i in 1:trials]
		if size(graph)[1] < 20
			optimal_congestion = [mccf(graph,d) for d in demands]
		else
			optimal_congestion = [Inf for d in demands]
		end

		for (r_name, routing) in routings

			push!(congestion_data, [])
			for (i,d) in enumerate(demands)
				r = routing(graph)

				# Route drawing
        		if i == 1
        		  for a in 1:size(graph)[1]
        		    for b in 1:size(graph)[1]
        		      #draw_route(graph,a ,b ,r(a,b), "$(t_name)/$(r_name)/$(a)-$(b)")
        		    end
        		  end
        		end

				assert_routing(graph, r)
				routing_congestion = compute_congestion(graph, r, d)
				push!(congestion_data[end], routing_congestion)
				println(t_name, "\t", r_name, "\t", demand_name, "\t", optimal_congestion[i], "\t", routing_congestion)
			end

			push!(optimal_data, optimal_congestion)
			push!(topology_data, [t_name])
			push!(routing_data, [r_name])
			push!(demand_data, [demand_name])
		end
	end
end

data = hcat(topology_data, demand_data,  routing_data, optimal_data, congestion_data)
data = ([vcat(data[i,:]...) for i in 1:size(data)[1]])
data = [data[i][j] for i in 1:size(data)[1] , j in 1:size(data[1])[1]]

pretty_table( data, header = header)
pretty_table( data, header = header,  backend = Val(:latex))

end # module Routing
