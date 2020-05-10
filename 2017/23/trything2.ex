defmodule Thing do
  def update(reg, key, val) do
    IO.puts "Setting #{key} to #{val}"
    Map.put(reg, key, val)
  end

  def loop_1(reg) do
    reg =
      reg
      |> update(:f, 1)
      |> update(:d, 2)
      |> loop_2()
      |> update(:h, (if reg[:f] === 0, do: reg[:h] + 1, else: reg[:h]))

    if reg[:b] === reg[:c] do
      raise "Done: #{reg[:h]}"
    end
    reg
    |> update(:b, reg[:b] + 17)
    |> loop_1()
  end

  def loop_2(reg) do
    # inc d by 1 until eq to b
    # at the end, e will be eq to b
    # f will be set to 0 if b is 1
    reg =
      reg
      |> update(:d, reg[:b])
      |> update(:e, reg[:b])
      |> update(:f, (if reg[:b] === 1, do: 0, else: reg[:f]))
      # |> update(:e, 2)
      # |> loop_3()
      # |> update(:e, reg[:b])
      # |> update(:f, (if reg[:d] === 1, do: 0, else: reg[:f]))
      # |> update(:d, reg[:d] + 1)
    # if reg[:d] === reg[:b], do: reg, else: loop_2(reg)
  end

  def loop_3(reg) do
    # will run b-e times
    reg
    |> update(:e, reg[:b])
    |> update(:f, (if reg[:d] * reg[:e] === reg[:b], do: 0, else: reg[:f]))
    # reg =
    #   reg
    #   |> update(:f, (if reg[:d] * reg[:e] === reg[:b], do: 0, else: reg[:f]))
    #   |> update(:e, reg[:e] + 1)
    # if reg[:e] === reg[:b], do: reg, else: loop_3(reg)
  end
end

reg = %{a: 1, b: 108100, c: 125100, d: 0, e: 0, f: 0, g: 0, h: 0}

Thing.loop_1(reg)

# set f,d 1,2
# set e 2
# set g (d*e)-b
# jnz g 2  (6)
# set f 0
# sub e -1
# set g e-b
# jnz g -8  (3)
# sub d -1
# set g d-b
# jnz g -13  (2)
# jnz f 2  (14)
# sub h -1
# set g b-c
# jnz g 2  (17)
# jnz 1 3  (out)
# sub b -17
# jnz 1 -23 (1)



