defmodule Machine do
  defstruct state: :a, pos: 0, tape: %{}

  @instructions %{
    a: [{1, 1, :b}, {0, -1, :b}],
    b: [{1, -1, :c}, {0, 1, :e}],
    c: [{1, 1, :e}, {0, -1, :d}],
    d: [{1, -1, :a}, {1, -1, :a}],
    e: [{0, 1, :a}, {0, 1, :f}],
    f: [{1, 1, :e}, {1, 1, :a}]
  }

  def run(n_steps) do
    Enum.reduce(1..n_steps, %Machine{}, fn(i, m) ->
      step(m)
    end)
    |> checksum()
  end

  def step(m) do
    {val_to_write, movement, next_state} =
      Enum.at(@instructions[m.state], m.tape[m.pos] || 0)
    %Machine{state: next_state, pos: m.pos + movement, tape: Map.put(m.tape, m.pos, val_to_write)}
  end

  def checksum(m) do
    Enum.sum(Map.values(m.tape))
  end
end

Machine.run(12_861_455)
|> IO.inspect
