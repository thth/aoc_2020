defmodule TwentyTwo do
  def part_one(input) do
    input
    |> parse()
    |> combat()
    |> calculate_score()
  end

  def part_two(input) do
    input
    |> parse()
    |> recursive_combat()
    |> elem(1)
    |> calculate_score()
  end

  defp parse(text) do
    text
    |> String.split(["\n\n", "Player 1:\n", "Player 2:\n"], trim: true)
    |> Enum.map(fn deck_str ->
      deck_str
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
    end)
    |> List.to_tuple()
  end

  defp combat({winner, []}), do: winner
  defp combat({[], winner}), do: winner
  defp combat({[h1 | r1], [h2 | r2]}) when h1 > h2, do: combat({r1 ++ [h1, h2], r2})
  defp combat({[h1 | r1], [h2 | r2]}) when h1 < h2, do: combat({r1, r2 ++ [h2, h1]})

  defp calculate_score(deck) do
    deck
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {card, i} -> card * i end)
    |> Enum.sum()
  end

  defp recursive_combat({d1, d2}), do: do_recursive({d1, d2}, MapSet.new())

  defp do_recursive({d1, d2}, seen) do
    cond do
      MapSet.member?(seen, {d1, d2}) ->
        {:d1, d1}
      d2 == [] ->
        {:d1, d1}
      d1 == [] ->
        {:d2, d2}
      hd(d1) <= length(tl(d1)) and hd(d2) <= length(tl(d2)) ->
        rd1 = Enum.take(tl(d1), hd(d1))
        rd2 = Enum.take(tl(d2), hd(d2))
        case recursive_combat({rd1, rd2}) do
          {:d1, _} -> do_recursive({tl(d1) ++ [hd(d1), hd(d2)], tl(d2)}, MapSet.put(seen, {d1, d2}))
          {:d2, _} -> do_recursive({tl(d1), tl(d2) ++ [hd(d2), hd(d1)]}, MapSet.put(seen, {d1, d2}))
        end
      hd(d1) > hd(d2) ->
        do_recursive({tl(d1) ++ [hd(d1), hd(d2)], tl(d2)}, MapSet.put(seen, {d1, d2}))
      hd(d1) < hd(d2) ->
        do_recursive({tl(d1), tl(d2) ++ [hd(d2), hd(d1)]}, MapSet.put(seen, {d1, d2}))
    end
  end
end

input = File.read!("input/22.txt")

input
|> TwentyTwo.part_one()
|> IO.inspect()

input
|> TwentyTwo.part_two()
|> IO.inspect()
