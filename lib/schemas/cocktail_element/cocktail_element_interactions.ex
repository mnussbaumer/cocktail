defmodule Cocktail.Element.Interactions do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :triggers,         {:array, :string}
    field :actions,          {:array, :string}
  end
end
