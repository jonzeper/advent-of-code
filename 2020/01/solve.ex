# Assumption: All n are positive integers

defmodule Solver do
    @target_sum 2020

    def find_match(value, candidates) when value > @target_sum, do: {:cont, candidates}

    def find_match(value, candidates) do
        match = Enum.find(candidates, fn x -> x + value == @target_sum end)
        cond do
            match -> {:halt, value * match}
            true -> {:cont, [value | candidates]}
        end
    end

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&String.to_integer/1)
        |> Enum.reduce_while([], &find_match/2)
    end
end

defmodule Solver2 do
    @target_sum 2020
    @target_depth 3

    def find_match(value, acc) when value > @target_sum, do: {:cont, acc}

    def find_match(value, %{values: values, depth: depth, candidates: candidates} = acc) do
        current_sum = Enum.reduce(values, 0, &+/2)
        if depth == @target_depth do
            match = Enum.find(candidates, fn x -> x + current_sum == @target_sum end)
            cond do
                match -> {:halt, Enum.reduce([match | values], &*/2)}
                true -> {:cont, %{acc | candidates: [value | candidates]}}
            end
        else
            next_values = [value | values]
            next_depth = depth + 1
            next_acc =%{values: next_values, depth: next_depth, candidates: []}
            match = candidates
            |> Enum.reduce_while(next_acc, &find_match/2)
            cond do
                is_integer(match) -> {:halt, match}
                true -> {:cont, %{acc | candidates: [value | candidates]}}
            end
        end
    end

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&String.to_integer/1)
        |> Enum.reduce_while(%{values: [], depth: 1, candidates: []}, &find_match/2)
    end
end

Solver.solve("test.txt") |> IO.puts # 514579
Solver.solve("input.txt") |> IO.puts # 800139
Solver2.solve("test.txt") |> inspect |> IO.puts # 241861950
Solver2.solve("input.txt") |> inspect |> IO.puts # 59885340
