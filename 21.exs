defmodule TwentyOne do
  def part_one(input) do
    ingredients_and_allergens = parse(input)

    allergens =
      ingredients_and_allergens
      |> translate()
      |> Map.values()
      |> MapSet.new()

   ingredients_and_allergens
   |> Enum.reduce(0, fn {ingredients, _}, acc ->
      ingredients
      |> MapSet.difference(allergens)
      |> MapSet.size()
      |> Kernel.+(acc)
   end)
  end

  def part_two(input) do
    input
    |> parse()
    |> translate()
    |> Enum.to_list()
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      [a, b] = String.split(line, [" (contains", ")"], trim: true)

      ingredients = String.split(a, " ") |> MapSet.new()
      allergens = String.split(b, ",") |> Enum.map(&String.trim/1) |> MapSet.new()

      {ingredients, allergens}
    end)
  end

  defp translate(list) do
    all_allergens =
      list
      |> Enum.reduce(MapSet.new(), fn {_, allergens}, acc ->
        MapSet.union(acc, allergens)
      end)
      |> Enum.to_list()

    do_translate([], all_allergens, list, %{})
  end

  defp do_translate([], [], _, allergen_map), do: allergen_map
  defp do_translate(past, [], ingredients_list, allergen_map) do
    do_translate([], past, ingredients_list, allergen_map)
  end
  defp do_translate(past, [allergen | rest], ingredients_list, allergen_map) do
    possible_translations =
      ingredients_list
      |> Enum.filter(fn {_, allergens} -> allergen in allergens end)
      |> Enum.map(fn {ingredients, _} ->
        translated_ingredients = allergen_map |> Map.values() |> MapSet.new()
        MapSet.difference(ingredients, translated_ingredients)
      end)
      |> Enum.reduce(&MapSet.intersection/2)

    case MapSet.size(possible_translations) do
      1 ->
        translation = Enum.at(possible_translations, 0)
        do_translate(past, rest, ingredients_list, Map.put(allergen_map, allergen, translation))
      _ ->
        do_translate(past ++ [allergen], rest, ingredients_list, allergen_map)
    end
  end
end

input = File.read!("input/21.txt")

input
|> TwentyOne.part_one()
|> IO.inspect()

input
|> TwentyOne.part_two()
|> IO.inspect()
