using Statistics
using LinearAlgebra
using StatsBase


include("./topologies.jl")
include("./utils.jl")

function network_simulation(graph, demands, route_fn_factory)
    n = size(graph, 1)
    m = size(demands, 1)


    edges = [(i, j) for i in 1:n, j in 1:n if graph[i, j] == 1 && i < j]

    packets = collect(1:size(demands, 1))
    traces = copy(packets)

    routings = [route_fn_factory(graph, src, dst) for (src, dst) in zip(packets, demands)]

    while any(packet -> packet[1] != packet[2], zip(packets, demands))
        routing_info = zip(packets, demands)
        destinations = map(a -> a[1](a[2]), zip(routings, routing_info))

        movement = collect(zip(packets, destinations))

        changes = []
        for edge in edges
            queue = findall(x -> (x[1], x[2]) == edge || (x[2], x[1]) == edge, movement)
            if !isempty(queue)
                push!(changes, queue[1])
            end
        end

        congestion = maximum([length(filter(x -> ((x[1], x[2]) == edge || (x[2], x[1]) == edge), movement)) for edge in edges])
        #println("Packets", packets)

        for change in changes
            packets[change] = movement[change][2]
        end

        traces = hcat(traces, packets)
    end
    return transpose(traces)
end

function dor_routing(src, dst)
    diff = xor(src - 1, dst - 1)

    if diff == 0
        return src
    else
        i = 0
        while (diff & 1) == 0
            i += 1
            diff = floor(Int64, diff / 2)
        end
        return xor(src - 1, 2^i) + 1
    end
end

function dor(packet)
    (node, destination) = packet
    return dor_routing(node, destination)
end

function create_dor(graph, src, dst)
    return packet -> dor(packet)
end

function valiant(packet, intermediary)
    (src, dst) = packet

    if src == intermediary[1]
        intermediary[1] = -999
    end

    if (intermediary[1] > 0)
        return dor_routing(src, intermediary[1])
    else
        return dor_routing(src, dst)
    end
end

function create_valiant(graph, src, dst)
    intermediary = [rand(1:size(graph, 1))]
    return packet -> valiant(packet, intermediary)
end

function create_impr_valiant(graph, src, dst)
    intermediary = [rand(1:size(graph, 1))]
    inv = [xor(size(graph, 1) - 1, intermediary[1] - 1) + 1]


    if (count_ones(xor(src, intermediary[1])) + count_ones(xor(intermediary[1], dst)) < count_ones(xor(src, inv[1])) + count_ones(xor(inv[1], dst)))
        return packet -> valiant(packet, intermediary)
    else
        return packet -> valiant(packet, inv)
    end
end

function random_routing(packet)
end

function create_random_routing(graph, src, dst)
end


function get_packet_dilation(trace)
    p = size(trace, 2)
    dilations = [count(x -> x[1] != x[2], zip(trace[1:end, i], trace[2:end, i])) for i in 1:p]
    return dilations
end

function get_packet_ct(trace)
    p = size(trace, 2)
    hops = Iterators.flatten([map(x -> x[1] > x[2] ? (x[1], x[2]) : (x[2], x[1]), Iterators.filter(x -> x[1] != x[2], zip(trace[1:end, i], trace[2:end, i]))) for i in 1:p])
    mean_congestion = mean(values(countmap(hops)))
    #println("Sum: ", sum(values(countmap(hops))))
    #println("Hops: ", mean(values(countmap(hops))))
    return mean_congestion
end

function average_packet_waiting_time()
end


for n in 5:15
    permutations = zip([permutation(2^n), map(x -> xor(x - 1, (2^n) - 1) + 1, 1:(2^n))], ["random", "inverse"])
    topology = hypergrid(2, n)
    for (perm, i) in permutations
        strategies = zip([create_dor, create_valiant, create_impr_valiant], ["DOR", "VALIANT", "VOCK"])
        for (strategy, j) in strategies
            open("hypercube.$i.$j.txt", "a") do file
                println("Doing $i $j")
                for k in 1:10
                    Random.seed!(2137 + k)
                    trace = network_simulation(topology, perm, strategy)
                    dilation = get_packet_dilation(trace)
                    congestion = get_packet_ct(trace)
                    write(file, "$n\t$i\t$j\t$(size(trace,1))\t$(mean(dilation))\t$(congestion)\n")
                    flush(file)
                end
            end
        end
    end
end


