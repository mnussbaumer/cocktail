defmodule Cocktail.Type do
  @behaviour Ecto.Type
  def type, do: :string

  @valid_atom [:page, :component]
  @valid_string Enum.reduce(@valid_atom, [], fn(type, acc) -> [Atom.to_string(type) | acc] end)
  @valid_map Enum.reduce(@valid_string, %{}, fn(string, acc) ->
    Map.put(acc, string, String.to_atom(string))
  end)

  def load(data) when is_binary(data) and data in @valid_string, do: {:ok, @valid_map[data]}
  def load(data) when is_atom(data) and data in @valid_atom, do: {:ok, data}
  def load(_), do: :error

  def cast(data) when is_atom(data) and data in @valid_atom, do: {:ok, data}
  def cast(data) when is_binary(data) and data in @valid_string, do: {:ok, @valid_map[data]}
  def cast(_), do: :error

  def dump(data) when is_atom(data) and data in @valid_atom, do: {:ok, Atom.to_string(data)}
  def dump(data) when is_binary(data) and data in @valid_string, do: {:ok, data}
end
