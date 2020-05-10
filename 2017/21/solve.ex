# This one is super messy.
# A better approach than breaking up picture into a whole new matrix of "Patterns"
# may be to scan over the chunks and build up the new picture along the way.
# I let this run a really long time to solve instead of re-writing

defmodule Pattern do
  def empty(size) do
    Enum.map(1..size, fn(_) -> [] end)
  end

  def rotate(pattern) do
    pattern
    |> Enum.reverse()
    |> Enum.reduce(empty(length(pattern)), &insert_rotated_column/2)
  end

  defp insert_rotated_column(row, pattern) do
    row
    |> Enum.with_index()
    |> Enum.reduce(pattern, fn({x, i}, pattern) ->
      List.replace_at(pattern, i, Enum.at(pattern, i) ++ [x])
    end)
  end

  def flip_vertical(pattern), do: Enum.reverse(pattern)
  def flip_horizontal(pattern), do: Enum.map(pattern, &Enum.reverse/1)
end

defmodule Rule do
  defstruct [:pattern, :output]

  def rotate(rule), do: %Rule{rule | pattern: Pattern.rotate(rule.pattern)}
  def flip_vertical(rule), do: %Rule{rule | pattern: Pattern.flip_vertical(rule.pattern)}
  def flip_horizontal(rule), do: %Rule{rule | pattern: Pattern.flip_horizontal(rule.pattern)}
end

defmodule Solver do
  @start [[0,1,0],[0,0,1],[1,1,1]]

  def solve do
    rules =
      File.stream!("input")
      |> Stream.map(&parse_rule/1)

    iterate(@start, rules, 18)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum()
    |> IO.inspect
  end

  def iterate(_p, _r, count) when count === 0, do: _p
  def iterate(picture, rules, count) do
    IO.inspect picture
    IO.puts "#{count} runs to go"
    picture =
      break_up_picture(picture)
      |> Enum.map(fn(row) ->
        Enum.map(row, fn(pattern) -> find_matching_rule(pattern, rules).output end)
      end)
      |> join_patterns()
    iterate(picture, rules, count - 1)
  end

  def break_up_picture(picture) do
    IO.puts "breaking up picture"
    case rem(length(picture), 2) do
      0 -> break_up_picture(picture, 2)
      1 -> break_up_picture(picture, 3)
    end
  end

  def join_patterns(patterns) do
    IO.puts "joining patterns"
    Enum.reduce(patterns, [], fn(row_of_patterns, picture) ->
      picture ++ join_pattern_row(row_of_patterns)
    end)
  end

  def join_pattern_row(row) do
    size = length(List.first(List.first(row)))
    Enum.reduce(0..size-1, [], fn(i, newrows) ->
      newrows ++ [Enum.reduce(row, [], fn(pattern, newrow) ->
        newrow ++ Enum.at(pattern, i)
      end)]
    end)
  end

  def break_up_picture(picture, chunk_size) do
    size = div(length(picture), chunk_size)
    rows =
      picture
      |> Enum.chunk_every(chunk_size)
    chunked =
      Enum.map(rows, fn(row) ->
        Enum.map(row, fn(x) -> Enum.chunk_every(x, chunk_size) end)
      end)
    Enum.reduce(chunked, [], fn(row, patterns) ->
      patterns ++ [zip_row(row, size, chunk_size)]
    end)
  end

  def zip_row(row, size, chunk_size) do
    Enum.reduce(0..size-1, [], fn(i, newrow) ->
      newrow ++ [Enum.reduce(0..chunk_size-1, [], fn(j, chunk) ->
        chunk ++ [Enum.at(Enum.at(row, j), i)]
      end)]
    end)
  end

  def find_matching_rule(pattern, rules) do
    Enum.find(rules, fn(rule) -> rule.pattern === pattern end)
    || Enum.find(Enum.map(rules, &Rule.flip_vertical/1), fn(rule) -> rule.pattern === pattern end)
    || Enum.find(Enum.map(rules, &Rule.flip_horizontal/1), fn(rule) -> rule.pattern === pattern end)
    || find_matching_rotated_rule(pattern, rules, 0)
  end

  def find_matching_rotated_rule(pattern, rules, rot_count) when rot_count > 2 do
    IO.puts "No matching pattern found for:"
    IO.inspect pattern
    nil
  end
  def find_matching_rotated_rule(pattern, rules, rot_count) do
    rotated_rules = Enum.map(rules, &Rule.rotate/1)
    Enum.find(rotated_rules, fn(rule) -> rule.pattern == pattern end)
    || Enum.find(Enum.map(rotated_rules, &Rule.flip_vertical/1), fn(rule) -> rule.pattern === pattern end)
    || Enum.find(Enum.map(rotated_rules, &Rule.flip_horizontal/1), fn(rule) -> rule.pattern === pattern end)
    || find_matching_rotated_rule(pattern, rotated_rules, rot_count + 1)
  end

  def parse_rule(line) do
    [pattern, output] =
      line
      |> String.trim()
      |> String.split(" => ")
      |> Enum.map(&String.split(&1, "/"))
      |> Enum.map(&Enum.map(&1, fn(s) -> s_to_is(s) end))
    %Rule{pattern: pattern, output: output}
  end

  def s_to_is(s) do
    s |> String.graphemes() |> Enum.map(fn(c) ->
      case c do
        "#" -> 1
        "." -> 0
      end
    end)
  end
end

pic = [
  ~w(a b c d e f),
  ~w(g h i j k l),
  ~w(m n o p q r),
  ~w(s t u v w x),
  ~w(y z 1 2 3 4),
  ~w(5 6 7 8 9 0)
]

# [
#   [["a", "b"], ["c", "d"], ["e", "f"]],
#   [["g", "h"], ["i", "j"], ["k", "l"]]
# ]

# [[[a b], [g h]], [[c d], [i j]], [[e f], [k l]]]


# [[["m", "n"], ["o", "p"], ["q", "r"]], [["s", "t"], ["u", "v"], ["w", "x"]]]
# [[["y", "z"], ["1", "2"], ["3", "4"]], [["5", "6"], ["7", "8"], ["9", "0"]]]

pic = [
  ~w(a b c d e f g h i),
  ~w(j k l m n o p q r),
  ~w(s t u v w x y z 0),
  ~w(a b c d e f g h i),
  ~w(j k l m n o p q r),
  ~w(s t u v w x y z 0),
  ~w(a b c d e f g h i),
  ~w(j k l m n o p q r),
  ~w(s t u v w x y z 0)
]

# [
#   [["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"]],
#   [["j", "k", "l"], ["m", "n", "o"], ["p", "q", "r"]],
#   [["s", "t", "u"], ["v", "w", "x"], ["y", "z", "0"]]
# ]
# [
#   [["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"]],
#   [["j", "k", "l"], ["m", "n", "o"], ["p", "q", "r"]],
#   [["s", "t", "u"], ["v", "w", "x"], ["y", "z", "0"]]
# ]
# [
#   [["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"]],
#   [["j", "k", "l"], ["m", "n", "o"], ["p", "q", "r"]],
#   [["s", "t", "u"], ["v", "w", "x"], ["y", "z", "0"]]
# ]

Solver.solve
|> Enum.each(&IO.inspect/1)

# p = [[1,2], [4,5]]
# p = [[1,1,1], [0,0,0], [0,0,0]]

# p
# |> IO.inspect
# |> Pattern.rotate
# |> IO.inspect
# |> Pattern.rotate
# |> IO.inspect
# |> Pattern.rotate
# |> IO.inspect
# |> Pattern.rotate
# |> IO.inspect


# Solver.solve

# ab   ca   dc    bd   ab
# cd   db   ba    ac   cd

# cd
# ba

# 111         abc
# 000         def
# 111         ghi

# 111000111   abcdefghi

# 101         gda
# 101         heb
# 101         ifc

# 101101101   gdahebifc

# 00   00
# 01   10



# abcdef   abc def
# ghijkl   ghi jkl
# mnopqr   mno pqr

# stuvwx   stu vwx
# yz1234   yz1 234
# 567890   567 890


# [[[a b],[g h]], [[c d], [i j]], [[e f],[k l]]]


# [[[[1, 0, 0, 1], [0, 0, 0, 0], [0, 0, 0, 0], [1, 0, 0, 1]]]]
# [[1, 0, 0, 1], [0, 0, 0, 0], [0, 0, 0, 0], [1, 0, 0, 1]]

# 1001
# 0000
# 0000
# 1001


# # .#./..#/###

# # ###/..#/.#.

# # .#./#../###

# # #../#.#/##.

# # ###/#../.#.

# # .##/#.#/..#

# # .#.
# # ..#
# # ###
