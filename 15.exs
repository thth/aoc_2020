defmodule Fifteen do
  @moduledoc "solution assumes no repeat numbers in input"

  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&run/1)
    |> Enum.find(fn {_, _, step} -> step == 2020 end)
    |> elem(1)
  end

  @doc "finishes in ~42s"
  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&run/1)
    |> Enum.find(fn {_, _, step} -> step == 30_000_000 end)
    |> elem(1)
  end

  defp parse(text) do
    list =
      text
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    map =
      list
      |> Enum.with_index(1)
      |> Enum.map(fn {n, i} -> {n, %{last_seen: i, next_last_seen: nil}} end)
      |> Enum.into(%{})
    {map, List.last(list), length(list)}
  end

  defp run({map, last, last_step}) do
    this_step = last_step + 1
    case map[last].next_last_seen do
      nil ->
        new_map =
          Map.update(map, 0, %{last_seen: this_step, next_last_seen: nil}, fn prev ->
            %{prev |
              last_seen: this_step,
              next_last_seen: prev.last_seen
            }
        end)
        {new_map, 0, this_step}
      next_last_seen ->
        diff = last_step - next_last_seen
        new_map =
          Map.update(map, diff, %{last_seen: this_step, next_last_seen: nil}, fn prev ->
            %{prev |
              last_seen: this_step,
              next_last_seen: prev.last_seen
            }
          end)
        {new_map, diff, this_step}
    end
  end
end

input = File.read!("input/15.txt")

input
|> Fifteen.part_one()
|> IO.inspect()

input
|> Fifteen.part_two()
|> IO.inspect()
