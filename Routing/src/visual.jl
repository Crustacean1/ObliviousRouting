using Karnak
using Colors
using Graphs

function save_graph_to_file(graph, tree, file)
  _graph = SimpleGraph(graph)
  _tree = SimpleGraph(graph)

  @svg begin
  	background("black")
  	fontsize(25)
  
  	drawgraph(_graph,layout=stress,vertexlabels=1:nv(_graph),
        vertexshapesizes=[25],
  		  vertexfillcolors=colorant"gray50",
  		  edgestrokecolors=colorant"purple",
  		  edgestrokeweights=10)
    @layer begin
  	  drawgraph(_tree,layout=stress,vertexlabels=1:nv(_tree),
         vertexshapesizes=[0],
  	  	  edgestrokecolors=colorant"blue",
          edgestrokeweights=(_,src,dst,_,_) -> tree[src,dst] * 5)
    end
  end 10000 10000 "$(file).svg"
end
