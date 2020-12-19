defmodule Nineteen do
  # part 1 that runs instantly w/ information from part 2 regarding
  # restrictions on the possibility of puzzle inputs
  def part_one(input) do
    {rules, msgs} = parse(input)
    rule_42 = possible_matches(rules, 42) |> MapSet.new()
    rule_31 = possible_matches(rules, 31) |> MapSet.new()
    chunk_len = rule_42 |> Enum.at(0) |> String.length()

    Enum.count(msgs, fn msg ->
      chunks =
        msg
        |> String.graphemes()
        |> Enum.chunk_every(chunk_len, chunk_len, :discard)
        |> Enum.map(&Enum.join/1)
      length(chunks) == 3 and base_valid?(chunks, rule_42, rule_31)
    end)
  end

  # my original part 1 that runs in ~40s
  # def part_one(input) do
  #   {rules, msgs} = parse(input)
  #   rule_0 = possible_matches(rules, 0) |> MapSet.new()

  #   Enum.count(msgs, &MapSet.member?(rule_0, &1))
  # end

  def part_two(input) do
    {rules, msgs} = parse(input)
    rule_42 = possible_matches(rules, 42) |> MapSet.new()
    rule_31 = possible_matches(rules, 31) |> MapSet.new()
    chunk_len = rule_42 |> Enum.at(0) |> String.length()

    Enum.count(msgs, &valid?(&1, rule_42, rule_31, chunk_len))
  end

  def parse(text) do
    [rules_str, msgs_str] = String.split(text, "\n\n")
    rules_n = fn ns ->
      String.split(ns, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end

    rules =
      rules_str
      |> String.split("\n")
      |> Enum.map(fn line ->
        [rule_n_str, rest_str] = String.split(line, " ", parts: 2)
        {rule_n, ":"} = Integer.parse(rule_n_str)
        rest =
          cond do
            rest_str =~ ~s["a"] -> ["a"]
            rest_str =~ ~s["b"] -> ["b"]
            rest_str =~ "|" ->
              [a, b] = String.split(rest_str, "|")
              [{:or, rules_n.(a), rules_n.(b)}]
            true ->
              rules_n.(rest_str)
          end

        {rule_n, rest}
      end)
      |> Enum.into(%{})

    msgs = String.split(msgs_str, "\n")

    {rules, msgs}
  end

  defp possible_matches(rules, rule_n), do: do_matches([rules[rule_n]], rules, [])

  defp do_matches([], _, matches), do: matches
  defp do_matches([head | rest], rules, matches) do
    if Enum.all?(head, &is_binary/1) do
      do_matches(rest, rules, [Enum.join(head) | matches])
    else
      do_matches(step_match(head, rules) ++ rest, rules, matches)
    end
  end

  defp step_match(past \\ [], match, rules)
  defp step_match(past, [head | rest], rules) when is_binary(head),
    do: step_match(past ++ [head], rest, rules)
  defp step_match(past, [head | rest], rules) when is_integer(head) do
    [past ++ rules[head] ++ rest]
  end
  defp step_match(past, [{:or, rules_a, rules_b} | rest], _rules) do
    a = past ++ rules_a ++ rest
    b = past ++ rules_b ++ rest
    [a, b]
  end

  defp valid?(msg, rule_42, rule_31, chunk_len) do
    chunks =
      msg
      |> String.graphemes()
      |> Enum.chunk_every(chunk_len, chunk_len, :discard)
      |> Enum.map(&Enum.join/1)
    len_valid?(msg, chunk_len)
    and base_valid?(chunks, rule_42, rule_31)
    and rest_valid?(Enum.slice(chunks, 2..-2), rule_42, rule_31)
  end

  defp len_valid?(msg, chunk_len), do: rem(String.length(msg), chunk_len) == 0

  defp base_valid?(chunks, rule_42, rule_31) do
    (Enum.at(chunks, 0) in rule_42)
    and (Enum.at(chunks, 1) in rule_42)
    and (Enum.at(chunks, -1) in rule_31)
  end

  defp rest_valid?(chunks, rule_42, rule_31, count \\ 0)
  defp rest_valid?([], _, _, _), do: true
  defp rest_valid?([head | rest], rule_42, rule_31, count) do
    if head in rule_42 do
      rest_valid?(rest, rule_42, rule_31, count + 1)
    else
      valid_31?([head | rest], rule_31, count)
    end
  end

  defp valid_31?([], _, _), do: true
  defp valid_31?(_, _, 0), do: false
  defp valid_31?([head | rest], rule_31, count) do
    if head in rule_31 do
      valid_31?(rest, rule_31, count - 1)
    else
      false
    end
  end
end

input = File.read!("input/19.txt")

input
|> Nineteen.part_one()
|> IO.inspect()

input
|> Nineteen.part_two()
|> IO.inspect()
