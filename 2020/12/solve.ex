defmodule Solver do
    @starting_position {0, 0, 90}

    def parse_instruction(str) do
        [action, n] = Regex.run(~r/(.)(\d*)/, str, capture: :all_but_first)
        {action, String.to_integer(n)}
    end

    def execute_instruction({action, n}, {x, y, dir} = pos) do
        case action do
            "N" -> {x, y - n, dir}
            "S" -> {x, y + n, dir}
            "E" -> {x + n, y, dir}
            "W" -> {x - n, y, dir}
            "L" -> {x, y, turn(dir, action, n)}
            "R" -> {x, y, turn(dir, action, n)}
            "F" -> forward(pos, n)
        end
    end

    def turn(dir, action, n) do
        new_dir = if action == "L", do: dir - n, else: dir + n
        cond do
            new_dir >= 360 -> new_dir - 360
            new_dir < 0 -> new_dir + 360
            true -> new_dir
        end
    end

    def forward({_x, _y, dir} = pos, n) do
        case dir do
            0 -> execute_instruction({"N", n}, pos)
            90 -> execute_instruction({"E", n}, pos)
            180 -> execute_instruction({"S", n}, pos)
            270 -> execute_instruction({"W", n}, pos)
        end
    end

    def final_answer({x, y, _dir}), do: abs(x) + abs(y)

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&parse_instruction/1)
        |> Enum.reduce(@starting_position, &execute_instruction/2)
        |> final_answer
    end
end

defmodule Solver2 do
    @starting_position {0, 0}
    @waypt_starting_position {10, -1}

    def parse_instruction(str) do
        [action, n] = Regex.run(~r/(.)(\d*)/, str, capture: :all_but_first)
        {action, String.to_integer(n)}
    end

    def execute_instruction({action, n}, {ship_pos, {w_x, w_y} = waypt_pos}) do
        case action do
            "N" -> {ship_pos, {w_x, w_y - n}}
            "S" -> {ship_pos, {w_x, w_y + n}}
            "E" -> {ship_pos, {w_x + n, w_y}}
            "W" -> {ship_pos, {w_x - n, w_y}}
            "L" -> {ship_pos, rotate(action, n, waypt_pos)}
            "R" -> {ship_pos, rotate(action, n, waypt_pos)}
            "F" -> forward(ship_pos, waypt_pos, n)
        end
    end

    def rotate(dir, n, {x, y}) do
        degrees = if dir == "L", do: 360 - n, else: n
        case degrees do
            90 -> {-y, x}
            180 -> {-x, -y}
            270 -> {y, -x}
        end
    end

    def forward({x, y}, {w_x, w_y} = waypt_pos, n) do
        {{x + w_x * n, y + w_y * n}, waypt_pos}
    end

    def final_answer({{x, y}, _waypt_pos}), do: abs(x) + abs(y)

    def solve(filename) do
        File.stream!(filename)
        |> Stream.map(&String.trim/1)
        |> Stream.map(&parse_instruction/1)
        |> Enum.reduce({@starting_position, @waypt_starting_position}, &execute_instruction/2)
        |> final_answer
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 25
Solver.solve("input.txt") |> inspect |> IO.puts # 439

Solver2.solve("test.txt") |> inspect |> IO.puts # 286
Solver2.solve("input.txt") |> inspect |> IO.puts # 12385
