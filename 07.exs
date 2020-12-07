defmodule Seven do
  def part_one(input) do
    bag_map = parse(input)

    list_outers_containing("shiny gold", bag_map)
    |> length()
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

  defp list_outers_containing(base_inner, bag_map) do
    outers = list_bags_containing(base_inner, bag_map)
    list_outers(outers, bag_map, [])
  end

  defp list_bags_containing(bag, bag_map) do
    bag_map
    |> Enum.filter(fn {_outer, inners} ->
      Enum.any?(inners, fn {_n, inner} -> inner == bag end)
    end)
    |> Enum.map(fn {outer, _inners} -> outer end)
  end

  defp list_outers([], _, seen), do: Enum.uniq(seen)
  defp list_outers([bag | rest], bag_map, seen) do
    additional_to_check = list_bags_containing(bag, bag_map) -- seen
    list_outers(additional_to_check ++ rest, bag_map, [bag | seen])
  end

  defp count_inner_bags({n, outer}, bag_map) do
    inners = Map.fetch!(bag_map, outer)
    multiples = Enum.map(inners, fn {inner_n, inner} -> {inner_n * n, inner} end)
    count_bags(multiples, bag_map, 0)
  end

  defp count_bags([], _, count), do: count
  defp count_bags([{n, outer} | rest], bag_map, count) do
    case Map.fetch!(bag_map, outer) do
      [] ->
        count_bags(rest, bag_map, count + n)
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
