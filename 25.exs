defmodule TwentyFive do
  def part_one(input) do
    {card, door} = parse(input)

    card_loop =
      1
      |> Stream.iterate(&loop(&1, 7))
      |> Stream.with_index()
      |> Enum.find(fn {v, _} -> v == card end)
      |> elem(1)

    1
    |> Stream.iterate(&loop(&1, door))
    |> Enum.at(card_loop)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp loop(n, sub) do
    rem(n * sub, 20201227)
  end
end

input = File.read!("input/25.txt")

input
|> TwentyFive.part_one()
|> IO.inspect()
