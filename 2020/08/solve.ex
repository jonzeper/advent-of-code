defmodule InputParser do
    def parse_instruction({line, i}) do
        [op, n] = String.trim(line) |> String.split(" ")
        {i, op, String.to_integer(n)}
    end

    def parse_instructions(filename) do
        File.stream!(filename)
        |> Stream.with_index
        |> Enum.map(&parse_instruction/1)
    end
end

defmodule Solver do
    def check_and_run_step(steps, i, {acc, past_steps}) do
        if MapSet.member?(past_steps, i) do
            acc
        else
            run_step(steps, i, {acc, past_steps})
        end
    end

    def run_step(steps, i, {acc, past_steps}) do
        {_, op, n} = Enum.at(steps, i)
        next_past_steps = MapSet.put(past_steps, i)
        case op do
            "nop" -> check_and_run_step(steps, i + 1, {acc, next_past_steps})
            "acc" -> check_and_run_step(steps, i + 1, {acc + n, next_past_steps})
            "jmp" -> check_and_run_step(steps, i + n, {acc, next_past_steps})
        end
    end

    def solve(filename) do
        InputParser.parse_instructions(filename)
        |> check_and_run_step(0, {0, MapSet.new()})
    end
end

defmodule Solver2 do
    def run_step(steps, i, {acc, past_steps, changed}) do
        if MapSet.member?(past_steps, i) do
            nil
        else
            instruction = Enum.at(steps, i)
            if instruction == nil do
                acc
            else
                {_, op, n} = instruction
                next_past_steps = MapSet.put(past_steps, i)
                case op do
                    "acc" -> run_step(steps, i + 1, {acc + n, next_past_steps, changed})
                    "jmp" ->
                        if changed do
                            run_step(steps, i + n, {acc, next_past_steps, false})
                        else
                            run_step(steps, i + n, {acc, next_past_steps, false})
                            || run_step(steps, i + 1, {acc, next_past_steps, true})
                        end
                    "nop" ->
                        if changed do
                            run_step(steps, i + 1, {acc, next_past_steps, false})
                        else
                            run_step(steps, i + 1, {acc, next_past_steps, false})
                            || run_step(steps, i + n, {acc, next_past_steps, true})
                        end
                end
            end
        end
    end

    def solve(filename) do
        InputParser.parse_instructions(filename)
        |> run_step(0, {0, MapSet.new(), false})
    end
end

Solver.solve("test.txt") |> inspect |> IO.puts # 5
Solver.solve("input.txt") |> inspect |> IO.puts # 1949

Solver2.solve("test.txt") |> inspect |> IO.puts # 8
Solver2.solve("input.txt") |> inspect |> IO.puts # 2092
