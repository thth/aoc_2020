defmodule One do
  def one(input) do
    input
    |> parse()
    |> find_two()
  end

  def two(input) do
    input
    |> parse()
    |> find_three()
  end

  defp parse(txt) do
    txt
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_two([a | rest]) do
    find_two(a, rest)
  end
  defp find_two(a, [b | rest] = list) do
    case Enum.find(list, fn n -> a + n == 2020 end) do
      nil -> find_two(b, rest)
      n -> a * n
    end
  end

  defp find_three([a, b | c]) do
    find_three([a, b | c], [b | c], c)
  end
  defp find_three(a, [_, b | c], []) do
    find_three(a, [b | c], c)
  end
  defp find_three([_ | rest], [_], []) do
    find_three(rest)
  end
  defp find_three([na | _] = a, [nb | _] = b, [_ | rest] = c) do
    case Enum.find(c, fn n -> na + nb + n == 2020 end) do
      nil -> find_three(a, b, rest)
      n -> na * nb * n
    end
  end
end

input = File.read!("input/01.txt")

One.one(input)
|> IO.inspect()

One.two(input)
|> IO.inspect()
