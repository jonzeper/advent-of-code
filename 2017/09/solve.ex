defmodule Parser do
  defstruct score: 0, level: 0, garbage: false, negated: false

  def score(%Parser{} = p) do
    p.score
  end

  def parse_char(p, c) do
    cond do
      p.negated -> %Parser{p | negated: false}
      p.garbage -> parse_garbage(p, c)
      true -> parse_normal(p, c)
    end
  end

  def parse_garbage(p, c) do
    case c do
      "!" -> %Parser{p | negated: true}
      ">" -> %Parser{p | garbage: false}
      _ -> p
    end
  end

  def parse_normal(p, c) do
    case c do
      "{" -> %Parser{p | level: p.level + 1}
      "}" -> %Parser{p | level: p.level - 1, score: p.score + p.level}
      "<" -> %Parser{p | garbage: true}
      "!" -> %Parser{p | negated: true}
      _ -> p
    end
  end
end

defmodule Solver do
  def solve do
    File.stream!("input")
    |> Enum.to_list()
    |> List.first()
    |> String.graphemes()
    |> Enum.reduce(%Parser{}, fn(c, p) -> Parser.parse_char(p, c) end)
    |> Parser.score()
    |> IO.inspect
  end
end

Solver.solve
