defmodule Solver do
  def count_ones_and_threes(values, acc) when values == [], do: acc

  def count_ones_and_threes([first | rest], {ones, threes, last}) do
    diff = first - last

    cond do
      diff == 3 -> count_ones_and_threes(rest, {ones, threes + 1, first})
      diff == 1 -> count_ones_and_threes(rest, {ones + 1, threes, first})
      true -> count_ones_and_threes(rest, {ones, threes, first})
    end
  end

  def final_answer({ones, threes, _}) do
    ones * (threes + 1)
  end

  def solve(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort()
    |> count_ones_and_threes({0, 0, 0})
    |> final_answer
  end
end

defmodule Solver2 do
  # def count_permutations(a, c) when a == [], do: {0, c}
  def count_permutations([start | tail], c) when tail == [], do: {1, c}

  def count_permutations([start | tail], collected \\ Map.new()) do
    # IO.puts "-------------------------------"
    # IO.puts "count_permutations from #{start} through #{inspect tail}"
    # IO.puts "  known_vals: #{inspect collected}"
    col_val = Map.get(collected, start)

    if col_val do
      # IO.puts "  val already known: #{col_val}"
      {col_val, collected}
    else
      ways_out =
        Enum.take(tail, 3)
        |> Enum.with_index()
        |> Enum.filter(fn {x, _} -> x - start < 4 end)

      # IO.puts "  ways_out: #{inspect ways_out}"

      {n_permutations_from_ways_out, next_collected} =
        ways_out
        |> Enum.reduce({0, collected}, fn {_, i}, {n, c} ->
          {nn, cc} = count_permutations(Enum.drop(tail, i), c)
          {nn + n, cc}
        end)

      ret_val = n_permutations_from_ways_out
      {ret_val, Map.put(next_collected, start, ret_val)}
    end
  end

  def solve(filename) do
    {permutations, _} =
      File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&String.to_integer/1)
      |> Enum.sort()
      |> List.insert_at(0, 0)
      |> count_permutations

    permutations
  end
end

# 35
Solver.solve("smalltest.txt") |> inspect |> IO.puts()
# 220
Solver.solve("test.txt") |> inspect |> IO.puts()
# 2343
Solver.solve("input.txt") |> inspect |> IO.puts()

# 8
Solver2.solve("smalltest.txt") |> inspect |> IO.puts()
# 19208
Solver2.solve("test.txt") |> inspect |> IO.puts()
# ?
Solver2.solve("input.txt") |> inspect |> IO.puts()
