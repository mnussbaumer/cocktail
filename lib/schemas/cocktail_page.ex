defmodule Cocktail.Page do
  use Ecto.Schema

  @default_title "untitled"

  @primary_key false
  embedded_schema do
    field :title,              :string, default: @default_title
    field :id,                 :string
    field :attrs,              Cocktail.Element.Attributes
    field :classes,            {:array, :string}, default: []
    field :style,              Cocktail.Element.Attributes
    field :stylesheets,        {:array, :string}, default: []
    field :javascripts,        {:array, :string}, default: []
    embeds_many :body,         Cocktail.Element
    embeds_many :interactions, Cocktail.Element.Interactions

    field :published,          :boolean, default: false
    field :published_at,       :utc_datetime
    field :updated_at,         :utc_datetime
    field :created_at,         :utc_datetime
    field :slug,               :string

    field :protected,          :boolean, default: false

    field :type,               Cocktail.Type, default: :page

    field :saved,              :boolean, virtual: true, default: false
  end

  def page_id(:page), do: :crypto.strong_rand_bytes(6) |> Base.encode16()
  def page_id(:component), do: "component-" <> (:crypto.strong_rand_bytes(6) |> Base.encode16())

  def create_default(type \\ :page, id \\ false) do
    id = id || page_id(type)
    %__MODULE__{
      id: id,
      slug: id,
      attrs: [],
      classes: [],
      style: [],
      stylesheets: [],
      javascripts: [],
      body: [],
      interactions: [],
      type: type
    }
  end

  def timestamp_save(%{created_at: cat} = page) do
    timestamp = DateTime.utc_now()
    case cat do
      nil -> %{page | created_at: timestamp, updated_at: timestamp}
      _ -> %{page | updated_at: timestamp}
    end
  end

  def timestamp_publish(%{} = page) do
    %{page | published: true, published_at: DateTime.utc_now()}
  end

  def public_settings, do: [:title, :slug]
    
end
