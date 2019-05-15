defmodule Cocktail.Element do
  use Ecto.Schema

  alias __MODULE__

  @default_content "New Element"

  @open_tags Cocktail.Element.HTML.Tag.open_tags(:atom)
  @closed_tags Cocktail.Element.HTML.Tag.childless_tags(:atom)

  @primary_key false
  embedded_schema do
    field :id,                 :string
    field :tag,                Element.HTML.Tag
    field :content,            :string, default: ""
    field :attrs,              Element.Attributes
    field :classes,            {:array, :string}, default: []
    field :style,              Element.Attributes
    embeds_many :body,         Element
    embeds_many :interactions, Element.Interactions
  end

  def create_default(tag) when tag in @open_tags do
    random_id = random_id()
    %__MODULE__{
      id: random_id,
      attrs: [],
      body: [],
      classes: [],
      content: @default_content <> " - " <> random_id,
      tag: tag,
      style: []
    }
  end

  def create_default(tag) when tag in @closed_tags do
    random_id = random_id()
    %__MODULE__{
      id: random_id,
      attrs: [],
      body: nil,
      classes: [],
      content: nil,
      tag: tag,
      style: []
    }
  end

  def from_component(
    %{
      attrs: attrs,
      classes: classes,
      style: style,
      body: body,
      interactions: interactions
    }
  ) do
    random_id = random_id()

    %__MODULE__{
      tag: :div,
      attrs: attrs,
      classes: classes,
      style: style,
      body: recreate_ids(body),
      content: nil,
      id: random_id
    }
  end

  def random_id, do: :crypto.strong_rand_bytes(6) |> Base.encode16()

  def recreate_ids(elements) do
    Enum.map(elements, fn(%{body: body} = element) ->
      %{element | id: random_id(), body: recreate_ids(body)}
    end)
  end
end
