defmodule TreeNode do
  defstruct name: "", weight: 0, parent: nil, children: [], total_weight: 0
end

defmodule Tree do
  defstruct nodes: %{}

  def find_root(tree) do
    some_node = List.first(Map.values(tree.nodes))
    find_root(tree.nodes, some_node)
  end

  def find_root(nodes, node) do
    if node.parent, do: find_root(nodes, nodes[node.parent]), else: node
  end

  @doc """
  We know the name and parent, but not weight.
  Children may have already been added as a parent node.
  """
  def add_children(tree, parent_name, child_names) do
    Enum.reduce(child_names, tree, fn(name, tree) ->
      if tree.nodes[name] do
        %{tree | nodes: update_node_parent(tree.nodes, name, parent_name)}
      else
        %{tree | nodes: Map.put(tree.nodes, name, %TreeNode{name: name, parent: parent_name})}
      end
    end)
  end

  @doc """
  We know the name, weight, and children.
  May have already been added as a child node without weight
  Parent may have already been added.
  There may be no children.
  """
  def add_node(tree, name, children, weight) do
    new_tree =
      if tree.nodes[name] do
        %{tree | nodes: Map.put(tree.nodes, name, %{tree.nodes[name] | weight: weight, children: children})}
      else
        %{tree | nodes: Map.put(tree.nodes, name, %TreeNode{name: name, weight: weight, children: children})}
      end
    add_children(new_tree, name, children)
  end

  def update_total_weights(tree) do
    root = Tree.find_root(tree)
    %{tree | nodes: update_total_weights(tree.nodes, root)}
  end

  def update_total_weights(nodes, node) do
    new_nodes = Enum.reduce(node.children, nodes, fn(child_name, nodes) ->
      update_total_weights(nodes, nodes[child_name])
    end)
    total_weight = Enum.reduce(node.children, node.weight, fn(child_name, total_weight) ->
      new_nodes[child_name].total_weight + total_weight
    end)
    Map.put(new_nodes, node.name, %TreeNode{node | total_weight: total_weight})
  end

  def find_unbalanced(tree) do
    root = Tree.find_root(tree)
    find_unbalanced(tree.nodes, root)
  end

  def find_unbalanced(nodes, node) do
    if is_unbalanced?(nodes, node.children) do
      IO.puts "Node #{node.name} is unbalanced"
      IO.puts "It has children with weights:"
      Enum.map(node.children, fn(child_name) -> nodes[child_name] end)
      |> Enum.each(fn(child) -> IO.puts "  #{child.name}: #{child.total_weight}" end)
    end
    Enum.map(node.children, fn(child_name) -> nodes[child_name] end)
    |> Enum.each(fn(child) -> find_unbalanced(nodes, child) end)
  end

  def is_unbalanced?(nodes, []), do: false
  def is_unbalanced?(nodes, children) when length(children) === 1, do: false
  def is_unbalanced?(nodes, children) do
    first_child_weight = nodes[List.first(children)].total_weight
    children
    |> Enum.any?(fn(child_name) -> nodes[child_name].total_weight !== first_child_weight end)
  end

  def node_total_weight(nodes, node) do
    Enum.reduce(node.children, node.weight, fn(n, total) ->
      total + node_total_weight(nodes, nodes[n])
    end)
  end

  def update_node_parent(nodes, name, parent) do
    Map.put(nodes, name, %{nodes[name] | parent: parent})
  end

  # def update_node_weight(nodes, name, weight) do
  #   %{nodes | name => %{nodes[name] | weight: weight}}
  # end

end

defmodule Solver do
  @re ~r/(?<prog>.*) \((?<weight>.*)\)( -> (?<children>.*)){0,1}/

  def parse_line(line) do
    parts = Regex.named_captures(@re, line)
    children =
      parts["children"]
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
    weight = String.to_integer(parts["weight"])
    %{parts | "children" => children, "weight" => weight }
  end

  def add_parts(parts, tree) do
    Tree.add_node(tree, parts["prog"], parts["children"], parts["weight"])
  end

  def solve do
    tree =
      File.stream!("input")
      |> Enum.map(&Solver.parse_line/1)
      |> Enum.reduce(%Tree{}, &add_parts/2)
      |> Tree.update_total_weights()
      |> Tree.find_unbalanced()

  end
end

Solver.solve
