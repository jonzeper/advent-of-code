defmodule Spinlock do
  defstruct buffer: [0], pos: 0, step: 1, step_size: 0, value_after_zero: 0, buflen: 1

  def spin(sl) do
    insert_pos = sl.pos + sl.step_size
    insert_pos = (insert_pos - (div(insert_pos, sl.buflen) * sl.buflen)) + 1
    value_after_zero = (if insert_pos === 1, do: sl.step, else: sl.value_after_zero)
    %Spinlock{sl | pos: insert_pos, step: sl.step + 1, value_after_zero: value_after_zero, buflen: sl.buflen + 1}

    # new_buf = List.insert_at(sl.buffer, insert_pos + 1, sl.step)
    # %Spinlock{sl | buffer: new_buf, pos: insert_pos + 1, step: sl.step + 1}
  end

  def value_after_zero(sl) do
    sl.value_after_zero
    # zero_index = Enum.find_index(sl.buffer, fn(x) -> x === 0 end)
    # Enum.at(sl.buffer, zero_index + 1)
  end
end

defmodule Solver do
  def solve do
    sl = %Spinlock{step_size: 369}
    sl = Enum.reduce(1..50000000, sl, fn(_i, sl) -> Spinlock.spin(sl) end)
    # Enum.at(sl.buffer, sl.pos+1) |> IO.inspect
    sl
    # Spinlock.value_after_zero(sl) |> IO.inspect
  end
end

# 10000 in 750ms

t1 = Time.utc_now()
Solver.solve |> IO.inspect
t2 = Time.utc_now()

IO.puts "Done in #{Time.diff(t2, t1, :millisecond)} ms"
# 3 test step_size
# 369 real step_size

# 50000000 fifty million

# 643 value after 0 for 2017 steps
