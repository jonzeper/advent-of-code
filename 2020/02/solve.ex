defmodule Password do
    defstruct [:min_count, :max_count, :letter, :password]

    def is_valid(password) do
        count = String.graphemes(password.password)
        |> Enum.count(fn c -> c == password.letter end)
        count >= password.min_count && count <= password.max_count
    end

    def is_valid2(password) do
        c1 = String.at(password.password, password.min_count - 1)
        c2 = String.at(password.password, password.max_count - 1)
        (c1 == password.letter or c2 == password.letter) and not (c1 == password.letter and c2 == password.letter)
    end
end

defmodule Solver do
    def parse_line(line) do
        [rule, password] = String.split(line, ":")
        [counts, letter] = String.split(rule, " ")
        [min_count, max_count] = String.split(counts, "-") |> Enum.map(&String.to_integer/1)
        %Password{
            min_count: min_count,
            max_count: max_count,
            letter: letter,
            password: String.trim(password)
        }
    end

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&parse_line/1)
        |> Enum.count(&Password.is_valid/1)
    end

    def solve2(filename) do
        File.stream!(filename)
        |> Stream.map(&parse_line/1)
        |> Enum.count(&Password.is_valid2/1)
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 2
Solver.solve("input.txt") |> inspect |> IO.puts # 625

Solver.solve2("test.txt") |> inspect |> IO.puts # 1
Solver.solve2("input.txt") |> inspect |> IO.puts # 391
