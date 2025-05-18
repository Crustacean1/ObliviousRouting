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

function frt_edge_expectation(graph, weights, distances, beta, edge, level)
	n = size(graph,1)
	beta_i = beta * (2 ^ level)
	(u,v) = edge
	u_distances = distances[u,:]
	v_distances = distances[v,:]

	# Find settling centers
	settling = [i for i in 1:n if u_distances[i] < beta_i  || v_distances[i] < beta_i]
	# Find cutting centers
	cutting = [i for i in 1:n if (u_distances[i] < beta_i && v_distances[i] > beta_i) || (u_distances[i] > beta_i && v_distances[i] < beta_i)]

	#@assert size(settling)[1] >= size(cutting)[1]

	return weights[u,v] * (2^(level+2)) * size(cutting)[1]/size(settling)[1]
end

function frt_expectation(graph, weights, distances, beta, perm)
	n = size(graph)[1]
	delta = ceil(log(2,maximum(distances)))

	edges = [(i,j) for i in 1:n, j in 1:n if graph[i,j] != 0 && i > j ]

	settles_u = (e, p, l) -> (distances[p,e[1]] < beta * 2 ^ l)
	settles_v = (e, p, l) -> (distances[p,e[2]] < beta * 2 ^ l)

	settled = [(l,e) for l in 1:delta, e in edges if any(p -> (settles_u(e,p,l) || settles_v(e,p,l)),perm)]
	cut 	= [(l,e) for l in 1:delta, p in perm, e in edges if	any(p -> xor(settles_u(e,p,l), settles_v(e,p,l)), perm)]
	unknown = [(l,e) for l in 1:delta, e in edges if !any(p -> (settles_u(e,p,l) || settles_v(e,p,l)), perm)]

	known_cost = sum([weights[e[1],e[2]] * 2 ^ (l+2) for (l,e) in cut])
	expected_cost = sum(frt_edge_expectation(graph, weights, distances, beta, edge, level) for (level, edge) in unknown; init = 0)
	total = known_cost + expected_cost
	return total
end

function get_diameter_exp(graph)
	(distances, _) = floyd_warshall(graph)
	return 2^ceil(Integer, log(2,maximum(distances)))
end

function get_possible_sizes(graph)
	(distances, _) = floyd_warshall(graph)
	distances = reshape(distances,:)
	return sort(collect(Set([(i + j) / 2  for (i,j) in zip(distances, distances[2:end])])))
end

function avg_spanning_tree(graph, weights)
	(distances,_) = floyd_warshall(graph)
	# Find best beta based on conditional expectations
	diameter = get_diameter_exp(graph)
	betas = get_possible_sizes(graph)  ./ diameter
	println("Betas: ", betas)
	test = findmin(map(beta -> frt_expectation(graph, weights, distances, beta, []), betas))
	println("Optimal beta: ", test, " with value: ", betas);
	free = collect(1:n)
	settled = []
	beta = 1

	for i in 1:n
		(maxval,j) = findmax(map(center -> frt_expectation(graph, weights, distances, beta, vcat(settled, center)), free))
		push!(settled,  free[j])
		deleteat!(free, j)
	end

	println("Spanning tree: ", beta, " ; ", settled," ; ", free)
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
  	D = [[collect(1:n)]]
	Controls = [[pi[1]]]

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

  println("Layers")
  display(layers)
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

