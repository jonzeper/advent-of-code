defmodule Solver do
    def seat_id(row, col), do: row * 8 + col

    def find_row_col([lohi | rest], min, max) when rest == [] do
        case lohi do
            "U" -> max
            "D" -> min
        end
    end

    def find_row_col([lohi | rest], min, max) do
        cut_size = div((max - min) + 1, 2)
        case lohi do
            "U" -> find_row_col(rest, min + cut_size, max)
            "D" -> find_row_col(rest, min, max - cut_size)
        end
    end

    def normalize_instruction(inst) when inst in ["B", "R"], do: "U"
    def normalize_instruction(inst) when inst in ["F", "L"], do: "D"

    def decode(pass) do
        chars = String.graphemes(pass) |> Enum.map(&normalize_instruction/1)
        row = find_row_col(Enum.slice(chars, 0..6), 0, 127)
        col = find_row_col(Enum.slice(chars, 7..9), 0, 7)
        seat_id(row, col)
    end

    def all_seat_ids(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&decode/1)
    end

    def solve(filename) do
        all_seat_ids(filename)
        |> Enum.max
    end

    def solve2(filename) do
        all_seat_ids(filename) |> find_missing_seat
    end

    def find_missing_seat(seat_ids) do
        seat_ids
        |> Enum.sort
        |> Enum.reduce_while(nil, &find_missing_seat/2)
    end

    def find_missing_seat(seat_id, last_seat_id) do
        if last_seat_id == seat_id - 2 do
            {:halt, seat_id - 1}
        else
            {:cont, seat_id}
        end
    end
end

Solver.decode("BFFFBBFRRR") |> inspect |> IO.puts # 567
Solver.decode("FFFBBBFRRR") |> inspect |> IO.puts # 119
Solver.decode("BBFFBBFRLL") |> inspect |> IO.puts # 820
Solver.solve("input.txt") |> IO.puts # 832
Solver.solve2("input.txt") |> IO.puts
