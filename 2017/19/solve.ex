defmodule PathMap do
  @max_x 14
  @max_y 5

  defstruct map: %{}, seen: [], vector: {0, 1}, pos: {0, 0}, steps: 0

  def find_start_pos(pm, x \\ 0) do
    if pm.map[{x, 0}] === "|", do: {x, 0}, else: find_start_pos(pm, x + 1)
  end

  def run(pm) do
    travel(%PathMap{pm | pos: find_start_pos(pm)})
  end

  def travel(pm) do
    value_at_pos = at_pos(pm, pm.pos)
    case value_at_pos do
      "-" -> travel(continue(pm))
      "|" -> travel(continue(pm))
      "+" -> travel(turn(pm))
      " " -> pm
      nil -> pm
      _ -> travel(continue(%PathMap{pm | seen: pm.seen ++ [value_at_pos]}))
    end
  end

  def turn(pm) do
    {pos_x, pos_y} = pm.pos
    case pm.vector do
      {0, _vec_y} ->
        cond do
          pos_x === 0 or at_pos(pm, {pos_x - 1, pos_y}) === "|" or at_pos(pm, {pos_x - 1, pos_y}) === " " ->
            continue(%PathMap{pm | vector: {1, 0}})
          true ->
            continue(%PathMap{pm | vector: {-1, 0}})
        end
      {_vec_x, 0} ->
        cond do
          pos_y === 0 or at_pos(pm, {pos_x, pos_y - 1}) === "-" or at_pos(pm, {pos_x, pos_y - 1}) === " " ->
            continue(%PathMap{pm | vector: {0, 1}})
          true ->
            continue(%PathMap{pm | vector: {0, -1}})
        end
    end
  end

  def continue(pm) do
    {old_x, old_y} = pm.pos
    {vec_x, vec_y} = pm.vector
    new_pos = {old_x + vec_x, old_y + vec_y}
    %PathMap{pm | pos: new_pos, steps: pm.steps + 1}
  end

  def at_pos(pm, pos) do
    pm.map[pos] || " "
  end
end

defmodule Solver do
  def solve do
    map =
      "input"
      |> File.stream!()
      |> Stream.map(&(String.replace(&1, "\n", "")))
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn({line, y}, map) ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(map, fn({c, x}, map) ->
          Map.put(map, {x,y}, c)
        end)
      end)

    pm = %PathMap{map: map}

    pm = PathMap.run(pm)

    IO.inspect pm.steps
    # IO.inspect Enum.join(pm.seen)
  end
end

Solver.solve
