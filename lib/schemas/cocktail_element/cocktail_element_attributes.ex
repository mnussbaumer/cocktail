defmodule Cocktail.Element.Attributes do
  @behaviour Ecto.Type
  def type, do: :binary

  def load(data) when is_binary(data), do: {:ok, :erlang.binary_to_term(data)}
  def load(data) when is_list(data), do: {:ok, data}
  def load(_), do: :error
  
  def cast(data) when is_binary(data), do: {:ok, :erlang.binary_to_term(data)}
  def cast(data) when is_list(data), do: {:ok, data}
  def cast(_), do: :error

  def dump(data) when is_binary(data), do: {:ok, data}
  def dump(data) when is_list(data), do: {:ok, :erlang.term_to_binary(data)}
end
