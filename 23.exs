defmodule TwentyThree do
  # using Stream.cycle and lists
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

  # using a map ("cupmap") with keys: cups, values: next clockwise cup
  # runs in ~45s
  def part_two(input) do
    initial_current_cup = input |> parse() |> List.first()
    initial_cupmap = setup_cupmap(input, 10..1_000_000)

    {_final_current_cup, final_cupmap} =
      {initial_current_cup, initial_cupmap}
      |> Stream.iterate(&cupmap_move(&1, 1_000_000))
      |> Enum.at(10_000_000)

    first_star = final_cupmap[1]
    second_star = final_cupmap[first_star]

    first_star * second_star
  end

  defp parse(text) do
    text
    |> String.to_integer()
    |> Integer.digits()
  end

  defp setup_cupmap(text, rest_start..rest_end) do
    original_list = parse(text)

    cupmap_initial =
      original_list
      |> List.insert_at(-1, rest_start)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&List.to_tuple/1)

    cupmap_middle =
      rest_start..(rest_end - 1)
      |> Stream.map(fn n -> {n, n + 1} end)

    cupmap_last = [{rest_end, List.first(original_list)}]

    Stream.concat([cupmap_initial, cupmap_middle, cupmap_last])
    |> Enum.into(%{})
  end

  defp move([current, a, b, c | rest] = list) do
    destination = find_destination(current, a, b, c, Enum.max(list))
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

  defp cupmap_move({curr, cupmap}, total_cups) do
    move1 = cupmap[curr]
    move2 = cupmap[move1]
    move3 = cupmap[move2]
    next_curr = cupmap[move3]
    destination = find_destination(curr, move1, move2, move3, total_cups)
    after_destination = cupmap[destination]

    new_cupmap =
      cupmap
      |> Map.put(curr, next_curr)
      |> Map.put(destination, move1)
      |> Map.put(move3, after_destination)

    {next_curr, new_cupmap}
  end

  defp find_destination(current, a, b, c, max) do
    cond do
      (n = cycle(current - 1, max)) not in [a, b, c] -> n
      (n = cycle(current - 2, max)) not in [a, b, c] -> n
      (n = cycle(current - 3, max)) not in [a, b, c] -> n
      true -> cycle(current - 4, max)
    end
  end

  defp cycle(n, _) when n > 0, do: n
  defp cycle(n, max), do: max - abs(n)
end

input = File.read!("input/23.txt")

input
|> TwentyThree.part_one()
|> IO.inspect()

input
|> TwentyThree.part_two()
|> IO.inspect()
