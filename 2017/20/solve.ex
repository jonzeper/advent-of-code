defmodule Particle do
  defstruct [:pos, :vel, :acc]
end

defmodule Solver do
  def particles do
    File.stream!("input")
    |> Stream.map(&(Regex.named_captures(~r/p=<(?<pos>.*)>, v=<(?<vel>.*)>, a=<(?<acc>.*)>/, &1)))
    |> Enum.with_index
    |> Enum.map(fn({%{"pos" => pos, "vel" => vel, "acc" => acc}, i}) ->
      {simple_vector(acc), simple_vector(vel), simple_vector(pos), i}
    end)
    |> Enum.sort()
  end

  def simple_vector(vec_string) do
    vec_string
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&abs/1)
    |> Enum.sum
  end
end

Solver.particles
# |> Enum.to_list
|> IO.inspect
