defmodule TwentyFour do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&identify/1)
    |> Enum.frequencies()
    |> Enum.count(fn {_, v} -> rem(v, 2) != 0 end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(&identify/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_, v} -> rem(v, 2) != 0 end)
    |> Enum.map(fn {k, _v} -> k end)
    |> MapSet.new()
    |> Stream.iterate(&step/1)
    |> Enum.at(100)
    |> MapSet.size()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      Regex.scan(~r/e|se|ne|w|sw|nw/, line)
      |> List.flatten()
    end)
  end

  defp identify(directions, coords \\ {0, 0})
  defp identify([], coords), do: coords
  defp identify(["e" | rest], {x, y}), do: identify(rest, {x + 1, y})
  defp identify(["w" | rest], {x, y}), do: identify(rest, {x - 1, y})
  defp identify(["ne" | rest], {x, y}) when rem(y, 2) == 0, do: identify(rest, {x, y - 1})
  defp identify(["ne" | rest], {x, y}), do: identify(rest, {x + 1, y - 1})
  defp identify(["se" | rest], {x, y}) when rem(y, 2) == 0, do: identify(rest, {x, y + 1})
  defp identify(["se" | rest], {x, y}), do: identify(rest, {x + 1, y + 1})
  defp identify(["nw" | rest], {x, y}) when rem(y, 2) == 0, do: identify(rest, {x - 1, y - 1})
  defp identify(["nw" | rest], {x, y}), do: identify(rest, {x, y - 1})
  defp identify(["sw" | rest], {x, y}) when rem(y, 2) == 0, do: identify(rest, {x - 1, y + 1})
  defp identify(["sw" | rest], {x, y}), do: identify(rest, {x, y + 1})

  defp step(mapset) do
    {min_x, _} = Enum.min_by(mapset, fn {x, _,} -> x end)
    {max_x, _} = Enum.max_by(mapset, fn {x, _,} -> x end)
    {_, min_y} = Enum.min_by(mapset, fn {_, y,} -> y end)
    {_, max_y} = Enum.max_by(mapset, fn {_, y,} -> y end)

    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1) do
      {x, y}
    end
    |> Enum.reduce(MapSet.new(), fn coords, acc ->
      if become_black_tile?(coords, mapset), do: MapSet.put(acc, coords), else: acc
    end)
  end

  defp become_black_tile?(coords, mapset) do
    black? = MapSet.member?(mapset, coords)
    adj_count = count_adj(mapset, coords)
    cond do
      black? and adj_count == 0 or adj_count > 2 -> false
      not black? and adj_count == 2 -> true
      true -> black?
    end
  end

  defp count_adj(mapset, {x, y}) when rem(y, 2) == 0 do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x - 1, y + 1}, {x, y - 1}, {x - 1, y - 1}]
    |> Enum.count(&MapSet.member?(mapset, &1))
  end

  defp count_adj(mapset, {x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x + 1, y + 1}, {x, y - 1}, {x + 1, y - 1}]
    |> Enum.count(&MapSet.member?(mapset, &1))
  end
end

input = File.read!("input/24.txt")

input
|> TwentyFour.part_one()
|> IO.inspect()

input
|> TwentyFour.part_two()
|> IO.inspect()
