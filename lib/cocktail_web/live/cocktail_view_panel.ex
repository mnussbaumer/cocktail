defmodule Cocktail.View.Panel do
  use Phoenix.LiveView
  alias Phoenix.PubSub, as: PPS
  alias Cocktail.PubSub, as: CPS

  @public_page_settings Enum.reduce(Cocktail.Page.public_settings(), [], fn(setting, acc) ->
    [Atom.to_string(setting) | acc]
  end)

  @content_type ["html", "text"]
  
  def render(assigns) do
    #IO.inspect(assigns, label: "render panel")
    CocktailWeb.CocktailView.render("editor_panel.html", assigns)
  end

  def mount(%{page_id: p_id} = page, socket) do
    #IO.inspect(page, label: "page panel")
    n_socket = Enum.reduce(page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    |> assign(:notifications, [])
    #|> IO.inspect(label: "panel socket")
    Cocktail.View.Editor.subscribe(["page:#{p_id}:editor", "page:#{p_id}:element:*"])
    {:ok, n_socket}
  end

  def handle_info({:notification, notification}, %{assigns: %{notifications: nots}} = socket) do
    rand_id = :crypto.strong_rand_bytes(6) |> Base.encode16()
    Process.send_after(self(), {:remove_notification, rand_id}, 2_500)
    {:noreply, assign(socket, :notifications, nots ++ [{rand_id, notification}])}
  end

  def handle_info({:remove_notification, id}, %{assigns: %{notifications: nots}} = socket) do
    new_nots = Enum.reject(nots, fn({notif_id, _}) -> notif_id == id end)
    {:noreply, assign(socket, :notifications, new_nots)}
  end

  def handle_event("toggle_edit", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:toggle_menu, :show_edit_menu})
    {:noreply, socket}
  end

  def handle_event("toggle_page_options", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:toggle_menu, :show_page_options})
    {:noreply, socket}
  end

  def handle_event("toggle_global_options", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:toggle_menu, :show_global_options})
    {:noreply, socket}
  end

  def handle_event("toggle_components", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:toggle_menu, :show_components})
    {:noreply, socket}
  end

  def handle_event("add_element", element, %{assigns: %{page_id: p_id}} = socket) do
    case Cocktail.Element.HTML.Tag.cast(element) do
      {:ok, el_atom} ->
        PPS.broadcast(CPS, "page:#{p_id}:panel", {:add, el_atom})
      _ ->
        :noop
    end
    {:noreply, socket}
  end

  def handle_event("delete_element", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :delete)
    {:noreply, socket}
  end

  def handle_event("add_style", [prop, value], %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:style, {prop, value}})
    {:noreply, socket}
  end

  def handle_event("add_style_children", [prop, value], %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:style_children, {prop, value}})
    {:noreply, socket}
  end

  def handle_event("delete_style", [prop, value], %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:remove_style, {prop, value}})
    {:noreply, socket}
  end

  def handle_event("add_class", classes, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:classes, classes})
    {:noreply, socket}
  end

  def handle_event("add_class_children", classes, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:classes_children, classes})
    {:noreply, socket}
  end

  def handle_event("delete_class", class, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:remove_classes, class})
    {:noreply, socket}
  end

  def handle_event("save", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :save)
    {:noreply, socket}
  end

  def handle_event("publish", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :publish)
    {:noreply, socket}
  end

  def handle_event("delete", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :delete_page)
    {:noreply, socket}
  end

  def handle_event("update_content", %{"content" => content, "type" => type}, %{assigns: %{page_id: p_id}} = socket) when type in @content_type do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:content, {content, type}})
    {:noreply, socket}
  end

  def handle_event("page_settings", %{"val" => val, "what" => field}, %{assigns: %{page_id: p_id}} = socket) when field in @public_page_settings do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:page_settings, {field, val}})
    {:noreply, socket}
  end

  def handle_event("select_parent", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :select_parent)
    {:noreply, socket}
  end

  def handle_event("select_prev_sib", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :select_prev_sib)
    {:noreply, socket}
  end

  def handle_event("select_next_sib", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :select_next_sib)
    {:noreply, socket}
  end

  def handle_event("load_component", component_id, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", {:load_component, component_id})
    {:noreply, socket}
  end

  def handle_event("select_child", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :select_child)
    {:noreply, socket}
  end

  def handle_event("move_prev", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :move_prev)
    {:noreply, socket}
  end

  def handle_event("move_next", _, %{assigns: %{page_id: p_id}} = socket) do
    PPS.broadcast(CPS, "page:#{p_id}:panel", :move_next)
    {:noreply, socket}
  end
end
