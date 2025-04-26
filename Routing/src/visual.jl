using Karnak
using Colors
using Graphs

function draw_route(graph, src, dst, route, file)
  _graph = SimpleGraph(graph)
  _tree = SimpleGraph(graph)

  colors = [i == src ? colorant"green" : (i == dst ? colorant"red" : colorant"grey30") for i in 1:nv(_tree)]

  @svg begin
  	background("black")
  	fontsize(25)
  
  	drawgraph(_graph,layout=stress,vertexlabels=1:nv(_graph),
        vertexshapesizes=[25],
  		  vertexfillcolors=colors,
  		  edgestrokecolors=colorant"gray50",
        edgestrokeweights=(_,src,dst,_,_) -> graph[src,dst] * 10)
    @layer begin
  	  drawgraph(_tree,layout=stress,vertexlabels=1:nv(_tree),
          vertexshapesizes=[25],
          vertexfillcolors=colors,
  	  	  edgestrokecolors=colorant"red",
               edgestrokeweights=(_,src,dst,_,_) -> (route[src,dst] + route[dst,src])* 8)
    end
  end 1000 1000 "$(file).svg"
end
