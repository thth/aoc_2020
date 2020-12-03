defmodule Three do
  @slope {3, 1}
  @slopes [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

  def part_one(input) do
    input
    |> parse()
    |> count(@slope)
  end

  def part_two(input) do
    geology = parse(input)
    @slopes
    |> Enum.map(&(count(geology, &1)))
    |> Enum.reduce(&*/2)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp count(geology, {dx, dy}) do
    geology
    |> Enum.take_every(dy)
    |> Enum.reduce({0, 0}, fn row, {trees, x} ->
      tree? = Enum.at(row, x) == "#"
      trees = if tree?, do: trees + 1, else: trees
      {trees, rem(x + dx, length(row))}
    end)
    |> elem(0)
  end
end

input = File.read!("input/03.txt")

Three.part_one(input)
|> IO.inspect()

Three.part_two(input)
|> IO.inspect()
