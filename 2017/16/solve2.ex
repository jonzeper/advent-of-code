defmodule Dancers do
  @original_order ~w(a b c d e f g h i j k l m n o p)
  # @original_order ~w(a b c d e)
  @n_dancers length(@original_order)

  defstruct dancers: @original_order

  def dance(d, steps) do
    Enum.reduce(steps, d, &run_step/2)
  end

  def dance(d, steps, times) do
    Enum.reduce(1..times, d, fn(i, d) ->
      if d.dancers === @original_order, do: IO.puts i
      dance(d, steps)
    end)
  end

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
end

defmodule Solver do
  def parse_input do
    File.stream!("input")
    |> Enum.to_list()
    |> List.first()
    # "s1,x3/4,pe/b"
    |> String.trim()
    |> String.split(",")
  end

  def solve do
    steps = parse_input()

    loop_size = 60
    n = div(1000000000, 60)
    # 999999960

    d = Dancers.dance(%Dancers{}, steps, 40)
    d.dancers |> Enum.join
  end
end

Solver.solve |> IO.inspect
