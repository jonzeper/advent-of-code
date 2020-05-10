defmodule Solver do
  def biggest_bucket(buckets) do
    {biggest_bucket, _size} =
      buckets
      |> Enum.with_index()
      |> Enum.reduce({0,0}, fn({bucket, i}, {biggest_i, biggest_size}) ->
        if bucket > biggest_size, do: {i, bucket}, else: {biggest_i, biggest_size}
      end)
    biggest_bucket
  end

  def distribute(index, buckets) do
    n = Enum.at(buckets, index)
    all_get = div(n, length(buckets))
    leftover = rem(n, length(buckets))
    leftover_front = leftover - (length(buckets) - index - 1)
    buckets
    |> Enum.with_index()
    |> Enum.map(fn({b, i}) ->
      case i do
        ^index -> all_get
        ii when ii > index and ii - index <= leftover -> b + all_get + 1
        ii when ii < index and ii < leftover_front -> b + all_get + 1
        _ -> b + all_get
      end
    end)
  end

  def try_distribute({buckets, found_patterns, steps}) do
    new_buckets =
      buckets
      |> biggest_bucket()
      |> distribute(buckets)

    if MapSet.member?(found_patterns, buckets) do
      steps
    else
      try_distribute({new_buckets, MapSet.put(found_patterns, buckets), steps + 1})
    end
  end
end

buckets =
  File.stream!("input")
  |> Enum.to_list()
  |> List.first()
  |> String.trim()
  |> String.split("\t")
  |> Enum.map(&String.to_integer/1)

IO.inspect Solver.try_distribute({buckets, MapSet.new(), 0})
