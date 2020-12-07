defmodule Seven do
  def part_one(input) do
    bag_map = parse(input)

    bag_map
    |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {outer, _inners}, {contains, not_contains} ->
      if contains_shiny_gold?(outer, bag_map, contains, not_contains) do
        {MapSet.put(contains, outer), not_contains}
      else
        {contains, MapSet.put(not_contains, outer)}
      end
    end)
    |> elem(0)
    |> MapSet.delete("shiny gold")
    |> MapSet.size()
  end

  def part_two(input) do
    bag_map = parse(input)
    count_inner_bags({1, "shiny gold"}, bag_map)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.into(%{}, fn line ->
      [outer_str, inners_str] = String.split(line, "contain")
      [_, outer] = Regex.run(~r/(.+) bags/, outer_str)
      inners =
        Regex.scan(~r/(\d+) ([\w\s]+) bag/, inners_str, capture: :all_but_first)
        |> Enum.map(fn [n, inner] -> {String.to_integer(n), inner} end)
      {outer, inners}
    end)
  end

  defp contains_shiny_gold?(outer, bag_map, contains, not_contains) when is_binary(outer),
    do: contains_shiny_gold?([outer], bag_map, contains, not_contains)
  defp contains_shiny_gold?([], _, _, _), do: false
  defp contains_shiny_gold?(["shiny gold" | _rest], _, _, _), do: true
  defp contains_shiny_gold?([outer | rest], bag_map, contains, not_contains) do
    cond do
      MapSet.member?(contains, outer) -> true
      MapSet.member?(not_contains, outer) ->
        contains_shiny_gold?(rest, bag_map, contains, not_contains)
      true ->
        to_check =
          bag_map
          |> Map.fetch!(outer)
          |> Enum.map(fn {_n, bag} -> bag end)
        contains_shiny_gold?(to_check ++ rest, bag_map, contains, not_contains)
    end
  end

  defp count_inner_bags({n, outer}, bag_map) do
    inners = Map.fetch!(bag_map, outer)
    multiples = Enum.map(inners, fn {inner_n, inner} -> {inner_n * n, inner} end)
    count_bags(multiples, bag_map, 0)
  end

  defp count_bags([], _, count), do: count
  defp count_bags([{n, outer} | rest], bag_map, count) do
    case Map.fetch!(bag_map, outer) do
      [] -> count_bags(rest, bag_map, count + n)
      inners ->
        multiples = Enum.map(inners, fn {inner_n, inner} -> {inner_n * n, inner} end)
        count_bags(multiples ++ rest, bag_map, count + n)
    end
  end
end

input = File.read!("input/07.txt")

input
|> Seven.part_one()
|> IO.inspect()

input
|> Seven.part_two()
|> IO.inspect()
