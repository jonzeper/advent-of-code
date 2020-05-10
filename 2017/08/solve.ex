defmodule Condition do
  defstruct register: "", operator: "", value: 0
end

defmodule Instruction do
  defstruct register: "", operation: "", value: 0, condition: %Condition{}
end

defmodule Computer do
  defstruct registers: %{}

  def evaluate_condition(comp, condition) do
    regval = Map.get(comp.registers, condition.register, 0)
    case condition.operator do
      ">" -> regval > condition.value
      ">=" -> regval >= condition.value
      "<" -> regval < condition.value
      "<=" -> regval <= condition.value
      "==" -> regval == condition.value
      "!=" -> regval != condition.value
    end
  end

  def run_instruction(comp, inst) do
    if evaluate_condition(comp, inst.condition) do
      regval = Map.get(comp.registers, inst.register, 0)
      newval = case inst.operation do
        "inc" -> regval + inst.value
        "dec" -> regval - inst.value
      end
      %{comp | registers: Map.put(comp.registers, inst.register, newval)}
    else
      comp
    end
  end

  def largest_register(comp) do
    Enum.max(Map.values(comp.registers))
  end
end

defmodule Solver do
  def line_to_instruction(line) do
    [reg, op, val, _, creg, cop, cval] = String.split(String.trim(line), " ")
    %Instruction{
      register: reg,
      operation: op,
      value: String.to_integer(val),
      condition: %Condition{
        register: creg,
        operator: cop,
        value: String.to_integer(cval)
      }
    }
  end

  def solve do
   File.stream!("input")
   |> Enum.map(&line_to_instruction/1)
   |> Enum.reduce(%Computer{}, fn(inst, comp) -> Computer.run_instruction(comp, inst) end)
   |> Computer.largest_register()
   |> IO.inspect
  end
end

Solver.solve
