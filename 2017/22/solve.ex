defmodule Infection do
  defstruct [:position, :map, vector: 0, n_infected: 0]

  @vectors [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]

  def new(map) do
    %Infection{map: map, position: center_of_map(map)}
  end

  def run(inf, steps) do
    Enum.reduce(1..steps, inf, fn(_, inf) -> step(inf) end)
  end

  def step(inf) do
    current_infected = inf.map[inf.position] === "#"
    # IO.puts "pos: #{inspect inf.position}"
    # IO.puts "inf: #{current_infected}"
    # IO.puts "map: #{inspect inf.map}"
    if current_infected do
      inf
      |> turn_right()
      |> clear_infection()
      |> move()
    else
      inf
      |> turn_left()
      |> infect()
      |> move()
    end
  end

  def turn_right(inf) do
    new_vec = inf.vector + 1
    new_vec = if new_vec > 3, do: 0, else: new_vec
    %Infection{inf | vector: new_vec}
  end

  def turn_left(inf) do
    new_vec = inf.vector - 1
    new_vec = if new_vec < 0, do: 3, else: new_vec
    %Infection{inf | vector: new_vec}
  end

  def clear_infection(inf) do
    %Infection{inf | map: Map.put(inf.map, inf.position, ".")}
  end

  def infect(inf) do
    %Infection{inf | map: Map.put(inf.map, inf.position, "#"), n_infected: inf.n_infected + 1}
  end

  def move(inf) do
    {vx, vy} = Enum.at(@vectors, inf.vector)
    {px, py} = inf.position
    %Infection{inf | position: {px + vx, py + vy}}
  end

  def n_infected(inf), do: inf.n_infected

  defp center_of_map(map) do
    center = trunc(:math.sqrt(length(Map.keys(map))) / 2)
    {center, center}
  end
end

defmodule Solver do
  def solve do
    parse_map()
    |> Infection.new()
    |> Infection.run(10_000)
    |> Infection.n_infected()
    |> IO.puts
  end

  def parse_map do
    File.stream!("input")
    |> Stream.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn({row, y}, map) ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map, fn({c, x}, map) -> Map.put(map, {x, y}, c) end)
    end)
  end
end

Solver.solve
