defmodule Four do
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
    |> Enum.map(&String.replace(&1, "\n", " "))
    |> Enum.map(fn str ->
      regex = ~r/(\w+):(\S+)/
      Regex.scan(regex, String.replace(str, "\n", " "), capture: :all_but_first)
    end)
    |> Enum.map(&Enum.into(&1, %{}, fn [k, v] -> {k, v} end))
  end

  defp fields_present?(creds) do
    required = MapSet.new(~w[byr iyr eyr hgt hcl ecl pid])
    creds = creds |> Map.keys() |> MapSet.new()
    MapSet.subset?(required, creds)
  end

  defp fields_valid?(creds) do
    with byr <- creds["byr"],
         byr <- (byr =~ ~r/^\d{4}$/) && String.to_integer(byr),
         true <- byr >= 1920 and byr <= 2002,
         # iyr
         iyr <- creds["iyr"],
         iyr <- (iyr =~ ~r/^\d{4}$/) && String.to_integer(iyr),
         true <- iyr >= 2010 and iyr <= 2020,
         # eyr
         eyr <- creds["eyr"],
         eyr <- (eyr =~ ~r/^\d{4}$/) && String.to_integer(eyr),
         true <- eyr >= 2020 and eyr <= 2030,
         # hgt
         hgt <- creds["hgt"],
         true <- hgt_valid?(hgt),
         #hcl
         hcl <- creds["hcl"],
         true <- (hcl =~ ~r/#[0-9a-f]{6}/),
         # ecl
         ecl <- creds["ecl"],
         true <- ecl in ~w[amb blu brn gry grn hzl oth],
         # pid
         pid <- creds["pid"],
         true <- (pid =~ ~r/^\d{9}$/)
    do
      true
    else
      _err -> false
    end
  end

  defp hgt_valid?(hgt) do
    regex = ~r/^(\d+)(\w+)$/i
    with [_, height, unit] <- Regex.run(regex, hgt),
         h <- String.to_integer(height)
    do
      case unit do
        "cm" -> h >= 150 and h <= 193
        "in" -> h >= 59 and h <= 76
        _ -> false
      end
    else
      _ -> false
    end
  end
end

input = File.read!("input/04.txt")

Four.part_one(input)
|> IO.inspect()

Four.part_two(input)
|> IO.inspect()
