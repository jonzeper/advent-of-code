defmodule Trie do
  defstruct children: %{}, leaf: false

  def add_new(node, [c | s] = _s) do
    next_node = node.children[c]
    if s === [] do
      case next_node do
        %{leaf: true} -> raise "Collision"
        nil -> %{node | children: Map.put(node.children, c, %Trie{leaf: true})}
        _ -> %{node | children: %{node.children | c => %{next_node | leaf: true}}}
      end
    else
      case next_node do
        nil ->
          %{node | children: Map.put(node.children, c, Trie.add_new(%Trie{}, s))}
        _ ->
          %{node | children: %{node.children | c => Trie.add_new(next_node, s)}}
      end
    end
  end
end

defmodule Solver do
  def is_valid?(input_line) do
    try do
      input_line
      |> String.trim
      |> String.split(" ")
      |> Enum.reduce(%Trie{}, fn(word, t) ->
        Trie.add_new(t, String.graphemes(word))
      end)
      true
    rescue
      RuntimeError -> false
    end
  end

  def solve do
    File.stream!("input")
    |> Enum.count(&is_valid?/1)
  end
end

IO.puts Solver.solve




# defmodule Thing do
#   defstruct [:x]

#   def add(thing, s) do
#     put_in thing,
#     # %{thing | x: thing.x + 1}
#   end
# end


# defmodule Test do
#   def run do
#     t = %Thing{x: 1}
#     t = Thing.add(t)
#     IO.puts t
#   end
# end

# Test.run
