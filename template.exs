File.touch("README.md")
File.mkdir_p!("input")

~w[One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve
Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen Twenty
TwentyOne TwentyTwo TwentyThree TwentyFour TwentyFive]
|> Enum.with_index(1)
|> Enum.each(fn {word, i} ->
  day = i |> Integer.to_string() |> String.pad_leading(2, "0")
  content =
    """
    defmodule #{word} do
      def part_one(input) do
        input
        |> parse()
      end

      def part_two(input) do
        input
        |> parse()
      end

      defp parse(text) do
        text
        # |> String.split("\\n")
        # |> Enum.map(&String.to_integer/1)
      end
    end

    input = File.read!("input/#{day}.txt")

    input
    |> #{word}.part_one()
    |> IO.inspect()

    # input
    # |> #{word}.part_two()
    # |> IO.inspect()
    """

  File.touch("input/#{day}.txt")

  # [:exclusive] so does not overwrite if existing
  File.write("#{day}.exs", content, [:exclusive])
end)