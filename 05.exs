defmodule Five do
  @row_range 0..127
  @col_range 0..7

  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&get_id/1)
    |> Enum.max()
  end

  def part_two(input) do
    occupied = parse(input)
    ids = Enum.map(occupied, &get_id/1)
    for row <- @row_range,
        col <- @col_range,
        {row, col} not in occupied,
        get_id({row, col}) + 1 in ids,
        get_id({row, col}) - 1 in ids
    do
      {row, col}
    end
    |> hd()
    |> get_id()
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&to_seat/1)
  end

  defp to_seat(str) do
    {row..row, col..col} =
      str
      |> String.graphemes()
      |> Enum.reduce({@row_range, @col_range}, fn char, {row_range, col_range} ->
        case char do
          "F" -> {upper_half(row_range), col_range}
          "B" -> {lower_half(row_range), col_range}
          "L" -> {row_range, upper_half(col_range)}
          "R" -> {row_range, lower_half(col_range)}
        end
      end)

    {row, col}
  end

  defp upper_half(a..b), do: a..(div(a + b + 1, 2) - 1)
  defp lower_half(a..b), do: (div(a + b + 1, 2)).. b

  defp get_id({row, col}), do: row * 8 + col
end

input = File.read!("input/05.txt")

Five.part_one(input)
|> IO.inspect()

Five.part_two(input)
|> IO.inspect()
