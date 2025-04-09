function tree_routing(tree, src, dst)
n = size(tree)[1]
  matrix = 
end

function mixed_tree_routing(graph)
  n = size(graph)[1]
  tree_count = ceil(Int,log(2,n))
  trees =  [uniform_random_tree(graph) for i in 1:tree_count]
  return [ for i in 1:n, j in 1:n]
end
