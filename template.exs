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
      def one(input) do
        input
        |> parse()
      end

      def two(input) do
        input
        |> parse()
      end

      defp parse(txt) do
        txt
      end
    end

    input = File.read!("input/#{day}.txt")

    #{word}.one(input)
    |> IO.inspect()

    #{word}.two(input)
    |> IO.inspect()
    """
  File.touch("input/#{day}.txt")
  File.write("#{day}.exs", content, [:exclusive])
end)