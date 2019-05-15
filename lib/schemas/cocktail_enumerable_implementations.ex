defimpl Enumerable, for: [Cocktail.Page, Cocktail.Element] do
  def reduce(struct, acc, fun) do
    do_reduce(:maps.to_list(Map.from_struct(struct)), acc, fun)
  end

  defp do_reduce(_,     {:halt, acc}, _fun),   do: {:halted, acc}
  defp do_reduce(list,  {:suspend, acc}, fun), do: {:suspended, acc, &do_reduce(list, &1, fun)}
  defp do_reduce([],    {:cont, acc}, _fun),   do: {:done, acc}
  defp do_reduce([h|t], {:cont, acc}, fun),    do: do_reduce(t, fun.(h, acc), fun)

  def member?(_list, _value),
    do: {:error, __MODULE__}
  def count(_list),
    do: {:error, __MODULE__}
end
