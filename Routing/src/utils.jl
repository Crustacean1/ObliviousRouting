using LinearAlgebra

function permutation(n)
	return shuffle(1:n)
end

function edges_to_graph(edges, n)
  graph = [0 for i in 1:n, j in 1:n]
  for edge in edges
    graph[edge[1], edge[2]] = 1
    graph[edge[2], edge[1]] = 1
  end
  return graph
end

function round_to_power(n)
	k = 0
	while n > 1.0
		n /= 2.0
		k+=1
	end
	return  k
end

function floyd_warshall(adj)
	n = size(adj)[1]

	dist_matrix = [adj[i,j] != 0.0 ? adj[i,j] : Inf for i in 1:n, j in 1:n]
	dist_matrix[diagind(dist_matrix)] .= 0

	sp_matrix = [dist_matrix[i,j] != Inf ? j : Inf for i in 1:n, j in 1:n]

	for i in 1:n
		for j in 1:n
			for k in 1:n
				if dist_matrix[j,i] + dist_matrix[i,k] < dist_matrix[j,k]
					dist_matrix[j,k] = dist_matrix[j,i] + dist_matrix[i,k]
					sp_matrix[j,k] = sp_matrix[j,i]
					sp_matrix[k,j] = sp_matrix[k,i]
				end
			end
		end
	end

	return (dist_matrix,sp_matrix)
end

function get_path(start, finish, sp_matrix)
	path = [start]
	while path[end] != finish
		push!(path, sp_matrix[path[end],finish])
	end
	return path
end

function path_length(graph, path)
	segments = zip(path, Iterators.drop(path,1))
	return sum([graph[i,j] for (i,j) in segments])
end

function random_demands(n)
	demands = [rand((0,1)) for i in 1:n, j in 1:n] 
	demands[diagind(demands)] .= 0
	return demands
end

function permutation_demands(n)
	perm = permutation(n)
	while has_fixed_point(perm)
		perm = permutation(n)
	end
	demands = [0 for i in 1:n, j in 1:n]
	for (s,t) in zip(perm,collect(1:n))
		demands[s,t] = 1
	end
	return demands

end

function compute_congestion(graph, routing, demand)
	n = size(graph)[1]
	total = [0 for i in 1:n, j in 1:n]
	for i in 1:n
		for j in 1:n
			total  = total .+ (routing(i,j) .* demand[i,j])
		end
	end
  total[diagind(total)] .= 0
	ratio =  total ./ graph
	return maximum([isnan(ratio[i,j]) ? 0 : ratio[i,j] for i in 1:n, j in 1:n])
end

function has_fixed_point(p)
	z = zip(p,1:size(p)[1])
	return any(i -> i[1]==i[2], z)
end

function route_to_flow(path_matrix, src, dst)
	n = size(path_matrix)[1]
	flow = [0 for i in 1:n, j in 1:n]
	i = src
	while i != dst
		flow[i, path_matrix[i,dst]] = 1
		i = path_matrix[i,dst]
	end
	return flow
end

function assert_routing(graph, routing)
	n = size(graph)[1]
	epsilon = 0.0001

	for i in 1:n
		for j in 1:n
			for k in 1:n
				flow = routing(i,j)
				total = sum(flow[k,:]) - sum(flow[:,k])
				if (
					(i == j) || 
					(k == j && abs(total + 1) < epsilon) ||
					(k == i && abs(total - 1) < epsilon) ||
					(abs(total) < epsilon  && k != j && k != i))
				else
					println("Invalid flow for ", k)
					println("Flow ",i ," ", j," ", k," ", total)
					display(flow)
					error("Invalid flow")
				end
			end
		end
	end
end

function assert_tree(graph, tree)
	n = size(graph)[1]
	# No more edges than strictly necessary
  edges = sum(tree.!=0)
  @assert edges == (n -1)*2
	distances, path = floyd_warshall(tree)
	# Any node is reachable from any other node
	@assert !any(x -> isinf(x), distances)
end

function loop_erased_random_walk(graph, source, targets)
	n = size(graph)[1]
	path = [source]
	while !(last(path) in targets)

    paths = filter(x -> x[1] != 0, collect(zip(graph[last(path),:], collect(1:n))))
		next = rand(paths)[2]
		push!(path, next)
	end
	for i in 1:n
		g_start = findfirst(x -> x==i, path)
		g_end = findlast(x -> x==i, path)
    if(g_start != g_end)
      path = vcat(path[begin:g_start+1], path[g_end:end])
    end
	end
  return collect(zip(path[begin:end-1], path[2:end]))
end

function uniform_random_tree(graph)
  n = size(graph)[1]
  tree_nodes = [rand(1:n)]
  outside = filter(x -> !(x in tree_nodes), collect(1:n))
  edges = []
    #println("Outside: ", outside)
  while !isempty(outside) 
    src = rand(outside)
    #println("Connecting: ", src, " to ", tree_nodes)
    path = loop_erased_random_walk(graph, src, tree_nodes)
    edges = vcat(edges, path)
    #println("Edges found: ", edges)
    tree_nodes = vcat(tree_nodes, map(x -> x[1], path))
    outside = filter(x -> !(x in tree_nodes), outside)
    #println("Outside: ", outside)
  end
  return edges_to_graph(edges, n)
end
