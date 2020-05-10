defmodule KnotHash do
  use Bitwise
  defstruct current: 0, skip_size: 0, sequence: Enum.to_list(0..255)

  def from_string(s) do
    instructions = (s |> to_charlist) ++ [17, 31, 73, 47, 23]

    ks =
      (0..63)
      |> Enum.reduce(%KnotHash{}, fn(_, ks) ->
        KnotHash.run_instructions(ks, instructions)
      end)

    ks.sequence
    |> Enum.chunk_every(16)
    |> Enum.map(&xor_chunk/1)
    |> Enum.map(fn(i) -> Integer.to_charlist(i, 16) end)
    |> Enum.map(&pad_hex/1)
    |> Enum.reduce("", fn(cl, s) -> s <> to_string(cl) end)
  end

  def run_instructions(ks, instructions) do
    instructions
    |> Enum.reduce(ks, &(iterate &2, &1))
  end

  defp iterate(ks, len) do
    subseq =
      ks.sequence
      |> Stream.cycle()
      |> Enum.slice(ks.current, len)
      |> Enum.reverse()

    new_seq =
      if ks.current + len > 255 do
        newstart = 256 - ks.current # Index in subseq of item which should now be first in new sequence
        beginlen = len - newstart # Number of elements from the end of subseq which are at begin of new sequence
        Enum.slice(subseq, newstart, beginlen) ++ Enum.slice(ks.sequence, beginlen, 256 - len) ++ Enum.slice(subseq, 0, len - beginlen)
      else
        Enum.slice(ks.sequence, 0, ks.current) ++ subseq ++ Enum.slice(ks.sequence, ks.current + len, 256)
      end

    new_current = normalize_index(ks.current + len + ks.skip_size)

    %KnotHash{ks | current: new_current, sequence: new_seq, skip_size: ks.skip_size + 1}
  end

  defp normalize_index(i) when i < 256, do: i
  defp normalize_index(i) when i > 255, do: normalize_index(i - 256)

  defp xor_chunk(chunk), do: Enum.reduce(chunk, &bxor/2)

  defp pad_hex(hex_charlist) when length(hex_charlist) === 1, do: '0' ++ hex_charlist
  defp pad_hex(hex_charlist) when length(hex_charlist) !== 1, do: hex_charlist
end
