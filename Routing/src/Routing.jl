module Routing

using JuMP,GLPK
using Graphs
using Karnak
using Colors
using NetworkLayout
using Distributions
using Random
using LinearAlgebra

m = [5.0  10.0;
	10.0 2.0]

n = 10

function lmax(graph)
  return sum(exp.(graph)) / 2
end

function rload(graph, tree, edge)
	adj = graph.!=0
	(a,b) = edge
	left = [a]
	right = [b]

	while true
		ln = [i for (i,j) in tree if j in left && !(i in left) && (i,j) != edge && (j,i) != edge]
		rn = [i for (j,i) in tree if j in left && !(i in left) && (i,j) != edge && (j,i) != edge]

		if size(ln)[1] == 0&& size(rn)[1] == 0
			break
		else
			for e in ln
				push!(left, e)
			end
			for e in rn
				push!(left, e)
			end
		end
	end

	while true
		ln = [i for (i,j) in tree if j in right && !(i in right) && (i,j) != edge && (j,i) != edge]
		rn = [i for (j,i) in tree if j in right && !(i in right) && (i,j) != edge && (j,i) != edge]
		if size(ln)[1] == 0 && size(rn)[1] == 0
			break
		else
			for e in ln
				push!(right, e)
			end
			for e in rn
				push!(right, e)
			end
		end
	end

	return sum(graph[left,right]) / graph[a,b]
end

function mcct(graph, reqs)
  n = size(graph)[1]
  model = Model(GLPK.Optimizer)

	adj = graph.!=0
  println("Adj matrix for MCCT:")
  display(adj)
  println("Requirements")
  display(reqs)

  @variable(model, tree[1:n,1:n], Bin)

  @variable(model, path[1:n, 1:n, 1:n, 1:n],Bin)
  @variable(model, connectivity[1:n, 1:n, 1:n, 1:n],Bin)

  # symmetry
  @constraint(model, [a=1:n,b=1:n], tree[a,b] == tree[b,a])
  @constraint(model, [a=1:n,b=1:n,i=1:n], sum(tree[i,j] for j in 1:n) >=1)
  @constraint(model, [a=1:n,b=1:n,i=1:n,j=1:n], path[a,b,i,j] == path[a,b,i,j])

  # use only graph edges
  @constraint(model, [i=1:n,j=1:n], tree[i,j] <= adj[i,j])
  # use path within tree
  @constraint(model, [a=1:n,b=1:n,i=1:n,j=1:n], path[a,b,i,j] <= tree[i,j])


  # if connvectivity an dpath exists, then subtraction of those also exist
  @constraint(model, [a=1:n,b=1:n,i=1:n,j=1:n,k=1:n], connectivity[a,b,i,j] >= (1-((1 - connectivity[a,b,i,k]) + (1 - path[a,b,j,k]))))
  @constraint(model, [a=1:n,b=1:n,i=1:n], connectivity[a,b,i,i] == true)
  @constraint(model, [a=1:n,b=1:n], connectivity[a,b,a,b] == true)
  @constraint(model, [a=1:n,b=1:n], connectivity[a,b,b,a] == true)
  @constraint(model, sum(tree) == 2*(n-1))

  @objective(model, Min, sum(path[a,b,i,j] * graph[i,j] * reqs[a,b] for a in 1:n, b in 1:n, i in 1:n, j in 1:n))

  optimize!(model)
  assert_is_solved_and_feasible(model)
  display(solution_summary(model))
  println("MCCT Objective value: ---> ", objective_value(model))
  display(Matrix(value.(tree)))

  return [(i,j) for i in 1:n, j in 1:n if value.(tree)[i,j] == 1] 
end

function convex_combination(graph)
	trees = []
	while sum([lamba for (lambda, tree) in trees]) < 1.0
		tree = mcct(graph, trees)
		lambda = sum([lamba for (lambda, tree) in trees])
		el = max(rload.(graph,tree), )
		delta = 0
		push!(trees, (delta,tree))
	end
	return trees
end


requirements =  rand(Uniform(0.1,1),n,n);
requirements[diagind(requirements)] .= 0.0

bandwidth =  Symmetric(max.(rand(Uniform(-1,1),n,n),fill(0.0,n,n)));
bandwidth[diagind(bandwidth)] .= 0.0

println("Bandwidth")
display(bandwidth)

println("Requirements")
display(requirements)

model = Model(GLPK.Optimizer)


@variable(model, flow[1:n,1:n,1:n,1:n] >=0)
@variable(model, beta >=0)


#Bandwidth constraint
@constraint(model, [k=1:n, h=1:n], sum(flow[i,j,k,h] for i in 1:n, j in 1:n) <= bandwidth[k,h])

# Flow constraint
@constraint(model, [k=1:n,h=1:n,g=1:n; g!=k && g!=h], sum(flow[k,h,i,g] for i in 1:n) == sum(flow[k,h,g,j] for j in 1:n))
@constraint(model, [k=1:n,h=1:n,g=1:n; g==k && g!=h], sum(flow[k,h,i,g] for i in 1:n) + requirements[k,h] * beta == sum(flow[k,h,g,j] for j in 1:n))
@constraint(model, [k=1:n,h=1:n,g=1:n; g!=k && g==h], sum(flow[k,h,i,g] for i in 1:n) == sum(flow[k,h,g,j] for j in 1:n) + requirements[k,h] * beta)

@objective(model, Max, beta)

print(model)
optimize!(model)
assert_is_solved_and_feasible(model)
display(solution_summary(model))
println("Objective value: ---> ", objective_value(model))


rload(bandwidth, [(1,2),(4,2),(4,3)], (4,2))

for i  = 1:n
	for j = 1:n
		if i == j 
			continue
		end
		println("For multicommodity from $i to $j requirement: $(requirements[i,j]) minimum : $(requirements[i,j] * value(beta))  $(value(beta))")
		display(value.(flow)[i,j,:,:])
	end
end

display(bandwidth)
println("Max: ", lmax(bandwidth))

tree = mcct(bandwidth, requirements)

g = Graphs.SimpleGraphs.SimpleGraph(n)

for (i,j) in tree
		add_edge!(g,i,j)
end

#band = [i.from for i in edges(g)]
#print(band)

@svg begin
	background("black")
	sethue("grey40")
	fontsize(50)

	drawgraph(g,layout=stress,vertexlabels=1:nv(g),
		   vertexfillcolors=[RGB(rand(3)/2...)
		   for i in 1:nv(g)],
		   edgestrokeweights=20
		   )
end 1000 1000 "tree.svg"
println("Done")

end # module Routing
