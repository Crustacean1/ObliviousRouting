using Plots, SpecialFunctions, CSV, DataFrames, Statistics ; gr()

data = CSV.read("experiment", DataFrame)

grouped = groupby(combine(groupby(data, [:routing, :dimensions]), :congestion => mean), :routing)


plot(ylabel="congestion", xlabel="log(|V|)")

for g in grouped
	plot!((2 .^ g.dimensions), g.congestion_mean, label=first(g.routing))
end


savefig("routing_performance.svg")
