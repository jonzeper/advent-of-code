defmodule Solver do
    def find_match([_ | rest], _) when rest == [], do: false
    def find_match([candidate | rest], target) do
        Enum.any?(rest, fn x -> x + candidate == target end)
        || find_match(rest, target)
    end

    def check_chunk(chunk, width) do
        target = List.last(chunk)
        find_match(Enum.slice(chunk, 0..width-1), target)
    end

    def solve(filename, width) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&String.to_integer/1)
        |> Stream.chunk_every(width + 1, 1)
        |> Enum.find(fn chunk -> !check_chunk(chunk, width) end)
        |> Enum.to_list
        |> List.last
    end
end

defmodule Solver2 do
    def test_add(x, {acc, sum, target}) do
        new_sum = sum + x
        cond do
            new_sum == target -> {:halt, acc ++ [x]}
            new_sum > target -> {:halt, nil}
            true -> {:cont, {acc ++ [x], new_sum, target}}
        end
    end

    def find_range_adding_to([head | tail], target) do
        Enum.reduce_while(tail, {[head], head, target}, &test_add/2)
        || find_range_adding_to(tail, target)
    end

    def range_to_answer(range) do
        [first | rest] = Enum.sort(range)
        first + List.last(rest)
    end

    def solve(filename, target) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.map(&String.to_integer/1)
        |> find_range_adding_to(target)
        |> range_to_answer
    end
end


# Solver.solve("test.txt", 5) |> inspect |> IO.puts # 127
# Solver.solve("input.txt", 25) |> inspect |> IO.puts # 552655238

Solver2.solve("test.txt", 127) |> inspect |> IO.puts # 62
Solver2.solve("input.txt", 552655238) |> inspect |> IO.puts
