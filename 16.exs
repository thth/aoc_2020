defmodule Sixteen do
  def part_one(input) do
    {fields, _, tickets} = parse(input)

    tickets
    |> Enum.map(fn ticket ->
      Enum.find(ticket, fn n ->
        fields
        |> Map.values()
        |> List.flatten()
        |> Enum.any?(fn range -> n in range end)
        |> Kernel.not()
      end) || 0
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    {fields, my_ticket, tickets} = parse(input)

    valid_tickets =
      tickets
      |> Enum.filter(fn ticket ->
        Enum.all?(ticket, fn n ->
          fields
          |> Map.values()
          |> List.flatten()
          |> Enum.any?(fn range -> n in range end)
        end)
      end)
      |> Kernel.++([my_ticket])

    find_fields(valid_tickets, fields)
    |> Enum.filter(fn {k, _i} -> k =~ "departure" end)
    |> Enum.map(fn {_k, i} -> i end)
    |> Enum.map(fn i -> Enum.at(my_ticket, i) end)
    |> Enum.reduce(&*/2)
  end

  defp parse(text) do
    [a, b, c] = String.split(text, "\n\n")

    fields =
      a
      |> String.split("\n")
      |> Enum.map(fn line ->
        [_, field, n1, n2, m1, m2] = Regex.run(~r/([\w\s]+): (\d+)-(\d+) or (\d+)-(\d+)/, line)
        {field, [String.to_integer(n1)..String.to_integer(n2), String.to_integer(m1)..String.to_integer(m2)]}
      end)
      |> Enum.into(%{})

    my_ticket =
      b
      |> String.split("\n")
      |> List.last()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    other_tickets =
      c
      |> String.split("\n")
      |> Enum.slice(1..-1)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)

    {fields, my_ticket, other_tickets}
  end

  defp find_fields(tickets, fields), do: find_fields(tickets, fields, %{})
  defp find_fields(tickets, fields, found) do
    cond do
      departures_found?(found, fields) -> found
      # so example doesn't infinite loop
      map_size(fields) == map_size(found) -> found
      true ->
        remaining_fields = fields |> Enum.filter(fn {k, _v} -> k not in Map.keys(found) end)
        ticket_length = tickets |> List.first() |> length()
        remaining_places =
          0..(ticket_length - 1)
          |> Enum.filter(fn i -> i not in Map.values(found) end)

        new_found =
          remaining_fields
          |> Enum.map(fn {k, [range_1, range_2]} ->
            fit_list =
              remaining_places
              |> Enum.map(fn i ->
                fit? =
                  tickets
                  |> Enum.map(fn ticket -> Enum.at(ticket, i) end)
                  |> Enum.all?(fn n -> n in range_1 or n in range_2 end)
                {i, fit?}
              end)
              # |> IO.inspect
            if Enum.count(fit_list, fn {_i, fit?} -> fit? end) == 1 do
              {k, Enum.find_value(fit_list, fn {i, fit?} -> if fit?, do: i, else: nil end)}
            else
              nil
            end
          end)
          |> Enum.filter(&(&1))
          |> Enum.into(%{})
          |> Map.merge(found)
        find_fields(tickets, fields, new_found)
    end
  end

  defp departures_found?(found, fields) do
    total_departures = fields |> Map.keys() |> Enum.count(&(&1 =~ "departure"))
    found
    |> Map.keys()
    |> Enum.filter(fn key -> key =~ "departure" end)
    |> length()
    |> Kernel.==(total_departures)
  end
end

input = File.read!("input/16.txt")

input
|> Sixteen.part_one()
|> IO.inspect()

input
|> Sixteen.part_two()
|> IO.inspect()
