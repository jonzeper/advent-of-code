defmodule MusicBox do
  defstruct(
    instructions: [],
    current: 0,
    registers: %{},
    mul_count: 0
  )

  def play(mb) do
    mb = play_instruction(mb, Enum.at(mb.instructions, mb.current))
    if mb.current >= 0 and mb.current < length(mb.instructions) do
      play(mb)
    else
      mb
    end
  end

  def play_instruction(mb, inst) do
    {type, vals} = inst
    mb = case type do
      "set" -> play_set(mb, vals)
      "sub" -> play_sub(mb, vals)
      "mul" -> play_mul(mb, vals)
      "jnz" -> play_jnz(mb, vals)
      _ -> mb
    end
    if type === "jnz" do
      mb
    else
      %MusicBox{mb | current: mb.current + 1}
    end
  end

  def play_set(mb, [a, b] = _) do
    %MusicBox{mb | registers: Map.put(mb.registers, a, evaluate_val(mb, b))}
  end

  def play_sub(mb, [a, b] = _) do
    b = evaluate_val(mb, b)
    play_set(mb, [a, evaluate_val(mb, a) - b])
  end

  def play_mul(mb, [a, b] = _) do
    b = evaluate_val(mb, b)
    play_set(%MusicBox{mb | mul_count: mb.mul_count + 1}, [a, evaluate_val(mb, a) * b])
  end

  def play_jnz(mb, [a, b] = _) do
    if evaluate_val(mb, a) !== 0 do
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

  def mul_count(mb), do: mb.mul_count

  def add_instruction(mb, inst) do
    %MusicBox{mb | instructions: mb.instructions ++ [inst]}
  end
end

defmodule Solver do
  def solve do
    File.stream!("input")
    |> Enum.reduce(%MusicBox{}, fn(step, mb) -> MusicBox.add_instruction(mb, parse_step(String.trim(step))) end)
    |> MusicBox.play()
    |> MusicBox.mul_count()
    |> IO.inspect
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
