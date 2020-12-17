defmodule Seventeen do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.at(6)
    |> MapSet.size()
  end

  def part_two(input) do
    input
    |> parse_4d()
    |> Stream.iterate(&step_4d/1)
    |> Enum.at(6)
    |> MapSet.size()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, inner_acc -> MapSet.put(inner_acc, {x, y, 42})
        _, inner_acc -> inner_acc
      end)
    end)
  end

  defp step(mapset) do
    {min_x, _, _} = Enum.min_by(mapset, fn {x, _, _} -> x end)
    {max_x, _, _} = Enum.max_by(mapset, fn {x, _, _} -> x end)
    {_, min_y, _} = Enum.min_by(mapset, fn {_, y, _} -> y end)
    {_, max_y, _} = Enum.max_by(mapset, fn {_, y, _} -> y end)
    {_, _, min_z} = Enum.min_by(mapset, fn {_, _, z} -> z end)
    {_, _, max_z} = Enum.max_by(mapset, fn {_, _, z} -> z end)

    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        z <- (min_z - 1)..(max_z + 1) do
      {x, y, z}
    end
    |> Enum.reduce(MapSet.new(), fn coords, acc ->
      if step_cube(coords, mapset), do: MapSet.put(acc, coords), else: acc
    end)
  end

  defp step_cube(coords, mapset) do
    active? = MapSet.member?(mapset, coords)
    adj_count = count_adj(mapset, coords)
    cond do
      active? and adj_count == 2 or adj_count == 3 -> true
      not active? and adj_count == 3 -> true
      true -> false
    end
  end

  defp count_adj(mapset, {x, y, z}) do
    for a <- (x-1)..(x+1),
        b <- (y-1)..(y+1),
        c <- (z-1)..(z+1),
        not (a == x and b == y and c == z) do
      {a, b, c}
    end
    |> Enum.count(&MapSet.member?(mapset, &1))
  end

  defp parse_4d(text) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, inner_acc -> MapSet.put(inner_acc, {x, y, 0xE57E1, 0xE99})
        _, inner_acc -> inner_acc
      end)
    end)
  end

  defp step_4d(mapset) do
    {min_x, _, _, _} = Enum.min_by(mapset, fn {x, _, _, _} -> x end)
    {max_x, _, _, _} = Enum.max_by(mapset, fn {x, _, _, _} -> x end)
    {_, min_y, _, _} = Enum.min_by(mapset, fn {_, y, _, _} -> y end)
    {_, max_y, _, _} = Enum.max_by(mapset, fn {_, y, _, _} -> y end)
    {_, _, min_z, _} = Enum.min_by(mapset, fn {_, _, z, _} -> z end)
    {_, _, max_z, _} = Enum.max_by(mapset, fn {_, _, z, _} -> z end)
    {_, _, _, min_w} = Enum.min_by(mapset, fn {_, _, _, w} -> w end)
    {_, _, _, max_w} = Enum.max_by(mapset, fn {_, _, _, w} -> w end)

    for x <- (min_x - 1)..(max_x + 1),
        y <- (min_y - 1)..(max_y + 1),
        z <- (min_z - 1)..(max_z + 1),
        w <- (min_w - 1)..(max_w + 1) do
      {x, y, z, w}
    end
    |> Enum.reduce(MapSet.new(), fn coords, acc ->
      case step_hypercube(coords, mapset) do
        true -> MapSet.put(acc, coords)
        false -> acc
      end
    end)
  end

  defp step_hypercube(coords, mapset) do
    active? = MapSet.member?(mapset, coords)
    adj_count = count_adj_4d(mapset, coords)
    cond do
      active? and adj_count == 2 or adj_count == 3 -> true
      not active? and adj_count == 3 -> true
      true -> false
    end
  end

  defp count_adj_4d(mapset, {x, y, z, w}) do
    for a <- (x-1)..(x+1),
        b <- (y-1)..(y+1),
        c <- (z-1)..(z+1),
        d <- (w-1)..(w+1),
        not (a == x and b == y and c == z and d == w) do
      {a, b, c, d}
    end
    |> Enum.count(&MapSet.member?(mapset, &1))
  end
end

input = File.read!("input/17.txt")

input
|> Seventeen.part_one()
|> IO.inspect()

input
|> Seventeen.part_two()
|> IO.inspect()
