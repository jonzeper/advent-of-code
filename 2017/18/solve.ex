defmodule MusicBox do
  defstruct(
    instructions: [],
    current: 0,
    registers: %{},
    last_sound: nil,
    recovered_sounds: []
  )

  def play(mb) do
    mb = play_instruction(mb, Enum.at(mb.instructions, mb.current))
    if mb.current >= 0 and mb.current < length(mb.instructions) do
      if length(mb.recovered_sounds) > 0 do
        mb
      else
        play(mb)
      end
    else
      mb
    end
  end

  def play_instruction(mb, inst) do
    IO.inspect(inst)
    {type, vals} = inst
    mb = case type do
      "snd" -> play_snd(mb, vals)
      "set" -> play_set(mb, vals)
      "add" -> play_add(mb, vals)
      "mul" -> play_mul(mb, vals)
      "mod" -> play_mod(mb, vals)
      "rcv" -> play_rcv(mb, vals)
      "jgz" -> play_jgz(mb, vals)
      _ -> mb
    end
    if type === "jgz" do
      mb
    else
      %MusicBox{mb | current: mb.current + 1}
    end
  end

  def play_snd(mb, [val] = _) do
    %MusicBox{mb | last_sound: evaluate_val(mb, val)}
  end

  def play_set(mb, [a, b] = _) do
    %MusicBox{mb | registers: Map.put(mb.registers, a, evaluate_val(mb, b))}
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
    cond do
      evaluate_val(mb, val) > 0 -> recover_sound(mb)
      true -> mb
    end
  end

  def play_jgz(mb, [a, b] = _) do
    if evaluate_val(mb, a) > 0 do
      %MusicBox{mb | current: mb.current + evaluate_val(mb, b)}
    else
      %MusicBox{mb | current: mb.current + 1}
    end
  end

  def evaluate_val(mb, val) do
    cond do
      is_integer(val) -> val
      true -> mb.registers[val] || 0
    end
  end

  def recover_sound(mb) do
    cond do
      mb.last_sound -> %MusicBox{mb | recovered_sounds: mb.recovered_sounds ++ [mb.last_sound]}
      true -> mb
    end
  end

  def add_instruction(mb, inst) do
    %MusicBox{mb | instructions: mb.instructions ++ [inst]}
  end
end

defmodule Solver do
  def solve do
    mb =
      File.stream!("input")
      |> Enum.reduce(%MusicBox{}, fn(step, mb) -> MusicBox.add_instruction(mb, parse_step(String.trim(step))) end)
      |> MusicBox.play()
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
