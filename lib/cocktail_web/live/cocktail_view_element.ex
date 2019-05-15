defmodule Cocktail.View.Element do
  use Phoenix.LiveView
  alias Phoenix.PubSub, as: PPS
  alias Cocktail.PubSub, as: CPS  

  def render(assigns) do
    #IO.inspect(assigns, label: "render element")
    CocktailWeb.CocktailView.render("editor_element.html", assigns)
  end

  def mount(page, socket) do
    #IO.inspect(page, label: "page element")
    n_socket = Enum.reduce(page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    #Cocktail.Editor.subscribe(["page:1:editor", "page:1:panel"])
    {:ok, n_socket}
  end

  def handle_event("select", id, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:select, id})
    {:noreply, socket}
  end

  def handle_info({:change, [_|_] = el, n_el}, %{body: %{}} = socket) do
    {:noreply, socket}
  end

  def handle_info({:add, _, _}, socket), do: {:noreply, socket}
  def handle_info(_, socket), do: {:noreply, socket}
end
