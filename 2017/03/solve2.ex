defmodule Solver do
  def matrix_fetch(matrix, pos) do
    result = Map.fetch(matrix, pos)
    if result === :error do
      0
    else
      {_, value} = result
      value
    end
  end

  def solve_pos(matrix, pos) do
    {x, y} = pos
    new_val = Enum.sum([
      matrix_fetch(matrix, {x-1, y-1}),
      matrix_fetch(matrix, {x-1, y}),
      matrix_fetch(matrix, {x-1, y+1}),
      matrix_fetch(matrix, {x, y-1}),
      matrix_fetch(matrix, {x, y+1}),
      matrix_fetch(matrix, {x+1, y-1}),
      matrix_fetch(matrix, {x+1, y}),
      matrix_fetch(matrix, {x+1, y+1})
    ])
    if new_val > 277678, do: IO.puts new_val
    new_val
  end

  def solve_right(matrix, level) do
    Enum.reduce 0..level*2-1, matrix, fn(i, matrix) ->
      pos = {level, (level-1)-i}
      Map.put(matrix, pos, solve_pos(matrix, pos))
    end
  end

  def solve_top(matrix, level) do
    Enum.reduce 0..level*2, matrix, fn(i, matrix) ->
      pos = {level-i, -level}
      Map.put(matrix, pos, solve_pos(matrix, pos))
    end
  end

  def solve_left(matrix, level) do
    Enum.reduce 0..level*2, matrix, fn(i, matrix) ->
      pos = {-level, (-level)+i}
      Map.put(matrix, pos, solve_pos(matrix, pos))
    end
  end

  def solve_bottom(matrix, level) do
    Enum.reduce 0..level*2, matrix, fn(i, matrix) ->
      pos = {(-level)+i, level}
      Map.put(matrix, pos, solve_pos(matrix, pos))
    end
  end

  def solve_level(matrix, level) do
    matrix = solve_right(matrix, level)
    matrix = solve_top(matrix, level)
    matrix = solve_left(matrix, level)
    solve_bottom(matrix, level)
  end

  def solve do
    matrix = %{{0,0} => 1}

    matrix = Enum.reduce 1..5, matrix, fn(level, matrix) ->
      solve_level(matrix, level)
    end
  end
end

Solver.solve
