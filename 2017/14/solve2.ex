defmodule Solver do
  use Bitwise

  def solve(key) do
    matrix = Enum.map(0..127, fn(i) -> make_row(i, key) end)
    {count, _} = Enum.reduce(0..127, {0, matrix}, fn(i, {count, matrix} = _) ->
      Enum.reduce(0..127, {count, matrix}, fn(j, {count, matrix} = _) ->
        if Enum.at(Enum.at(matrix, i), j) === 1 do
          {count + 1, traverse(matrix, i, j)}
        else
          {count, traverse(matrix, i, j)}
        end
      end)
    end)
    IO.inspect count
  end

  def traverse(matrix, i, _j) when i < 0, do: matrix
  def traverse(matrix, i, _j) when i > 127, do: matrix
  def traverse(matrix, _i, j) when j < 0, do: matrix
  def traverse(matrix, _i, j) when j > 127, do: matrix
  def traverse(matrix, i, j) do
    val = Enum.at(Enum.at(matrix, i), j)
    if val === 1 do
      List.replace_at(matrix, i, List.replace_at(Enum.at(matrix, i), j, -1))
      |> traverse(i - 1, j)
      |> traverse(i + 1, j)
      |> traverse(i, j - 1)
      |> traverse(i, j + 1)
    else
      matrix
    end
  end

  def make_row(i, key) do
    KnotHash.from_string(key <> "-" <> Integer.to_string(i))
    |> String.graphemes()
    |> Enum.map(&(String.to_integer(&1, 16)))
    |> Enum.reduce([], &(&2 ++ btobool(&1)))
    |> Enum.map(fn(b) -> if b, do: 1, else: 0 end)
    # |> Enum.count(&(&1))
  end

  def btobool(i) do
    [(i &&& 0b1000) > 0, (i &&& 0b0100) > 0, (i &&& 0b0010) > 0, (i &&& 0b0001) > 0]
  end
end


Solver.solve("hfdlxzhv")
