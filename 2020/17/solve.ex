defmodule Matrix do
  defstruct grid: %{}, bounds: nil

  def put_pixel(grid, value, [pos]), do: Map.put(grid, pos, value)
  def put_pixel(grid, value, [pos | positions]) do
    Map.put(grid, pos, put_pixel(Map.get(grid, pos, %{}), value, positions))
  end

  def get_pixel(grid, [pos]) do
    Map.get(grid, pos, 0)
  end
  def get_pixel(grid, [pos | positions]) do
    get_pixel(Map.get(grid, pos, %{}), positions)
  end

  def turn_on(matrix, positions) do
    next_grid = put_pixel(matrix.grid, 1, positions)
    next_bounds =
      positions
      |> Enum.zip(matrix.bounds)
      |> Enum.map(fn {pos, {min, max}} ->
        case pos do
          ^min -> {min - 1, max}
          ^max -> {min, max + 1}
          _ -> {min, max}
        end
      end)

    %Matrix{grid: next_grid, bounds: next_bounds}
  end

  # TODO: Delete empty dimensions?
  # TODO: Reduce bounds?
  def turn_off(matrix, positions) do
    next_grid = put_pixel(matrix.grid, 0, positions)
    %Matrix{matrix | grid: next_grid}
  end

  def count_neighbors(grid, positions, dontcount \\ true)
  def count_neighbors(grid, [pos], dontcount) do
    (pos-1..pos+1)
    |> Enum.count(fn x -> Map.get(grid, x, 0) == 1 and not (dontcount and x == pos) end)
  end
  def count_neighbors(grid, [pos | positions], dontcount) do
    (pos-1..pos+1)
    |> Enum.map(fn x -> count_neighbors(Map.get(grid, x, %{}), positions, dontcount and x == pos) end)
    |> Enum.sum
  end

  def iterate(matrix) do
    iterate(matrix, matrix, matrix.bounds, [])
  end

  def iterate(og_matrix, matrix, [{min, max}], positions) do
    (min..max)
    |> Enum.reduce(matrix, fn x, matrix ->
      positions = List.insert_at(positions, -1, x)
      pixel = Matrix.get_pixel(og_matrix.grid, positions)
      n_neighbors = Matrix.count_neighbors(og_matrix.grid, positions)
      case {pixel, n_neighbors} do
        {1, 2} -> matrix
        {1, 3} -> matrix
        {1, _} -> Matrix.turn_off(matrix, positions)
        {0, 3} -> Matrix.turn_on(matrix, positions)
        _ -> matrix
      end
    end)
  end

  def iterate(og_matrix, matrix, [{min, max} | bounds], positions) do
    (min..max)
    |> Enum.reduce(matrix, fn x, matrix ->
      Matrix.iterate(og_matrix, matrix, bounds, List.insert_at(positions, -1, x))
    end)
  end

  def count_active_pixels(matrix), do: _count_active_pixels(matrix.grid)
  def _count_active_pixels(dimension) do
    dimension
    |> Map.values
    |> Enum.map(fn x -> if is_map(x), do: _count_active_pixels(x), else: x end)
    |> Enum.sum
  end

  def debug(matrix) do
    [{min_x, max_x}, {min_y, max_y}, {min_z, max_z}] = matrix.bounds
    (min_z..max_z)
    |> Enum.each(fn z ->
      IO.puts("----z=#{z}-----------------------")
      (min_y..max_y)
      |> Enum.each(fn y ->
        line =
          (min_x..max_x)
          |> Enum.map(fn x ->
            pixel =
              Map.get(matrix.grid, x, %{})
              |> Map.get(y, %{})
              |> Map.get(z, 0)
            case pixel do
              0 -> {".", Matrix.count_neighbors(matrix.grid, [x, y, z])}
              1 -> {"#", Matrix.count_neighbors(matrix.grid, [x, y, z])}
            end
          end)
        IO.puts("#{inspect Enum.join(Enum.map(line, fn {x,_} -> x end))} #{inspect Enum.join(Enum.map(line, fn {_,x} -> x end))}")
      end)
      IO.puts("---------------------------------")
    end)
  end
end

defmodule Solver do
  def solve(filename, dimensions \\ 3) do
    lines =
      File.stream!(filename)
      |> Stream.map(&String.trim/1)
      |> Enum.map(&String.graphemes/1)

    xy_bounds = [
      {-1, Enum.count(List.first(lines))},
      {-1, Enum.count(lines)}
    ]
    extra_bounds =
      (1..(dimensions-2))
      |> Enum.map(fn _ -> {-1, 1} end)
    initial_bounds = xy_bounds ++ extra_bounds

    initial_matrix =
      lines
      |> Enum.with_index
      |> Enum.reduce(%Matrix{bounds: initial_bounds}, fn {line, y}, matrix ->
        line
        |> Enum.with_index
        |> Enum.reduce(matrix, fn {c, x}, matrix ->
          extra_dims =
            (1..(dimensions-2))
            |> Enum.map(fn _ -> 0 end)
          if c == "#", do: Matrix.turn_on(matrix, [x, y] ++ extra_dims), else: matrix
        end)
      end)

    # Matrix.debug(initial_matrix)
    # Matrix.debug(initial_matrix |> Matrix.iterate)

    final_matrix =
      (1..6)
      |> Enum.reduce(initial_matrix, fn _, matrix -> Matrix.iterate(matrix) end)
      # |> Matrix.debug

    final_matrix |> Matrix.count_active_pixels
  end
end

# 112
:timer.tc(Solver, :solve, ["test.txt"]) |> inspect |> IO.puts

# {64734, 380}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# {1069003, 848}
:timer.tc(Solver, :solve, ["test.txt", 4]) |> inspect |> IO.puts

# {2141164, 2332}
:timer.tc(Solver, :solve, ["input.txt", 4]) |> inspect |> IO.puts
