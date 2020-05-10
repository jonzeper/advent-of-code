defmodule Firewall do
  defstruct scanners: %{}, pos: 0, time: 0

  def add_scanner(fw, depth, range) do
    %Firewall{fw | scanners: Map.put(fw.scanners, depth, range)}
  end

  def is_caught?(fw) do
    scanner_pos(fw.scanners, fw.pos, fw.time) === 0
  end

  def gets_caught?(fw, delay) do
    Map.keys(fw.scanners)
    |> Enum.any?(fn(depth) ->
      range = fw.scanners[depth]
      rem(delay + depth, range * 2 - 2) === 0
    end)
  end

  def find_safe_delay(fw, i \\ 0) do
    if Firewall.gets_caught?(fw, i) do
      find_safe_delay(fw, i + 1)
    else
      i
    end
  end

  defp scanner_pos(scanners, depth, time) do
    if Map.has_key?(scanners, depth) do
      range = scanners[depth]
      case range do
        1 -> 0
        2 -> rem(time, 2)
        _ ->
          Stream.cycle(Enum.to_list(0..range-1) ++ Enum.to_list(range-2..1))
          |> Enum.at(time)
      end
    else
      -1
    end
  end
end

defmodule Solver do
  def solve do
    File.stream!("input")
    |> Enum.reduce(%Firewall{time: 0}, &add_line/2)
    |> Firewall.find_safe_delay()
    |> IO.inspect
  end

  def add_line(line, fw) do
    [depth, range] =
      line
      |> String.trim()
      |> String.split(": ")
      |> Enum.map(&String.to_integer/1)

    Firewall.add_scanner(fw, depth, range)
  end
end

Solver.solve


# 0: 4  0 is out, as well as any number where rem(n, 4*2-2(6)) is 0

# 1: 2  1 is out, as well as any number where rem(n+1, 2*2-2(2)) is 0
# 2: 3  1 is out, as well as any number where rem(n+2, 3*2-2(4)) is 0
# 4: 4  any number where rem(n+4, 4*2-2) is 0
# 6: 6
# 8: 5  any number wehere rem(n+8, 5) is 0
# 10: 6
