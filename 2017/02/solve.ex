defmodule Solver do
  def solve(input) do
    Enum.reduce(input, 0, fn(line, checksum) ->
      checksum + max_minus_min(line)
    end)
  end

  def max_minus_min([first | line]) do
    {min, max} =
      Enum.reduce(line, {first, first}, fn(x, {min, max}) ->
        min = if x < min, do: x, else: min
        max = if x > max, do: x, else: max
        {min, max}
      end)
    max - min
  end

  def solve2(input) do
    Enum.reduce(input, 0, fn(line, checksum) ->
      checksum + divisible_result(Enum.sort_by(line, &(-&1)))
    end)
  end

  def divisible_result(line) do
    [head | rest] = line
    divisible_result(head, rest) || divisible_result(rest)
  end

  def divisible_result(head, rest) do
    Enum.find_value(rest, fn(x) ->
      if rem(head, x) === 0, do: div(head, x), else: false
    end)
  end
end

input =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn(line) ->
    String.split(line, "\t")
    |> Enum.map(&String.to_integer/1)
  end)

start = Time.utc_now()
Enum.each(1..5000, fn(_) -> Solver.solve2(input) end)
IO.puts "Done in #{Time.diff(Time.utc_now(), start, :millisecond)} ms"

a = Solver.solve2(input)
IO.puts a
