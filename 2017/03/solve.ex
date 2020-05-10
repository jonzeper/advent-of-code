defmodule Solver03 do
  require Integer

  def solve_for(input) do
    nearest_sqrt = trunc(:math.sqrt(input))
    diff = input - nearest_sqrt * nearest_sqrt
    y = div(nearest_sqrt, 2)

    if Integer.is_even(nearest_sqrt) do
      abs((-(y-1)) - y) + even_diff(nearest_sqrt, diff)
    else
      diff
    end
  end

  def even_diff(root, diff) do
    if diff > root, do: diff = diff - root
    if diff <= div(root, 2) do
      2 - diff
    else
      0 - (root - diff)
    end
  end

  def odd_diff(root, diff) do
    # Didn't do this since my input gave even diff
  end

  def solve(input) do
    dist = solve_for(input)
    "#{input} is #{dist} steps away"
  end

end

IO.puts Solver03.solve(2)  # 1
IO.puts Solver03.solve(4)  # 1
IO.puts Solver03.solve(16)  # 3
IO.puts Solver03.solve(36)  # 5
IO.puts Solver03.solve(8)  # 1
IO.puts Solver03.solve(17) # 4
IO.puts Solver03.solve(30) # 5
IO.puts Solver03.solve(50) # 7
IO.puts Solver03.solve(10) # 3
IO.puts Solver03.solve(277678) # 3


Enum.each 1..10, fn(i) ->
  IO.puts Solver03.odd_diff(5, i)
end
