defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> find_two()
  end

  def part_two(input) do
    input
    |> parse()
    |> find_three()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp find_two(list) do
    li = Enum.with_index(list)
    for {a, ai} <- li,
        {b, bi} <- li,
        ai < bi,
        a + b == 2020
    do
      a * b
    end
    |> List.first()
  end

  defp find_three(list) do
    li = Enum.with_index(list)
    for {a, ai} <- li,
        {b, bi} <- li,
        {c, ci} <- li,
        ai < bi,
        bi < ci,
        a + b + c == 2020
    do
      a * b * c
    end
    |> List.first()
  end
end

input = File.read!("input/01.txt")

input
|> One.part_one()
|> IO.inspect()

input
|> One.part_two()
|> IO.inspect()
