defmodule PatternMatching do
  def test_1(element), do: "Function with one non-list argument: #{inspect element}"
  
  def test_1(:a), do: "Function matched on :a"
  def test_1([]), do: "Function matched on empty list"
  def test_1([element]) do
    IO.puts("Function matched on list with a single element: #{inspect element}")
    test_1(element)
  end
  def test_1([head| tail]) do
    IO.puts("Function matched on non_empty list, with head: #{inspect head} and tail #{inspect tail}")
    test_1(tail)
  end

  def test_1(element), do: "Function with one non-list argument: #{inspect element}"

  def test_1(argument_1, argument_2), do: "Matched with 2 arguments: 1: #{inspect argument_1}\n2: #{inspect argument_2}"

end
