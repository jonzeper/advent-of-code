defmodule Thing do
  def update(reg, key, val) do
    # IO.puts "Setting #{key} to #{val}"
    Map.put(reg, key, val)
  end

  def run(reg) do
    reg
    |> update(:b, 108100)
    |> update(:c, 125100)
    |> loop_1()
  end

  def loop_1(reg) do
    reg =
      reg
      |> update(:f, 1)
      |> update(:d, 2)
      |> loop_2()
      |> update(:h, (if reg[:f] === 0, do: reg[:h] + 1, else: reg[:h]))
      |> update(:g, reg[:b] - reg[:c])

    if reg[:g] === 0 do
      raise "Done: #{reg[:h]}"
    end
    reg
    |> update(:b, reg[:b] + 17)
    |> loop_1()
  end

  def loop_2(reg) do
    # b d e f g
    # b ends same
    # d ends equal to b
    # e ends equal to b
    # f ends 0 if b is ever evenly divisible by d
    # g ends 0
    is_divisible = Enum.any?(2..reg[:b], fn(x) ->
      if rem(reg[:b], x) === 0 && x !== reg[:b], do: IO.puts "#{reg[:b]} / #{x}"
      rem(reg[:b], x) === 0 && x !== reg[:b]
    end)
    # if !is_divisible, do: IO.puts "#{reg[:b]}"
    reg
    |> update(:d, reg[:b])
    |> update(:e, reg[:b])
    |> update(:f, (if is_divisible, do: 0, else: reg[:f]))
    |> update(:g, 0)
    # reg =
    #   reg
    #   # |> update(:e, 2)
    #   # |> loop_3()
    #   |> update(:e, reg[:b])
    #   |> update(:f, (if rem(reg[:b], reg[:d]) === 0, do: 0, else: reg[:f]))
    #   # |> update(:g, 0)
    #   # end loop 3
    #   |> update(:d, reg[:d] + 1)
    #   |> update(:g, reg[:d] - reg[:b])
    # if reg[:g] === 0, do: reg, else: loop_2(reg)
  end

  def loop_3(reg) do
    # b d e f g
    # b same
    # d same
    # e equal b
    # f 0 if d*e ever equals b during loop
    # g 0
    # --
    # b will be between 108100 and 125100, increments of 17
    # e will always start at 2
    # d will be any number between 2 and 108100
    # if there is any e for which e*d == 108100, f will end at 0
    reg
    |> update(:e, reg[:b])
    |> update(:f, (if rem(reg[:b], reg[:d]) === 0, do: 0, else: reg[:f]))
    |> update(:g, 0)
    # reg =
    #   reg
    #   |> update(:g, reg[:d] * reg[:e] - reg[:b])
    #   |> update(:f, (if reg[:g] === 0, do: 0, else: reg[:f]))
    #   |> update(:e, reg[:e] + 1)
    #   |> update(:g, reg[:e] - reg[:b])
    # if reg[:g] === 0, do: reg, else: loop_3(reg)
  end
end

reg = %{a: 1, b: 108100, c: 125100, d: 0, e: 0, f: 0, g: 0, h: 0}

Thing.loop_1(reg)
