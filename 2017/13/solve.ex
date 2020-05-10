defmodule Firewall do
  defstruct scanners: %{}, time: 0, severity: 0

  def add_scanner(fw, depth, range) do
    %Firewall{fw | scanners: Map.put(fw.scanners, depth, range)}
  end

  def iterate(fw) do
    %Firewall{fw | time: fw.time + 1, severity: fw.severity + severity(fw)}
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

  def severity(fw) do
    if scanner_pos(fw.scanners, fw.time, fw.time) === 0 do
      IO.puts "Caught at #{fw.time}, adding: #{fw.time * fw.scanners[fw.time]}"
      fw.time * fw.scanners[fw.time]
    else
      0
    end
  end
end

defmodule Solver do
  def solve do
    fw =
      File.stream!("input")
      |> Enum.reduce(%Firewall{time: 0}, &add_line/2)

    fw = Enum.reduce(0..92, fw, fn(_, fw) -> Firewall.iterate(fw) end)

    IO.inspect(fw.severity)
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

