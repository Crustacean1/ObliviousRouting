function route_with_intermediary(graph)
	n = size(graph)[1]
	dst, path = floyd_warshall(graph)
	intermediaries = [rand(1:n) for i in 1:n, j in 1:n]
	intermediaries[diag(intermediaries)] = diag(intermediaries)
	return (i,j) -> route_to_flow(path, i, intermediaries[i,j]) .+ route_to_flow(path, intermediaries[i,j], j)
end

