defmodule Nine do
  def part_one(input) do
    input
    |> parse()
    |> find_invalid()
  end

  def part_two(input) do
    list = parse(input)
    target = find_invalid(list)
    range = find_contiguous(list, target)

    Enum.min(range) + Enum.max(range)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_invalid([_ | rest] = list) do
    target = Enum.at(list, 25)
    pool = Enum.slice(list, 0..24)
    possible_sums = for n <- pool, m <- pool -- [n], do: n + m
    if target in possible_sums
      find_invalid(rest)
    else
      target
    end
  end

  defp find_contiguous(list, target, i \\ 0)
  defp find_contiguous([_ | rest] = list, target, i) do
    slice = Enum.slice(list, 0..i)
    case Enum.sum(slice) do
      ^target -> slice
      n when n > target -> find_contiguous(rest, target, 0)
      _ -> find_contiguous(list, target, i + 1)
    end
  end
end

input = File.read!("input/09.txt")

input
|> Nine.part_one()
|> IO.inspect()

input
|> Nine.part_two()
|> IO.inspect()
