using Distributions

function save_graph(graph, file)
end

function load_graph(file)
end

function hypergrid_neighbours(a,b,n,k)
	distance = 0
	for _ in 1:k
		distance += abs((a%n) - (b%n))
		a = div(a,n)
		b = div(b,n)
	end
	return distance == 1
end

function hypergrid(n, k)
	m = (n^k - 1)
	graph = [hypergrid_neighbours(i,j,n,k) for i in 0:m, j in 0:m]
	return graph
end

function gnp(n, p)
	vertices = collect(1:n)
	tv = rand(1:n)
	tree = []
	push!(tree,vertices[tv])
	deleteat!(vertices, tv)
	edges = []

	for i = 1:(n-1)
		vertex = rand(1:(n-i))
		tree_vertex = rand(1:i)

		push!(edges, (vertices[vertex], tree[tree_vertex]))
		push!(tree, vertices[vertex])

		deleteat!(vertices, vertex)
	end
	adj = [0.0 for i in 1:n, j in 1:n]

	for i in 1:n
		for j in 1:n
			if rand(Uniform(0,1)) < p && i != j
				adj[j,i] = adj[i,j] = rand(Uniform(1,5))
			end
		end
	end

	for (i,j) in edges 
		adj[i,j] = adj[j,i] = rand(Uniform(1,5))
	end

	return adj
end

