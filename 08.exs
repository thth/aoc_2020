defmodule Eight do
  def part_one(input) do
    {:error, {:loop, acc}} =
      input
      |> parse()
      |> run()
    acc
  end

  def part_two(input) do
    instructions = parse(input)

    Stream.unfold(0, fn i ->
      cond do
        i >= map_size(instructions) - 1 -> nil
        instructions[i] |> elem(0) == "acc" -> {nil, i + 1}
        true ->
          attempt =
            Map.update!(instructions, i, fn
              {"jmp", n} -> {"nop", n}
              {"nop", n} -> {"jmp", n}
            end)
          {attempt, i + 1}
      end
    end)
    |> Enum.find_value(fn
      nil -> nil
      attempt ->
        case run(attempt) do
          {:ok, n} -> n
          {:error, _} -> nil
        end
    end)
  end

  defp parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, cmd, n] = Regex.run(~r/(\w+) \+*(-*\d+)/, line)
      {cmd, String.to_integer(n)}
    end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {k, i} -> {i, k} end)
  end

  defp run(ins,  pos \\ 0, past \\ [], acc \\ 0) do
    cond do
      pos == map_size(ins) -> {:ok, acc}
      pos not in 0..(map_size(ins) - 1) -> {:error, {:out_of_range, acc}}
      pos in past -> {:error, {:loop, acc}}
      true ->
        case ins[pos] do
          {"nop", _} -> run(ins, pos + 1, [pos | past], acc)
          {"acc", n} -> run(ins, pos + 1, [pos | past], acc + n)
          {"jmp", n} -> run(ins, pos + n, [pos | past], acc)
        end
    end
  end
end

input = File.read!("input/08.txt")

input
|> Eight.part_one()
|> IO.inspect()

input
|> Eight.part_two()
|> IO.inspect()
