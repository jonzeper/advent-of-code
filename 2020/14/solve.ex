use Bitwise

defmodule InputParser do
  def parse_instruction(str) do
    [action, value] = str |> String.trim() |> String.split(" = ")

    if action == "mask" do
      {:mask, value}
    else
      [memloc] = Regex.run(~r/\d+/, action)
      {:mem, String.to_integer(memloc), String.to_integer(value)}
    end
  end
end

defmodule Solver do
  defmodule MachineState do
    defstruct or_mask: 0, and_mask: 0, mem: %{}

    def update_mem(state, location, value) do
      %MachineState{state | mem: Map.put(state.mem, location, value)}
    end

    def value_sum(state) do
      state.mem
      |> Map.values()
      |> Enum.sum()
    end
  end

  def and_mask(mask_str) do
    mask_str |> String.replace(~r/[X]/, "1") |> String.to_integer(2)
  end

  def or_mask(mask_str) do
    mask_str |> String.replace(~r/[X]/, "0") |> String.to_integer(2)
  end

  def execute_instruction({:mask, value}, state) do
    and_mask = and_mask(value)
    or_mask = or_mask(value)
    %MachineState{state | and_mask: and_mask, or_mask: or_mask}
  end

  def execute_instruction({:mem, location, value}, state) do
    new_value = (value &&& state.and_mask) ||| state.or_mask
    MachineState.update_mem(state, location, new_value)
  end

  def solve(filename) do
    File.stream!(filename)
    |> Enum.map(&InputParser.parse_instruction/1)
    |> Enum.reduce(%MachineState{}, &execute_instruction/2)
    |> MachineState.value_sum()
  end
end

defmodule Solver2 do
  @mask_size 36

  defmodule MachineState do
    defstruct or_mask: nil, x_bits: nil, mem: %{}

    def value_sum(state), do: state.mem |> Map.values |> Enum.sum
  end

  # List bit positions containing "X", counting from the right
  # e.g.  000X00X0 => [1,4]
  def find_x_bits(mask) do
    mask
    |> String.graphemes
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.reduce([], fn {c, i}, acc -> if c == "X", do: [i | acc], else: acc end)
  end

  # After we've applied all variations of X bits, apply the or_mask and return the final mask
  def get_masks(or_mask, [], original_location), do: [original_location ||| or_mask];

  def get_masks(or_mask, [x_bit | rest], original_location) do
    # A mask where we've set X to 1. Use bitwise OR with this mask to force a bit to 1
    # e.g. position 3 => 2^3 == 0b1000
    x_as_1_mask = trunc(:math.pow(2, x_bit))

    # A mask where we've set X to 0. Use bitwise AND with this mask to force a bit to 0
    # First we'll create a mask with all bits set to 1, then XOR the x_as_1_mask to flip the desired bit to 0
    # e.g. 0b11111111 ^^^ 0b00001000 == 0b11110111
    x_as_0_mask = trunc(:math.pow(2, @mask_size) - 1) ^^^ x_as_1_mask # Apply this as an AND mask to all following combos

    # For the X=1 and X=0 cases, continue down the list of X-bits to generate a complete mask for each variation
    x_as_1_values = get_masks(or_mask, rest, original_location) |> Enum.map(fn x -> (x ||| x_as_1_mask) end)
    x_as_0_values = get_masks(or_mask, rest, original_location) |> Enum.map(fn x -> (x &&& x_as_0_mask) end)
    x_as_1_values ++ x_as_0_values
  end

  def execute_instruction({:mask, mask}, state) do
    next_or_mask = mask |> String.replace(~r/[X]/, "0") |> String.to_integer(2)
    next_x_bits = find_x_bits(mask)
    %MachineState{state | or_mask: next_or_mask, x_bits: next_x_bits}
  end

  def execute_instruction({:mem, location, value}, state) do
    next_mem =
      get_masks(state.or_mask, state.x_bits, location)
      |> Enum.reduce(state.mem, fn loc, mem -> Map.put(mem, loc, value) end)
    %MachineState{state | mem: next_mem}
  end

  def solve(filename) do
    File.stream!(filename)
    |> Enum.map(&InputParser.parse_instruction/1)
    |> Enum.reduce(%MachineState{}, &execute_instruction/2)
    |> MachineState.value_sum()
  end
end

# 165
Solver.solve("test.txt") |> inspect |> IO.puts()

# 6513443633260
Solver.solve("input.txt") |> inspect |> IO.puts()

# 208
Solver2.solve("test2.txt") |> inspect |> IO.puts()

# 3442819875191
Solver2.solve("input.txt") |> inspect |> IO.puts()
