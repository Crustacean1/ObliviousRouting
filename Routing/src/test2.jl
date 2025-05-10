using Random

include("utils.jl")
include("topologies.jl")
include("obl_racke.jl")
include("visual.jl")
include("optimal.jl")

Random.seed!(2137)

k = 6
graph = hypergrid(2,k)
demand_permutation = permutation(2^k)
#demand_permutation = [2,4,1,3]

solution = perm_mccf(graph, demand_permutation)

display(size(graph))
display(demand_permutation)
println("Solution: ", solution)
