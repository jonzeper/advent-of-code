defmodule HexGrid do
  defstruct pos: {0, 0}, max_steps: 0

  def move(hg, dir) do
    {x, y} = hg.pos
    newpos = case dir do
      "n" -> {x, y+1}
      "ne" -> {x+1, y}
      "se" -> {x+1, y-1}
      "s" -> {x, y-1}
      "sw" -> {x-1, y}
      "nw" -> {x-1, y+1}
    end
    max_steps = max(steps_to_home(newpos), hg.max_steps)
    %HexGrid{hg | pos: newpos, max_steps: max_steps}
  end

  defp steps_to_home({x, y} = _pos) do
    max(abs(x), abs(y))
  end
end


defmodule Solver do
  def solve do
    File.stream!("input")
    |> Enum.to_list()
    |> List.first()
    |> String.trim()
    |> String.split(",")
    |> Enum.reduce(%HexGrid{}, fn(dir, hg) -> HexGrid.move(hg, dir) end)
    |> IO.inspect
  end
end


Solver.solve
