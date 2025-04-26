function cut_cluster(cluster, distances, pi, beta)
  println("Beta: ", beta)
  clustered = [[i for i in cluster if distances[p,i] < beta] for p in pi]
  total = []

  reduced = []
  for c in clustered
    d = [i for i in c if !(i in total)]
    total = vcat(total, d)
    push!(reduced, d)
  end

  return reduced
end

function frt_edge_expectation(graph, weights, distances, beta, perm, edge, level)
	n = size(graph)[1]
	beta_i = beta * (2 ^ level)
	(u,v) = edge
	u_distances = distances[u,:]
	v_distances = distances[v,:]
	#println("Edge function ", edge, " beta: ", beta_i)

	# Find settling centers
	settling = [i for i in 1:n if u_distances[i] < beta_i  || v_distances[i] < beta_i]
	# Find cutting centers
	cutting = [i for i in 1:n if (u_distances[i] < beta_i && v_distances[i] > beta_i) || (u_distances[i] > beta_i && v_distances[i] < beta_i)]

	@assert size(settling)[1] >= size(cutting)[1]

	if (!isempty(intersect(settling, perm)))
		return 0
	else
		# Tree expanded path  times probability of being cut at this level
		return weights[u,v] * (2^(level+2)) * size(cutting)[1]/size(settling)[1]
	end
end

function frt_expectation(graph, weights, distances, beta, perm)
	n = size(graph)[1]
	delta = ceil(log(2,maximum(distances)))
	#println("Delta: ", delta)

	edges = [(i,j) for i in 1:n, j in 1:n if graph[i,j] != 0 && i > j ]
	#display(distances)
	#display(edges)
	result = sum([frt_edge_expectation(graph, weights, distances, beta, perm, edge, level)] for edge in edges, level in 1:delta)
	#println("Expected cost: ", result)
	return result
end

function avg_spanning_tree(graph, weights, distances)
	# Find best beta based on conditional expectations
	betas = [1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9]
	(val,beta) = findmin(map(beta -> frt_expectation(graph, weights, distances, beta, []), betas))
	println("Optimal beta: ", beta, " with value: ", val);
	free = collect(1:n)
	settled = []

	for i in 1:n
		(_,j) = findmax(map(center -> frt_expectation(graph, weights, distances, beta, vcat(settled, center)), free))
		push!(settled,  free[j])
		deleteat!(free, j)
	end

	#println("Spanning tree: ", beta, " ; ", settled," ; ", free)
	return frt_decomposition(graph, distances, beta, settled)
end

function frt_normalization(graph, distances)
  	distinct_distances = [distances[i,j] for i in 1:n, j in 1:n if i != j]
  	e_min = minimum(distinct_distances)
  	e_max = maximum(distinct_distances)
  	Delta = round_to_power(e_max / min(e_min,1.0))
  	scaling = (2 ^ Delta) / e_max

	println("Scaling: ", scaling)
	display(graph)
	graph2 = graph .* scaling
	distances2 = distances .* scaling
	distinct_distances = distinct_distances .* scaling

	println("Normalized graph to: ", minimum(distinct_distances)," --- ", maximum(distinct_distances))
	return (graph2, distances2)
end

function frt_decomposition(graph, distance_matrix, beta, pi)
	n = size(graph)[1]

	Delta = log(2,maximum(distance_matrix))
	println("Delta: ", Delta)
  	D = [[collect(1:n)]]
  	Controls = [[]]

  	#display(D)

  	while any([size(cluster)[1] != 1 for cluster in D[end]])
		  delta = Delta - 1 - size(D)[1]

    	d = vcat([cut_cluster(c, distance_matrix, pi, beta * (2.0 ^ delta)) for c in D[end]]...)
    	centers = vcat([pi for _ in D[end]]...)

    	e = (!isempty).(d)
    	D = vcat(D, [d[e]])
    	Controls = vcat(Controls, [centers[e]])
	end

	return D,Controls
end

function cluster_connection(graph, assigned, unassigned)
  n = size(graph)[1]
  unassigned_nodes = collect(Iterators.flatten(unassigned))
  common = graph[assigned, unassigned_nodes]
  common = [c == 0 ? 9999999 : c for c in common]

  _, minind = findmin(common)

  x = minind[1]
  y = minind[2]

  cind = assigned[x]#findfirst(a -> y in a, unassigned)
  dind = unassigned_nodes[y]#findfirst(a -> x in a, assigned)


  gind = findfirst(a -> dind in a, unassigned)
  assigned = vcat(assigned, unassigned[gind])
  deleteat!(unassigned, gind)

  return (assigned, unassigned, (dind, cind))
end

function cut_tree_to_spanning_tree(graph, layers)
  n = size(graph)[1]

  #println("Layers")
  #display(layers)
  if size(layers)[1] == 0
    return  []
  end
  edges = []

  assigned = layers[1][1]
  unassigned = collect(Iterators.drop(layers[1],1))

  # Connect the clusters via single link
  cluster_size = size(collect(Iterators.flatten(layers[1])))[1]
  while size(assigned)[1] != cluster_size
    assigned, unassigned, edge = cluster_connection(graph, assigned, unassigned)
    println("Found  $(cluster_size) to $(size(assigned)[1]) edge $(size(layers)[1]): ", edge, " " , assigned," ", unassigned)
    edges = vcat(edges, edge)
  end

  # Repeat recursively for subclusters
  for cluster in layers[1]
    sublayers = Iterators.drop(map(layer -> filter(x -> size(intersect(x,cluster))[1] == size(x)[1],layer), layers),1)
    edges = vcat(edges, cut_tree_to_spanning_tree(graph, collect(sublayers)))
  end

  return edges
end

function cost_of_decomposition(graph, weights, decomposition)
end

function mcct(graph)
	# Select beta
	beta = 0
	perm = []
	n = size(graph)[1]

	for i in 1:n
		push!(perm,j)
	end
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

