defmodule TreeNode do
  defstruct name: "", weight: 0, parent: nil

  def find_root(node) do
    if node.parent, do: find_root(node.parent), else: node
  end
end

defmodule Tree do
  defstruct nodes: %{}

  def find_root(tree) do
    some_node = List.first(Map.values(tree.nodes))
    find_root(tree.nodes, some_node)
  end

  defp find_root(nodes, node) do
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
        %{tree | nodes: update_node_weight(tree.nodes, name, weight)}
      else
        %{tree | nodes: Map.put(tree.nodes, name, %TreeNode{name: name, weight: weight})}
      end
    add_children(new_tree, name, children)
  end

  defp update_node_parent(nodes, name, parent) do
    %{nodes | name => %{nodes[name] | parent: parent}}
  end

  defp update_node_weight(nodes, name, weight) do
    %{nodes | name => %{nodes[name] | weight: weight}}
  end
end

defmodule Solver do
  # A sneaky way to solve this would be to do a word count.
  # The name which shows up only once is the root.
  @re ~r/(?<prog>.*) \((?<weight>.*)\)( -> (?<children>.*)){0,1}/

  def parse_line(line) do
    parts = Regex.named_captures(@re, line)
    children =
      parts["children"]
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
    %{parts | "children" => children }
  end

  def add_parts(parts, tree) do
    Tree.add_node(tree, parts["prog"], parts["children"], parts["weight"])
  end

  def solve do
    File.stream!("input")
    |> Enum.map(&Solver.parse_line/1)
    |> Enum.reduce(%Tree{}, &add_parts/2)
    |> Tree.find_root()
    |> IO.inspect
  end
end

Solver.solve
