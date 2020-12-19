defmodule Nineteen do
  def part_one(input) do
    {rules, msgs} = parse(input)

    regex_0 =
      regex_str(rules, 0)
      |> (fn str -> "^#{str}$" end).()
      |> Regex.compile!()

    Enum.count(msgs, &(&1 =~ regex_0))
  end

  def part_two(input) do
    {rules, msgs} = parse(input)

    regex_42 = regex_str(rules, 42) |> (fn str -> "^#{str}$" end).() |> Regex.compile!()
    regex_31 = regex_str(rules, 31) |> (fn str -> "^#{str}$" end).() |> Regex.compile!()

    Enum.count(msgs, &valid?(&1, regex_42, regex_31))
  end

  # weird parsing that was originally used for non-regex solution
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
            rest_str =~ ~s["a"] -> "a"
            rest_str =~ ~s["b"] -> "b"
            rest_str =~ "|" ->
              [a, b] = String.split(rest_str, "|")
              {:or, rules_n.(a), rules_n.(b)}
            true ->
              rules_n.(rest_str)
          end

        {rule_n, rest}
      end)
      |> Enum.into(%{})

    msgs = String.split(msgs_str, "\n")

    {rules, msgs}
  end

  defp regex_str(rules, rule_n) do
    case rules[rule_n] do
      {:or, or1, or2} ->
        or1_str =
          or1
          |> Enum.map(fn rule -> regex_str(rules, rule) end)
          |> Enum.join()
        or2_str =
          or2
          |> Enum.map(fn rule -> regex_str(rules, rule) end)
          |> Enum.join()
        "(#{or1_str}|#{or2_str})"
      list when is_list(list) ->
        list
        |> Enum.map(fn rule ->
          regex_str(rules, rule)
        end)
        |> Enum.join()
      char -> char
    end
  end

  defp valid?(msg, regex_42, regex_31) do
    chunks =
      msg
      |> String.graphemes()
      |> Enum.chunk_every(8)
      |> Enum.map(&Enum.join/1)
    base_valid?(chunks, regex_42, regex_31)
    and rest_valid?(Enum.slice(chunks, 2..-2), regex_42, regex_31)
  end

  defp base_valid?(chunks, regex_42, regex_31) do
    (Enum.at(chunks, 0) =~ regex_42)
    and (Enum.at(chunks, 1) =~ regex_42)
    and (Enum.at(chunks, -1) =~ regex_31)
  end

  defp rest_valid?(chunks, regex_42, regex_31, count \\ 0)
  defp rest_valid?([], _, _, _), do: true
  defp rest_valid?([head | rest], regex_42, regex_31, count) do
    if head =~ regex_42 do
      rest_valid?(rest, regex_42, regex_31, count + 1)
    else
      valid_31?([head | rest], regex_31, count)
    end
  end

  defp valid_31?([], _, _), do: true
  defp valid_31?(_, _, 0), do: false
  defp valid_31?([head | rest], regex_31, count) do
    if head =~ regex_31 do
      valid_31?(rest, regex_31, count - 1)
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
