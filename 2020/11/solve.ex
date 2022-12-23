defmodule SeatGrid do
    def padded_row(row) when not is_list(row), do: row
    def padded_row(row) do
        row |> List.insert_at(0, ".") |> List.insert_at(-1, ".")
    end

    def update_seat(seat_and_neighbors) do
        {seat, neighbors} = List.pop_at(seat_and_neighbors, 7)
        n_occupied = Enum.count(neighbors, fn s -> s == "#" end)
        cond do
            seat == "L" and n_occupied == 0 -> {"#", true}
            seat == "#" and n_occupied >= 4 -> {"L", true}
            true -> {seat, false}
        end
    end
    def update_seat_reduce(seat_and_neighbors, {updated_seats, changed}) do
        {updated_seat, seat_changed} = update_seat(seat_and_neighbors)
        {List.insert_at(updated_seats, -1, updated_seat), changed || seat_changed}
    end

    def update_row(seats_and_neighbors) do
        Enum.reduce(seats_and_neighbors, {[], false}, &update_seat_reduce/2)
    end

    def run_row(a, prev_row \\ Stream.cycle(["."]), updated_rows \\ [], changed \\ false)
    def run_row(a, _, updated_rows, changed) when a == [], do: {updated_rows, changed}

    def run_row([row | rest], prev_row, updated_rows, changed) do
        next_row = if rest == [], do: Stream.cycle(["."]), else: List.first(rest)
        check_rows = [
            Stream.chunk_every(padded_row(prev_row), 3, 1),
            Stream.chunk_every(padded_row(next_row), 3, 1),
            Stream.chunk_every(padded_row(row), 3, 1)
        ]
        {updated_row, row_changed} =
            Enum.zip(check_rows)
            |> Enum.map(&Tuple.to_list/1)
            |> Enum.map(&List.flatten/1)
            |> update_row

        run_row(rest, row, updated_rows ++ [List.delete_at(updated_row, -1)], changed || row_changed)
    end

    def run(rows) do
        {updated_rows, changed} = run_row(rows)
        if changed, do: run(updated_rows), else: updated_rows
    end

    def count_occupied_seats(rows) do
        rows
        |> Enum.map(fn row -> Enum.count(row, fn c -> c == "#" end) end)
        |> Enum.sum
    end
end

defmodule Solver do
    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.map(&String.graphemes/1)
        |> SeatGrid.run
        |> SeatGrid.count_occupied_seats
    end
end

defmodule Solver2 do
    def count_visible_neighbors(rows, row_i, seat_i) do
        -1..1
        |> Enum.map(fn dir_y ->
            -1..1
            |> Enum.count(fn dir_x -> search_visible_neighbors(rows, row_i, seat_i, dir_y, dir_x) end)
        end)
        |> Enum.sum
    end

    def get_row(_, row_i) when row_i < 0, do: []
    def get_row(rows, row_i), do: Enum.at(rows, row_i, [])
    def get_seat(_, seat_i) when seat_i < 0, do: nil
    def get_seat(row, seat_i), do: Enum.at(row, seat_i)

    def search_visible_neighbors(_, _, _, y, x) when y == 0 and x == 0, do: false
    def search_visible_neighbors(rows, row_i, seat_i, dir_y, dir_x) do
        # IO.puts "Searching from #{row_i},#{seat_i} -> #{dir_y},#{dir_x}"
        new_y = row_i + dir_y
        new_x = seat_i + dir_x
        row = get_row(rows, new_y)
        seat = get_seat(row, new_x)
        # IO.gets("Found: #{seat}")
        case seat do
            nil -> false
            "#" -> true
            "L" -> false
            _ -> search_visible_neighbors(rows, new_y, new_x, dir_y, dir_x)
        end
    end

    def update_seat(rows, row_i, seat_i, seat) do
        IO.write("update_seat #{row_i}, #{seat_i}\r")
        visible_neighbors = count_visible_neighbors(rows, row_i, seat_i)
        cond do
            seat == "L" and visible_neighbors == 0 -> {"#", true}
            seat == "#" and visible_neighbors >= 5 -> {"L", true}
            true -> {seat, false}
        end
    end

    def update_seat_reduce(rows, row_i, {seat, seat_i}, {updated_seats, prev_changed}) do
        {updated_seat, changed} = update_seat(rows, row_i, seat_i, seat)
        {List.insert_at(updated_seats, -1, updated_seat), changed || prev_changed}
    end

    def update_row_reduce(rows, {row, row_i}, {updated_rows, prev_changed}) do
        {updated_row, changed} =
            row
            |> Enum.with_index
            |> Enum.reduce({[], false}, fn seat, acc -> update_seat_reduce(rows, row_i, seat, acc) end)
        {List.insert_at(updated_rows, -1, updated_row), changed || prev_changed}
    end

    def run_once(rows) do
        IO.puts "-------------------------"
        Enum.each(rows, fn row -> IO.puts(Enum.join(row)) end)
        IO.puts "-------------------------"
        {updated_rows, changed} =
            rows
            |> Enum.with_index
            |> Enum.reduce({[], false}, fn row, acc -> update_row_reduce(rows, row, acc) end)
        {updated_rows, changed}
    end

    def run(rows) do
        {updated_rows, changed} = run_once(rows)
        if changed, do: run(updated_rows), else: updated_rows
    end

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Enum.map(&String.graphemes/1)
        |> run
        |> SeatGrid.count_occupied_seats
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 37
# Solver.solve("input.txt") |> inspect |> IO.puts # 2275

Solver2.solve("test.txt") |> inspect |> IO.puts # 26
Solver2.solve("input.txt") |> inspect |> IO.puts # 2121


