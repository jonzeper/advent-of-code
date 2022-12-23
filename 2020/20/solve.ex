# Assumption: A border can match at most one other border
# Assumption: Tiles are square

defmodule Tile do
  @monster_middle ~r/#....##....##....###/
  @monster_bottom ~r(#..#..#..#..#..#)
  defstruct [id: 0, lines: [], loc: {0, 0}]

  def from_strs(strs) do
    [<<"Tile ", tile_num_str::binary-size(4), ":">> | lines] =
      Enum.map(strs, &String.trim/1)

    %Tile{id: String.to_integer(tile_num_str), lines: Enum.map(lines, &String.graphemes/1)}
  end

  def rotate(tile) do
    {new_lines, _} =
      tile.lines
      |> Enum.reduce({[], tile.lines}, fn _, {new_lines, old_lines} ->
        {next_new, next_old} =
          old_lines
          |> Enum.reduce({[], []}, fn [x | rest], {new, old} ->
            {[x | new], List.insert_at(old, -1, rest)}
          end)
        {[next_new | new_lines], next_old}
      end)
    %Tile{tile | lines: Enum.reverse(new_lines)}
  end

  def flip_v(tile) do
    %Tile{tile | lines: Enum.reverse(tile.lines)}
  end

  def flip_h(tile) do
    %Tile{tile | lines: Enum.map(tile.lines, &Enum.reverse/1)}
  end

  def left_side(tile), do: Enum.map(tile.lines, &List.first/1)
  def right_side(tile), do: Enum.map(tile.lines, &List.last/1)
  def top_side(tile), do: List.first(tile.lines)
  def bottom_side(tile), do: List.last(tile.lines)

  def count_hashes(tile) do
    tile.lines
    |> Enum.map(fn line -> Enum.count(line, fn c -> c == "#" end) end)
    |> Enum.sum
  end

  def count_sea_monsters(tile) do
    count_sea_monsters(tile, 0, 0)
  end
  def count_sea_monsters(tile, 4, 1), do: count_sea_monsters(Tile.flip_h(Tile.flip_v(tile)), 0, 2)
  def count_sea_monsters(tile, 4, 0), do: count_sea_monsters(Tile.flip_v(tile), 0, 1)
  def count_sea_monsters(tile, rotations, flips) do
    count =
      possible_monster_bodies(tile)
      |> Enum.count(fn {line_num, starting_index} ->
        valid_monster?(tile, line_num, starting_index)
      end)
    if count > 0 do
      Tile.pp(tile)
      count
    else
      count_sea_monsters(Tile.rotate(tile), rotations + 1, flips)
    end
  end

  def valid_monster?(tile, line_num, starting_index) do
    head_line = Enum.at(tile.lines, line_num - 1)
    bottom_area =
      Enum.at(tile.lines, line_num + 1)
      |> Enum.join
      |> String.slice(starting_index + 1, 16)

    if Enum.at(head_line, starting_index + 18) == "#" and Regex.match?(@monster_bottom, bottom_area) do
      IO.puts("monster on line #{line_num}, starting at #{starting_index}")
      IO.puts("  #{String.slice(Enum.join(Enum.at(tile.lines, line_num - 1)), starting_index, 20)}")
      IO.puts("  #{String.slice(Enum.join(Enum.at(tile.lines, line_num)), starting_index, 20)}")
      IO.puts("  #{String.slice(Enum.join(Enum.at(tile.lines, line_num + 1)), starting_index, 20)}")
      true
    else
      false
    end
  end

  def possible_monster_bodies(tile) do
    tile.lines
    |> Enum.with_index
    |> Enum.drop(1)
    |> List.delete_at(-1)
    |> Enum.reduce([], fn {line, n}, acc ->
      matches = Regex.scan(@monster_middle, Enum.join(line), return: :index)
      acc ++ Enum.map(matches, fn [{i, _}] -> {n, i} end)
    end)
  end

  def pp(tile), do: Enum.each(tile.lines, fn line -> IO.puts(Enum.join(line)) end)
end

defmodule Solution do
  @tile_size 10
  defstruct [tiles: %{}]

  def add_tile(solution, tile), do: %Solution{tiles: Map.put(solution.tiles, tile.loc, tile)}
  def add_tile(solution, new_tile, existing_tile, matching_side_of_existing) do
    {loc_x, loc_y} = existing_tile.loc
    new_loc = case matching_side_of_existing do
      :left -> {loc_x - 1, loc_y}
      :right -> {loc_x + 1, loc_y}
      :above -> {loc_x, loc_y - 1}
      :below -> {loc_x, loc_y + 1}
    end
    add_tile(solution, %Tile{new_tile | loc: new_loc})
  end

  def try_to_add_tile(solution, new_tile) do
    case find_place_for_tile(solution, new_tile) do
      {rotated_new_tile, existing_tile, matching_side_of_existing} ->
        {:added, add_tile(solution, rotated_new_tile, existing_tile, matching_side_of_existing)}
      _ ->
        {:not_added, solution}
    end
  end

  def find_place_for_tile(solution, new_tile) do
    solution.tiles
    |> Map.values
    |> Enum.reduce_while(nil, fn existing_tile, _ -> match_tiles(new_tile, existing_tile) end)
  end

  def match_tiles(new_tile, existing_tile, rotation_count \\ 0, flipped \\ 0)
  def match_tiles(_new_tile, _existing_tile, 4, 2), do: {:cont, nil}
  def match_tiles(new_tile, existing_tile, 4, 1), do: match_tiles(Tile.flip_v(Tile.flip_h(new_tile)), existing_tile, 0, 2)
  def match_tiles(new_tile, existing_tile, 4, 0) do
    match_tiles(Tile.flip_h(new_tile), existing_tile, 0, 1)
  end
  def match_tiles(new_tile, existing_tile, rotation_count, flipped) do
    cond do
      Tile.left_side(new_tile) == Tile.right_side(existing_tile) ->
        {:halt, {new_tile, existing_tile, :right}}
      Tile.right_side(new_tile) == Tile.left_side(existing_tile) ->
        {:halt, {new_tile, existing_tile, :left}}
      Tile.top_side(new_tile) == Tile.bottom_side(existing_tile) ->
        {:halt, {new_tile, existing_tile, :below}}
      Tile.bottom_side(new_tile) == Tile.top_side(existing_tile) ->
        {:halt, {new_tile, existing_tile, :above}}
      true ->
        match_tiles(Tile.rotate(new_tile), existing_tile, rotation_count + 1, flipped)
    end
  end

  def add_tiles(solution, tiles) do
    {next_solution, remaining_tiles} =
      tiles
      |> Enum.reduce({solution, []}, fn tile, {solution, remaining_tiles} ->
        case Solution.try_to_add_tile(solution, tile) do
          {:added, s} -> {s, remaining_tiles}
          {:not_added, _} -> {solution, [tile | remaining_tiles]}
        end
      end)
    if Enum.count(remaining_tiles) > 0, do: add_tiles(next_solution, remaining_tiles), else: next_solution
  end

  def find_corners(solution) do
    {xs, ys} =
      solution.tiles
      |> Map.values
      |> Enum.reduce({[], []}, fn %Tile{loc: {x, y}}, {xs, ys} -> {[x | xs], [y | ys]} end)

    minx = Enum.min(xs)
    maxx = Enum.max(xs)
    miny = Enum.min(ys)
    maxy = Enum.max(ys)

    [{minx, miny}, {minx, maxy}, {maxx, miny}, {maxx, maxy}]
    |> Enum.map(fn loc -> Map.get(solution.tiles, loc) end)
  end

  def merge_tiles(solution) do
    {xs, ys} =
      solution.tiles
      |> Map.values
      |> Enum.reduce({[], []}, fn %Tile{loc: {x, y}}, {xs, ys} -> {[x | xs], [y | ys]} end)

    minx = Enum.min(xs)
    maxx = Enum.max(xs)
    miny = Enum.min(ys)
    maxy = Enum.max(ys)

    merged_lines =
      (miny..maxy)
      |> Enum.reduce([], fn y, lines -> lines ++ merge_row(solution, y, minx, maxx) end)

    %Tile{lines: merged_lines}
  end

  def merge_row(solution, y, minx, maxx) do
    (1..@tile_size - 2)
    |> Enum.map(fn i ->
      (minx..maxx)
      |> Enum.reduce([], fn x, line ->
        tile = Map.get(solution.tiles, {x, y})
        tile_line = Enum.at(tile.lines, i)
        line ++ Enum.drop(List.delete_at(tile_line, -1), 1)
      end)
    end)
  end
end


defmodule Solver do
  @monster_size 15

  def read_tiles(filename) do
    File.stream!(filename)
    |> Stream.chunk_by(fn x -> x == "\n" end)
    |> Stream.reject(fn x -> x == ["\n"] end)
    |> Enum.map(&Tile.from_strs/1)
  end

  def build_solution([first_tile | rest_of_tiles]) do
    %Solution{}
    |> Solution.add_tile(first_tile)
    |> Solution.add_tiles(rest_of_tiles)
  end

  def solve(filename) do
    read_tiles(filename)
    |> build_solution
    |> Solution.find_corners
    |> Enum.reduce(1, fn tile, acc -> acc * tile.id end)
  end

  def solve2(filename) do
    tile =
      read_tiles(filename)
      |> build_solution
      |> Solution.merge_tiles

    monster_count =
      tile
      |> Tile.count_sea_monsters

    IO.puts("#{monster_count} monsters found")
    Tile.count_hashes(tile) - (@monster_size * monster_count)
  end
end


# 20899048083289
:timer.tc(Solver, :solve, ["full-test.txt"]) |> inspect |> IO.puts

# {3153246, 29584525501199}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# {3222322, 1665}
:timer.tc(Solver, :solve2, ["input.txt"]) |> inspect |> IO.puts
