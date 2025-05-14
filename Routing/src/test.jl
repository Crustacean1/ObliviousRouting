using Random

include("utils.jl")
include("topologies.jl")
include("obl_racke.jl")
include("visual.jl")

Random.seed!(2138)

function get_stretch(graph, weight, tree)
	(distances,_) = floyd_warshall(tree)
	sum()
end

function get_clusters(graph)
	n = size(graph,1)
	clusters = collect(1:n)
	for j in 1:n
		for i in 2:n
			pos = Iterators.peel(Iterators.filter(x -> x[1] != clusters[i] && x[2] !=0, zip(clusters,graph[i,:])))
			if pos != nothing
				if clusters[i] > pos[1][1]
					clusters[i] = pos[1][1]
				end
			end
		end
	end

	maxval = [0 for i in 1:n]
	for i in 1:n
		maxval[clusters[i]] += 1
	end

	maxim = argmax(maxval)

	return graph[clusters.==maxim,clusters.==maxim]
end

n = 1000

graph = gnp(n, 2/n)
graph = get_clusters(graph)

n = size(graph,1)

distances, _ = floyd_warshall(graph)

route = [0 for i in 1:n, j in 1:n]

for i in 1:1
	global route += uniform_random_tree(graph)
end

draw_route(graph, -1, -1, route, "test")

#graph_size = size(graph)[1]
#
#weights = [1 for i in 1:n, j in 1:n]
#edge_count = floor(Int, count(any.(x -> x != 0, graph)) / 2 )
#
##println("Generated hypergrid with ", graph_size, " nodes and ", edge_count, " edges")
#
#spanning_tree = uniform_random_tree(graph)
#avg_cut,_ = avg_spanning_tree(graph, weights, distances)
#println("Avg cut")
#display(avg_cut)
#avg_tree = edges_to_graph(cut_tree_to_spanning_tree(graph, avg_cut), n)
#
#println("Spanning tree")
#display(spanning_tree)
#
#println("Generating spanning tree")
#display(avg_tree)
#
#draw_route(graph, 1,2, spanning_tree, "tree1")
#draw_route(graph, 1,2,avg_tree, "tree2")
#assert_tree(graph, spanning_tree)
#
#
