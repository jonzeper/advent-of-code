# TODO: Part two strategy - play it through until we find a loop, then, the answer comes to us
# hmmm even that may be too slow. Let's try though
# One

defmodule Solver do
  # @max_cup 9
  @max_cup 9
  @iter_count 100

  def solve(str) do
    cups =
      str
      |> String.graphemes
      |> Enum.map(&String.to_integer/1)

    iterate(cups, 0)
  end

  def iterate(cups, @iter_count), do: cups
  def iterate(cups, iter_count) do
    # IO.puts ""
    # IO.puts (inspect cups)
    [current, cup1, cup2, cup3 | rest] = cups
    picked_up = [cup1, cup2, cup3]
    destination_cup = determine_destination_cup(current, picked_up)
    # IO.puts("destination: #{destination_cup}")
    newc =

    [current | (rest
    |> Enum.reduce([], fn cup, acc ->
      if cup == destination_cup do
        [cup3, cup2, cup1, cup | acc]
      else
        [cup | acc]
      end
    end))]
    |> Enum.reverse
    # IO.puts(inspect picked_up)
    # IO.puts(inspect newc)
    iterate(newc, iter_count + 1)
  end

  def determine_destination_cup(1, picked_up), do: determine_destination_cup(@max_cup + 1, picked_up)
  def determine_destination_cup(cup, picked_up) do
    if Enum.member?(picked_up, cup - 1), do: determine_destination_cup(cup - 1, picked_up), else: cup - 1
  end

  def find_destination_cup(cups, 0), do: find_destination_cup(cups, 10)
  def find_destination_cup(cups, current_cup) do
    Enum.find_index(cups, fn cup -> cup == current_cup - 1 end) || find_destination_cup(cups, current_cup - 1)
  end
end

# 67384529
# :timer.tc(Solver, :solve, ["219748365"]) |> inspect |> IO.puts


# {3170, [1, 6, 7, 3, 8, 4, 5, 2, 9]}
:timer.tc(Solver, :solve, ["389125467"]) |> inspect |> IO.puts
