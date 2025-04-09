using JuMP,GLPK

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
	
	if termination_status(model) == MOI.OPTIMAL
		return (value(beta), value(beta))
	else
		return (value(beta), Inf)
	end
end
