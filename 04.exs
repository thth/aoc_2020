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

  defp valid?(field, value) when field in ~w[byr iyr eyr hgt] and is_binary(value), do:
    valid?(field, Integer.parse(value))
  defp valid?("byr", {byr, ""}), do: byr >= 1920 and byr <= 2002
  defp valid?("iyr", {iyr, ""}), do: iyr >= 2010 and iyr <= 2020
  defp valid?("eyr", {eyr, ""}), do: eyr >= 2020 and eyr <= 2030
  defp valid?("hgt", {hgt, "cm"}), do: hgt >= 150 and hgt <= 193
  defp valid?("hgt", {hgt, "in"}), do: hgt >= 59 and hgt <= 76
  defp valid?("hcl", hcl), do: hcl =~ ~r/#[0-9a-f]{6}/
  defp valid?("ecl", ecl), do: ecl in ~w[amb blu brn gry grn hzl oth]
  defp valid?("pid", pid), do: pid =~ ~r/^\d{9}$/
  defp valid?(_, _), do: false
end

input = File.read!("input/04.txt")

input
|> Four.part_one()
|> IO.inspect()

input
|> Four.part_two()
|> IO.inspect()
