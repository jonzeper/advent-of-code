defmodule Solver do
  @operators ~w(+ - * /)
  @debug false

  def do_a_math("+", x, y), do: x + y
  def do_a_math("-", x, y), do: x - y
  def do_a_math("*", x, y), do: x * y
  def do_a_math("/", x, y), do: div(x, y)

  def evaluate(eq) do
    evaluate(eq, [], 0, "+")
  end
  def evaluate([], _, final_value, _), do: final_value
  def evaluate([x | rest], buffer, current, op) when is_number(x) do
    next_val = do_a_math(op, current, x)
    evaluate(rest, buffer, next_val, nil)
  end
  def evaluate([x | rest], buffer, current, _op) when x in @operators do
    evaluate(rest, buffer, current, x)
  end
  def evaluate(["(" | rest], buffer, current, op) do
    evaluate(rest, [{current, op} | buffer], 0, "+")
  end
  def evaluate([")" | rest], [{last_val, last_op} | buffer], current, _op) do
    next_val = do_a_math(last_op, last_val, current)
    evaluate(rest, buffer, next_val, nil)
  end

  def tokenize(eq_str, buffer \\ 0, tokens \\ [])
  def tokenize("", buffer, tokens) do
    tokens = if buffer > 0, do: [buffer | tokens], else: tokens
    tokens |> Enum.reverse |> Enum.reject(fn x -> x == " " end)
  end
  def tokenize(eq_str, buffer, tokens) do
    next_g = String.next_grapheme(eq_str)
    {c, rem_str} = next_g
    if String.match?(c, ~r/\d/) do
      tokenize(rem_str, buffer * 10 + String.to_integer(c), tokens)
    else
      next_tokens = if buffer > 0, do: [c | [buffer | tokens]], else: [c | tokens]
      tokenize(rem_str, 0, next_tokens)
    end
  end

  def evaluate_str(eq_str) do
    eq_str |> tokenize |> evaluate
  end

  def evaluate_str2(eq_str) do
    eq_str |> tokenize |> reduce_parens |> evaluate2
  end

  def evaluate2(eq) do
    if @debug, do: IO.puts("  -- evaluate2 --")
    if @debug, do: IO.puts("    eq: #{inspect eq}")
    eq |> addition_pass |> evaluate
  end

  def solve(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&evaluate_str/1)
    |> Enum.sum
  end

  def solve2(filename) do
    File.stream!(filename)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&evaluate_str2/1)
    |> Enum.sum
  end

  def addition_pass(eq), do: addition_pass(eq, [])
  def addition_pass([], updated), do: end_addition_pass(updated)
  def addition_pass([x | []], updated), do: end_addition_pass(updated ++ [x])
  def addition_pass([x | [y | []]], updated), do: end_addition_pass(updated ++ [x, y])
  def addition_pass([x | [y | [z | eq]]], updated) when is_number(x) and y == "+" and is_number(z) do
    addition_pass(eq, updated ++ [x + z])
  end
  def addition_pass([x | [y | [z | eq]]], updated) do
    addition_pass([y | [z | eq]], updated ++ [x])
  end
  def end_addition_pass(eq) do
    if @debug, do: IO.puts "--- end_addition_pass ---"
    if @debug, do: IO.puts "    eq: #{inspect eq}"
    # eq
    if Enum.find_index(eq, fn x -> x == "+" end), do: addition_pass(eq), else: eq
  end

  def reduce_parens(eq) do
    if @debug, do: IO.puts "-- reduce parens -- "
    if @debug, do: IO.puts "  eq: #{inspect eq}"
    i_first_paren = Enum.find_index(eq, fn x -> x == "(" end)
    if @debug, do: IO.puts "  i_first_paren: #{i_first_paren}"
    if i_first_paren == nil do
      if @debug, do: IO.puts("  no parens found")
      eq
    else
      i_next_paren = Enum.find_index(Enum.drop(eq, i_first_paren + 1), fn x -> x == "(" end)
      if @debug, do: IO.puts "  i_next_paren: #{inspect i_next_paren}"
      i_close_paren = Enum.find_index(Enum.drop(eq, i_first_paren + 1), fn x -> x == ")" end)
      if @debug, do: IO.puts "  i_close_paren: #{inspect i_close_paren}"
      if i_next_paren == nil or i_next_paren > i_close_paren do
        if @debug, do: IO.puts("  reducing...")
        sub = Enum.slice(eq, (i_first_paren + 1..i_close_paren + i_first_paren ))
        if @debug, do: IO.puts("    sub: #{inspect sub}")
        reduced_val = evaluate2(Enum.slice(eq, (i_first_paren + 1..i_close_paren + i_first_paren)))
        if @debug, do: IO.puts("    reduced_to: #{reduced_val}")
        (Enum.take(eq, i_first_paren) ++ [reduced_val] ++ Enum.drop(eq, i_first_paren + i_close_paren + 2))
        |> reduce_parens
      else
        if @debug, do: IO.puts("  not innermost, checking further...")
        Enum.take(eq, i_first_paren + 1) ++ reduce_parens(Enum.drop(eq, i_first_paren + 1))
        |> reduce_parens
      end
    end
  end
end

# 26
Solver.evaluate_str("2 * 3 + (4 * 5)") |> inspect |> IO.puts

# 437
Solver.evaluate_str("5 + (8 * 3 + 9 + 3 * 4 * 3)") |> inspect |> IO.puts

# 12240
Solver.evaluate_str("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") |> inspect |> IO.puts

# 13632
Solver.evaluate_str("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") |> inspect |> IO.puts

# {38975, 464478013511}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# ----- Part Two ----- #

# 51
Solver.evaluate_str2("1 + (2 * 3) + (4 * (5 + 6))") |> inspect |> IO.puts

# 46
Solver.evaluate_str2("2 * 3 + (4 * 5)") |> inspect |> IO.puts

# 1445
Solver.evaluate_str2("5 + (8 * 3 + 9 + 3 * 4 * 3)") |> inspect |> IO.puts

# 669060
Solver.evaluate_str2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") |> inspect |> IO.puts

# 23340
Solver.evaluate_str2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") |> inspect |> IO.puts

# {38563, 85660197232452}
:timer.tc(Solver, :solve2, ["input.txt"]) |> inspect |> IO.puts
