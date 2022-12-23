defmodule Solver do
  def parse_rule(rule_str, rules_map) do
    [rule_number, rule_str] = String.split(rule_str, ": ")
    rule_options =
      rule_str
      |> String.trim
      |> String.split(" | ")
      |> Enum.map(fn x ->
        String.split(x, " ")
        |> Enum.map(fn x ->
          case x do
            "\"a\"" -> "a"
            "\"b\"" -> "b"
            i -> String.to_integer(i)
          end
        end)
      end)
    Map.put(rules_map, String.to_integer(rule_number), rule_options)
  end

  def reduce_simple_string_rules(rules) do
    # Find rules with only one option which is a string
    only_string_rules =
      rules
      |> Enum.reduce(%{}, fn {k, options}, acc ->
        if Enum.count(options) == 1 and not is_number(List.first(List.first(options))) do
          Map.put(acc, k, List.first(List.first(options)))
        else
          acc
        end
      end)

    # Find rules which only contain rules which are only strings, and replace with the strings
    new_rules =
      rules
      |> Enum.reduce(%{}, fn {k, options}, acc ->
        next_options =
          options
          |> Enum.map(fn seq ->
            next_seq =
              Enum.map(seq, fn x -> Map.get(only_string_rules, x, x) end)
            if Enum.all?(next_seq, fn x -> not is_number(x) end) do
              [Enum.join(next_seq)]
            else
              next_seq
            end
          end)
        if Enum.member?(Map.keys(only_string_rules), k) do
          acc
        else
          Map.put(acc, k, next_options)
        end
      end)

    if new_rules == rules do
      new_rules
    else
      reduce_simple_string_rules(new_rules)
    end
  end

  def reduce_complex_string_rules(rules) do
    # Find rules where all options are just a string
    only_string_rules =
      rules
      |> Enum.reduce(%{}, fn {k, seq_options}, acc ->
        if Enum.all?(seq_options, fn seq -> Enum.count(seq) == 1 and not is_number(List.first(seq)) end) do
          Map.put(acc, k, seq_options)
        else
          acc
        end
      end)

    # Get rid of above rules by inserting the options directly where referenced
    new_rules =
      rules
      |> Enum.reduce(%{}, fn {k, seq_options}, acc ->
        if Enum.member?(Map.keys(only_string_rules), k) do
          acc
        else
          next_options = replace_string_variants(seq_options, only_string_rules)
          Map.put(acc, k, next_options)
        end
      end)

    if Enum.count(new_rules) > 1 do
      reduce_complex_string_rules(new_rules)
    else
      new_rules
    end
  end

  def replace_string_variants(seq_options, rules) do
    seq_options
    |> Enum.reduce([], fn seq, acc ->
      new_seq_opts =
        replace_string_variants_seq([], seq, rules)
        |> List.flatten
        |> Enum.chunk_every(Enum.count(seq))
        |> Enum.map(fn seq -> if Enum.any?(seq, fn x -> is_number(x) end), do: seq, else: [Enum.join(seq)] end)
      acc ++ new_seq_opts
    end)
  end

  def replace_string_variants_seq(base, [], rules), do: base
  def replace_string_variants_seq(base, [seq_step | rem_steps], rules) do
    string_variants = Map.get(rules, seq_step)
    if string_variants do
      Enum.map(string_variants, fn v ->
        replace_string_variants_seq(base ++ [v], rem_steps, rules)
      end)
    else
      replace_string_variants_seq(base ++ [seq_step], rem_steps, rules)
    end
  end

  def reduce_rules(rules) do
    reduce_complex_string_rules(rules)
  end

  def inspect_rules(rules) do
    rules
    |> Map.keys
    |> Enum.sort
    |> Enum.each(fn k -> "#{k}: #{Map.get(rules, k) |> inspect(charlists: :as_lists)}" |> IO.puts end)
    IO.puts "^--- #{Enum.count(rules)} rules"
    IO.puts ""
    rules
  end

  def solve(filename) do
    [rule_strs, test_strs] =
      File.stream!(filename)
      |> Stream.chunk_by(fn x -> x == "\n" end)
      |> Enum.reject(fn x -> x == ["\n"] end)

    rules =
      rule_strs
      |> Enum.reduce(%{}, &parse_rule/2)

    valid_strs =
      rules
      |> reduce_rules
      |> Map.get(0)
      |> List.flatten

    IO.puts("#{Enum.count(valid_strs)} valid_strs found")

    test_strs
    |> Enum.map(&String.trim/1)
    |> Enum.count(fn s -> Enum.member?(valid_strs, s) end)
    |> IO.puts
    # rules
    #   |> all_possibilities(0, "")
      # |> List.flatten

    # test_strs
    # |> Enum.map(&String.trim/1)
    # |> Enum.map(&String.graphemes/1)
    # |> Enum.count(fn s -> matches_rule?(s, rules, 0) end)
  end


  # def matches_rule?(s, rules, rule_num) do
  #   options = Map.get(rules, rule_num)
  #   Enum.any?(options, fn seq ->
  #     matches_seq?(s, rules, seq)
  #   end)
  # end

  # def matches_seq?([c | rest] = s, rules, [seq_step | seq_rest]) when is_number(seq_step) do
  #   matches_rule?(s, rules, seq_rest) and
  # end
  # def matches_seq?([c | rest] = s, rules, [seq_step | seq_rest]) do # when is_char(seq_step)
  #   if c == seq_step do
  #     matches_seq?(rest, rules, seq_rest)
  #   else
  #     false
  #   end
  # end
end

# {11689867, :ok}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts
