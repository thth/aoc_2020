defmodule Thirteen do
  def part_one(input) do
    {time, bus_list} = parse(input)
    bus_list
    |> Enum.map(fn bus -> {bus - rem(time, bus), bus} end)
    |> Enum.min()
    |> (fn {a, b} -> a * b end).()
  end

  def part_two(input, wolframalpha_api_key) do
    :ssl.start()
    :application.start(:inets)

    query =
      input
      |> parse_two()
      |> Enum.map(fn {mod, n} -> "(t + #{n}) mod #{mod} = 0" end)
      |> Enum.join(", ")
      |> URI.encode_www_form()
    url = "https://api.wolframalpha.com/v2/query?output=json"
      <> "&appid=#{wolframalpha_api_key}"
      <> "&input=#{query}"
      <> "&podtitle=Integer%20solution"

    with {:ok, {_, _, body_charlist}} <- :httpc.request(url),
         body <- List.to_string(body_charlist),
         [_, answer] <- Regex.run(~r/"plaintext":"t = \d+ n \+ (\d+)/, body) do
      String.to_integer(answer)
    else
      nil -> "oh no"
      err -> err
    end
  end

  defp parse(text) do
    [time, buses] = String.split(text, "\n")
    bus_list =
      Regex.scan(~r/(\d+)/, buses, capture: :all_but_first)
      |> Enum.map(fn [str] -> String.to_integer(str) end)
    {String.to_integer(time), bus_list}
  end

  defp parse_two(text) do
    text
    |> String.trim()
    |> String.split("\n")
    |> Enum.at(1)
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reduce([], fn
      {"x", _}, acc -> acc
      {n, i}, acc  -> acc ++ [{String.to_integer(n), i}]
    end)
  end
end

input = File.read!("input/13.txt")

# the value of this variable is left as an exercise to the reader
wolframalpha_api_key = ""

input
|> Thirteen.part_one()
|> IO.inspect()

input
|> Thirteen.part_two(wolframalpha_api_key)
|> IO.inspect()
