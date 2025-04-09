function route_directly(graph)
	n = size(graph)[1]
	dst, path = floyd_warshall(graph)
	return (i,j) -> route_to_flow(path, i,j)
end
