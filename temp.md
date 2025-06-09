Introduction
- [x] routing is important
- [x] body of work is deticated to various issues
- [x] network design is also important and dual
- [ ] adaptive routing is good, but hard (azar)
- [x] Models of networks (graphs, and )
- [x] Metrics to measure (congestion/load) which can be normed, dilation (which can be not)
- [x] Bounds on topologies
- [x] sorting networks
- [x] valiant (hypercubes)

Notes:
- [x] Mention single sink routing in intro
- [x] Specify *nice* model for oblivious routing with load and aggregation functions and commodities, attribute Gupta
- [x] congestion and \lambda routability
- ! [x] Oblivious Routing on Node-Capacitated and Directed Graphs
- expander graphs, warrant a mention at least
- [x] rent or buy network design (tangential at best)
- [x] mention Network Design problems (as sort of dual) problem
- [x] routing classification  adaptive/ single pah / fractional path/ totally optimal

Bounds and references: https://nicze.de/philipp/msc_thesis.pdf

Articles todo:
- Semi-oblivious routing: lower bounds


For adaptive stuff:
- Semi-Oblivious Traffic Engineering: The Road Not Taken


Articles:
- [x] Optimal oblivious routing in polynomial time # Improvement on the construction time to the original racke
- [x] Optimal Oblivious Path Selection on the Mesh # Bounds optimally congestion and dilation
- [ ] Approximating Congestion + Dilation in Networks via "Quality of Routing” Games
- [x] Oblivious routing in directed graphs with random demands # For the bounds on directed graphs
- [ ] On-line routing of virtual circuits with applications to load balancing and machine scheduling !!! Adaptive routing
- [ ] Dynamic vs. Oblivious Routing in Network Design
- [ ] Making Intra-Domain Routing Robust to Changing and Uncertain Traffic Demands: Understanding Fundamental Tradeoffs # Lp formulations for demand matrixes with some error margins, also check out MPLS
- [ ] Game theory: How bad is selfish routing?

Meta articles:
- [ ] A Survey of Congestion+Dilation Results for Packet Scheduling
- [ ] Routing and network design with robustness to changing or uncertain traffic demands

## Oblivious routing for uncertain links
Gupta and Racke improved on the ideas of Fakchareonphol by extending the randomized algorithm to more general class of link loads.
They also introduced more general model of oblivious routing, by allowing link load function $\ell$ to be any subadditive, and monotonous function. They also introduce the "cost" of the routing as function $agg$ and consider cases when $agg=\max$ and provide $O(log(n)log(log(n))) competetive strategy that can be constructed in polynomial time, the other achievement is bound in case $agg=\sum$, $O(\log(n))$ for fractional flow and $O(\log^2(n)) for integral flow. 
This is one of the earliest works to consider oblivious load edges, the previous work being \cite{GoelAndEstrin}, they obtain O(1) cost in case of single sink routing.
The other work by Naranya approached the topic of obliviousness in regards to the aggregation function, their O(\sqrt{n}) result, while asymptotically tight, shows that it is impossible to find good routing algorithm that is oblivious to the aggragation function.

The routing protocol scheme in the paper was following: 
1. construct the decomposition tree family as specified in Fackhareonphol
2. Given the resulting decomposition tree $T$ use it to route traffic in following fashion:
    - For demand from $s$ to $t$ in integral routing select the shortest(only) path in decomposition tree, whereas
    leaves of the tree $T$ have 1 to 1 mapping with nodes in $V$.
    The routing flow in $G$ is created by concatenating paths corresponding to edges in original tree

The proof of this routing perfomance uses $\alpha$ padding property
- Definition of alpha padding

The optimality proof uses the bound on stretch between any 2 vertices by Fakchareonphol to bound the cost of routing from above, but it is insufficient to prove competitive ratio.
As such the authors introduce $\alpha$-padding to find the lower bound on optimum routing cost.

The intuition behind this construction is that trees where 'short' edge is cut on level $i$ by hierarchical decomposition incurs cost of $2^i$,  this can arbitrarily increase cost of oblivious solution, as such it is required that cut edge is 'not too short' as to bound the lower cost of optimal routing.

The interesting part of this algorithm is the obliviousness to the edge load functions.

For the aggregation function $\Sum$ and load function id, the oblivious solution is trivially the shortest path flow between any source demand.

Ideas:
- use k shortest paths for performance comparision

Summaries:
- Route Optimization in IP networks: basically describes a controlling mechanism that adjusts fixed routing parameter based on traffic, 
- Oblivious routing in IP Networks: destination based routing, faking topological information for OSPF, Problem of computing dbr is NP-hard, with bad performance guarantees \Omega(|V|)
- OSPF Routing with Optimal Oblivious Performance Ratio Under Polyhedral Demand Uncertainty - just an LP for OSPF, nothing particularly interesting
- Traffic Engineering With Equal-Cost-MultiPath: An Algorithmic Perspective
- Making Intra-Domain Routing Robust to Changing and Uncertain Traffic Demands: Understanding Fundamental Tradeoffs, interesting demand model, LP with demand matrices at most w times different, proofs for performance on cycles and cliques

Bounds:
- O(Log(n)) on randomized obliviious routing: All-optical networks
- O(log^2(n)) algorithm for directed graphs w.h.p on independent demand matrix (Oblivious Routing in Directed Graphs with Random Demands)
- \Omega(sqrt(n)) bound on directed graphs with single-sink
Local optimization of global objectives: competitive distributed deadlock resolution and resource allocation.


Randomized rounding: A technique for provably good algorithms -> fractional flow vs probability distribution
Routing, merging and sorting on parallel models of computation. - Hopcroft (requirement for randomnes)
