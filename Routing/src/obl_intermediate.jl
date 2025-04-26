function route_with_intermediary(graph)
	n = size(graph)[1]
	dst, path = floyd_warshall(graph)
	intermediaries = [rand(1:n) for i in 1:n, j in 1:n]
	#intermediaries[diag(intermediaries)] = diag(intermediaries)
  for i in 1:n
	  intermediaries[i,i] = i
  end
	return (i,j) -> route_to_flow(path, i, intermediaries[i,j]) .+ route_to_flow(path, intermediaries[i,j], j)
end

function node_hyper_path(i,j, k)
  return [(1 & (xor(i,j)>>(l))) for l in 0:k]
end

function route_hyper_path(ii, jj, n)
  i = ii - 1
  j = jj - 1

  k = floor(Int, log(2,n))
  path = node_hyper_path(i,j,k)
  routing = [0 for i in 1:n, j in 1:n]
  src = i
  for (h,edge) in enumerate(path)
    next = xor(src,(edge << (h-1)))
    routing[src + 1,next + 1] = 1
    src = next
  end
  #println("My routing: ", i , " to ", j)
  #display(routing)
  return routing
end


function valiant_routing(graph)
	n = size(graph)[1]
	intermediaries = [rand(1:n) for i in 1:n, j in 1:n]
  for i in 1:n
	  intermediaries[i,i] = i
  end
  return (i,j) -> route_hyper_path(i,intermediaries[i,j],n)  .+ route_hyper_path(intermediaries[i,j],j,n)
end
