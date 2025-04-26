using Random

include("utils.jl")
include("topologies.jl")
include("obl_racke.jl")
include("visual.jl")

Random.seed!(2137)

n = 20
graph = gnp(n,0.01)
distances, _ = floyd_warshall(graph)

graph_size = size(graph)[1]

weights = [1 for i in 1:n, j in 1:n]
edge_count = floor(Int, count(any.(x -> x != 0, graph)) / 2 )

#println("Generated hypergrid with ", graph_size, " nodes and ", edge_count, " edges")

spanning_tree = uniform_random_tree(graph)
avg_cut,_ = avg_spanning_tree(graph, weights, distances)
println("Avg cut")
display(avg_cut)
avg_tree = edges_to_graph(cut_tree_to_spanning_tree(graph, avg_cut), n)

println("Spanning tree")
display(spanning_tree)

println("Generating spanning tree")
display(avg_tree)

draw_route(graph, 1,2, spanning_tree, "tree1")
draw_route(graph, 1,2,avg_tree, "tree2")
assert_tree(graph, spanning_tree)


