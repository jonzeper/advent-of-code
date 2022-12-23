defmodule Tracker do
  defstruct [history: %{}, last: nil, turn: 0]

  def add(tracker, i) do
    next_history = if tracker.last, do: Map.put(tracker.history, tracker.last, tracker.turn), else: tracker.history
    %Tracker{history: next_history, last: i, turn: tracker.turn + 1}
  end

  def next(tracker) do
    last_repeat = Map.get(tracker.history, tracker.last)
    next = if last_repeat, do: tracker.turn - last_repeat, else: 0
    next
  end

  def last(tracker) do
    tracker.last
  end
end

defmodule Solver do
  def solve(input, n \\ 2020) do
    ints =
      input
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    tracker =
      ints
      |> Enum.reduce(%Tracker{}, fn i, t -> t |> Tracker.add(i) end)

    input_length = Enum.count(ints)
    (1..(n - input_length))
    |> Enum.reduce(tracker, fn _, t -> t |> Tracker.add(Tracker.next(t)) end)
    |> Tracker.last
  end
end

# 436
Solver.solve("0,3,6") |> inspect |> IO.puts

# 1
Solver.solve("1,3,2") |> inspect |> IO.puts

# 10
Solver.solve("2,1,3") |> inspect |> IO.puts

# 27
Solver.solve("1,2,3") |> inspect |> IO.puts

# 78
Solver.solve("2,3,1") |> inspect |> IO.puts

# 438
Solver.solve("3,2,1") |> inspect |> IO.puts

# 1836
Solver.solve("3,1,2") |> inspect |> IO.puts

# 441
:timer.tc(Solver, :solve, ["1,0,18,10,19,6"]) |> inspect |> IO.puts

# Solver.solve("0,3,6", 30000000) |> inspect |> IO.puts

# TODO: There's probably a faster way to do this...
# {36599423, 10613991}
:timer.tc(Solver, :solve, ["1,0,18,10,19,6", 30000000]) |> inspect |> IO.puts
