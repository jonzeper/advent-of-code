defmodule HexGrid do
  defstruct pos: {0, 0}, steps: 0

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
    %HexGrid{hg | pos: newpos, steps: hg.steps + 1}
  end

  def reset_steps(hg) do
    %HexGrid{hg | steps: 0}
  end

  def move_home(hg) do
    {x, y} = hg.pos
    cond do
      x == 0 && y == 0 -> hg
      x == 0 && y > 0 -> HexGrid.move(hg, "s") |> HexGrid.move_home()
      x == 0 && y < 0 -> HexGrid.move(hg, "n") |> HexGrid.move_home()
      x > 0 && y == 0 -> HexGrid.move(hg, "sw") |> HexGrid.move_home()
      x < 0 && y == 0 -> HexGrid.move(hg, "ne") |> HexGrid.move_home()
      x > 0 && y > 0 -> HexGrid.move(hg, "s") |> HexGrid.move_home()
      x > 0 && y < 0 -> HexGrid.move(hg, "nw") |> HexGrid.move_home()
      x < 0 && y < 0 -> HexGrid.move(hg, "n") |> HexGrid.move_home()
      x < 0 && y > 0 -> HexGrid.move(hg, "se") |> HexGrid.move_home()
    end
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
    |> HexGrid.reset_steps()
    |> HexGrid.move_home()
    |> IO.inspect
  end
end


Solver.solve
