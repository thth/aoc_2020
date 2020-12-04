defmodule Four do
  @fields ~w[byr iyr eyr hgt hcl ecl pid]
  def part_one(input) do
    input
    |> parse()
    |> Enum.filter(&fields_present?/1)
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.filter(&fields_present?/1)
    |> Enum.filter(&fields_valid?/1)
    |> Enum.count()
  end

  defp parse(text) do
    text
    |> String.split("\n\n")
    |> Enum.map(&Regex.scan(~r/(\w+):(\S+)/, &1, capture: :all_but_first))
    |> Enum.map(&Enum.into(&1, %{}, fn [k, v] -> {k, v} end))
  end

  defp fields_present?(creds) do
    required = MapSet.new(@fields)
    creds = creds |> Map.keys() |> MapSet.new()
    MapSet.subset?(required, creds)
  end

  defp fields_valid?(creds) do
    Enum.all?(@fields, &valid?(&1, creds[&1]))
  end

  defp valid?(field, year) when field in ~w[byr iyr eyr] do
    case {field, Integer.parse(year)} do
      {"byr", {byr, ""}} -> byr >= 1920 and byr <= 2002
      {"iyr", {iyr, ""}} -> iyr >= 2010 and iyr <= 2020
      {"eyr", {eyr, ""}} -> eyr >= 2020 and eyr <= 2030
      _ -> false
    end
  end
  defp valid?("hgt", hgt) do
    case Integer.parse(hgt) do
      {h, "cm"} -> h >= 150 and h <= 193
      {h, "in"} -> h >= 59 and h <= 76
      _ -> false
    end
  end
  defp valid?("hcl", hcl), do: hcl =~ ~r/#[0-9a-f]{6}/
  defp valid?("ecl", ecl), do: ecl in ~w[amb blu brn gry grn hzl oth]
  defp valid?("pid", pid), do: pid =~ ~r/^\d{9}$/
end

input = File.read!("input/04.txt")

Four.part_one(input)
|> IO.inspect()

Four.part_two(input)
|> IO.inspect()
