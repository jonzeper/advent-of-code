defmodule Solver do
  def find_best_departure([ready_time, bus_ids]) do
    bus_ids
    |> String.split(",")
    |> Enum.filter(fn x -> x != "x" end)
    |> Enum.map(&String.to_integer/1)
    |> find_best_departure(String.to_integer(ready_time))
  end

  def find_best_departure(
        [bus_id | rem_bus_ids],
        ready_time,
        {_best_bus_id, best_time} = best \\ {0, 0}
      ) do
    depart_time = depart_time(ready_time, bus_id)

    next_best =
      if depart_time < best_time or best_time == 0 do
        {bus_id, depart_time}
      else
        best
      end

    if rem_bus_ids == [] do
      Tuple.append(next_best, ready_time)
    else
      find_best_departure(rem_bus_ids, ready_time, next_best)
    end
  end

  def depart_time(ready_time, bus_id) do
    ceil(ready_time / bus_id) * bus_id
  end

  def final_answer({bus_id, depart_time, ready_time}) do
    bus_id * (depart_time - ready_time)
  end

  def solve(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.take(2)
    |> find_best_departure
    |> final_answer
  end
end

defmodule Solver2 do
  def get_bus_specs(bus_id_strs, bus_specs \\ [], desired_diff \\ 0)

  def get_bus_specs([bus_id_str | remaining], bus_specs, desired_diff) when bus_id_str == "x" do
    if remaining == [],
      do: bus_specs,
      else: get_bus_specs(remaining, bus_specs, desired_diff + 1)
  end

  def get_bus_specs([bus_id_str | remaining], bus_specs, desired_diff) do
    bus_id = String.to_integer(bus_id_str)
    next_bus_specs = List.insert_at(bus_specs, -1, {bus_id, desired_diff})

    if remaining == [],
      do: next_bus_specs,
      else: get_bus_specs(remaining, next_bus_specs, desired_diff + 1)
  end

  def best_time(depart_time, bus_id, desired_diff) do
    ceil((depart_time + desired_diff) / bus_id) * bus_id
  end

  def is_good?(depart_time, bus_id, desired_diff) do
    best_time = best_time(depart_time, bus_id, desired_diff)
    # IO.puts "depart_time: #{depart_time} best_time: #{best_time} desired_diff: #{desired_diff} #{best_time - depart_time}"
    # if best_time - depart_time == desired_diff, do: IO.puts " ^----"
    best_time - depart_time == desired_diff
  end

  def find_it(first_bus_id, first_good_time, [{next_bus_id, next_diff} | bus_specs], interval) do
    {a_time, a_n} =
      first_good_time
      |> Stream.iterate(fn depart_time -> depart_time + first_bus_id * interval end)
      |> Stream.with_index
      |> Enum.find(fn {depart_time, i} -> is_good?(depart_time, next_bus_id, next_diff) end)

    if bus_specs == [] do
      a_time
    else
      {b_time, b_n} =
        a_time + (first_bus_id * interval)
        |> Stream.iterate(fn depart_time -> depart_time + first_bus_id * interval end)
        |> Stream.with_index
        |> Enum.find(fn {depart_time, i} -> is_good?(depart_time, next_bus_id, next_diff) end)

      find_it(first_bus_id, a_time, bus_specs, (b_n + 1) * interval)
    end
  end

  def final_answer([{first_bus_id, _} | bus_specs]) do
    find_it(first_bus_id, first_bus_id, bus_specs, 1)
  end

  def solve_for_str(bus_ids_str) do
    bus_ids_str
    |> String.split(",")
    |> get_bus_specs
    |> final_answer
  end

  def solve(filename) do
    [_ready_time, bus_ids_str, _newline] = File.read!(filename) |> String.split("\n")

    bus_ids_str
    |> solve_for_str
  end
end

# 295
Solver.solve("test.txt") |> inspect |> IO.puts()
# 2215
Solver.solve("input.txt") |> inspect |> IO.puts()

# 1068781
Solver2.solve("test.txt") |> inspect |> IO.puts()

Solver2.solve_for_str("17,x,13,19") |> inspect |> IO.puts() # 3417
Solver2.solve_for_str("67,7,59,61") |> inspect |> IO.puts() # 754018
Solver2.solve_for_str("67,x,7,59,61") |> inspect |> IO.puts() # 779210
Solver2.solve_for_str("67,7,x,59,61") |> inspect |> IO.puts() # 1261476
Solver2.solve_for_str("1789,37,47,1889") |> inspect |> IO.puts() # 1202161486

# 1058443396696792
Solver2.solve("input.txt") |> inspect |> IO.puts()
