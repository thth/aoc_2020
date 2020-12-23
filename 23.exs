defmodule TwentyThree do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&move/1)
    |> Enum.at(100)
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != 1))
    |> Enum.slice(1, length(parse(input)) - 1)
    |> Integer.undigits()
  end

  def part_two(input) do
    list = parse_two(input)
    list
    |> Stream.iterate(&move_two/1)
    |> Enum.at(10)
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != 1))
    |> Enum.slice(1, 2)
    |> Enum.reduce(&*/2)
  end

  defp parse(text) do
    text
    |> String.to_integer()
    |> Integer.digits()
  end

  defp parse_two(text) do
    original = parse(text)
    start = Enum.max(original) + 1
    original ++ Enum.to_list(start..1_000_000)
  end

  defp move([current, a, b, c | rest] = list) do
    sorted_rest = Enum.sort(rest, :desc)
    destination = Enum.find(sorted_rest, &(&1 < current)) || Enum.at(sorted_rest, 0)
    new_rest =
      [current | rest]
      |> Stream.cycle()
      |> Stream.drop_while(&(&1 != destination))
      |> Enum.slice(1, length(list) - 3)
    [a, b, c | new_rest]
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != current))
    |> Enum.slice(1, length(list))
  end

  defp move_two([current, a, b, c | rest]) do
    destination = find_next(current, a, b, c, 1_000_000)
    new_rest =
      [current | rest]
      |> Stream.cycle()
      |> Stream.drop_while(&(&1 != destination))
      |> Enum.slice(1, 999_997)
    [a, b, c | new_rest]
    |> Stream.cycle()
    |> Stream.drop_while(&(&1 != current))
    |> Enum.slice(1, 1_000_000)
  end

  defp find_next(current, a, b, c, max) do
    cond do
      (n = cycle(current - 1, max)) not in [a, b, c] -> n
      (n = cycle(current - 2, max)) not in [a, b, c] -> n
      (n = cycle(current - 3, max)) not in [a, b, c] -> n
      true -> cycle(current - 4, max)
    end
  end

  defp cycle(n, max) do
    if n > 0 do
      n
    else
      max - abs(n)
    end
  end
end

input = File.read!("input/23.txt")
# # input = File.read!("input/help.txt")

input
|> TwentyThree.part_one()
|> IO.inspect()

# input
# |> TwentyThree.part_two()
# |> IO.inspect()
