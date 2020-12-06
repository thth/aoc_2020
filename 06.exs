defmodule Six do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn group -> Enum.reduce(group, &MapSet.union/2) end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn group -> Enum.reduce(group, &MapSet.intersection/2) end)
    |> Enum.map(&MapSet.size/1)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n"))
    |> Enum.map(fn group -> Enum.map(group, &String.graphemes/1) end)
    |> Enum.map(fn group -> Enum.map(group, &MapSet.new/1) end)
  end
end

input = File.read!("input/06.txt")

input
|> Six.part_one()
|> IO.inspect()

input
|> Six.part_two()
|> IO.inspect()
