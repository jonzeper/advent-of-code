defmodule Solver do
  def is_tree(c) do
    c == "#"
  end

  def sled_step(slope_x, terrain, %{x: x, trees: trees}) do
    if is_tree(Enum.at(terrain, x)) do
      %{x: x + slope_x, trees: trees + 1}
    else
      %{x: x + slope_x, trees: trees}
    end
  end

  def count_trees(terrain, [slope_y, slope_x]) do
    %{trees: trees} =
      terrain
      |> Stream.take_every(slope_y)
      |> Enum.reduce(%{x: 0, trees: 0}, &sled_step(slope_x, &1, &2))

    trees
  end

  def get_terrain(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(&Stream.cycle/1)
  end

  def solve(filename, slope_y, slope_x) do
    get_terrain(filename)
    |> count_trees([slope_y, slope_x])
  end

  def solve2(filename) do
    terrain = get_terrain(filename)

    [[1, 1], [1, 3], [1, 5], [1, 7], [2, 1]]
    |> Enum.map(fn slopes -> count_trees(terrain, slopes) end)
    |> Enum.reduce(&*/2)
  end
end

# Part One
# 7
Solver.solve("test.txt", 1, 3) |> inspect |> IO.puts()
# 145
Solver.solve("input.txt", 1, 3) |> inspect |> IO.puts()

# Part Two
# 336
Solver.solve2("test.txt") |> inspect |> IO.puts()
# 3424528800
Solver.solve2("input.txt") |> inspect |> IO.puts()
