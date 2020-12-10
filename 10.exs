defmodule Ten do
  def part_one(input) do
    {_, counts} =
      input
      |> parse()
      |> Enum.sort()
      |> Enum.reduce({0, %{}}, fn curr, {prev, acc} ->
        {curr, Map.update(acc, curr - prev, 1, &(&1 + 1))}
      end)

    counts[1] * (counts[3] + 1)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.sort()
    |> count_paths()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp count_paths(list, memo \\ %{0 => 1})
  defp count_paths([n], memo), do: sum_prev_paths(n, memo)
  defp count_paths([n | rest], memo),
    do: count_paths(rest, Map.put(memo, n, sum_prev_paths(n, memo)))

  defp sum_prev_paths(n, memo),
    do: Map.get(memo, n - 1, 0) + Map.get(memo, n - 2, 0) + Map.get(memo, n - 3, 0)
end

input = File.read!("input/10.txt")

input
|> Ten.part_one()
|> IO.inspect()

input
|> Ten.part_two()
|> IO.inspect()
