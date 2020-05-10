defmodule MusicBox do
  defstruct(
    instructions: [],
    current: 0,
    registers: %{},
    queue: [],
    output: [],
    send_count: 0
  )

  def new(id, instructions) do
    %MusicBox{registers: %{"p" => id}, instructions: instructions}
  end

  def next_instruction(mb) do
    Enum.at(mb.instructions, mb.current)
  end

  def increment_instruction(mb) do
    %MusicBox{mb | current: mb.current + 1}
  end

  def play_next(mb) do
    next_instruction = MusicBox.next_instruction(mb)
    MusicBox.play_instruction(mb, next_instruction)
  end

  def play(mb, steps \\ 0) do
    {status, mb} = play_next(mb)
    if mb.current < 0 or mb.current >= length(mb.instructions) or status === :waiting do
      {steps, mb}
    else
      play(mb, steps + 1)
    end
  end

  def play_instruction(mb, inst) do
    {type, vals} = inst
    # IO.puts "Playing #{type}, #{vals}"
    {status, mb} =
      case type do
        "snd" -> play_snd(mb, vals)
        "set" -> play_set(mb, vals)
        "add" -> play_add(mb, vals)
        "mul" -> play_mul(mb, vals)
        "mod" -> play_mod(mb, vals)
        "rcv" -> play_rcv(mb, vals)
        "jgz" -> play_jgz(mb, vals)
      end
    if type !== "jgz" && status !== :waiting do
      {:ok, MusicBox.increment_instruction(mb)}
    else
      {status, mb}
    end
  end

  def play_snd(mb, [val] = _) do
    mb = %MusicBox{mb | output: mb.output ++ [evaluate_val(mb, val)], send_count: mb.send_count + 1}
    {:ok, mb}
  end

  def play_set(mb, [a, b] = _) do
    {:ok, %MusicBox{mb | registers: Map.put(mb.registers, a, evaluate_val(mb, b))}}
  end

  def play_add(mb, [a, b] = _) do
    b = evaluate_val(mb, b)
    play_set(mb, [a, evaluate_val(mb, a) + b])
  end

  def play_mul(mb, [a, b] = _) do
    b = evaluate_val(mb, b)
    play_set(mb, [a, evaluate_val(mb, a) * b])
  end

  def play_mod(mb, [a, b] = _) do
    b = evaluate_val(mb, b)
    play_set(mb, [a, rem(evaluate_val(mb, a), b)])
  end

  def play_rcv(mb, [val] = _) do
    if length(mb.queue) > 0 do
      [input | remaining] = mb.queue
      {:ok, mb} = play_set(mb, [val, input])
      {:ok, %MusicBox{mb | queue: remaining}}
    else
      {:waiting, mb}
    end
  end

  def play_jgz(mb, [a, b] = _) do
    if evaluate_val(mb, a) > 0 do
      {:ok, %MusicBox{mb | current: mb.current + evaluate_val(mb, b)}}
    else
      {:ok, %MusicBox{mb | current: mb.current + 1}}
    end
  end

  def evaluate_val(mb, val) do
    cond do
      is_integer(val) -> val
      true -> mb.registers[val] || 0
    end
  end
end

defmodule MusicBoxManager do
  defstruct [:mb1, :mb2]

  def new(instructions) do
    %MusicBoxManager{
      mb1: MusicBox.new(0, instructions),
      mb2: MusicBox.new(1, instructions)
    }
  end

  def play(mbm) do
    {mb1_steps, mb1} = MusicBox.play(%MusicBox{mbm.mb1 | output: []})
    mb2 = %MusicBox{mbm.mb2 | queue: mbm.mb2.queue ++ mb1.output}

    {mb2_steps, mb2} = MusicBox.play(%MusicBox{mb2 | output: []})
    mb1 = %MusicBox{mb2 | queue: mb1.queue ++ mb2.output}

    if mb1_steps + mb2_steps !== 0 do
      play(%MusicBoxManager{mbm | mb1: mb1, mb2: mb2})
    else
      IO.puts(mb1.send_count)
    end
  end
end


defmodule Solver do
  def solve do
    instructions =
      File.stream!("input")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&parse_step/1)

    mbm1 = MusicBoxManager.new(instructions) |> MusicBoxManager.play
  end

  def parse_step(step) do
    type = String.slice(step, 0, 3)
    vals =
      String.slice(step, 4, 99)
      |> String.split(" ")
      |> Enum.map(fn(v) ->
        case Integer.parse(v) do
          :error -> v
          {intval, _} -> intval
        end
      end)
    {type, vals}
  end
end

Solver.solve
|> IO.inspect
