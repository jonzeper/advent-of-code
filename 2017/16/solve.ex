defmodule Dancers do
  defstruct dancers: ~w(a b c d e f g h i j k l m n o p)

  @n_dancers 16

  def spin(d, len) do
    newd = Enum.slice(d.dancers, -len, @n_dancers) ++ Enum.slice(d.dancers, 0, @n_dancers - len)
    %Dancers{d | dancers: newd}
  end

  def exchange(d, a, b) do
    a_val = Enum.at(d.dancers, a)
    b_val = Enum.at(d.dancers, b)
    newd =
      d.dancers
      |> List.replace_at(a, b_val)
      |> List.replace_at(b, a_val)
    %Dancers{d | dancers: newd}
  end

  def partner(d, a, b) do
    a_pos = Enum.find_index(d.dancers, &(&1 === a))
    b_pos = Enum.find_index(d.dancers, &(&1 === b))
    exchange(d, a_pos, b_pos)
  end
end

defmodule Solver do
  def parse_input do
    File.stream!("input")
    |> Enum.to_list()
    |> List.first()
    |> String.trim()
    |> String.split(",")
  end

  def run_step(step, dancers) do
    case String.at(step, 0) do
      "s" ->
        spin_length = (String.slice(step, 1, 5) |> String.to_integer())
        Dancers.spin(dancers, spin_length)
      "x" ->
        [a, b] = (String.slice(step, 1, 5) |> String.split("/") |> Enum.map(&String.to_integer/1))
        Dancers.exchange(dancers, a, b)
      "p" ->
        [a, b] = (String.slice(step, 1, 5) |> String.split("/"))
        Dancers.partner(dancers, a, b)
    end
  end

  def solve do
    dancers =
      parse_input()
      |> Enum.reduce(%Dancers{}, &run_step/2)
    dancers.dancers |> Enum.join
  end

  def test do
    IO.puts "Spinning 1"
    d = Dancers.spin(%Dancers{}, 1)
    IO.puts "is now #{d.dancers}"
    IO.puts "Exchanging 1, 15"
    d = Dancers.exchange(d, 1, 15)
    IO.puts "is now #{d.dancers}"
    IO.puts "Partnering c, f"
    d = Dancers.partner(d, "c", "f")
    IO.puts "is now #{d.dancers}"
  end
end

# Solver.test
Solver.solve |> IO.inspect
