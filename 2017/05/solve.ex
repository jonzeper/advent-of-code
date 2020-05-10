defmodule Solver do
  defstruct current: 0, jumps_made: 0, instructions: {}

  def jump(s) do
    jump_size = Enum.at(s.instructions, s.current)
    new_position = jump_size + s.current
    if rem(s.jumps_made, 10000) === 0 do
      IO.puts "#{s.jumps_made}: #{new_position}"
    end
    if new_position < 0 || new_position >= length(s.instructions) do
      s.jumps_made + 1
    else
      # modifier = 1 # First version of puzzle
      modifier = if jump_size > 2, do: -1, else: 1
      new_instructions = List.update_at(s.instructions, s.current, fn(i) -> i + modifier end)
      new_solver = %Solver{current: new_position, jumps_made: s.jumps_made + 1, instructions: new_instructions}
      jump(new_solver)
    end
  end

  def solve do
    instructions =
      File.stream!("input")
      |> Enum.map(fn(s) -> s |> String.trim() |> String.to_integer() end)
    solver = %Solver{instructions: instructions}
    jump(solver)
  end
end

IO.inspect Solver.solve


# 13 824 104 after a long time
