function route_tree_path(src,dst, paths, weights)
	k = size(paths)[1]
	n = size(paths[1])[1]

	sources = [src for i in 1:k]
	routing = [0.0 for i in 1:n, j in 1:n]
	for i in 1:k
		while sources[i] != dst
			next_vertex = paths[i][sources[i], dst]
			routing[sources[i],next_vertex] += weights[i] 
			sources[i] = next_vertex
		end
	end
	return routing
end

function route_tree(graph)
	n = size(graph)[1]
	tree_count = ceil(Int,log(2,n))
	trees = [uniform_random_tree(graph) for i in 1:tree_count]
	tree_distances = [floyd_warshall(tree)[2] for tree in trees]
	return (i, j) -> route_tree_path(i,j, tree_distances, [1/tree_count for i in 1:n])
end
