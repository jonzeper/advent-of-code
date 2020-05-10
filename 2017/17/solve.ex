defmodule Spinlock do
  defstruct buffer: [0], pos: 0, step: 1, step_size: 0

  def spin(sl) do
    new_pos = sl.pos + sl.step_size
    new_pos = new_pos - (div(new_pos, length(sl.buffer)) * length(sl.buffer))
    new_buf = List.insert_at(sl.buffer, new_pos + 1, sl.step)
    %Spinlock{sl | buffer: new_buf, pos: new_pos + 1, step: sl.step + 1}
  end

  def value_after_zero(sl) do
    zero_index = Enum.find_index(sl.buffer, fn(x) -> x === 0 end)
    Enum.at(sl.buffer, zero_index + 1)
  end
end

defmodule Solver do
  def solve do
    sl = %Spinlock{step_size: 369}
    sl = Enum.reduce(1..2017, sl, fn(_i, sl) -> Spinlock.spin(sl) end)
    Enum.at(sl.buffer, sl.pos+1) |> IO.inspect
  end
end

Solver.solve |> IO.inspect

# 3 test step_size
# 369 real step_size

# 50000000 fifty million
