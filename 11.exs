defmodule Eleven do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.reduce_while(nil, fn map, prev_count ->
      case Enum.count(map, fn {_, occupied?} -> occupied? end) do
        ^prev_count -> {:halt, prev_count}
        new_count -> {:cont, new_count}
      end
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&step_two/1)
    |> Enum.reduce_while(nil, fn map, prev_count ->
      case Enum.count(map, fn {_, occupied?} -> occupied? end) do
        ^prev_count -> {:halt, prev_count}
        new_count -> {:cont, new_count}
      end
    end)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"L", x}, inner_acc -> Map.put(inner_acc, {x, y}, false)
        {"#", x}, inner_acc -> Map.put(inner_acc, {x, y}, true)
        {".", x}, inner_acc -> Map.put(inner_acc, {x, y}, nil)
      end)
    end)
  end

  defp step(map), do: for seat <- map, into: %{}, do: step_seat(seat, map)

  defp step_seat({seat, nil}, _map), do: {seat, nil}
  defp step_seat({seat, occupied?}, map) do
    adj_count = count_adj(seat, map)
    cond do
      not occupied? and adj_count == 0 -> {seat, true}
      occupied? and adj_count >= 4 -> {seat, false}
      true -> {seat, occupied?}
    end
  end

  defp count_adj({x, y}, map) do
    [
      {x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1},
      {x    , y - 1},             {x    , y + 1},
      {x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}
    ]
    |> Enum.count(&Map.get(map, &1))
  end

  defp step_two(map), do: for seat <- map, into: %{}, do: step_seat_two(seat, map)

  defp step_seat_two({seat, nil}, _map), do: {seat, nil}
  defp step_seat_two({seat, occupied?}, map) do
    adj_count = count_visible(seat, map)
    cond do
      not occupied? and adj_count == 0 -> {seat, true}
      occupied? and adj_count >= 5 -> {seat, false}
      true -> {seat, occupied?}
    end
  end

  defp count_visible(seat, map) do
    [
      {-1, -1}, {-1, 0}, {-1, 1},
      {0,  -1},           {0, 1},
      {1,  -1}, {1,  0},  {1, 1}
    ]
    |> Enum.count(&dir_occupied?(map, seat, &1))
  end

  defp dir_occupied?(map, {x, y}, {dx, dy}) do
    check = {x + dx, y + dy}
    case Map.get(map, check, :out) do
      :out -> false
      false -> false
      true -> true
      nil -> dir_occupied?(map, check, {dx, dy})
    end
  end
end

input = File.read!("input/11.txt")

input
|> Eleven.part_one()
|> IO.inspect()

input
|> Eleven.part_two()
|> IO.inspect()
