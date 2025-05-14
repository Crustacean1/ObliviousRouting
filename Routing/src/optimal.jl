using JuMP,GLPK,HiGHS

function mccf(graph, demands)
	n = size(graph)[1]
	model = Model(GLPK.Optimizer)
	
	@variable(model, flow[1:n,1:n,1:n,1:n] >=0)
	@variable(model, beta >=0)
	
	#Bandwidth constraint
	@constraint(model, [k=1:n, h=1:n], sum(flow[i,j,k,h] for i in 1:n, j in 1:n) <= graph[k,h] * beta)
	
	# Flow constraint
	@constraint(model, [k=1:n,h=1:n,g=1:n; g!=k && g!=h], sum(flow[k,h,i,g] for i in 1:n) == sum(flow[k,h,g,j] for j in 1:n))
	@constraint(model, [k=1:n,h=1:n,g=1:n; g==k && g!=h], sum(flow[k,h,i,g] for i in 1:n) + demands[k,h] == sum(flow[k,h,g,j] for j in 1:n))
	@constraint(model, [k=1:n,h=1:n,g=1:n; g!=k && g==h], sum(flow[k,h,i,g] for i in 1:n) == sum(flow[k,h,g,j] for j in 1:n) + demands[k,h] )
	
	@objective(model, Min, beta)

	set_optimizer_attribute(model, "tm_lim", 10000)  # Time limit of 10 seconds

	optimize!(model)
	
	return value(beta)
end

function perm_mccf(graph, permutation)
	n = size(graph)[1]
	d = floor(Int,log(2,n))

	model = Model(GLPK.Optimizer)

	@variable(model, in_flow[1:n,1:n,1:d] >=0)

	@variable(model, beta >= 0)

	perm_vec = permutation - Diagonal(ones(size(permutation,1)))
	#perm_vec = [((i == permutation[j]) ? 1 : 0) - ((i == j) ? 1 : 0) for i in 1:n,j in 1:n]

	@constraint(model, [k=1:n, j=1:n], sum(in_flow[k,j,i] for i in 1:d) == sum(in_flow[k,xor(j - 1 ,(2^(i-1))) + 1,i] for i in 1:d) + perm_vec[k,j]);
	@constraint(model, [i=1:n, j=1:d], sum(in_flow[k,i,j] + in_flow[k,xor(i - 1 ,(2^(j-1))) + 1,j] for k in 1:n) <= beta)

	@objective(model, Min, beta)

	optimize!(model)

	in = value.(in_flow)

	return (i,j) -> begin
		matrix = [0.0 for b in 1:n, a in 1:n]
		if permutation[i,j] == 1
			for k in 1:n
				for h in 1:d
					matrix[k,xor(k - 1,2^(h-1)) + 1] = in[i,k,h]
				end
			end
		end
		return matrix
	end
end

function perm_mccf_int(graph, permutation)
	n = size(graph)[1]
	d = floor(Int,log(2,n))

	model = Model(HiGHS.Optimizer)

	@variable(model, in_flow[1:n,1:n,1:d] >=0, Int)

	@variable(model, beta >= 0)

	perm_vec = permutation - Diagonal(ones(size(permutation,1)))

	@constraint(model, [k=1:n, j=1:n], sum(in_flow[k,j,i] for i in 1:d) == sum(in_flow[k,xor(j - 1 ,(2^(i-1))) + 1,i] for i in 1:d) + perm_vec[k,j]);
	@constraint(model, [i=1:n, j=1:d], sum(in_flow[k,i,j] + in_flow[k,xor(i - 1 ,(2^(j-1))) + 1,j] for k in 1:n) <= beta)

	@objective(model, Min, beta)

	optimize!(model)

	in = value.(in_flow)

	return (i,j) -> begin
		matrix = [0.0 for b in 1:n, a in 1:n]
		if permutation[i,j] == 1
			for k in 1:n
				for h in 1:d
					matrix[k,xor(k - 1,2^(h-1)) + 1] = in[i,k,h]# + in[i,xor(k - 1,2^(h-1)) + 1, h]
				end
			end
		end
		return matrix
	end
end
