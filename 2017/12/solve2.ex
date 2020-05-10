defmodule GraphNode do
  defstruct edges: MapSet.new()
end

defmodule Graph do
  defstruct nodes: %{}

  def add_entry(g, name, edge_names) do
    %Graph{g | nodes: Map.put(g.nodes, name, %GraphNode{edges: edge_names})}
  end

  def disjoint_set_count(g) do
    {count, _} = Enum.reduce(Map.keys(g.nodes), {0, MapSet.new}, fn(node_name, {count, found} = _) ->
      if !MapSet.member?(found, node_name) do
        {count + 1, MapSet.union(found, nodes_in_set(g, node_name))}
      else
        {count, found}
      end
    end)
    count
  end

  def nodes_in_set(g, node_name, found \\ MapSet.new()) do
    if !MapSet.member?(found, node_name) do
      node = g.nodes[node_name]
      found = MapSet.put(found, node_name)
      Enum.reduce(node.edges, found, fn(edge_name, found) ->
        MapSet.union(found, nodes_in_set(g, edge_name, found))
      end)
    else
      found
    end
  end

  def set_size(g, node_name, found \\ MapSet.new()) do
    if !MapSet.member?(found, node_name) do
      node = g.nodes[node_name]
      found = MapSet.put(found, node_name)
      Enum.reduce(node.edges, 1, fn(edge_name, size) ->
        size + set_size(g, edge_name, found)
      end)
    else
      0
    end
  end
end

defmodule Solver do
  def solve do
    File.stream!("input")
    |> Enum.reduce(%Graph{}, &add_line/2)
    |> Graph.disjoint_set_count()
    |> IO.inspect
  end

  defp add_line(line, g) do
    [name, children] =
      line
      |> String.trim()
      |> String.split(" <-> ")

    children = children |> String.split(",") |> Enum.map(&String.trim/1)
    Graph.add_entry(g, name, children)
  end
end



Solver.solve
