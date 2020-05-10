# Generator A starts with 783
# Generator B starts with 325

# take the previous value it produced,
# multiply it by a factor (generator A uses 16807; generator B uses 48271),
# and then keep the remainder of dividing that resulting product by 2147483647

use Bitwise

g1 = Stream.iterate(783, fn(i) -> rem(i * 16807, 2147483647) end)
g2 = Stream.iterate(325, fn(i) -> rem(i * 48271, 2147483647) end)
g = Stream.zip(g1, g2)

Enum.reduce_while(g, {0, 1}, fn({v1, v2} = _, {total, i} = _) ->
  if i > 40000000 do
    {:halt, {total, i}}
  else
    match = (v1 &&& 65535) === (v2 &&& 65535)
    new_total = if match, do: total + 1, else: total
    {:cont, {new_total, i + 1}}
  end
end)
|> IO.inspect
