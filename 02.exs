defmodule Two do
  def part_one(input) do
    input
    |> parse()
    |> Enum.count(fn {a, b, letter, pass} ->
      pass
      |> String.graphemes()
      |> Enum.count(&(&1 == letter))
      |> Kernel.in(a..b)
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.count(fn {a, b, letter, pass} ->
      graphemes = String.graphemes(pass)
      a? = Enum.at(graphemes, a - 1) == letter
      b? = Enum.at(graphemes, b - 1) == letter
      :erlang.xor(a?, b?)
    end)
  end

  defp parse(text) do
    regex = ~r/(\d+)-(\d+) (\w): (\w+)/

    text
    |> String.split("\n")
    |> Enum.map(&Regex.run(regex, &1))
    |> Enum.map(fn [_, a, b, letter, pass] ->
      a = String.to_integer(a)
      b = String.to_integer(b)
      {a, b, letter, pass}
    end)
  end
end

input = File.read!("input/02.txt")

Two.part_one(input)
|> IO.inspect()

Two.part_two(input)
|> IO.inspect()
