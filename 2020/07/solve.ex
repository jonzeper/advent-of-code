defmodule InputParser do
    def parse_rule(line) do
        [container_color, contents_spec] = String.split(line, " bags contain ")
        contents_specs =
            String.split(contents_spec, ", ")
            |> Enum.map(&parse_contents_spec/1)
        [container_color, contents_specs]
    end

    def parse_contents_spec(contents_spec) do
        Regex.run(~r/(\d+) (.*?) bag/, contents_spec, capture: :all_but_first)
    end

    def read_rules(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim_trailing(&1, ".\n"))
        |> Stream.map(&parse_rule/1)
    end
end

defmodule Solver do
    def add_contained_by_rule(rules, container_color, contained_color) do
        Map.update(rules, contained_color, MapSet.new([container_color]), fn set -> MapSet.put(set, container_color) end)
    end

    def build_rules([container_color, contents], rules) do
        contents
        |> Enum.filter(fn x -> x != nil end)
        |> Enum.map(fn [_, color] -> color end)
        |> Enum.reduce(rules, fn color, acc -> add_contained_by_rule(acc, container_color, color) end)
    end

    def get_options(rules, color) do
        options = Map.get(rules, color) || MapSet.new()
        Enum.reduce(options, options, fn c, acc -> MapSet.union(acc, get_options(rules, c)) end)
    end

    def solve(filename) do
        InputParser.read_rules(filename)
        |> Enum.reduce(Map.new(), &build_rules/2)
        |> get_options("shiny gold")
        |> MapSet.size
    end
end

defmodule Solver2 do
    def add_rule(container_color, contents, rules) do
        Map.update(rules, container_color, [contents], fn x -> x ++ [contents] end)
    end

    def build_rules([container_color, contents], rules) do
        contents
        |> Enum.filter(fn x -> x != nil end)
        |> Enum.map(fn [quantity, color] -> [String.to_integer(quantity), color] end)
        |> Enum.reduce(rules, fn contents, rules -> add_rule(container_color, contents, rules) end)
    end

    def count_bags(rules, color) do
        Enum.reduce(Map.get(rules, color) || [], 0, fn [quantity, color], count -> count + quantity + quantity * count_bags(rules, color) end)
    end

    def solve(filename) do
        InputParser.read_rules(filename)
        |> Enum.reduce(Map.new(), &build_rules/2)
        |> (&count_bags(&1, "shiny gold")).()
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 4
Solver.solve("input.txt") |> inspect |> IO.puts # 252

Solver2.solve("test2.txt") |> inspect |> IO.puts # 126
Solver2.solve("input.txt") |> inspect |> IO.puts # 35487
