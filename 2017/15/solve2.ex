# Generator A starts with 783
# Generator B starts with 325

# take the previous value it produced,
# multiply it by a factor (generator A uses 16807; generator B uses 48271),
# and then keep the remainder of dividing that resulting product by 2147483647

use Bitwise

defmodule Solver do
  def g1_next(i) do
    n = rem(i * 16807, 2147483647)
    if rem(n, 4) === 0, do: n, else: g1_next(n)
  end

  def g2_next(i) do
    n = rem(i * 48271, 2147483647)
    if rem(n, 8) === 0, do: n, else: g2_next(n)
  end

  def solve do
    g1 = Stream.iterate(783, &g1_next/1)
    g2 = Stream.iterate(325, &g2_next/1)
    g = Stream.zip(g1, g2)

    Enum.reduce_while(g, {0, 1}, fn({v1, v2} = _, {total, i} = _) ->
      if i > 5000000 do
        {:halt, {total, i}}
      else
        match = (v1 &&& 65535) === (v2 &&& 65535)
        new_total = if match, do: total + 1, else: total
        {:cont, {new_total, i + 1}}
      end
    end)
    |> IO.inspect
  end
end


Solver.solve
