using Random

include("utils.jl")
include("topologies.jl")
include("obl_racke.jl")
include("visual.jl")

Random.seed!(2138)

function avg_stretch(graph, weight, tree)
    (distances, _) = floyd_warshall(graph)
    (tree_distances, _) = floyd_warshall(tree)
    return sum(tree_distances .* weight) / sum(distances .* weight)
end

function get_clusters(graph)
    n = size(graph, 1)
    clusters = collect(1:n)
    for j in 1:n
        for i in 2:n
            pos = Iterators.peel(Iterators.filter(x -> x[1] != clusters[i] && x[2] != 0, zip(clusters, graph[i, :])))
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

    return graph[clusters.==maxim, clusters.==maxim]
end

function to_decomposition_tree(decomposition)
    new_partition = []
    partitioning = decomposition[1]
    total = 0
    for i in 1:size(decomposition, 1)
        partitioning = zip(partitioning, decomposition[i])
        unique = collect(Set(partitioning))
        #println("Layer $i $unique $partitioning")

        partitioning = map(m -> total + findfirst(==(m), unique), partitioning)
        total = maximum(partitioning)

        push!(new_partition, partitioning)
    end
    routing_matrix = [0 for i in 1:total, j in 1:total]

    for i in 1:size(new_partition, 1)-1
        for j in 1:size(partitioning, 1)
			routing_matrix[new_partition[i][j], new_partition[i+1][j]] = routing_matrix[new_partition[i+1][j], new_partition[i][j] ] = size(new_partition,1) - i
        end
    end
	display(routing_matrix)

    display(new_partition)
	return routing_matrix
end

function get_min_stretch_tree(graph, weight)
    partition = avg_spanning_tree(graph, weight)
    println("Partition")
    display(partition)
    tree = cut_tree_to_spanning_tree(graph, partition)
    return tree
end

n = 50

graph = gnp(n, 1 / n)
graph = get_clusters(graph)

n = size(graph, 1)

distances, _ = floyd_warshall(graph)
println("Diameter: ", maximum(distances))

route = [0 for i in 1:n, j in 1:n]

trees = [uniform_random_tree(graph) for i in 1:20]

weight = [graph[i, j] != 0 ? 1 : 0 for i in 1:n, j in 1:n]
stretch = [avg_stretch(graph, weight, tree) for tree in trees]
println("Treez: ", stretch)


println("Possible distances: ", get_possible_sizes(graph))
println("Exp: ", get_diameter_exp(graph))

println("Average stretch $(sum(stretch)/size(stretch,1)) $(avg_stretch(graph, weight, graph))")

decomposition = avg_spanning_tree(graph, weight)
display(decomposition)
dec_tree = to_decomposition_tree(decomposition)
draw_route(dec_tree, -1, -1, dec_tree, "test")


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
