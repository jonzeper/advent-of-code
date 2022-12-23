defmodule Solver do
    def answer_set(answers) do
        answers
        |> Enum.map(&String.graphemes/1)
        |> Enum.reduce(MapSet.new(), &answer_set/2)
    end

    def answer_set(answers, answer_set) do
        MapSet.union(answer_set, MapSet.new(answers))
    end

    def answer_set2(answers) do
        answers
        |> Enum.map(&String.graphemes/1)
        |> Enum.reduce_while(nil, &answer_set2/2)
    end

    def answer_set2(answers, answer_set) when answer_set == nil do
        {:cont, MapSet.new(answers)}
    end

    def answer_set2(answers, answer_set) do
        new_set = MapSet.intersection(answer_set, MapSet.new(answers))
        if MapSet.size(new_set) == 0 do
            {:halt, new_set}
        else
            {:cont, new_set}
        end
    end

    def get_responses(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.chunk_by(fn line -> line != "" end)
        |> Stream.filter(fn line -> line != [""] end)
    end

    def solve(filename) do
        get_responses(filename)
        |> Stream.map(&answer_set/1)
        |> Stream.map(&MapSet.size/1)
        |> Enum.sum
    end

    def solve2(filename) do
        get_responses(filename)
        |> Stream.map(&answer_set2/1)
        |> Stream.map(&MapSet.size/1)
        |> Enum.sum
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 11
Solver.solve("input.txt") |> inspect |> IO.puts # 6549

Solver.solve2("test.txt") |> inspect |> IO.puts # 6
Solver.solve2("input.txt") |> inspect |> IO.puts # 6
