defmodule Solver do
  def parse_rule(rule_str) do
    [label, ranges_str] =
      rule_str
      |> String.trim
      |> String.split(": ")

    ranges =
      ranges_str
      |> String.split(" or ")
      |> Enum.map(fn range_str -> range_str |> String.split("-") |> Enum.map(&String.to_integer/1) end)

    {label, ranges}
  end

  def parse_rules(rules_txt) do
    rules_txt
    |> Enum.reduce([], fn rule_str, acc -> [parse_rule(rule_str) | acc] end)
  end

  def is_invalid(rules, value) do
    rules
    |> Enum.all?(fn {_, ranges} ->
      Enum.all?(ranges, fn [min, max] ->
        value < min or value > max
      end)
    end)
  end

  def invalid_values(rules, ticket_str) do
    ticket_str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.filter(fn value -> is_invalid(rules, value) end)
  end

  def error_rate(rules, tickets_txt) do
    tickets_txt
    |> Enum.drop(1)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn ticket_str -> invalid_values(rules, ticket_str) end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum
  end

  def solve(filename) do
    [rules_txt, _my_ticket_txt, other_tickets_txt] =
      File.stream!(filename)
      |> Stream.chunk_by(fn line -> line == "\n" end)
      |> Enum.filter(fn lines -> lines != ["\n"] end)

    rules = parse_rules(rules_txt)

    error_rate(rules, other_tickets_txt)
  end

  def solve2(filename) do
    [rules_txt, my_ticket_txt, other_tickets_txt] =
      File.stream!(filename)
      |> Stream.chunk_by(fn line -> line == "\n" end)
      |> Enum.filter(fn lines -> lines != ["\n"] end)

    rules = parse_rules(rules_txt)

    values_by_pos =
      other_tickets_txt
      |> Enum.drop(1)
      |> Enum.map(&String.trim/1)
      |> Enum.filter(fn s -> invalid_values(rules, s) |> Enum.count == 0 end)
      |> Enum.map(fn s -> s |> String.split(",") |> Enum.map(&String.to_integer/1) end)
      |> transpose_tickets

    initial_possible_rules =
      Enum.map((1..Enum.count(values_by_pos)), fn _ -> rules end)

    determine_labels(values_by_pos, initial_possible_rules)
    |> final_answer(my_ticket_txt)
  end

  def final_answer(labels, my_ticket_txt) do
    my_ticket_txt
    |> Enum.drop(1)
    |> List.first
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.zip(labels)
    |> Enum.reduce(1, fn {v, l}, acc -> if String.starts_with?(l, "departure"), do: acc * v, else: acc end)
    # Enum.reduce(1, )
  end

  # Change from a list of tickets to a list of values at each position
  def transpose_tickets(tickets, values_by_pos \\ [])
  def transpose_tickets([[] | _], values_by_pos), do: values_by_pos
  def transpose_tickets(tickets, values_by_pos) do
    {values, next_tickets} =
      tickets
      |> Enum.reduce({[], []}, fn t, {vs, ots} -> [v | o_t] = t; {[v | vs], [o_t | ots]} end)
    transpose_tickets(next_tickets, List.insert_at(values_by_pos, -1, values))
  end

  def determine_labels(values_by_pos, possible_rules) do
    next_possible_rules =
      reduce_possible_rules(possible_rules, values_by_pos, [])
      |> remove_determined_labels
    if Enum.all?(next_possible_rules, fn rs -> Enum.count(rs) == 1 end) do
      Enum.map(next_possible_rules, fn [{label, _}] -> label end)
    else
      determine_labels(values_by_pos, next_possible_rules)
    end
  end

  def reduce_possible_rules([], _, updated), do: updated
  def reduce_possible_rules([rules_at_pos | rem_rules], [values | rem_values], updated) do
    reduced_possibilities =
      rules_at_pos
      |> Enum.filter(fn rule -> Enum.all?(values, fn v -> value_matches_rule?(v, rule) end) end)

    reduce_possible_rules(rem_rules, rem_values, List.insert_at(updated, -1, reduced_possibilities))
  end

  def remove_determined_labels(possible_rules) do
    determined_labels =
      possible_rules
      |> Enum.filter(fn rs -> Enum.count(rs) == 1 end)
      |> Enum.map(fn [{label, _}] -> label end)

    possible_rules
    |> Enum.map(fn rs ->
      if Enum.count(rs) == 1 do
        rs
      else
        Enum.reject(rs, fn {label, _} -> Enum.member?(determined_labels, label) end)
      end
    end)
  end

  def value_matches_rule?(value, {_label, ranges}) do
    ranges
    |> Enum.any?(fn [min, max] -> value >= min and value <= max end)
  end
end

# 71
Solver.solve("test.txt") |> inspect |> IO.puts

# {3774, 19070}
:timer.tc(Solver, :solve, ["input.txt"]) |> inspect |> IO.puts

# {61228, 161926544831}
:timer.tc(Solver, :solve2, ["input.txt"]) |> inspect |> IO.puts
