# Build a tree, starting with {0,0}
# Each node stores its {a,b} and total strength including itself
# Find node (should be a leaf) with highest strength

# Same node could appear in multiple places on the tree
# Should it be a graph instead?
# Makes it harder to deal with using each only once
# but the tree will be quite large

# If graph,
# how to know when to stop traversing path?
# - could figure max node strength
#   if remaining_nodes*max_stren < best - what we have so far
#   But we'll still end up traversing most of the path

defmodule Solver do
  def add_part(parts, pa, pb) do
    parts
    |> Map.put(pa, add_part_to_set(Map.get(parts, pa), {pa, pb}))
    |> Map.put(pb, add_part_to_set(Map.get(parts, pb), {pa, pb}))
  end

  def add_part_to_set(set, part) do
    (set || MapSet.new())
    |> MapSet.put(part)
  end

  def other_value(v, {a, b} = _part) do
    if v === a, do: b, else: a
  end

  def strongest_longest_path(parts) do
    strongest_longest_path_from(parts, 0)
  end

  def strongest_longest_path_from(parts, from, used \\ MapSet.new(), path \\ [], strength \\ 0) do
    possibles = MapSet.difference(parts[from], used)

    possibles
    |> Enum.reduce({used, path, strength}, fn(part, {best_used, best_path, best_strength}) ->
      next_from = other_value(from, part)
      next_used = MapSet.put(used, part)
      next_strength = Enum.sum(Tuple.to_list(part)) + strength
      {u, p, s} = strongest_longest_path_from(parts, next_from, next_used, [part | path], next_strength)
      cond do
        length(p) > length(best_path) -> {u, p, s}
        length(p) === length(best_path) && s > best_strength -> {u, p, s}
        true -> {best_used, best_path, best_strength}
      end
    end)
  end

  def add_line(parts, line) do
    [pa, pb] =
      line
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    add_part(parts, pa, pb)
  end
end

{u,p,s} =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Enum.reduce(%{}, fn(line, parts) -> Solver.add_line(parts, line) end)
  |> Solver.strongest_longest_path()

{p, length(p), s}
|> IO.inspect
