defmodule Solver do
  use Bitwise

  def solve(key) do
    Enum.reduce((0..127), 0, fn(i, sum) -> sum + count_bits(i, key) end)
  end

  def count_bits(i, key) do
    KnotHash.from_string(key <> "-" <> Integer.to_string(i))
    |> String.graphemes()
    |> Enum.map(&(String.to_integer(&1, 16)))
    |> Enum.reduce([], &(&2 ++ btobool(&1)))
    |> Enum.count(&(&1))
  end

  def btobool(i) do
    [(i &&& 0b1000) > 0, (i &&& 0b0100) > 0, (i &&& 0b0010) > 0, (i &&& 0b0001) > 0]
  end
end


IO.puts Solver.solve("hfdlxzhv")
