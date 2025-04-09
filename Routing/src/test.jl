include("utils.jl")
include("topologies.jl")
include("visual.jl")

graph = hypergrid(2,6)
#graph = gnp(200,0.0018)

graph_size = size(graph)[1]
edge_count = floor(Int, count(any.(x -> x != 0, graph)) / 2 )

println("Generated hypergrid with ", graph_size, " nodes and ", edge_count, " edges")

spanning_tree = uniform_random_tree(graph)
println("Spanning tree")
display(spanning_tree)

save_graph_to_file(graph, spanning_tree, "cube")
assert_tree(graph, spanning_tree)


