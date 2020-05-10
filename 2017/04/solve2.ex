defmodule Solver do
  def add_word(word, stored) do
    len = String.length(word)
    word = String.graphemes(word) |> Enum.sort |> Enum.join

    if stored[len] === nil do
      Map.put(stored, len, MapSet.new([word]))
    else
      if MapSet.member?(stored[len], word) do
        raise "Collision"
      else
        %{stored | len => MapSet.put(stored[len], word)}
      end
    end
  end

  def is_valid?(phrase) do
    try do
      phrase
      |> String.split(" ")
      |> Enum.reduce(%{}, &add_word/2)
      true
    rescue
      RuntimeError -> false
    end
  end

  def solve do
    File.stream!("input")
    |> Enum.map(&String.trim/1)
    |> Enum.count(&is_valid?/1)
  end
end

IO.puts Solver.solve
