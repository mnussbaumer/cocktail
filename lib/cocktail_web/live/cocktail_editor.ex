defmodule Cocktail.View.Editor do
  use Phoenix.LiveView

  alias Phoenix.PubSub, as: PPS
  alias Cocktail.PubSub, as: CPS

  @public_page_settings Enum.reduce(Cocktail.Page.public_settings(), [], fn(setting, acc) ->
    [Atom.to_string(setting) | acc]
  end)

  #@content_type ["html", "text"]
  
  def render(assigns) do
    #IO.inspect(assigns, label: "render")
    CocktailWeb.CocktailView.render("editor.html", assigns)
  end

  def mount({:load, type, id}, socket) do
    page = case GenServer.call(Cocktail.Persister.Server, {:load, type, id}) do
             {:ok, %{saved: _} = loaded} -> %{loaded | saved: true}
             {:ok, loaded} -> Map.put(loaded, :saved, true)
               _ -> %{Cocktail.Page.create_default(type, id) | id: id}
             end
    n_socket = 
      Enum.reduce(page, socket, fn({k,v}, acc) -> (
          assign(acc, k, v)
        )
      end)
      |> assign_defaults(page, type)
      |> load_components()
    
    subscribe(["page:#{page.id}:panel", "page:#{page.id}:element:*"])
    
    {:ok, n_socket}
  end

  def handle_event("select", id, %{assigns: page} = socket) do
    n_socket = select_element(id, page, socket)
    {:noreply, n_socket}
  end

  def handle_event("add_style", [prop, value], %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style(id, page, {prop, value})
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    #IO.inspect(n_socket.assigns.selected, label: "selected")
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_event("add_style_children", [prop, value], %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style_children(id, page, {prop, value})
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_event("delete_style", [prop, value], %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style(id, page, {prop, value}, true)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_event("add_class", classes, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class(id, page, classes)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_event("add_class_children", classes, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class_children(id, page, classes)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_event("delete_class", class, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class(id, page, [class], true)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:toggle_menu, menu_item}, socket) do
    {:noreply, toggle_menu(menu_item, socket)}
  end

  def handle_info({:classes, classes}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class(id, page, classes)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:classes_children, classes}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class_children(id, page, classes)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:remove_classes, class}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.class(id, page, [class], true)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:add, element}, %{assigns: %{body: body, selected: %{full_chain: id}}} = socket) do
    n_socket = assign(socket, :body, Cocktail.Operations.add(element, id, body))
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:select, id}, %{assigns: page} = socket) do
    n_socket = select_element(id, page, socket)
    {:noreply, n_socket}
  end

  def handle_info(:delete, %{assigns: %{body: body, selected: %{full_chain: id}} = page} = socket) do
    n_socket = assign(socket, :body, Cocktail.Operations.delete(id, body))
    n_socket_2 = select_element(List.delete_at(id, -1), page, n_socket)
    {:noreply, set_unsaved(n_socket_2)}
  end

  def handle_info({:style, prop_value}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style(id, page, prop_value)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:style_children, prop_value}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style_children(id, page, prop_value)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:remove_style, prop_value}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.style(id, page, prop_value, true)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info({:content, cont_n_type}, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    n_page = Cocktail.Operations.content(id, page, cont_n_type)
    n_socket = Enum.reduce(n_page, socket, fn({k, v}, acc) ->
      assign(acc, k, v)
    end)
    {:noreply, n_socket}
  end

  def handle_info(:save, %{assigns: %{protected: true}} = socket) do
    {:noreply, socket}
  end
  
  def handle_info(:save, %{assigns: %{id: p_id, type: type} = page} = socket) do
    case GenServer.call(Cocktail.Persister.Server, {:save, page}) do
      {:ok, page} ->
        PPS.broadcast(CPS, "page:#{p_id}:editor", {:notification, {:info, "Saved!"}})
        {
          :noreply,
          Enum.reduce(page, socket, fn({k, v}, acc) ->
            assign(acc, k, v)
          end)
          |> assign(:saved, true)
        }
      {:error, error} ->
        PPS.broadcast(CPS, "page:#{p_id}:editor", {:notification, {:error, error}})
        {:noreply, socket}
    end
  end

  def handle_info(:publish, %{assigns: %{protected: true}} = socket) do
    {:noreply, socket}
  end
  def handle_info(:publish, %{assigns: %{id: p_id} = page} = socket) do
    case GenServer.call(Cocktail.Persister.Server, {:publish, page}) do
      {:ok, page} ->
        PPS.broadcast(CPS, "page:#{p_id}:editor", {:notification, {:info, "Published!"}})
        {:noreply, Enum.reduce(page, socket, fn({k, v}, acc) ->
            assign(acc, k, v)
          end)
        }
      {:error, error} ->
        PPS.broadcast(CPS, "page:#{p_id}:editor", {:notification, {:error, error}})
        {:noreply, socket}
    end
  end

  def handle_info(:delete_page, %{assigns: %{protected: true}} = socket) do
    {:noreply, socket}
  end
  def handle_info(:delete_page, %{assigns: page} = socket) do
    case GenServer.call(Cocktail.Persister.Server, {:delete, page}) do
      {:ok, %{id: id, title: title, type: type}} ->
        {
          :stop,
          socket
          |> put_flash(:info, "#{type} #{id} with title #{title} deleted.")
          |> redirect(to: CocktailWeb.Router.Helpers.cocktail_path(CocktailWeb.Endpoint, :index))
        }
      {:error, _error} ->
        {:noreply, socket}
    end
  end

  def handle_info({:page_settings, {field, val}}, socket) when field in @public_page_settings do
    n_socket = assign(socket, String.to_atom(field), val)
    {:noreply, set_unsaved(n_socket)}
  end

  def handle_info(:select_parent, %{assigns: page} = socket) do
    n_selected = Cocktail.Operations.select_parent(page)
    n_socket = assign(socket, :selected, n_selected)
    {:noreply, n_socket}
  end

  def handle_info(:select_prev_sib, %{assigns: page} = socket) do
    n_selected = Cocktail.Operations.select_previous_sibling(page)
    n_socket = assign(socket, :selected, n_selected)
    {:noreply, n_socket}
  end

  def handle_info(:select_next_sib, %{assigns: page} = socket) do
    n_selected = Cocktail.Operations.select_next_sibling(page)
    n_socket = assign(socket, :selected, n_selected)
    {:noreply, n_socket}
  end

  def handle_info({:load_component, component_id}, %{assigns: %{id: p_id, body: body, selected: %{full_chain: id}} = page} = socket) do
    case GenServer.call(Cocktail.Persister.Server, {:load, :component, component_id}) do
      {:ok, component} ->
        n_socket = assign(socket, :body, Cocktail.Operations.add({:component, component}, id, body))
        {:noreply, n_socket}
      {:error, error} ->
        PPS.broadcast(CPS, "page:#{p_id}:editor", {:notification, {:error, error}})
        {:noreply, socket}
    end
  end

  def handle_info(:select_child, %{assigns: page} = socket) do
    n_selected = Cocktail.Operations.select_child(page)
    n_socket = assign(socket, :selected, n_selected)
    {:noreply, n_socket}
  end

  def handle_info(:move_prev, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    %{assigns: n_page} = n_socket = assign(socket, :body, Cocktail.Operations.move_prev(page))
    n_socket_2 = select_element(id, n_page, n_socket)
    {:noreply, n_socket_2}
  end

  def handle_info(:move_next, %{assigns: %{selected: %{full_chain: id}} = page} = socket) do
    %{assigns: n_page} = n_socket = assign(socket, :body, Cocktail.Operations.move_next(page))
    n_socket_2 = select_element(id, n_page, n_socket)
    {:noreply, n_socket_2}
  end

  def select_element(id, page, socket) do
    n_selected = Cocktail.Operations.select(id, page)
    assign(socket, :selected, Map.put(n_selected, :full_chain, id))
  end

  def subscribe(list) do
    Enum.each(list, fn(topic) ->
      PPS.subscribe(CPS, topic)
    end)
  end

  def set_unsaved(%{changed: changed} = socket) when changed != %{} do
    assign(socket, :saved, false)
  end

  def set_unsaved(socket), do: socket

  @menu_toggles [:show_edit_menu, :show_page_options, :show_global_options, :show_components]
  
  def toggle_menu(menu_item, %{assigns: assigns} = socket) do
    case Map.fetch!(assigns, menu_item) do
      true -> assign(socket, menu_item, false)
      false ->
        Enum.reduce(@menu_toggles, socket, fn
          (^menu_item, acc) -> assign(acc, menu_item, true)
          (toggle, acc) -> assign(acc, toggle, false)
        end)
    end
  end

  def assign_defaults(socket, page, type) do
    Enum.reduce(@menu_toggles, socket, fn(toggle, acc) ->
      assign(acc, toggle, false)
    end)
    |> assign(:selected, Cocktail.Operations.default_selected(page))
    |> assign(:type, type)
  end

  def load_components(socket) do
    components = Cocktail.Persister.Server.load_components()
    assign(socket, :components, components)
  end
end
